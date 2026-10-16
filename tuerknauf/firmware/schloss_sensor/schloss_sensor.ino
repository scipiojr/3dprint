/*
  Verschlusssensor Haustür – Seeed XIAO ESP32C6 oder ESP32-C6 Super Mini
  ---------------------------------------------------------------------
  Zwei Hall-Latches (TI DRV5012) unter dem Griffrand erkennen zwei entgegengesetzt
  gepolte Magnete im Griff. Daraus ergeben sich 4 Schritte pro Umdrehung (Quadratur).
  Der Zähler wird in Vierteldrehungen geführt; nach dem Drehen meldet das Gerät per MQTT,
  ob abgeschlossen ist, und schläft dann wieder (Deep Sleep: XIAO ~20 µA, Super Mini ~55 µA laut Messungen Dritter).

  Arduino-IDE:  Boardpaket "esp32" von Espressif ab Version 3.0
                Board "XIAO_ESP32C6"         -> XIAO-Variante (platine/traeger.kicad_pcb)
                Board "ESP32C6 Dev Module"   -> Super-Mini-Variante (platine/traeger_supermini.kicad_pcb)
                jeweils "USB CDC On Boot: Enabled"
  Bibliothek:   PubSubClient (Nick O'Leary)

  Flashen über USB: Kabel einstecken, dann den Knauf kurz drehen (weckt den ESP).
  Solange USB verbunden ist, bleibt er wach und lässt sich normal hochladen.
  Rückfallebene: Befehl "wach" senden und Knauf drehen -> 10 Minuten wach.

  Kalibrieren (einmalig, per MQTT, Nachricht mit "retain" an <T_BASIS>/befehl):
    1. Abschließen, bis das Haus oben steht         -> "zu"   senden, Knauf kurz antippen/drehen
    2. Eine halbe Drehung aufschließen (Tür offen)  -> "auf"  senden, Knauf kurz drehen
  Weitere Befehle: "wach" (10 min wach bleiben), "reset" (Kalibrierung löschen).
  Der Befehl wird beim nächsten Aufwachen abgeholt und danach gelöscht.

  Status-LED (Lichtfenster unten in der Platte):
    weiß kurz     Neustart (z. B. Reset per Büroklammer)
    grün kurz     Meldung erfolgreich gesendet (abschaltbar: LED_OK_BLINKEN)
    3x gelb       WLAN nicht erreichbar
    3x lila       MQTT-Broker nicht erreichbar / Senden fehlgeschlagen
    2x rot        Akku unter AKKU_WARNUNG Prozent – bitte laden
    blau blitzt   wach am USB oder im Wartungsmodus ("wach")
  Reset: Büroklammer ins kleine Loch neben dem Lichtfenster (XIAO: Taster SW1 auf der Trägerplatine,
         Super Mini: RST-Taster auf dem Modul).
  Hardware: Modul auf die passende Trägerplatine gelötet, Pins wie unten. Das Modul wird aus dem
  gewählten Board erkannt; MODUL_XIAO unten lässt sich auch von Hand setzen.
*/

#include <WiFi.h>
#include <PubSubClient.h>
#include <Preferences.h>
#include "esp_sleep.h"
#include "driver/usb_serial_jtag.h"

// ===================== Einstellungen =====================
const char* WLAN_SSID = "MEIN_WLAN";
const char* WLAN_PASS = "MEIN_PASSWORT";
const char* MQTT_HOST = "192.168.1.10";
const uint16_t MQTT_PORT = 1883;
const char* MQTT_USER = "";            // leer lassen, wenn der Broker keine Anmeldung braucht
const char* MQTT_PASS = "";

// Feste IP spart beim Aufwachen etwa eine Sekunde Funkzeit (optional)
const bool FESTE_IP = false;
IPAddress ip(192, 168, 1, 60), gateway(192, 168, 1, 1), netzmaske(255, 255, 255, 0), dns(192, 168, 1, 1);

const char* GERAET  = "haustuer_schloss";
const char* T_BASIS = "haustuer/schloss";

// Schlossweg in Vierteldrehungen, bezogen auf "abgeschlossen, Haus oben" = 0, positiv = Schließrichtung
const int REL_MAX = 2;    // abgeschlossen: noch 1/2 Drehung weiter in Schließrichtung möglich
const int REL_MIN = -5;   // aufschließen 1/2 Drehung, danach noch 3/4 Drehung bis zum Anschlag
// rel >= 0: abgeschlossen | rel == -1: Zwischenstellung | rel <= -2: offen

const uint32_t RUHE_MS        = 2500;                        // so lange keine Bewegung -> melden
const uint64_t HERZSCHLAG_US  = 12ULL * 3600ULL * 1000000ULL; // Statusmeldung alle 12 h
const uint64_t WIEDERHOLEN_US = 10ULL * 60ULL * 1000000ULL;   // nach Fehlschlag in 10 min erneut

#ifndef MODUL_XIAO
  #if defined(ARDUINO_XIAO_ESP32C6)
    #define MODUL_XIAO 1        // Seeed XIAO ESP32C6
  #else
    #define MODUL_XIAO 0        // ESP32-C6 Super Mini
  #endif
#endif

// Pins. Sensoren an LP-GPIOs (0–7), sonst geht das Aufwachen per ext1 nicht.
const int PIN_A   = 1;    // GPIO1: Hall-Sensor A (von vorne gesehen links unten)   XIAO D1
const int PIN_B   = 2;    // GPIO2: Hall-Sensor B (rechts unten)                     XIAO D2
const int PIN_BAT = 0;    // GPIO0: Akkuspannung über die Trägerplatine (Teiler 100k/100k, 100 nF nach GND)   XIAO D0/A0
#if MODUL_XIAO
const int PIN_MESS = 21;  // D3: HIGH schaltet Teiler und RGB-LED der Trägerplatine ein (1M-Pulldown hält ihn sonst aus)
const int PIN_LED_R = 19;  // D8: RGB-LED rot (LOW = an, nur bei eingeschaltetem D3)
const int PIN_LED_G = 20;  // D9: grün
const int PIN_LED_B = 18;  // D10: blau
const int PIN_RF  = 3;    // RF-Schalter aktivieren (LOW)
const int PIN_ANT = 14;   // LOW = Keramikantenne auf der Platine, HIGH = externe Antenne
const char* MODELL = "XIAO ESP32C6";
#else
const int PIN_MESS = 3;   // GPIO3: HIGH schaltet den Teiler der Trägerplatine ein (1M-Pulldown hält ihn sonst aus)
const int PIN_RGB  = 8;   // GPIO8: WS2812 auf dem Modul
const uint8_t LED_HELL = 40;   // Helligkeit 0–255 (hinter dem Lichtfenster reicht wenig)
const char* MODELL = "ESP32-C6 Super Mini";
#endif
const bool LED_OK_BLINKEN = true;  // nach jeder erfolgreichen Meldung kurz grün
const int  AKKU_WARNUNG   = 15;    // Prozent

// ===================== Zustand =====================
// RTC-Speicher überlebt den Deep Sleep (nicht aber das Abklemmen des Akkus)
RTC_DATA_ATTR int32_t pos = 0;               // Zähler in Vierteldrehungen
RTC_DATA_ATTR int8_t  letzteRichtung = 1;
RTC_DATA_ATTR uint8_t letzterCode = 0xFF;
RTC_DATA_ATTR int32_t gemeldetPos = INT32_MIN;
RTC_DATA_ATTR bool    meldungOffen = true;
RTC_DATA_ATTR uint8_t wlanKanal = 0;
RTC_DATA_ATTR uint8_t wlanBssid[6];

Preferences prefs;          // Flash: Kalibrierung und letzter Zählerstand
int32_t posZu = 0;          // Zählerstand bei "abgeschlossen, Haus oben"
int8_t  richtung = 0;       // +1/-1 = Zählrichtung beim Abschließen, 0 = noch unbekannt
bool    zuGesetzt = false;
bool    kalibGeaendert = false;

WiFiClient netz;
PubSubClient mqtt(netz);
String befehl;
uint32_t wachBis = 0;       // Befehl "wach": 10 Minuten nicht schlafen (Flashen/Fehlersuche)

bool usbVerbunden() { return usb_serial_jtag_is_connected(); }

void logf(const char* fmt, ...) {
  if (!usbVerbunden()) return;
  char buf[160];
  va_list ap; va_start(ap, fmt); vsnprintf(buf, sizeof(buf), fmt, ap); va_end(ap);
  Serial.println(buf);
}

// ---------- Drehung zählen ----------
uint8_t lesen() { return (digitalRead(PIN_A) << 1) | digitalRead(PIN_B); }
int8_t grayIndex(uint8_t c) { static const int8_t t[4] = {0, 1, 3, 2}; return t[c & 3]; }
int relativ() { return (pos - posZu) * richtung; }

void begrenzen() {   // Anschläge des Schlosses: läuft der Zähler darüber hinaus, wird nachgeführt
  if (!zuGesetzt || richtung == 0) return;
  int r = relativ();
  if (r > REL_MAX) { posZu = pos - REL_MAX * richtung; kalibGeaendert = true; }
  if (r < REL_MIN) { posZu = pos - REL_MIN * richtung; kalibGeaendert = true; }
}

void schritt(uint8_t neu) {
  if (letzterCode == 0xFF) { letzterCode = neu; return; }
  if (neu == letzterCode) return;
  int d = (grayIndex(neu) - grayIndex(letzterCode) + 4) % 4;
  if (d == 1)      { pos += 1; letzteRichtung = 1; }
  else if (d == 3) { pos -= 1; letzteRichtung = -1; }
  else             { pos += 2 * letzteRichtung; }   // Zwischenschritt verpasst: gleiche Richtung annehmen
  letzterCode = neu;
  begrenzen();
}

bool bewegung() {
  uint8_t c = lesen();
  if (c == letzterCode) return false;
  schritt(c);
  return true;
}

const char* zustand() {
  if (!zuGesetzt || richtung == 0) return "unkalibriert";
  int r = relativ();
  if (r >= 0)  return "abgeschlossen";
  if (r <= -2) return "offen";
  return "zwischen";
}

// ---------- Akku ----------
float akkuVolt() {
  digitalWrite(PIN_MESS, HIGH);   // Teiler einschalten
  delay(30);                      // 100 nF über 50 kOhm laden lassen (Zeitkonstante 5 ms)
  uint32_t s = 0;
  for (int i = 0; i < 16; i++) s += analogReadMilliVolts(PIN_BAT);
  digitalWrite(PIN_MESS, LOW);    // Teiler aus -> im Schlaf kein Querstrom
  return s / 16.0f * 2.0f / 1000.0f;
}
// ---------- Status-LED ----------
#if MODUL_XIAO
// Die LEDs hängen am selben Schalter wie der Teiler: D3 HIGH versorgt sie, LOW am LED-Pin schaltet die Farbe ein.
void ledAus() {
  digitalWrite(PIN_LED_R, HIGH); digitalWrite(PIN_LED_G, HIGH); digitalWrite(PIN_LED_B, HIGH);
  digitalWrite(PIN_MESS, LOW);
}
void ledFarbe(bool r, bool g, bool b) {
  digitalWrite(PIN_LED_R, !r); digitalWrite(PIN_LED_G, !g); digitalWrite(PIN_LED_B, !b);
  digitalWrite(PIN_MESS, (r || g || b) ? HIGH : LOW);
}
#else
// WS2812 auf dem Modul (Farbreihenfolge übernimmt rgbLedWrite)
void ledAus() { rgbLedWrite(PIN_RGB, 0, 0, 0); }
void ledFarbe(bool r, bool g, bool b) { rgbLedWrite(PIN_RGB, r ? LED_HELL : 0, g ? LED_HELL : 0, b ? LED_HELL : 0); }
#endif
void ledBlinken(bool r, bool g, bool b, int n, int an = 150, int aus = 200) {
  for (int i = 0; i < n; i++) { ledFarbe(r, g, b); delay(an); ledAus(); if (i < n - 1) delay(aus); }
}
float letzteAkkuVolt = 0;

int akkuProzent(float v) {   // grob linear, LiPo 3,3 V = leer, 4,15 V = voll
  int p = (int)((v - 3.3f) / (4.15f - 3.3f) * 100.0f + 0.5f);
  return constrain(p, 0, 100);
}

// ---------- WLAN / MQTT ----------
bool wlanWarten(uint32_t ms) {
  uint32_t t0 = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - t0 < ms) { bewegung(); delay(10); }
  return WiFi.status() == WL_CONNECTED;
}

bool wlanVerbinden() {
#if MODUL_XIAO
  pinMode(PIN_RF, OUTPUT);  digitalWrite(PIN_RF, LOW);
  pinMode(PIN_ANT, OUTPUT); digitalWrite(PIN_ANT, LOW);
#endif
  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  if (FESTE_IP) WiFi.config(ip, gateway, netzmaske, dns);
  bool ok = false;
  if (wlanKanal) {                       // schnell: Kanal und Access Point vom letzten Mal
    WiFi.begin(WLAN_SSID, WLAN_PASS, wlanKanal, wlanBssid, true);
    ok = wlanWarten(5000);
    if (!ok) { WiFi.disconnect(); wlanKanal = 0; }
  }
  if (!ok) { WiFi.begin(WLAN_SSID, WLAN_PASS); ok = wlanWarten(10000); }
  if (ok) { wlanKanal = WiFi.channel(); memcpy(wlanBssid, WiFi.BSSID(), 6); }
  return ok;
}

void empfang(char* topic, byte* payload, unsigned int len) {
  befehl = "";
  for (unsigned int i = 0; i < len; i++) befehl += (char)payload[i];
  befehl.trim();
}

String t(const char* sub) { return String(T_BASIS) + "/" + sub; }

void discovery() {    // Home Assistant MQTT-Discovery, nur einmal bzw. nach Versionswechsel
  const int VERSION = 1;
  if (prefs.getInt("disc", 0) == VERSION) return;
  String dev = String("\"dev\":{\"ids\":[\"") + GERAET + "\"],\"name\":\"Haustür Schloss\",\"mf\":\"Eigenbau\",\"mdl\":\"" + MODELL + "\"}";
  String s1 = String("{\"name\":\"Aufgeschlossen\",\"uniq_id\":\"") + GERAET + "_lock\",\"stat_t\":\"" + t("zustand") +
              "\",\"dev_cla\":\"lock\",\"val_tpl\":\"{{ 'OFF' if value == 'abgeschlossen' else 'ON' }}\",\"json_attr_t\":\"" +
              t("attribute") + "\"," + dev + "}";
  String s2 = String("{\"name\":\"Stellung\",\"uniq_id\":\"") + GERAET + "_stellung\",\"stat_t\":\"" + t("zustand") +
              "\",\"ic\":\"mdi:lock-question\"," + dev + "}";
  String s3 = String("{\"name\":\"Akku\",\"uniq_id\":\"") + GERAET + "_akku\",\"stat_t\":\"" + t("attribute") +
              "\",\"val_tpl\":\"{{ value_json.akku_pct }}\",\"unit_of_meas\":\"%\",\"dev_cla\":\"battery\",\"stat_cla\":\"measurement\"," + dev + "}";
  String s4 = String("{\"name\":\"Akkuspannung\",\"uniq_id\":\"") + GERAET + "_akku_v\",\"stat_t\":\"" + t("attribute") +
              "\",\"val_tpl\":\"{{ value_json.akku_v }}\",\"unit_of_meas\":\"V\",\"dev_cla\":\"voltage\",\"stat_cla\":\"measurement\",\"ent_cat\":\"diagnostic\"," + dev + "}";
  bool ok = mqtt.publish((String("homeassistant/binary_sensor/") + GERAET + "/schloss/config").c_str(), s1.c_str(), true)
          & mqtt.publish((String("homeassistant/sensor/") + GERAET + "/stellung/config").c_str(), s2.c_str(), true)
          & mqtt.publish((String("homeassistant/sensor/") + GERAET + "/akku/config").c_str(), s3.c_str(), true)
          & mqtt.publish((String("homeassistant/sensor/") + GERAET + "/akku_v/config").c_str(), s4.c_str(), true);
  if (ok) prefs.putInt("disc", VERSION);
}

void befehlAusfuehren() {
  if (befehl == "zu") {
    posZu = pos; zuGesetzt = true; kalibGeaendert = true;
    logf("Kalibrierung: abgeschlossen bei pos=%ld", (long)pos);
  } else if (befehl == "auf" && zuGesetzt) {
    int32_t d = posZu - pos;
    if (d != 0) { richtung = d > 0 ? 1 : -1; kalibGeaendert = true; }
    logf("Kalibrierung: Richtung=%d", richtung);
  } else if (befehl == "wach") {
    wachBis = millis() + 10UL * 60UL * 1000UL;
    logf("Wartung: 10 Minuten wach");
  } else if (befehl == "reset") {
    zuGesetzt = false; richtung = 0; posZu = 0; kalibGeaendert = true;
  }
}

void kalibrierungSpeichern() {
  if (!kalibGeaendert) return;
  prefs.putInt("posZu", posZu);
  prefs.putChar("richtung", richtung);
  prefs.putBool("zuGesetzt", zuGesetzt);
  kalibGeaendert = false;
}

// Rückgabe: 0 = gemeldet, 1 = kein WLAN, 2 = MQTT/Senden fehlgeschlagen
int melden(const char* grund) {
  if (!wlanVerbinden()) { logf("WLAN fehlgeschlagen"); WiFi.mode(WIFI_OFF); return 1; }
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  mqtt.setCallback(empfang);
  mqtt.setBufferSize(768);
  bool verbunden = strlen(MQTT_USER) ? mqtt.connect(GERAET, MQTT_USER, MQTT_PASS) : mqtt.connect(GERAET);
  if (!verbunden) { logf("MQTT fehlgeschlagen"); WiFi.disconnect(true); WiFi.mode(WIFI_OFF); return 2; }

  // gespeicherten Befehl abholen (retained)
  befehl = "";
  mqtt.subscribe(t("befehl").c_str());
  uint32_t t0 = millis();
  while (millis() - t0 < 400) { mqtt.loop(); bewegung(); delay(5); }
  if (befehl.length()) {
    befehlAusfuehren();
    mqtt.publish(t("befehl").c_str(), "", true);   // Befehl löschen
  }
  kalibrierungSpeichern();
  discovery();

  float v = akkuVolt(); letzteAkkuVolt = v;
  char attr[200];
  snprintf(attr, sizeof(attr),
           "{\"position\":%d,\"zaehler\":%ld,\"akku_v\":%.2f,\"akku_pct\":%d,\"rssi\":%d,\"grund\":\"%s\"}",
           (zuGesetzt && richtung) ? relativ() : 0, (long)pos, v, akkuProzent(v), (int)WiFi.RSSI(), grund);
  bool ok = mqtt.publish(t("zustand").c_str(), zustand(), true) && mqtt.publish(t("attribute").c_str(), attr, true);
  for (int i = 0; i < 5; i++) { mqtt.loop(); delay(10); }
  mqtt.disconnect();
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);
  logf("Gemeldet: %s (%s) %s", zustand(), attr, ok ? "ok" : "FEHLER");
  return ok ? 0 : 2;
}

// ---------- Schlafen ----------
void einschlafen(uint64_t timerUs) {
  uint8_t c = lesen();                                // aufwachen, sobald ein Sensor seinen Pegel wechselt
  esp_sleep_enable_ext1_wakeup_io(1ULL << PIN_A, (c & 2) ? ESP_EXT1_WAKEUP_ANY_LOW : ESP_EXT1_WAKEUP_ANY_HIGH);
  esp_sleep_enable_ext1_wakeup_io(1ULL << PIN_B, (c & 1) ? ESP_EXT1_WAKEUP_ANY_LOW : ESP_EXT1_WAKEUP_ANY_HIGH);
  esp_sleep_enable_timer_wakeup(timerUs);
  pinMode(PIN_MESS, INPUT);                           // im Schlaf hält R4 (1 MOhm) den Teiler (XIAO: auch die LEDs) aus
#if MODUL_XIAO
  pinMode(PIN_LED_R, INPUT); pinMode(PIN_LED_G, INPUT); pinMode(PIN_LED_B, INPUT);
#else
  ledAus();                                           // WS2812 bleibt versorgt und behält die letzte Farbe
#endif
  esp_deep_sleep_start();
}

void setup() {
  pinMode(PIN_A, INPUT);
  pinMode(PIN_B, INPUT);
  uint8_t code = lesen();                             // so früh wie möglich lesen

  esp_sleep_wakeup_cause_t grund = esp_sleep_get_wakeup_cause();
  prefs.begin("schloss", false);
  posZu     = prefs.getInt("posZu", 0);
  richtung  = prefs.getChar("richtung", 0);
  zuGesetzt = prefs.getBool("zuGesetzt", false);
  if (grund != ESP_SLEEP_WAKEUP_EXT1 && grund != ESP_SLEEP_WAKEUP_TIMER) {   // Kaltstart
    pos = prefs.getInt("pos", 0);
    letzterCode = 0xFF;
    meldungOffen = true;
  }
  schritt(code);

  setCpuFrequencyMhz(80);
  Serial.begin(115200);
  analogReadResolution(12);
  pinMode(PIN_BAT, INPUT);
  pinMode(PIN_MESS, OUTPUT); digitalWrite(PIN_MESS, LOW);
#if MODUL_XIAO
  pinMode(PIN_LED_R, OUTPUT); pinMode(PIN_LED_G, OUTPUT); pinMode(PIN_LED_B, OUTPUT);
#endif
  ledAus();
  if (grund != ESP_SLEEP_WAKEUP_EXT1 && grund != ESP_SLEEP_WAKEUP_TIMER) ledBlinken(true, true, true, 1, 300);  // Neustart

  // Drehung verfolgen, bis der Knauf RUHE_MS still steht; bei USB wach bleiben (Flashen möglich)
  bool herzschlag = (grund == ESP_SLEEP_WAKEUP_TIMER);
  uint32_t letzteBewegung = millis();
  uint32_t letztesBlau = 0;
  while (true) {
    if (bewegung()) letzteBewegung = millis();
    if ((usbVerbunden() || millis() < wachBis) && millis() - letztesBlau > 3000) {   // wach: blau blitzen
      letztesBlau = millis(); ledBlinken(false, false, true, 1, 30);
    }
    if (millis() - letzteBewegung > RUHE_MS) {
      bool aenderung = (pos != gemeldetPos) || meldungOffen || herzschlag;
      if (aenderung) {
        bool still = herzschlag;                      // Herzschlag nachts: nur Fehler/Akku anzeigen
        int e = melden(herzschlag ? "herzschlag" : "bewegung");
        if (e == 0) {
          gemeldetPos = pos; meldungOffen = false; herzschlag = false;
          if (prefs.getInt("pos", INT32_MIN) != pos) prefs.putInt("pos", pos);
          if (LED_OK_BLINKEN && !still) ledBlinken(false, true, false, 1, 80);
        } else {
          meldungOffen = true;
          if (!still) { if (e == 1) ledBlinken(true, true, false, 3); else ledBlinken(true, false, true, 3); }
        }
        if (!still) {
          if (letzteAkkuVolt == 0) letzteAkkuVolt = akkuVolt();      // ohne WLAN trotzdem den Akku prüfen
          if (akkuProzent(letzteAkkuVolt) < AKKU_WARNUNG) { delay(300); ledBlinken(true, false, false, 2); }
        }
      }
      if (!usbVerbunden() && millis() > wachBis) break;
      letzteBewegung = millis();                      // am USB: weiter wach, alle RUHE_MS prüfen
    }
    delay(2);
  }
  prefs.end();
  einschlafen(meldungOffen ? WIEDERHOLEN_US : HERZSCHLAG_US);
}

void loop() {}

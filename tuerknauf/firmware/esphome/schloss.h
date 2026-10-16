// Hilfsfunktionen für haustuer_schloss.yaml (ESPHome, ESP32-C6 Super Mini)
#pragma once
#include "esp_sleep.h"
#include "driver/gpio.h"
#include "driver/usb_serial_jtag.h"
#include <string>

// Pegel beider Hall-Sensoren als 2-Bit-Code (A = Bit 1, B = Bit 0)
inline int schloss_code(int pin_a, int pin_b) {
  return (gpio_get_level((gpio_num_t) pin_a) << 1) | gpio_get_level((gpio_num_t) pin_b);
}

// Quadratur auswerten: gibt true zurück, wenn sich der Code geändert hat
inline bool schloss_schritt(int neu, int &letzter, int &pos, int &letzte_richtung) {
  static const int gray[4] = {0, 1, 3, 2};
  if (letzter < 0 || letzter > 3) { letzter = neu; return false; }
  if (neu == letzter) return false;
  int d = (gray[neu & 3] - gray[letzter & 3] + 4) % 4;
  if (d == 1)      { pos += 1; letzte_richtung = 1; }
  else if (d == 3) { pos -= 1; letzte_richtung = -1; }
  else             { pos += 2 * letzte_richtung; }   // Zwischenschritt verpasst: gleiche Richtung annehmen
  letzter = neu;
  return true;
}

// Aufwachen, sobald ein Sensor seinen Pegel wechselt (je Pin eigener Pegel, ext1 des ESP32-C6)
inline void schloss_wecken_einrichten(int pin_a, int pin_b) {
  int a = gpio_get_level((gpio_num_t) pin_a), b = gpio_get_level((gpio_num_t) pin_b);
  esp_sleep_enable_ext1_wakeup_io(1ULL << pin_a, a ? ESP_EXT1_WAKEUP_ANY_LOW : ESP_EXT1_WAKEUP_ANY_HIGH);
  esp_sleep_enable_ext1_wakeup_io(1ULL << pin_b, b ? ESP_EXT1_WAKEUP_ANY_LOW : ESP_EXT1_WAKEUP_ANY_HIGH);
}

inline bool schloss_usb() { return usb_serial_jtag_is_connected(); }

// Stellung bezogen auf "abgeschlossen, Haus oben": ab 0 abgeschlossen, -1 Zwischenstellung, ab -2 offen
inline std::string schloss_zustand(int pos, int pos_zu, int richtung, bool zu_gesetzt) {
  if (!zu_gesetzt || richtung == 0) return "unkalibriert";
  int r = (pos - pos_zu) * richtung;
  if (r >= 0) return "abgeschlossen";
  if (r <= -2) return "offen";
  return "zwischen";
}

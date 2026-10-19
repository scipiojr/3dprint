// =====================================================================
//  BIOMÜLL-SYSTEM  –  Trichter (Sackhalter) und Korb  (PETG)
//  Parametrisch, für OpenSCAD 2021.01 oder neuer (Customizer nutzbar)
// =====================================================================
//
//  Prinzip
//  -------
//  * KORB: Plattform mit Füßen + Tragebänder/Bügel, die direkt am Sack
//    hochlaufen. Der Sack steht auf der Plattform.
//    Version 3: An den Schmalseiten stecken statt der Bänder zwei steife,
//    abnehmbare Seitenwände (nach unten offenes U, Höhe einstellbar). Jeder
//    Seitensteg endet in einem Zapfen, der von oben in eine Tasche der
//    Plattform gesteckt wird und mit einer Rastzunge einschnappt.
//    Gehoben wird nur an den Bügeln der Langseiten.
//  * TRICHTER: liegt rundum auf dem Absatz des Eimers und bleibt immer drin.
//    Seine Öffnung umschließt Sack + Tragebänder: der Sack ragt durch den
//    Trichter auf und wird von ihm in Position gehalten. Die Griffe der
//    Bänder sitzen zwischen Sack und Trichter-Innenrand, unter der
//    Eimerkante. Der ganze Korb wird durch die Trichteröffnung gehoben.
//
//  Bedienung
//  ---------
//  "teil" wählen ("uebersicht" zeigt alles im Eimer). "stueck = -1" zeigt
//  alle Druckstücke eines Teils nebeneinander, "stueck = 0, 1, …" liefert
//  genau EIN druckfertig orientiertes Stück -> F6 -> STL exportieren.
//  Die Konsole (ECHO) meldet Stückzahlen, Längen, Höhen und Warnungen.
//
//  Automatische Teilung (bei Teilen größer als bett_x/y - 2*bett_rand)
//  --------------------
//   * Plattform: Schwalbenschwanz-Puzzle über die volle Höhe -> kleben.
//   * Bänder/Bügel: verdickter Stoß mit Schwalbenschwanz -> kleben.
//   * Trichter (276 mm, immer geteilt): gerade Fuge,
//     Laschen mit M3-Löchern -> Edelstahlschrauben + Muttern, optional
//     zusätzlich 2K-Epoxid (spülmaschinenfest).
//
//  Trichter Version 2 (18.10.2026): Keilwand ("innenform") – Außenform
//  unverändert, innen steilere Schräge und breitere Bettauflage; dazu eine
//  abbrechbare Druckhilfe, die jede Hälfte beim Druck zum Ring schließt.
//
//  Koordinaten (Übersicht): X = Eimer-Längsachse, Y = Querachse,
//  Z = 0 auf dem Innenboden (Standfläche der Füße).
// =====================================================================

/* [Ausgabe] */
// Welches Teil?
teil = "uebersicht"; // [uebersicht:Übersicht im Eimer, plattform:Plattform, langseite:Bügel/Band Langseite (2x drucken), seitenwand:Seitenwand Schmalseite (2x drucken), schmalseite:Band Schmalseite (nur bei schmalseite_typ = band, 2x drucken), trichter:Trichter, mittelteil:Trichter-Mittelteil (optional, nur bei mittelteil > 0; je Längsseite 1x), lehre:Passlehre Trichterrand, rastprobe:Rastprobe (Tasche + Wandstück, vorab drucken)]
// -1 = alle Stücke nebeneinander, 0,1,2 … = einzelnes druckfertiges Stück
stueck = -1;

/* [Drucker] */
bett_x = 260;
bett_y = 260;
bett_z = 260;
// Sicherheitsabstand zum Rand des Druckbetts (je Seite)
bett_rand = 5;

/* [Eimer – gemessen] */
// Innenlänge im oberen Randbereich (oberhalb des Absatzes)
eimer_l = 283;
// Innenbreite im oberen Randbereich
eimer_b = 210;
// gerades Stück der Langseite zwischen den Eckschrägen
eimer_gerade_l = 245;
// gerades Stück der Schmalseite zwischen den Eckschrägen
eimer_gerade_b = 170;
// Rücksprung je Seite am Absatz
absatz = 3;
// Höhe des Absatzes über der Standfläche der Plattform (Innenboden!)
absatz_z = 275;
// Absatz bis Oberkante Eimer (32,0 - 30,5 cm)
absatz_bis_rand = 15;

/* [Papiersack] */
// Sackbreite (liegt in Eimer-Längsrichtung)
sack_b = 200;
// Sacktiefe (Eimer-Querrichtung)
sack_t = 160;
sack_h = 360;

/* [Plattform] */
// Länge: Sack + Bänder (passt durch die Trichteröffnung); gilt bei schmalseite_typ = "band"
platte_l = 206;
// Länge bei schmalseite_typ = "wand": Sack + Wand + Tasche (liegt innerhalb der festen Trichteröffnung)
platte_l_wand = 210;
platte_b = 166;
// Schenkellänge der 45°-Eckschrägen
platte_fase = 16;
// Plattenstärke (massiv, oben und unten geschlossen)
platte_t = 4;
// Fase an Plattenrand und Lochkanten
platte_kante = 1;
// Bodenabstand: Plattenunterseite bis Eimerboden (= Fußhöhe)
bodenabstand = 40;
// Lochform
loch_form = "oval"; // [oval, rund]
// Lochlänge (bei "rund" = Durchmesser loch_b)
loch_l = 44;
// Lochbreite bzw. Durchmesser
loch_b = 22;
// Mindeststeg zwischen den Löchern
loch_steg = 9;
// Mindestabstand Loch <-> Plattenrand
loch_rand = 9;
// Füße rund, mit kegeligem Übergang zur Platte
fuss = 22;
fuss_fuss = 32;
fuss_fuss_h = 5;
// zusätzlicher Fuß in der Mitte (Platte ist massiv, 4 Eckfüße reichen)
mittelfuss = false;
// Scharniere je Langseite (2 = Bügel mit zwei Beinen)
scharniere_lang = 2; // [0, 1, 2]
// Abstand der zwei Scharniere einer Langseite
scharnier_abstand_lang = 110;
// Scharniere je Schmalseite (nur bei schmalseite_typ = "band"; bei "wand" entfallen sie)
scharniere_kurz = 1; // [0, 1, 2]
scharnier_abstand_kurz = 80;

/* [Scharnier (Plattform <-> Band)] */
stift_d = 6;
// Stiftmitte unter Plattenoberseite
stift_z = -10;
haken_b = 24;
haken_spiel = 0.35;
haken_wand = 2.4;
// Stift mit zwei Abflachungen oben und unten (Maß über die Flächen, 4,2 mm hoch, 6 mm breit): Der Haken geht nur bei
// senkrecht nach unten hängendem Band (180° aus der Senkrechten, ±7°) auf den Stift und wieder ab. 0 = runder Stift mit Schnapphaken (alt)
stift_flach = 4.2;
// Die Plattform tritt am Scharnier um dieses Maß zurück (Schlitz tiefer nach innen), damit die Hakenrundung nicht schabt
schlitz_zugabe = 2;
// Spiel des Hakenkanals je Seite zur Abflachung
kanal_spiel = 0.25;
// Einführfase am Kanal (gleicht auch den Elefantenfuß aus)
kanal_fase = 0.6;
// Übermaß der Schnappöffnung (nur bei stift_flach = 0)
schnapp = 0.5;
tropfen = 0.6;
schlitz_spiel = 1.0;
kante_versatz = 0.3;
fase = 2.0;
fase_seite = 1.5;
boss_unten = -16;
wange = 6;

/* [Bänder & Griffe] */
// Gesamtlänge Bügel/Band Langseite, 0 = automatisch (aus griff_ueber_absatz)
laenge_lang = 0;
// Gesamtlänge Bügel/Band Schmalseite, 0 = automatisch
laenge_kurz = 0;
// Griff-Oberkante über dem Absatz (muss unter der Eimerkante bleiben). 3 statt 5: hält den Bügel unter 250 mm (ungeteilt druckbar)
griff_ueber_absatz = 3;
band_b = 22;
band_t = 1.6;
hals_t = 2.0;
hals_l = 20;
band_r = 0.8;
band_c = 0.4;
// lichte Breite der Griffschlaufe (Hand)
fenster_b = 108;
// lichte Höhe der Griffschlaufe
fenster_h = 32;
rahmen_b = 8;
rahmen_t = 4;
rahmen_r = 2;
rahmen_c = 0.6;
// Griffsteg: Höhe in Zugrichtung
griff_h = 20;
// Griffsteg: Dicke (gewölbt, zeigt zum Sack hin)
griff_t = 8;
zwickel_l = 45;
seitensteg_band = 8;
seitensteg_buegel = 12;

/* [Seitenwände Schmalseiten (Version 3)] */
// "wand" = steife, abnehmbare U-Wand mit Steckzapfen (Version 3), "band" = Band mit Griffschlaufe (Version 2)
schmalseite_typ = "wand"; // [wand:Seitenwand (Version 3), band:Band mit Griffschlaufe (Version 2)]
// Wandhöhe ab Plattenoberseite (frei wählbar; Zapfen/Tasche bleiben gleich, andere Höhen passen in dieselbe Plattform)
wand_h = 100;
// Wanddicke: bestimmt die Steifigkeit (Durchbiegung ~ 1/Dicke³)
wand_t = 4;
// Breite der beiden Seitenstege
wand_steg_b = 20;
// Höhe des Querstegs oben
wand_quer_h = 20;
// Seitenstege nach innen versetzen (0 = Außenkante direkt nach der Eckschräge der Plattform)
wand_eck_abstand = 0;
// Spiel zwischen Wand und Sack (Wand innen <-> sack_b/2)
wand_sack_spiel = 0.5;
// Zapfenlänge unter der Schulter (Führung + Rastbereich)
zapfen_l = 28;
// Zapfenbreite (schmaler als der Steg: die Stegkante bildet die Schulter, die auf der Platte aufliegt)
zapfen_b = 14;
// Spiel Zapfen <-> Tasche (je Seite); kleiner = weniger Wackeln, aber enger
zapfen_spiel = 0.2;
// Tiefe der Tasche unter der Plattenoberseite (Führungslänge, Plattenstärke + Block)
tasche_tiefe = 14;
// Wandstärke des Taschenblocks nach außen (Rest zur Trichteröffnung beachten!)
tasche_wand = 2.0;
// Freiraum hinter der Rastzunge in der Tasche (Zunge federt hierhin ein)
tasche_relief = 3;
// Höhe der Rastnase (Überstand nach außen)
rast_nase = 3;
// Breite der federnden Rastzunge
rast_zunge_b = 8;
// Breite der beiden Schlitze neben der Zunge
rast_schlitz = 1.0;
// Abstand der Schlitz-Enden (Zungenwurzel) von der Schulter
rast_wurzel = 1;
// Länge der Auflaufschräge der Nase
rast_rampe = 5;
// Länge der ebenen Rastfläche der Nase
rast_flach = 1.2;
// senkrechtes Spiel zwischen Nase und Blockunterseite
rast_spiel_z = 0.3;
// Kantenrundung der Wand (Oberseite) und Fase (Bettseite)
wand_r = 1.2;
wand_c = 0.5;
// Fase des Taschenblocks
tasche_kante = 0.6;

/* [Trichter] */
mit_trichter = true;
// Tiefe der Trichterschräge unter dem Absatz
trichter_tiefe = 40;
// Lichte Weite der Trichteröffnung in Längsrichtung (gesamt, inkl. Mittelteil). FEST: ändert sich nicht mit der Plattform
oeffnung_l = 217;
// Lichte Weite der Trichteröffnung in Querrichtung (fest)
oeffnung_b = 172;
// Schenkellänge der 45°-Eckschrägen der Öffnung (fest)
oeffnung_fase = 16;
// senkrechter Haltekragen an der Öffnung (hält Sack + Bänder)
kragen_unten_h = 15;
wand = 2.5;
// Auflagekragen auf dem Absatz (Dicke)
kragen_t = 4;
// Spiel Kragen <-> Eimerwand oben (je Seite)
flansch_spiel = 1.25;
// Spiel Trichterkörper <-> Eimerwand unterhalb des Absatzes
trichter_spiel = 1.0;
// Verbindungslasche an der Trennfuge: Überstand nach außen
rippe_h = 8;
// Verbindungslasche: Dicke je Stück
rippe_t = 5;
// Schraubenloch (M3)
schraube_d = 3.4;
// Innenseite der Schräge. Die Außenform ist bei beiden Varianten gleich.
innenform = "keil"; // [keil:Keilwand – innen steiler, oben dicker (druckfreundlich), parallel:gleich dicke Wand (Version 1)]
// Keilwand: Breite der Kragen-Oberseite an den Schmalseiten (= Auflage auf dem Druckbett)
ring_x = 10;
// Keilwand: dasselbe an den Langseiten (größer = weniger Fingerraum am Griff)
ring_y = 6;

/* [Druckhilfe Trichter] */
// Steg auf dem Druckbett, der die offene Seite jeder Trichterhälfte schließt. Nach dem Druck abbrechen.
druckhilfe = false;
druckhilfe_b = 4;
druckhilfe_h = 5;
// Abstand Steg <-> Trennfuge
druckhilfe_spalt = 1.5;
// Höhe der zwei Haltestege (ca. 3 Schichten), zum Abbrechen
druckhilfe_steg_h = 0.5;
druckhilfe_steg_b = 4;

/* [Trichter-Mittelteil] */
// OPTIONAL: Zwischenstück je Längsseite (z. B. 5), das zwischen die beiden Trichterhälften geschraubt wird (0 = keins, Standard).
// Standard 0: zwei Hälften je Eimerlänge/2 (140,25 mm), Öffnung fest 217 x 172. Mit Mittelteil werden die Hälften um dieses Maß
// kürzer erzeugt (Trichter gesamt = Eimerlänge wie gemessen); nur sinnvoll, um bereits gedruckte Hälften weiterzuverwenden.
mittelteil = 0;

/* [Verbindungen (Plattform, Bänder)] */
schwalbe_tiefe = 10;
schwalbe_hals = 10;
schwalbe_kopf = 15;
schwalbe_abstand = 45;
// Spiel in der Steckverbindung (je Seite)
fuge_spiel = 0.15;
// Band-Stoß: Länge und Dicke der Verdickung
stoss_l = 30;
stoss_t = 4;

/* [Hidden] */
$fn = 48;
EPS = 0.01;
UX = bett_x - 2 * bett_rand;
UY = bett_y - 2 * bett_rand;

// ---------------------------------------------------------------------
// Achteck (Rechteck mit abgeschrägten Ecken): o = [hx, hy, cx, cy]
// hx/hy = halbe Außenmaße, cx/cy = Schenkellängen der Schräge
// ---------------------------------------------------------------------
function okt(o) = let(hx = o[0], hy = o[1], cx = o[2], cy = o[3])
    [[-hx + cx, -hy], [hx - cx, -hy], [hx, -hy + cy], [hx, hy - cy],
     [hx - cx, hy], [-hx + cx, hy], [-hx, hy - cy], [-hx, -hy + cy]];
// Achteck um d nach innen versetzen (jede Kante parallel um d)
function okt_off(o, d) = let(
    hx = o[0] - d, hy = o[1] - d, cx = o[2], cy = o[3], s = sqrt(cx * cx + cy * cy),
    k = (cy * o[0] + cx * o[1] - cx * cy) / s - d,
    xa = (k * s - cx * hy) / cy, yb = (k * s - cy * hx) / cx)
    [hx, hy, hx - xa, hy - yb];
function okt_k(o) = (o[3] * o[0] + o[2] * o[1] - o[2] * o[3]) / sqrt(o[2] * o[2] + o[3] * o[3]);
// größter waagerechter Versatz zwischen zwei parallelen Achtecken
function okt_ins(a, b) = max(a[0] - b[0], a[1] - b[1], okt_k(a) - okt_k(b));
module okt_poly(o) polygon(okt(o));
module okt_scheibe(o, z) translate([0, 0, z]) linear_extrude(EPS) okt_poly(o);
module okt_prisma(o, z0, z1) translate([0, 0, z0]) linear_extrude(z1 - z0) okt_poly(o);

// ---------------------------------------------------------------------
// Abgeleitete Größen
// ---------------------------------------------------------------------
// Scharnier
R_IN = stift_d / 2 + haken_spiel;
R_OUT = R_IN + haken_wand;
PIN_V = kante_versatz + R_OUT;
SLOT_U = haken_b / 2 + schlitz_spiel;
SLOT_V = PIN_V + R_OUT + 0.7 + schlitz_zugabe;
BOSS_U = SLOT_U + wange;
BOSS_V = SLOT_V + 5;
_th = R_IN + tropfen;
_ts = stift_d - schnapp;
GAP_TO = acos((R_IN * R_IN + _th * _th - _ts * _ts) / (2 * R_IN * _th));
FLACH = stift_flach > 0;
KANAL_B = stift_flach + 2 * kanal_spiel;     // lichte Kanalbreite im Haken
// Lösefenster: Drehwinkel aus der Flachlage, in dem der Stift noch durch den Kanal passt
function stift_breite(phi) = let(r = stift_d / 2, f = stift_flach / 2)
    abs(cos(phi)) * r <= f ? 2 * r : 2 * (f * abs(cos(phi)) + sqrt(r * r - f * f) * abs(sin(phi)));
LOESE_WINKEL = max([for (p = [0:0.25:90]) if (stift_breite(p) <= KANAL_B) p]);

// Plattform
WAND = schmalseite_typ == "wand";
SCH_KURZ = WAND ? 0 : scharniere_kurz;           // Scharniere (Bänder) je Schmalseite
PL = WAND ? platte_l_wand : platte_l;            // Plattformlänge
L2 = PL / 2;
W2 = platte_b / 2;
ZB = -platte_t;
ZF = ZB - bodenabstand;
PLATTE_OBEN_Z = bodenabstand + platte_t;
PLATTE_OKT = [L2, W2, platte_fase, platte_fase];

function seite(e, n, a) = n == 2 ? [[e, -a / 2], [e, a / 2]] : n == 1 ? [[e, 0]] : [];
STRAPS = concat(seite("+y", scharniere_lang, scharnier_abstand_lang), seite("-y", scharniere_lang, scharnier_abstand_lang),
                seite("+x", SCH_KURZ, scharnier_abstand_kurz), seite("-x", SCH_KURZ, scharnier_abstand_kurz));

// Seitenwand (Version 3): Lage der Wand und der Taschen (x ab Plattenmitte)
WX_I = sack_b / 2 + wand_sack_spiel;             // Wand innen
WX_O = WX_I + wand_t;                            // Wand außen
YE = W2 - platte_fase - wand_eck_abstand;        // Außenkante der Seitenstege (y)
YC = YE - wand_steg_b / 2;                       // Stegmitte (y)
// Taschenblock lokal (am_rand: y = 0 ist die Plattenkante, innen = negativ)
SL_I = WX_I - zapfen_spiel - L2;                 // Schlitz innen
SL_O = WX_O + zapfen_spiel - L2;                 // Schlitz außen
TL_I = SL_I - tasche_relief - tasche_wand;       // Block innen
TL_O = SL_O + tasche_wand;                       // Block außen (ragt als Ohr über die Plattenkante)
BH = max(wand_steg_b / 2, zapfen_b / 2 + zapfen_spiel + tasche_wand);  // halbe Blockbreite
POCKETS = WAND ? [for (e = ["+x", "-x"], s = [-1, 1]) [e, s * YC]] : [];
// Eckfüße möglichst weit außen, ohne die Scharnier- bzw. Taschenblöcke zu berühren
FX0 = L2 - fuss_fuss / 2 - 7;
FX = WAND ? min(FX0, L2 + TL_I - 2.5 - fuss_fuss / 2) : FX0;
FY = scharniere_lang > 0 ? W2 - BOSS_V - 4 - fuss_fuss / 2 - 2 : W2 - fuss_fuss / 2 - 7;
FEET = concat([[-FX, -FY], [FX, -FY], [-FX, FY], [FX, FY]], mittelfuss ? [[0, 0]] : []);

// Eimer & Trichter
MT = max(0, mittelteil);
// Eimer wie gemessen (für die Übersicht)
RIM_E = [eimer_l / 2, eimer_b / 2, (eimer_l - eimer_gerade_l) / 2, (eimer_b - eimer_gerade_b) / 2];
// Grundform der Trichterhälften: um das Mittelteil kürzer, Eckschrägen unverändert
RIM = [(eimer_l - MT) / 2, eimer_b / 2, (eimer_l - eimer_gerade_l) / 2, (eimer_b - eimer_gerade_b) / 2];
UNTEN = okt_off(RIM_E, absatz);                       // Eimer innen unterhalb des Absatzes
T_TOP = okt_off(RIM, absatz + trichter_spiel);      // Trichter außen, Höhe Absatz
RATIO = T_TOP[3] / T_TOP[2];
// Trichteröffnung (lichte Weite): FEST (oeffnung_l/b), Hälften um das halbe Mittelteil kürzer, Eckschrägen parallel zum Trichter
LIP = [oeffnung_l / 2 - MT / 2, oeffnung_b / 2, oeffnung_fase, oeffnung_fase * RATIO];
// Öffnung im montierten Zustand (mit Mittelteil)
OEFF = [oeffnung_l / 2, oeffnung_b / 2, oeffnung_fase, oeffnung_fase * RATIO];
// Abstand eines Punktes (x, y) von der Öffnungskante (positiv = innerhalb)
function oeff_abstand(x, y) = let(s = sqrt(OEFF[2] * OEFF[2] + OEFF[3] * OEFF[3]))
    min(OEFF[0] - abs(x), OEFF[1] - abs(y), okt_k(OEFF) - (OEFF[3] * abs(x) + OEFF[2] * abs(y)) / s);
ALPHA_X = atan(trichter_tiefe / (T_TOP[0] - LIP[0]));
ALPHA_Y = atan(trichter_tiefe / (T_TOP[1] - LIP[1]));
ALPHA_C = atan(trichter_tiefe / (okt_k(T_TOP) - okt_k(LIP)));
ALPHA_MIN = min(ALPHA_X, ALPHA_Y, ALPHA_C);
DELTA = wand / sin(ALPHA_MIN);                      // waagerechte Wandstärke
T_BOT = okt_off(LIP, -DELTA);                       // Trichter außen, Unterkante
function o_at(z) = T_TOP + (T_TOP - T_BOT) * (z / trichter_tiefe);   // Außenfläche
function fin(z) = okt_off(o_at(z), DELTA);                           // Innenfläche (Version 1)
// Achteck mit Halbmaßen hx/hy, Eckschräge parallel zu ref, Abstand k der Schräge von der Mitte
function okt_mk(hx, hy, ref, k) = let(s = sqrt(ref[2] * ref[2] + ref[3] * ref[3]),
    t = (ref[3] * hx + ref[2] * hy - k * s) / (ref[2] * ref[3])) [hx, hy, t * ref[2], t * ref[3]];
// Keilwand: Innenkante oben (Kragen-Oberseite) -> geradlinig bis zur Öffnung LIP
TOP_IN = okt_mk(RIM[0] - flansch_spiel - ring_x, RIM[1] - flansch_spiel - ring_y, RIM,
                okt_k(RIM) - flansch_spiel - (ring_x + ring_y) / 2);
function fin_k(z) = LIP + (TOP_IN - LIP) * ((z + trichter_tiefe) / (kragen_t + trichter_tiefe));
IN_H = kragen_t + trichter_tiefe;
BETA_X = atan(IN_H / (TOP_IN[0] - LIP[0]));
BETA_Y = atan(IN_H / (TOP_IN[1] - LIP[1]));
BETA_C = atan(IN_H / (okt_k(TOP_IN) - okt_k(LIP)));
// Breite der Kragen-Oberseite (Bettauflage) an den Langseiten, für die Druckhilfe
RING_Y_EFF = RIM[1] - flansch_spiel - (innenform == "keil" ? TOP_IN[1] : max(fin(kragen_t)[1], RIM[1] - flansch_spiel - 1.5));
RING_X_EFF = RIM[0] - flansch_spiel - (innenform == "keil" ? TOP_IN[0] : max(fin(kragen_t)[0], RIM[0] - flansch_spiel - 1.5));
T_L = 2 * (RIM[0] - flansch_spiel);
T_B = 2 * (RIM[1] - flansch_spiel);
T_NX = ceil(T_L / UX);
T_NY = ceil(T_B / UY);
function teilung(n, ges) = [for (i = [1:1:n - 1]) -ges / 2 + i * ges / n];
T_CX = teilung(T_NX, T_L);
T_CY = teilung(T_NY, T_B);

// Bänder: automatische Länge -> Griff-Oberkante auf absatz_z + griff_ueber_absatz
HAKEN_UNTEN_Z = PLATTE_OBEN_Z + stift_z - R_OUT;
GRIFF_Z = absatz_z + griff_ueber_absatz;
LEN_KURZ = laenge_kurz > 0 ? laenge_kurz : GRIFF_Z - HAKEN_UNTEN_Z;
LEN_LANG = laenge_lang > 0 ? laenge_lang : GRIFF_Z - HAKEN_UNTEN_Z;
LOOP_H = rahmen_b + fenster_h + griff_h;
function legs(n, a) = n == 2 ? [-a / 2, a / 2] : [0];
LEGS_KURZ = legs(SCH_KURZ, scharnier_abstand_kurz);
LEGS_LANG = legs(scharniere_lang, scharnier_abstand_lang);
SW_KURZ = SCH_KURZ == 2 ? seitensteg_buegel : seitensteg_band;
SW_LANG = scharniere_lang == 2 ? seitensteg_buegel : seitensteg_band;

// =====================================================================
//  Allgemein: Teilung mit Schwalbenschwanz
// =====================================================================
module schwalbe(x, y) polygon([[x - 0.5, y - schwalbe_hals / 2], [x + schwalbe_tiefe, y - schwalbe_kopf / 2],
                               [x + schwalbe_tiefe, y + schwalbe_kopf / 2], [x - 0.5, y + schwalbe_hals / 2]]);
// 2D-Bereich des Stücks i bei Schnitten "cuts" (entlang X), Zapfen an Positionen "tabs" (Y)
module bereich_x(i, cuts, tabs, ext = 3000) {
    n = len(cuts);
    x_lo = i == 0 ? -ext : cuts[i - 1];
    x_hi = i == n ? ext : cuts[i];
    difference() {
        union() {
            translate([x_lo, -ext]) square([x_hi - x_lo, 2 * ext]);
            if (i < n) for (y = tabs) schwalbe(x_hi, y);
        }
        if (i > 0) for (y = tabs) offset(delta = fuge_spiel) schwalbe(x_lo, y);
    }
}
module bereich_y(j, cuts, tabs) rotate([0, 0, 90]) bereich_x(j, cuts, [for (t = tabs) -t]);
function zapfen(von, bis) = let(m = max(1, floor((bis - von) / schwalbe_abstand) + 1),
                                s = (von + bis) / 2 - (m - 1) * schwalbe_abstand / 2)
    [for (k = [0:m - 1]) s + k * schwalbe_abstand];
// Zapfen nicht auf die Schnittlinien der anderen Richtung setzen
function frei(tabs, cuts) = [for (t = tabs) if (min(concat([1e9], [for (c = cuts) abs(t - c)])) > schwalbe_kopf / 2 + schwalbe_tiefe + 2) t];
// Quader-Bereich für Stück (i, j) bei geraden Schnitten
module kasten(i, j, cx, cy) {
    xl = i == 0 ? -500 : cx[i - 1];
    xh = i == len(cx) ? 500 : cx[i];
    yl = j == 0 ? -500 : cy[j - 1];
    yh = j == len(cy) ? 500 : cy[j];
    translate([xl, yl, -400]) cube([xh - xl, yh - yl, 800]);
}
function mitte(i, cuts, ges) = ((i == 0 ? -ges / 2 : cuts[i - 1]) + (i == len(cuts) ? ges / 2 : cuts[i])) / 2;

// =====================================================================
//  PLATTFORM  (Plattenoberseite z = 0, Füße nach -z)
// =====================================================================
function e_ang(e) = e == "+y" ? 0 : e == "-y" ? 180 : e == "+x" ? -90 : 90;
function e_half(e) = (e == "+y" || e == "-y") ? W2 : L2;
function e_p(e, pos) = (e == "+y" || e == "-x") ? pos : -pos;
// lokales Kantensystem: Kante bei y = 0, innen = -y, x entlang der Kante
module am_rand(e, pos) rotate([0, 0, e_ang(e)]) translate([e_p(e, pos), e_half(e), 0]) children();

function keep_rand(e, pos) = let(u = BOSS_U + 6, v = BOSS_V + 4)
    e == "+y" ? [pos - u, pos + u, W2 - v, W2 + 1] :
    e == "-y" ? [-pos - u, -pos + u, -W2 - 1, -W2 + v] :
    e == "+x" ? [L2 - v, L2 + 1, pos - u, pos + u] :
                [-L2 - 1, -L2 + v, pos - u, pos + u];
function keep_tasche(e, pos) = let(u = BH + 3)
    e == "+x" ? [L2 + TL_I - 3, L2 + TL_O + 1, pos - u, pos + u] :
                [-L2 - TL_O - 1, -L2 - TL_I + 3, pos - u, pos + u];
KEEP = concat([for (s = STRAPS) keep_rand(s[0], s[1])], [for (t = POCKETS) keep_tasche(t[0], t[1])]);
function edist(x, y) = min(L2 - abs(x), W2 - abs(y), (L2 + W2 - platte_fase - abs(x) - abs(y)) / sqrt(2));
LL = loch_form == "rund" ? loch_b : loch_l;
PX = LL + loch_steg;
PY = loch_b + loch_steg;
// Randpunkte eines Langlochs (Mitte cx, cy)
function loch_pkte(cx, cy) = [for (a = [0:30:330]) let(s = cos(a) >= 0 ? 1 : -1)
    [cx + s * (LL - loch_b) / 2 + loch_b / 2 * cos(a), cy + loch_b / 2 * sin(a)]];
function loch_ok(cx, cy) = let(hx = LL / 2, hy = loch_b / 2)
    min([for (q = loch_pkte(cx, cy)) edist(q[0], q[1])]) >= loch_rand &&
    len([for (k = KEEP) if (k[0] - loch_steg / 2 < cx + hx && cx - hx < k[1] + loch_steg / 2 &&
                           k[2] - loch_steg / 2 < cy + hy && cy - hy < k[3] + loch_steg / 2) 1]) == 0 &&
    len([for (f = FEET) if (norm([max(abs(f[0] - cx) - (LL - loch_b) / 2, 0), f[1] - cy]) - loch_b / 2 < fuss_fuss / 2 + loch_steg) 1]) == 0;
NXL = ceil(L2 / PX) + 1;
NYL = ceil(W2 / PY) + 1;
LOECHER = [for (iy = [-NYL:NYL], ix = [-NXL:NXL])
    let(cx = ix * PX + (abs(iy) % 2) * PX / 2, cy = iy * PY)
    if (loch_ok(cx, cy)) [cx, cy]];
module loch2d() hull() for (s = [-1, 1]) translate([s * (LL - loch_b) / 2, 0]) circle(d = loch_b, $fn = 48);
module loch_schnitt() hull() {
    translate([0, 0, -platte_t - 1]) linear_extrude(EPS) offset(delta = platte_kante + 1) loch2d();
    translate([0, 0, -platte_t + platte_kante]) linear_extrude(EPS) loch2d();
    translate([0, 0, -platte_kante]) linear_extrude(EPS) loch2d();
    translate([0, 0, 1]) linear_extrude(EPS) offset(delta = platte_kante + 1) loch2d();
}

module schlitz_schnitt() {
    translate([-SLOT_U, -SLOT_V, -60]) cube([2 * SLOT_U, SLOT_V + 1, 70]);
    // 45°-Fase an der Umlenkkante
    rotate([90, 0, 90]) linear_extrude(2 * (SLOT_U + fase_seite), center = true)
        polygon([[-SLOT_V + 0.5, -fase - 0.5], [-SLOT_V + 0.5, 1], [-SLOT_V - fase - 1, 1]]);
    // Fasen an den Seitenkanten
    for (m = [0, 1]) mirror([m, 0, 0]) translate([0, 1, 0]) rotate([90, 0, 0]) linear_extrude(SLOT_V + fase + 1)
        polygon([[SLOT_U - 0.5, -fase_seite - 0.5], [SLOT_U - 0.5, 1], [SLOT_U + fase_seite + 1, 1]]);
}

// ---------------------------------------------------------------------
//  Tasche für den Wandzapfen (lokales Kantensystem von am_rand: x entlang der Kante,
//  y = 0 Plattenkante, innen negativ, z = 0 Plattenoberseite)
//  Block: unten offen (durchgehender Schlitz), oben bündig mit der Platte, als Ohr über die Kante.
//  Der Schlitz geht durch Platte und Block; hinter der Rastzunge liegt ein Relief, in das die
//  Zunge beim Einstecken einfedert. Die Nase rastet unter der Blockunterseite ein.
// ---------------------------------------------------------------------
module tasche_block() hull() {
    k = tasche_kante;
    translate([-BH + k, TL_I + k, -tasche_tiefe]) cube([2 * BH - 2 * k, TL_O - TL_I - 2 * k, EPS]);
    translate([-BH, TL_I, -tasche_tiefe + k]) cube([2 * BH, TL_O - TL_I, tasche_tiefe - 2 * k]);
    translate([-BH + k, TL_I + k, -EPS]) cube([2 * BH - 2 * k, TL_O - TL_I - 2 * k, EPS]);
}
module tasche_schnitt() {
    sw = zapfen_b / 2 + zapfen_spiel;
    // Schlitz für den Zapfen, durch Platte und Block (unten offen)
    translate([-sw, SL_I, -tasche_tiefe - 1]) cube([2 * sw, SL_O - SL_I, tasche_tiefe + 2]);
    // Relief hinter der Rastzunge (nach innen)
    translate([-(rast_zunge_b / 2 + 0.3), SL_I - tasche_relief, -tasche_tiefe - 1])
        cube([rast_zunge_b + 0.6, tasche_relief + 0.5, tasche_tiefe + 2]);
    // Einführfase oben am Schlitz
    hull() {
        translate([-sw, SL_I, -0.8]) cube([2 * sw, SL_O - SL_I, EPS]);
        translate([-sw - 0.8, SL_I - 0.8, 0]) cube([2 * sw + 1.6, SL_O - SL_I + 1.6, 1]);
    }
}

module plattform_roh() {
    difference() {
        union() {
            // massive Platte, Kanten oben und unten gefast
            hull() {
                okt_scheibe(okt_off(PLATTE_OKT, platte_kante), ZB);
                okt_scheibe(PLATTE_OKT, ZB + platte_kante);
                okt_scheibe(PLATTE_OKT, -platte_kante - EPS);
                okt_scheibe(okt_off(PLATTE_OKT, platte_kante), -EPS);
            }
            // runde Füße mit kegeligem Übergang
            for (f = FEET) translate([f[0], f[1], 0]) {
                translate([0, 0, ZF]) cylinder(d = fuss, h = bodenabstand + EPS, $fn = 48);
                translate([0, 0, ZB - fuss_fuss_h]) cylinder(d1 = fuss, d2 = fuss_fuss, h = fuss_fuss_h + EPS, $fn = 48);
            }
            for (s = STRAPS) am_rand(s[0], s[1])
                translate([-BOSS_U, -BOSS_V, boss_unten]) cube([2 * BOSS_U, BOSS_V, ZB - boss_unten + EPS]);
            // Taschenblöcke der Seitenwände (reichen als Ohr bis über die Plattenkante)
            for (t = POCKETS) am_rand(t[0], t[1]) tasche_block();
        }
        for (s = STRAPS) am_rand(s[0], s[1]) schlitz_schnitt();
        for (t = POCKETS) am_rand(t[0], t[1]) tasche_schnitt();
        for (q = LOECHER) translate([q[0], q[1], 0]) loch_schnitt();
    }
    for (s = STRAPS) am_rand(s[0], s[1])
        translate([0, -PIN_V, stift_z]) intersection() {
            rotate([0, 90, 0]) cylinder(d = stift_d, h = 2 * (SLOT_U + 1), center = true, $fn = 40);
            // Abflachungen waagerecht (oben und unten): Stift 4,2 mm hoch; ohne Stützen druckbar
            if (FLACH) cube([2 * (SLOT_U + 2), stift_d + 2, stift_flach], center = true);
        }
}

PL_NX = ceil(PL / UX);
PL_NY = ceil(platte_b / UY);
PL_CX = teilung(PL_NX, PL);
PL_CY = teilung(PL_NY, platte_b);
PL_N = PL_NX * PL_NY;

module plattform_stueck(k) {
    i = k % PL_NX;
    j = floor(k / PL_NX);
    // druckfertig: Oberseite aufs Bett, Füße nach oben
    rotate([180, 0, 0]) translate([-mitte(i, PL_CX, PL), -mitte(j, PL_CY, platte_b), 0])
        intersection() {
            plattform_roh();
            if (PL_N > 1) linear_extrude(400, center = true) intersection() {
                bereich_x(i, PL_CX, frei(zapfen(-W2 + 15, W2 - 15), PL_CY));
                bereich_y(j, PL_CY, frei(zapfen(-L2 + 15, L2 - 15), PL_CX));
            }
        }
}

// =====================================================================
//  BAND / BÜGEL  (Druckkoordinaten: X = Länge, Y = Breite, Z = Dicke,
//  Z = 0 ist die Außenseite, die zur Eimerwand zeigt)
// =====================================================================
module profil(y0, y1, T, r, c) {
    w = y1 - y0;
    re = max(0.002, min(r, T / 2, w / 2 * 0.98));
    ce = max(0.001, min(c, re * 0.98, w / 2 * 0.9));
    n = 6;
    polygon(concat([[y0 + ce, 0], [y1 - ce, 0], [y1, ce]],
                   [for (k = [0:n]) let(a = 90 * k / n) [y1 - re + re * cos(a), T - re + re * sin(a)]],
                   [for (k = [0:n]) let(a = 90 + 90 * k / n) [y0 + re + re * cos(a), T - re + re * sin(a)]],
                   [[y0, ce]]));
}
module schnitt_band(x, y0, y1, T, r, c) translate([x, 0, 0]) rotate([90, 0, 90]) linear_extrude(EPS) profil(y0, y1, T, r, c);
// konvexe 2D-Form (children) als Platte mit gerundeter Oberkante und Fase unten
module rund_platte(T, r, c, n = 5) hull() {
    linear_extrude(EPS) offset(delta = -c) children();
    translate([0, 0, c]) linear_extrude(EPS) children();
    for (k = [0:n]) let(a = 90 * k / n) translate([0, 0, T - r + r * sin(a) - EPS])
        linear_extrude(EPS) offset(delta = -(r - r * cos(a))) children();
}
// Schneidkörper für ein konvexes Fenster (Kanten 45° gefast)
module fenster_schnitt(T, r, c) hull() {
    translate([0, 0, -1]) linear_extrude(EPS) offset(delta = c + 1) children();
    translate([0, 0, c]) linear_extrude(EPS) children();
    translate([0, 0, T - r]) linear_extrude(EPS) children();
    translate([0, 0, T + 1]) linear_extrude(EPS) offset(delta = r + 1) children();
}
module rrect(x0, x1, y0, y1, r) translate([x0 + r, y0 + r]) offset(r = r) square([x1 - x0 - 2 * r, y1 - y0 - 2 * r]);

// Hakenprofil (u = Bandlänge X, v = Banddicke Z; v < 0 zeigt zum Druckbett bzw. im Eimer zur Wand)
module haken2d() difference() {
    intersection() {
        hull() {
            circle(R_OUT, $fn = 64);
            translate([0, R_OUT * sqrt(2)]) circle(0.01);
            // flache Standfläche, damit beide Kanalwangen auf dem Bett stehen
            if (FLACH) translate([-0.75 * R_OUT, -R_OUT]) square([1.5 * R_OUT, 0.01]);
        }
        translate([-2 * R_OUT, -2 * R_OUT]) square([4 * R_OUT, 3 * R_OUT]);
    }
    intersection() {
        hull() { circle(R_IN, $fn = 64); translate([0, R_IN * sqrt(2)]) circle(0.01); }
        translate([-2 * R_OUT, -2 * R_OUT]) square([4 * R_OUT, 2 * R_OUT + R_IN + tropfen]);
    }
    if (FLACH) {
        // gerader Kanal zur Bettseite: lässt den Stift nur in Richtung der Abflachungen durch
        translate([-KANAL_B / 2, -2 * R_OUT]) square([KANAL_B, 2 * R_OUT]);
        polygon([[-KANAL_B / 2 - kanal_fase - 1, -R_OUT - 1], [KANAL_B / 2 + kanal_fase + 1, -R_OUT - 1],
                 [KANAL_B / 2, -R_OUT + kanal_fase], [-KANAL_B / 2, -R_OUT + kanal_fase]]);
    } else
        polygon(concat([[0, 0]], [for (k = [0:16]) let(t = GAP_TO * k / 16) [3 * R_OUT * sin(t), 3 * R_OUT * cos(t)]]));
}

// Kennwerte eines Bandes: [lx0, gx0, ramp0, neck_end, lw2]
function band_info(Lb, legs, side_w) = let(lx0 = Lb - LOOP_H)
    [lx0, lx0 - zwickel_l, lx0 - 15, R_OUT + hals_l, fenster_b / 2 + side_w];

module band_roh(Lb, legs, side_w, stoesse = []) {
    I = band_info(Lb, legs, side_w);
    lx0 = I[0]; gx0 = I[1]; ramp0 = I[2]; neck_end = I[3]; lw2 = I[4];
    Xc = R_OUT;
    win_x0 = lx0 + rahmen_b;
    win_x1 = win_x0 + fenster_h;
    xg = (win_x1 + Lb) / 2;
    hg = griff_h / 2;
    hb = band_b / 2;
    hk = haken_b / 2;
    single = len(legs) == 1;
    leg_end = single ? gx0 + 1 : lx0 + 1;
    // Bandansatz am Haken: bei Kanal-Haken erst hinter dem Kanal, damit der Kanal frei bleibt
    xn = FLACH ? Xc + KANAL_B / 2 + kanal_fase : Xc - 2;
    union() {
        for (L = legs) {
            translate([0, L, 0]) rotate([90, 0, 0]) linear_extrude(haken_b, center = true) translate([Xc, Xc]) haken2d();
            hull() {
                schnitt_band(xn, L - hk, L + hk, hals_t, band_r, band_c);
                schnitt_band(max(Xc, xn + 1), L - hk, L + hk, hals_t, band_r, band_c);
                schnitt_band(xn + 6, L - hb, L + hb, hals_t, band_r, band_c);
            }
            hull() {
                schnitt_band(xn, L - hb, L + hb, hals_t, band_r, band_c);
                schnitt_band(neck_end, L - hb, L + hb, hals_t, band_r, band_c);
            }
            hull() {
                schnitt_band(neck_end, L - hb, L + hb, hals_t, band_r, band_c);
                schnitt_band(neck_end + 3, L - hb, L + hb, band_t, band_r, band_c);
            }
            hull() {
                schnitt_band(neck_end + 3, L - hb, L + hb, band_t, band_r, band_c);
                schnitt_band(single ? leg_end : ramp0, L - hb, L + hb, band_t, band_r, band_c);
            }
            if (!single) {
                hull() {
                    schnitt_band(ramp0, L - hb, L + hb, band_t, band_r, band_c);
                    schnitt_band(lx0, L - hb, L + hb, rahmen_t, rahmen_r, rahmen_c);
                    schnitt_band(lx0 + 1, L - hb, L + hb, rahmen_t, rahmen_r, rahmen_c);
                }
                // Hohlkehle Bein -> Schlaufe (zur Mitte hin)
                s = L > 0 ? -1 : 1;
                yi = L + s * hb;
                hull() {
                    schnitt_band(lx0 - 12, min(yi, yi + s * 0.3), max(yi, yi + s * 0.3), rahmen_t, rahmen_r, rahmen_c);
                    schnitt_band(lx0 + 1, min(yi, yi + s * 12), max(yi, yi + s * 12), rahmen_t, rahmen_r, rahmen_c);
                }
            }
            // verdickte Stoßstellen (nur wenn das Band geteilt wird)
            for (c = stoesse) rund_platte(stoss_t, 1, band_c) translate([c - stoss_l / 2, L - hb]) square([stoss_l, band_b]);
        }
        if (single) hull() {   // Zwickel Band -> Schlaufe
            schnitt_band(gx0, -hb, hb, band_t, band_r, band_c);
            schnitt_band(lx0 + rahmen_b, -(lw2 - 12), lw2 - 12, rahmen_t, rahmen_r, rahmen_c);
        }
        // Rahmen der Griffschlaufe
        difference() {
            rund_platte(rahmen_t, rahmen_r, rahmen_c) rrect(lx0, Lb, -lw2, lw2, 12);
            fenster_schnitt(rahmen_t, rahmen_r, rahmen_c) rrect(win_x0, win_x1, -fenster_b / 2, fenster_b / 2, 10);
        }
        // Griffsteg, oben gewölbt
        intersection() {
            translate([xg, 0, 3]) scale([hg, 1, griff_t - 3]) rotate([90, 0, 0]) cylinder(r = 1, h = 2 * lw2 + 2, center = true, $fn = 64);
            rund_platte(griff_t, 3, rahmen_c) rrect(lx0, Lb, -lw2, lw2, 12);
        }
    }
}

// Teilung eines Bandes
function band_n(Lb) = max(1, ceil(Lb / UX));
function band_cuts(Lb, legs, side_w) = let(
    n = band_n(Lb), I = band_info(Lb, legs, side_w),
    lo = I[3] + 3 + stoss_l / 2 + 2,
    hi = (len(legs) == 1 ? I[1] : I[2]) - stoss_l / 2 - 2)
    [for (i = [1:1:n - 1]) min(hi, max(lo, i * Lb / n))];

module band_stueck(k, Lb, legs, side_w) {
    cuts = band_cuts(Lb, legs, side_w);
    n = len(cuts) + 1;
    xl = k == 0 ? 0 : cuts[k - 1];
    xh = k == n - 1 ? Lb : cuts[k];
    translate([-(xl + xh) / 2, 0, 0]) intersection() {
        band_roh(Lb, legs, side_w, cuts);
        if (n > 1) linear_extrude(100, center = true) bereich_x(k, cuts, legs);
    }
}

// =====================================================================
//  SEITENWAND (Version 3)  Druckkoordinaten: X = Länge ab Zapfenspitze (X = 0),
//  Y = quer (Mitte der Wand = 0), Z = Dicke; Z = 0 ist die Innenseite (zum Sack, auf dem Bett),
//  die Außenseite mit der Rastnase zeigt nach oben. Montiert zeigt X nach oben.
// =====================================================================
WL = zapfen_l + wand_h;                              // Gesamtlänge Zapfenspitze bis Oberkante
// Nase: Auflaufschräge unten, ebene Rastfläche, Rastkante bei X_RAST (oben)
X_RAST = zapfen_l - tasche_tiefe - rast_spiel_z;
module wand_bein(yc, h) {
    difference() {
        union() {
            // Steg ab der Schulter bis in den Quersteg
            rund_platte(wand_t, wand_r, wand_c) rrect(zapfen_l, zapfen_l + max(h - wand_quer_h / 2, 1), yc - wand_steg_b / 2, yc + wand_steg_b / 2, 3);
            // Zapfen
            rund_platte(wand_t, wand_r, wand_c) rrect(0, zapfen_l + 1, yc - zapfen_b / 2, yc + zapfen_b / 2, 1.5);
            // Rastnase auf der Außenseite der Zunge
            translate([0, yc, 0]) rotate([90, 0, 0]) linear_extrude(rast_zunge_b - 1, center = true)
                polygon([[X_RAST, wand_t - 0.3], [X_RAST, wand_t + rast_nase], [X_RAST - rast_flach, wand_t + rast_nase],
                         [X_RAST - rast_flach - rast_rampe, wand_t - 0.3]]);
        }
        // Schlitze neben der Zunge (Ende gerundet)
        for (sg = [-1, 1]) {
            y0 = yc + sg * (rast_zunge_b / 2 + rast_schlitz / 2) - rast_schlitz / 2;
            hull() {
                translate([-1, y0, -1]) cube([1, rast_schlitz, wand_t + 4 * rast_nase]);
                translate([zapfen_l - rast_wurzel - rast_schlitz / 2, y0 + rast_schlitz / 2, -1]) cylinder(d = rast_schlitz, h = wand_t + 4 * rast_nase, $fn = 16);
            }
        }
    }
}
// Wand: zwei Seitenstege + Quersteg (nach unten offenes U)
module wand_roh(h = wand_h, beine = [-YC, YC], quer = true) {
    union() {
        for (yc = beine) wand_bein(yc, h);
        if (quer) {
            xq = zapfen_l + h - wand_quer_h;
            rund_platte(wand_t, wand_r, wand_c) rrect(xq, zapfen_l + h, -YE, YE, 3);
            // Fase in den Innenecken (Steg <-> Quersteg), kein Absatz für Schmutz
            f = 8;
            for (sg = [-1, 1]) let(yi = sg * (YE - wand_steg_b))
                rund_platte(wand_t, wand_r, wand_c) polygon([[xq - f, yi + sg * 2], [xq + 2, yi + sg * 2], [xq + 2, yi - sg * f]]);
        }
    }
}
// druckfertig: flach, Mitte der Länge im Ursprung
module seitenwand_stueck() translate([-WL / 2, 0, 0]) wand_roh();

// Wand im Eimer (am +x- bzw. -x-Rand)
module wand_am_rand(e) {
    m = [[0, 0, 1, WX_I], [0, 1, 0, 0], [1, 0, 0, PLATTE_OBEN_Z - zapfen_l], [0, 0, 0, 1]];
    if (e == "+x") multmatrix(m) wand_roh();
    else mirror([1, 0, 0]) multmatrix(m) wand_roh();
}
module waende_alle() if (WAND) for (e = ["+x", "-x"]) wand_am_rand(e);

// Rastprobe: Taschenblock mit Plattenstück + kurzes Wandstück (Spiel und Rastkraft vorab prüfen)
PROBE_H = 25;
module tasche_probe() rotate([180, 0, 0]) difference() {
    union() {
        translate([-BH - 6, TL_I - 6, ZB]) cube([2 * BH + 12, -TL_I + 6, -ZB]);   // Plattenstück
        tasche_block();
    }
    tasche_schnitt();
}
module wand_probe() translate([-(zapfen_l + PROBE_H) / 2, 0, 0]) wand_roh(h = PROBE_H, beine = [0], quer = false);

// Lage eines Bandes im Eimer (am Scharnier der Kante e)
module band_am_rand(e, pos) rotate([0, 0, e_ang(e)])
    translate([e_p(e, pos), e_half(e) - PIN_V, PLATTE_OBEN_Z + stift_z])
        multmatrix([[0, -1, 0, 0], [0, 0, -1, 0], [1, 0, 0, 0], [0, 0, 0, 1]])
            translate([-R_OUT, 0, -R_OUT]) children();

// =====================================================================
//  Verbindungslaschen (Trichter und Sackring) an geraden Trennfugen
// =====================================================================
module tropfenloch2d(d) hull() { circle(d = d, $fn = 24); translate([0, -d / 2 * sqrt(2)]) circle(0.01); }
// Laschen an der Außenfläche hull(a@za, b@zb), begrenzt auf das Prisma "clip"
module laschen(cx, cy, a, za, b, zb, clip) {
    for (c = cx) intersection() {
        translate([c - rippe_t, -500, zb]) cube([2 * rippe_t, 1000, za - zb]);
        hull() { okt_scheibe(okt_off(a, -rippe_h), za - EPS); okt_scheibe(okt_off(b, -rippe_h), zb); }
        okt_prisma(clip, zb - 1, za + 1);
    }
    for (c = cy) intersection() {
        translate([-500, c - rippe_t, zb]) cube([1000, 2 * rippe_t, za - zb]);
        hull() { okt_scheibe(okt_off(a, -rippe_h), za - EPS); okt_scheibe(okt_off(b, -rippe_h), zb); }
        okt_prisma(clip, zb - 1, za + 1);
    }
}
// M3-Löcher durch die Laschen, je Fuge und Seite zwei
// Die Lasche reicht von der Trichter-Außenfläche bis zur Eimerkontur (max. rippe_h). Oben ist sie
// deshalb schmal. Löcher nur dort, wo rundum mindestens loch_rand_min Material steht.
loch_rand_min = 1.5;
function lasche_zs(D, za, zb) = let(
    H = za - zb,
    t_min = (schraube_d + 2 * loch_rand_min) / D,                    // ab hier breit genug
    t2 = 1 - (schraube_d / 2 * sqrt(2) + loch_rand_min) / H,          // unterstes Loch (Tropfenspitze beachten)
    t1 = t2 - (schraube_d + 6) / H)                                   // Abstand für Mutter/Schraubenkopf
    t2 < t_min ? [] : t1 >= t_min ? [za - t1 * H, za - t2 * H] : [za - t2 * H];
function lasche_mitte(D, oben, z, za, zb) = let(t = (za - z) / (za - zb), w = min(rippe_h, D * t))
    oben - D * t + w / 2;
module laschen_loecher(cx, cy, a, za, b, zb) {
    DY = a[1] - b[1];
    DX = a[0] - b[0];
    for (c = cx, s = [-1, 1], z = lasche_zs(DY, za, zb))
        translate([c, s * lasche_mitte(DY, a[1], z, za, zb), z]) rotate([90, 0, 90])
            linear_extrude(2 * rippe_t + 2, center = true) tropfenloch2d(schraube_d);
    for (c = cy, s = [-1, 1], z = lasche_zs(DX, za, zb))
        translate([s * lasche_mitte(DX, a[0], z, za, zb), c, z]) rotate([90, 0, 0])
            linear_extrude(2 * rippe_t + 2, center = true) tropfenloch2d(schraube_d);
}

// =====================================================================
//  TRICHTER  (Absatzebene z = 0)
// =====================================================================
module trichter_roh() {
    difference() {
        union() {
            hull() { okt_scheibe(T_TOP, -EPS); okt_scheibe(T_BOT, -trichter_tiefe); }
            linear_extrude(kragen_t) okt_poly(okt_off(RIM, flansch_spiel));
            laschen(T_CX, T_CY, T_TOP, 0, T_BOT, -trichter_tiefe, T_TOP);
            // senkrechter Haltekragen an der Öffnung
            okt_prisma(okt_off(LIP, -wand), -trichter_tiefe - kragen_unten_h, -trichter_tiefe + EPS);
        }
        okt_prisma(LIP, -trichter_tiefe - kragen_unten_h - 1, -trichter_tiefe + 1);
        // Innenraum
        if (innenform == "keil")
            hull() { okt_scheibe(fin_k(kragen_t + 1), kragen_t + 1); okt_scheibe(fin_k(-trichter_tiefe - 1), -trichter_tiefe - 1); }
        else intersection() {
            hull() { okt_scheibe(fin(kragen_t + 1), kragen_t + 1); okt_scheibe(fin(-trichter_tiefe - 1), -trichter_tiefe - 1); }
            okt_prisma(okt_off(RIM, flansch_spiel + 1.5), -trichter_tiefe - 2, kragen_t + 3);
        }
        laschen_loecher(T_CX, T_CY, T_TOP, 0, T_BOT, -trichter_tiefe);
    }
}
T_N = T_NX * T_NY;
// Druckhilfe (Trichterkoordinaten): Steg neben jeder Trennfuge auf Höhe der Kragen-Oberseite,
// mit zwei dünnen Haltestegen am Kragen. Schließt die offene Seite des Stücks zu einem Ring.
module druckhilfe_teile(i, j) {
    zt = kragen_t;
    xl = i == 0 ? -T_L / 2 : T_CX[i - 1];
    xh = i == len(T_CX) ? T_L / 2 : T_CX[i];
    yl = j == 0 ? -T_B / 2 : T_CY[j - 1];
    yh = j == len(T_CY) ? T_B / 2 : T_CY[j];
    sb = druckhilfe_b;
    // Fugen quer zur Längsachse (x = const)
    for (c = concat(i > 0 ? [[xl, -1]] : [], i < len(T_CX) ? [[xh, 1]] : [])) {
        x0 = c[0] + c[1] * druckhilfe_spalt;
        xm = x0 + c[1] * sb / 2;
        xi = c[0] - c[1] * 1.0;
        translate([min(x0, x0 + c[1] * sb), yl + 1, zt - druckhilfe_h]) cube([sb, yh - yl - 2, druckhilfe_h]);
        for (s = [-1, 1]) let(yc = s * (T_B / 2 - RING_Y_EFF / 2)) if (yc > yl + 2 && yc < yh - 2)
            translate([min(xm, xi), yc - druckhilfe_steg_b / 2, zt - druckhilfe_steg_h])
                cube([abs(xm - xi), druckhilfe_steg_b, druckhilfe_steg_h]);
    }
    // Fugen längs (y = const)
    for (c = concat(j > 0 ? [[yl, -1]] : [], j < len(T_CY) ? [[yh, 1]] : [])) {
        y0 = c[0] + c[1] * druckhilfe_spalt;
        ym = y0 + c[1] * sb / 2;
        yi = c[0] - c[1] * 1.0;
        translate([xl + 1, min(y0, y0 + c[1] * sb), zt - druckhilfe_h]) cube([xh - xl - 2, sb, druckhilfe_h]);
        for (s = [-1, 1]) let(xc = s * (T_L / 2 - RING_X_EFF / 2)) if (xc > xl + 2 && xc < xh - 2)
            translate([xc - druckhilfe_steg_b / 2, min(ym, yi), zt - druckhilfe_steg_h])
                cube([druckhilfe_steg_b, abs(ym - yi), druckhilfe_steg_h]);
    }
}
module trichter_stueck(k) {
    i = k % T_NX;
    j = floor(k / T_NX);
    // druckfertig: Kragen-Oberseite aufs Bett
    translate([0, 0, kragen_t]) rotate([180, 0, 0]) translate([-mitte(i, T_CX, T_L), -mitte(j, T_CY, T_B), 0]) {
        intersection() { trichter_roh(); kasten(i, j, T_CX, T_CY); }
        if (druckhilfe && T_N > 1) druckhilfe_teile(i, j);
    }
}

// Mittelteil: Profil des Trichters an der Fuge (x = 0, gerader Bereich der Langseiten), auf MT verlängert.
// Enthält Wand, Kragen, Haltekragen, Lasche und die Schraublöcher. Zwei Stücke (je Längsseite eins).
module mittelteil_roh() scale([MT, 1, 1]) intersection() {
    trichter_roh();
    translate([-0.5, -500, -200]) cube([1, 1000, 400]);
}
module mittelteil_stueck(k) {
    s = k == 0 ? 1 : -1;
    // druckfertig: Profil flach aufs Bett, Schraublöcher senkrecht
    translate([0, 0, MT / 2]) rotate([0, 90, 0]) intersection() {
        mittelteil_roh();
        translate([-50, s > 0 ? 0 : -500, -200]) cube([100, 500, 400]);
    }
}
// Trichter im Eimer, ggf. mit Mittelteilen
module trichter_montiert() {
    if (MT > 0 && T_NX == 2) {
        for (i = [0, 1], j = [0:T_NY - 1]) translate([(i == 0 ? -1 : 1) * MT / 2, 0, 0])
            intersection() { trichter_roh(); kasten(i, j, T_CX, T_CY); }
        color("orange") mittelteil_roh();
    } else trichter_roh();
}
SCHRAUBE_L = let(n = 2 * rippe_t + MT + 2.4 + 1.5) [for (l = [12, 16, 20, 25, 30, 35, 40]) if (l >= n) l][0];

// Passlehre: Kragen + kurzer Kragenfuß -> vorab prüfen, ob der Trichter passt
module lehre_roh() {
    linear_extrude(2) difference() { okt_poly(okt_off(RIM, flansch_spiel)); okt_poly(okt_off(T_TOP, 2)); }
    translate([0, 0, -8]) linear_extrude(8 + EPS) difference() { okt_poly(T_TOP); okt_poly(okt_off(T_TOP, 2)); }
}
module lehre_stueck(k) {
    i = k % T_NX;
    j = floor(k / T_NX);
    translate([0, 0, 2]) rotate([180, 0, 0]) translate([-mitte(i, T_CX, T_L), -mitte(j, T_CY, T_B), 0])
        intersection() { lehre_roh(); kasten(i, j, T_CX, T_CY); }
}

// =====================================================================
//  ÜBERSICHT
// =====================================================================
module eimer_geist() {
    color([0.7, 0.7, 0.75, 0.18]) {
        difference() {
            linear_extrude(absatz_z) okt_poly(okt_off(UNTEN, -2.5));
            translate([0, 0, -1]) linear_extrude(absatz_z + 2) okt_poly(UNTEN);
        }
        translate([0, 0, absatz_z]) difference() {
            linear_extrude(absatz_bis_rand) okt_poly(okt_off(RIM_E, -2.5));
            translate([0, 0, -1]) linear_extrude(absatz_bis_rand + 2) okt_poly(RIM_E);
        }
    }
}
module baender_alle() {
    if (SCH_KURZ > 0) for (e = ["+x", "-x"]) band_am_rand(e, 0) band_roh(LEN_KURZ, LEGS_KURZ, SW_KURZ);
    if (scharniere_lang > 0) for (e = ["+y", "-y"]) band_am_rand(e, 0) band_roh(LEN_LANG, LEGS_LANG, SW_LANG);
}
module uebersicht() {
    eimer_geist();
    color("seagreen") translate([0, 0, PLATTE_OBEN_Z]) plattform_roh();
    color("peru") baender_alle();
    color("darkorange") waende_alle();
    if (mit_trichter) {
        color("steelblue") translate([0, 0, absatz_z]) trichter_montiert();
    }
    // Papiersack (zusammengesackt), nur als Geist
    %translate([-sack_b / 2, -sack_t / 2, PLATTE_OBEN_Z]) cube([sack_b, sack_t, absatz_z + absatz_bis_rand - 5 - PLATTE_OBEN_Z]);
}

// =====================================================================
//  PRÜFUNGEN & BERICHT
// =====================================================================
echo(str("=== Biomüll-System | Druckraum nutzbar ", UX, " x ", UY, " x ", bett_z, " mm ==="));
echo(str("Plattform ", PL, " x ", platte_b, ", Höhe ", PLATTE_OBEN_Z, " mm -> ", PL_N, " Stück(e)",
         PL_N > 1 ? " (Schwalbenschwanz, kleben)" : "", ", ", len(LOECHER), " Löcher, Eckfüße bei x = ±", FX, ", y = ±", FY));
if (SCH_KURZ > 0)
    echo(str("Schmalseite: ", SCH_KURZ == 2 ? "Bügel" : "Band", ", Länge ", LEN_KURZ, " mm, Griff-Oberkante ",
             HAKEN_UNTEN_Z + LEN_KURZ, " mm über Boden -> ", band_n(LEN_KURZ), " Stück(e), 2x drucken"));
if (WAND) {
    echo(str("Schmalseite: Seitenwand ", WL, " x ", 2 * YE, " mm (Höhe ab Plattenoberseite ", wand_h, ", Dicke ", wand_t,
             "), Oberkante ", PLATTE_OBEN_Z + wand_h, " mm über Boden, 2x drucken -> seitenwand_h", wand_h, "_2x.stl"));
    echo(str("Wand: innen x = ", WX_I, ", außen x = ", WX_O, " (Sack ", sack_b / 2, ", Öffnung ", OEFF[0], "); Stege y = ±",
             YE - wand_steg_b, " … ±", YE, "; Taschenblock bis x = ", L2 + TL_O, ", Rest zur Öffnung ", OEFF[0] - (L2 + TL_O), " mm"));
    echo(str("Rastzunge: Länge ", zapfen_l - rast_wurzel, " mm, Einfederung ", rast_nase + zapfen_spiel, " mm, Dehnung ca. ",
             round(1000 * RAST_DEHNUNG) / 10, " %, Haltefläche ", rast_nase - zapfen_spiel, " mm; Durchbiegung der Wand oben bei 5 N ca. ",
             round(10 * WAND_DURCH) / 10, " mm (Biegung der Stege), mit Spiel im Zapfen höchstens ", round(10 * WAND_SPIEL_OBEN) / 10, " mm"));
}
if (scharniere_lang > 0)
    echo(str("Langseite: ", scharniere_lang == 2 ? "Bügel" : "Band", ", Länge ", LEN_LANG, " mm, Griff-Oberkante ",
             HAKEN_UNTEN_Z + LEN_LANG, " mm über Boden -> ", band_n(LEN_LANG), " Stück(e), 2x drucken"));
if (mit_trichter) {
    echo(str("Trichter ", T_L + (T_NX == 2 ? MT : 0), " x ", T_B, " x ", kragen_t + trichter_tiefe + kragen_unten_h, " mm -> ", T_N,
             " Stücke", MT > 0 && T_NX == 2 ? str(" (Hälften je ", T_L / 2 - MT / 2, " mm + 2 Mittelteile ", MT, " mm)") : T_NX == 2 ? str(" (Hälften je ", T_L / 2, " mm, ohne Mittelteil)") : "", ", Öffnung ", 2 * LIP[0] + (T_NX == 2 ? MT : 0), " x ", 2 * LIP[1], " mm, Schräge ", round(ALPHA_X), "°/", round(ALPHA_Y), "°, Ecken ", round(ALPHA_C), "°"));
    echo(str("Sack ", sack_b, " x ", sack_t, " in Öffnung: Abstand je Seite ", OEFF[0] - sack_b / 2, " / ", OEFF[1] - sack_t / 2,
             " mm", WAND ? "" : str(" (davon Band ", kante_versatz + hals_t, " mm)"), ", Öffnungs-Unterkante ", absatz_z - trichter_tiefe - kragen_unten_h, " mm über Boden"));
    if (T_N > 1) echo(str("Trichter-Verbindung: je Fuge ", 2 * len(lasche_zs(len(T_CX) > 0 ? T_TOP[1] - T_BOT[1] : T_TOP[0] - T_BOT[0], 0, -trichter_tiefe)),
                          " Schrauben M3 x ", SCHRAUBE_L, " (Edelstahl) + Muttern, optional 2K-Epoxid"));
    if (innenform == "keil") {
        echo(str("Keilwand: Innenschräge ", round(BETA_X), "°/", round(BETA_Y), "°, Ecken ", round(BETA_C),
                 "° (Überhang beim Druck ", round(90 - BETA_X), "°/", round(90 - BETA_Y), "°/", round(90 - BETA_C),
                 "° aus der Senkrechten), Kragen-Oberseite ", RING_X_EFF, " / ", RING_Y_EFF, " mm breit"));
        if (okt_ins(fin(0), fin_k(0)) < -0.01 || okt_ins(fin(-trichter_tiefe / 2), fin_k(-trichter_tiefe / 2)) < -0.01)
            echo("WARNUNG: Keilwand stellenweise dünner als 'wand' – ring_x/ring_y vergrößern.");
        if (TOP_IN[2] <= 0 || TOP_IN[3] <= 0) echo("WARNUNG: ring_x/ring_y passen nicht zur Eckschräge.");
    }
}
if (FLACH) {
    echo(str("Scharnier: Stift ", stift_d, " mm, abgeflacht auf ", stift_flach, " mm; Hakenkanal ", KANAL_B,
             " mm -> Haken nur bei senkrecht nach unten hängendem Band (180° ±", LOESE_WINKEL, "°) auf-/abnehmbar"));
    if (KANAL_B >= stift_d - 0.5) echo("WARNUNG: Hakenkanal fast so breit wie der Stift – Haken hält nicht sicher.");
    if (KANAL_B <= stift_flach) echo("WARNUNG: Hakenkanal schmaler als die Abflachung – Haken geht nicht auf.");
}
if (MT > 0 && T_NX != 2) echo("WARNUNG: Mittelteil nur bei zwei Trichterhälften (eine Fuge in der Mitte) vorgesehen.");
if (kragen_t > absatz_bis_rand) echo("WARNUNG: Trichterkragen steht über den Eimerrand!");
if (GRIFF_Z + 0 > absatz_z + absatz_bis_rand - 3 || (laenge_lang > 0 && HAKEN_UNTEN_Z + laenge_lang > absatz_z + absatz_bis_rand - 3)
    || (laenge_kurz > 0 && HAKEN_UNTEN_Z + laenge_kurz > absatz_z + absatz_bis_rand - 3))
    echo("WARNUNG: Griff ragt bis an/über die Eimerkante (Ablage!).");
if (mit_trichter && (LIP[0] > T_TOP[0] - 3 || LIP[1] > T_TOP[1] - 3))
    echo("WARNUNG: Plattform ist fast so groß wie der Eimer – Trichter wird sehr schmal.");
if (mit_trichter && ALPHA_MIN < 45) echo("WARNUNG: Trichterschräge flacher als 45°.");
if (PL < sack_b || platte_b < sack_t) echo("WARNUNG: Plattform kleiner als der Sackboden.");
if (scharniere_lang > 0 && W2 - kante_versatz - hals_t < sack_t / 2) echo("WARNUNG: Bänder Langseite stehen im Sack – platte_b vergrößern.");
if (SCH_KURZ > 0 && L2 - kante_versatz - hals_t < sack_b / 2) echo("WARNUNG: Bänder Schmalseite stehen im Sack – platte_l vergrößern.");
if (SCH_KURZ > 0 && LEN_KURZ - LOOP_H - zwickel_l < R_OUT + hals_l + 8) echo("WARNUNG: Band Schmalseite zu kurz für Griffschlaufe.");
if (scharniere_lang > 0 && LEN_LANG - LOOP_H - zwickel_l < R_OUT + hals_l + 8) echo("WARNUNG: Band Langseite zu kurz für Griffschlaufe.");
if (SCH_KURZ > 0 && band_info(LEN_KURZ, LEGS_KURZ, SW_KURZ)[4] > W2 - platte_fase / 2)
    echo("WARNUNG: Griffschlaufe Schmalseite breiter als die Plattform.");
if (scharniere_lang > 0 && band_info(LEN_LANG, LEGS_LANG, SW_LANG)[4] > L2 - platte_fase / 2)
    echo("WARNUNG: Griffschlaufe Langseite breiter als die Plattform.");
for (b = concat(SCH_KURZ > 0 ? [[LEN_KURZ, LEGS_KURZ, SW_KURZ]] : [], [[LEN_LANG, LEGS_LANG, SW_LANG]])) {
    cs = band_cuts(b[0], b[1], b[2]);
    st = concat([0], cs, [b[0]]);
    if (max([for (i = [0:len(st) - 2]) st[i + 1] - st[i]]) > UX)
        echo(str("WARNUNG: Band ", b[0], " mm lässt sich nicht passend teilen – Schlaufe/Griff verkleinern."));
}
if (PLATTE_OBEN_Z > bett_z || kragen_t + trichter_tiefe + kragen_unten_h > bett_z) echo("WARNUNG: Teil höher als der Druckraum.");

// ---- Seitenwand und Öffnung (Version 3 und feste Trichteröffnung)
// größte Dehnung der Rastzunge beim Einrasten (Kragarm, Dicke wand_t, Länge zapfen_l - rast_wurzel)
RAST_DEHNUNG = 1.5 * wand_t * (rast_nase + zapfen_spiel) / pow(zapfen_l - rast_wurzel, 2);
// Durchbiegung der Wandoberkante bei 5 N (zwei Stege 20 x 4, E = 2100 MPa), und Zusatz durch das Spiel im Zapfen
WAND_DURCH = 5 * pow(wand_h, 3) / (3 * 2100 * 2 * (wand_steg_b * pow(wand_t, 3) / 12));
WAND_SPIEL_OBEN = WAND_DURCH + 2 * zapfen_spiel / tasche_tiefe * wand_h;
// Abstand eines Punktes zum Rechteck [x0, x1, y0, y1] (für Fuß <-> Block)
function rechteck_abstand(x, y, r) = norm([max(r[0] - x, 0, x - r[1]), max(r[2] - y, 0, y - r[3])]);
function tasche_rechteck(t) = let(u = BH) t[0] == "+x" ? [L2 + TL_I, L2 + TL_O, t[1] - u, t[1] + u] : [-L2 - TL_O, -L2 - TL_I, t[1] - u, t[1] + u];
if (WAND) {
    if (OEFF[0] - WX_O < 1.5) echo("WARNUNG: Seitenwand liegt zu nah an der Trichteröffnung (< 1,5 mm) – wand_t/wand_sack_spiel verkleinern.");
    if (OEFF[0] - (L2 + TL_O) < 1.5) echo("WARNUNG: Taschenblock liegt zu nah an der Trichteröffnung (< 1,5 mm) – tasche_wand verkleinern.");
    if (oeff_abstand(L2 + TL_O, YE) < 1.5 || oeff_abstand(WX_O, YE) < 1.5)
        echo("WARNUNG: Wand oder Taschenblock kommt im Eckbereich zu nah an die Öffnung (Eckschräge) – wand_eck_abstand vergrößern.");
    if (WX_I < sack_b / 2) echo("WARNUNG: Wand berührt den Sack – wand_sack_spiel erhöhen.");
    if (YE - wand_steg_b <= 0) echo("WARNUNG: Seitenstege überlappen – wand_steg_b oder wand_eck_abstand ändern.");
    if (len([for (f = FEET, t = POCKETS) if (rechteck_abstand(f[0], f[1], tasche_rechteck(t)) < fuss_fuss / 2 + 1) 1]) > 0)
        echo("WARNUNG: Fuß kollidiert mit einem Taschenblock.");
    if (RAST_DEHNUNG > 0.03) echo("WARNUNG: Rastzunge zu kurz oder zu steif (Dehnung beim Einrasten über 3 %) – rast_wurzel verkleinern, zapfen_l vergrößern oder rast_nase verkleinern.");
    if (rast_nase <= zapfen_spiel + 0.3) echo("WARNUNG: Haltefläche der Rastnase zu klein (rast_nase gegen zapfen_spiel).");
    if (X_RAST - rast_flach - rast_rampe < 0.2) echo("WARNUNG: Zapfen zu kurz für die Rastnase (zapfen_l vergrößern oder tasche_tiefe verkleinern).");
    if (zapfen_l - rast_wurzel < tasche_tiefe - rast_wurzel) echo("WARNUNG: Zapfen kürzer als die Tasche.");
    if (PLATTE_OBEN_Z + wand_h > absatz_z + absatz_bis_rand - 3) echo("WARNUNG: Wand reicht bis an/über die Eimerkante (Ablage!) – wand_h verkleinern.");
    if (PLATTE_OBEN_Z + wand_h > absatz_z - trichter_tiefe - kragen_unten_h) echo("HINWEIS: Wand ragt in die Trichteröffnung hinein (Höhe über der Öffnungs-Unterkante); der Korb geht trotzdem durch, weil die Wand innerhalb des Öffnungsumrisses liegt.");
    if (WAND_SPIEL_OBEN > 8) echo("HINWEIS: Wand gibt oben bei 5 N mehr als 8 mm nach – wand_t erhöhen (bis 6) oder wand_h verkleinern.");
    if (WL > UX || 2 * YE > UY) echo("WARNUNG: Wand größer als der Druckraum.");
    if (platte_l_wand / 2 > OEFF[0] - 1.5) echo("WARNUNG: Plattform fast so lang wie die Trichteröffnung.");
}
if (!WAND && PL / 2 > OEFF[0] - 1.5) echo("WARNUNG: Plattform fast so lang wie die Trichteröffnung.");
if (W2 > OEFF[1] - 1.5) echo("WARNUNG: Plattform fast so breit wie die Trichteröffnung.");
if (oeff_abstand(L2, W2 - platte_fase) < 1.5 || oeff_abstand(L2 - platte_fase, W2) < 1.5)
    echo("WARNUNG: Plattform kommt im Eckbereich zu nah an die Trichteröffnung (< 1,5 mm).");


// =====================================================================
//  AUSGABE
// =====================================================================
if (teil == "uebersicht") {
    uebersicht();
} else if (teil == "plattform") {
    for (k = (stueck < 0 ? [0:PL_N - 1] : [stueck])) if (k < PL_N)
        translate(stueck < 0 ? [(k % PL_NX) * (PL / PL_NX + 40), floor(k / PL_NX) * (platte_b / PL_NY + 40), 0] : [0, 0, 0])
            plattform_stueck(k);
} else if (teil == "seitenwand") {
    if (!WAND) echo("HINWEIS: schmalseite_typ = band – keine Seitenwand.");
    else seitenwand_stueck();
} else if (teil == "rastprobe") {
    if (!WAND) echo("HINWEIS: schmalseite_typ = band – keine Rastprobe.");
    else {
        if (stueck != 1) tasche_probe();
        if (stueck != 0) translate([0, 2 * BH + 30, 0]) wand_probe();
    }
} else if (teil == "schmalseite" && SCH_KURZ > 0) {
    n = band_n(LEN_KURZ);
    for (k = (stueck < 0 ? [0:n - 1] : [stueck])) if (k < n)
        translate([stueck < 0 ? k * (LEN_KURZ / n + 40) : 0, 0, 0]) band_stueck(k, LEN_KURZ, LEGS_KURZ, SW_KURZ);
} else if (teil == "langseite" && scharniere_lang > 0) {
    n = band_n(LEN_LANG);
    for (k = (stueck < 0 ? [0:n - 1] : [stueck])) if (k < n)
        translate([stueck < 0 ? k * (LEN_LANG / n + 40) : 0, 0, 0]) band_stueck(k, LEN_LANG, LEGS_LANG, SW_LANG);
} else if (teil == "trichter") {
    for (k = (stueck < 0 ? [0:T_N - 1] : [stueck])) if (k < T_N)
        translate(stueck < 0 ? [(k % T_NX) * (T_L / T_NX + 40), floor(k / T_NX) * (T_B / T_NY + 40), 0] : [0, 0, 0])
            trichter_stueck(k);
} else if (teil == "mittelteil") {
    if (MT <= 0) echo("HINWEIS: mittelteil = 0 – kein Mittelteil.");
    else for (k = (stueck < 0 ? [0, 1] : [stueck])) if (k < 2) mittelteil_stueck(k);
} else if (teil == "lehre") {
    for (k = (stueck < 0 ? [0:T_N - 1] : [stueck])) if (k < T_N)
        translate(stueck < 0 ? [(k % T_NX) * (T_L / T_NX + 40), floor(k / T_NX) * (T_B / T_NY + 40), 0] : [0, 0, 0])
            lehre_stueck(k);
}

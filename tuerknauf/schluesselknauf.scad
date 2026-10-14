// Schlüssel-Drehknauf mit Beschlag – Winkhaus Profilzylinder  (Version 5)
// Teile: Platte (Beschlag mit Lagerbund, optional Elektronikfach), Schaft (Gabel), Griff (Glocke),
//        Haus-Einsatz, Gewindekappen für den Griff, Kappen für die Türschrauben.
//
// Kraftfluss: Querkräfte am Griff -> Glocke läuft auf dem Lagerbund der Platte
// (radial 0,25 mm Spiel) -> Platte -> Schrauben -> Tür.
// Drücken -> Griffunterkante setzt auf Platte (0,3 mm). Ziehen -> Flansch am Deckel (0,4 mm).
// Der Schlüssel hat zu allen Teilen MEHR Spiel (>= 0,6 mm), wird also nur auf Drehung belastet.
//
// Ohne Elektronik (elektronik = false): kurze Platte, Griff ohne Magnettaschen.
// Mit elektronik = true entsteht die Smarthome-Variante mit Verschlusssensor (siehe SMARTHOME.md / Tag "smarthome").
//
// Druck: PETG, 4-5 Perimeter, 40 % Infill, 0,2 mm Schicht.
//   Platte: RÜCKSEITE (Türseite) auf das Druckbett (ohne Elektronik keine Stützen nötig).
//   Griff:  Oberseite (Haus) auf das Druckbett.
// Hinweis: Aus OpenSCAD exportierte Teile liegen in Einbaulage. Griff, Haus und Gewindekappen
// zum Drucken um 180° um die X-Achse drehen (oder im Slicer drehen).

teil = "alle";   // "platte", "led_fenster", "xiao_halter", "schaft", "griff", "haus", "kappe", "kappe_kopf", "kappe_mutter", "fach_test", "alle"

/* ---------- gemessen ---------- */
c         = 10.2;  // Stirnfläche Zylinder über Türoberfläche
k_breite  = 23.7;  // Breite Schlüsselkopf
k_dicke   = 2.6;   // Dicke Kopf
k_laenge  = 35.8;  // Schulter bis Oberkante Kopf
k_hals    = 10.4;  // Breite Hals (Dicke 2,4)
k_kopf_z  = 13.6;  // Schulter bis Beginn Kopf (geschätzt aus 35,8 - 22,2)
pin_z     = 28 + 3.7/2;  // Mitte Schlüsselloch über Schulter (Unterkante Loch bei 28 mm; gemessen 29, 1 mm tiefer korrigiert)
schraub_abst = 65;
kopf_z    = 6.6;   // Oberkante Senkkopf über Tür (alte Platte 6,6)

/* ---------- Schraube quer durch Griff+Schlüssel ---------- */
// M3x30 Rundkopf + M3-Mutter. M4 passt NICHT durch das 3,7-mm-Loch im Schlüssel.
pin_d     = 3;             // Gewinde-Ø
schr_len  = 30;            // Länge unter dem Kopf
mutter_s  = 5.5;           // Schlüsselweite M3-Mutter
mutter_h  = 2.4;           // Dicke M3-Mutter
pin_loch  = pin_d + 0.4;   // 3,4 mm Durchgang im Griff
mutter_e  = mutter_s / cos(30) + 0.4;          // Sechskant über Ecken + Spiel
boden     = (schr_len - mutter_h - 1.6) / 2;   // Abstand der Auflageflächen von der Mitte (13 mm)

/* ---------- Konstruktion Lager ---------- */
schraub_d = 5.5; kopf_d = 10.5;
pl_b = 38;                      // Plattenbreite
deckel = 4;
fl_d = 26; fl_h = 4; rohr_d = 20;
bund_d = 32; bund_h = 14;       // Lagerbund auf der Platte (14 mm Führungslänge)
bund_id = 25.5;                 // innen frei für den drehenden Schlüsselkopf
lager_spiel = 0.25;             // radial Glocke <-> Bund
spiel = 0.3; ax_spiel = 0.4;
schlitz = k_dicke + 1.2;        // 3,8 mm -> Schlüssel 0,6 mm Luft je Seite

/* ---------- Griff ---------- */
gr_d    = 56;   // Griff-Ø (vorher 42; Daumen soll nicht mehr zwischen Griff und Türdrücker passen)
fase_u  = 4;    // 45°-Fase unten außen: Freigang über den Kappen der Türschrauben
dach    = 3;
riffel  = 24;   // Anzahl Griffmulden
$fn = 96;

/* ---------- Sensorik ---------- */
mag_r  = 19;    // Radius der Magnetbahn im Griff
mag_d  = 3;     // Magnet Ø3 x 2 mm, axial magnetisiert
mag_h  = 2;
// Sensorplatine (platine/schloss_sensor.kicad_pcb): Kreisbogen r 16,4..21,3, |x| <= 16,2,
// Hall-Sensoren bei 225° (A) und 315° (B) auf r 19,8, Lötaugen für das 4-adrige Kabel bei r 18 / 225°
pcb_ri = 16.4; pcb_ra = 21.3; pcb_x = 16.2;   // Platinenkontur
pcb_sp = 0.2;   // Spiel rundum in der Tasche
pcb_d  = 1.6;   // Platinendicke (AISLER 2 Lagen: 1,6 mm)
pcb_t  = pcb_d + 0.8;   // Taschentiefe: Platine + 0,4 Bauteile + 0,4 Luft – Sensoroberseite 0,4 mm unter der Platte
kabel_a = 225; kabel_r = 18.0;   // Lötaugen J1

/* ---------- Elektronikfach (von hinten offen, die Tür schließt es) ---------- */
elektronik = false;  // false: Platte ohne Elektronikfach/Sensortaschen, Griff ohne Magnete (reiner Knauf)
gestapelt = true;    // true: XIAO liegt über dem Akku (kürzer, volle Dicke) | false: XIAO unter dem Akku (länger, flach auslaufend)
fach_oben = -40;     // Oberkante Fach (unter der unteren Türschraube)
bat_b = gestapelt ? 32 : 31;     // Akku 803040: 30 x 40 x 8 mm (+ Schutzplatine); gestapelt 1 mm Kabelweg je Seite
bat_l = 46;
bat_h = gestapelt ? 10.0 : 10.5; // Decke des Akkufachs über Türfläche (Akku 8 mm + Schaumstoff/Kabel)
xiao_b = 17.8; xiao_l = 21.0; xiao_d = 1.0;   // Seeed XIAO ESP32C6
usb_ueber = 1.0;     // Überstand USB-C-Buchse über die Platinenkante (nachmessen!)
xiao_bt   = 3.6;     // Bauteilhöhe auf der Oberseite
wand_u    = 1.5;     // Wand unten
usb_oeff  = [13.0, 7.2];   // Öffnung für den USB-C-Stecker (Breite, Höhe) – passt für übliche Kabel
halter_sep = false;  // gestapelt: false = XIAO-Tasche direkt in der Platte (braucht Stützen im Fach),
                     //            true  = separater XIAO-Halter (alles ohne Stützen druckbar)
halter_sp = 0.2;     // Spiel XIAO-Halter im Fach (je Seite)
// Trägerplatine (platine/traeger.kicad_pcb): XIAO flach aufgelötet, darüber Akku-Messung, RGB-LED, Reset-Taster.
// Koordinaten auf der Platine: Ursprung = XIAO-Mitte, von vorne gesehen; die Platine reicht von der USB-Kante
// des XIAO (-10,5) bis 28,5 mm darüber. Bauteile zeigen nach vorne, eingesetzt wird von hinten.
tr_b = 22.0; tr_unten = -10.5; tr_oben = 28.5; tr_d = 0.8;
tr_luft = 0.6;       // zwischen Akkufach-Decke und Platinenrückseite (Lötstellen)
tr_bt   = 1.9;       // Bauteilraum vor der Platine (Taster 1,5 mm, Lötstellen der Kabel)
tr_sp   = 0.2;       // Spiel je Seite
tr_led  = [-6.8, 17.2];   // RGB-LED
tr_tast = [ 2.0, 17.2];   // Reset-Taster (Büroklammer)
fenster_d = 4.0;     // Lichtfenster über der LED: eigener Körper für transparentes PETG (Mehrfarbdruck)
taster_loch = 1.4;   // Büroklammer Ø 1 mm

// abgeleitet
z_pf      = gestapelt ? bat_h + tr_luft + tr_d + xiao_d : 3.4;  // XIAO-Vorderseite über Türfläche (Bauteile zeigen nach vorne)
zf0  = c + spiel;            // Flansch unten
zf1  = zf0 + fl_h;           // Flansch oben
cav  = zf1 + ax_spiel;       // Hohlraum oben
H    = cav + deckel;         // Plattenoberfläche
Hx   = gestapelt ? H : 12.5;    // Plattendicke am unteren Ende
zb   = H + bund_h;           // Oberkante Lagerbund
ztop = c + k_laenge;         // Schlüssel oben
zg0  = H + 0.3;              // Griff unten (Anlauf auf Platte)
zg1  = ztop + 0.6 + dach;    // Griff oben
zpin = c + pin_z;
y_in_unten = gestapelt ? fach_oben - bat_l                                  // Innenseite Bodenwand
                       : fach_oben - bat_l - 1.5 - (usb_ueber + xiao_l + 0.3);
y_x0      = (gestapelt && halter_sep) ? y_in_unten + halter_sp : y_in_unten;   // Vorderkante USB-Buchse
halter_l  = usb_ueber + xiao_l + 0.3 + 2.0;                    // Länge XIAO-Halter (2 mm Endwand)
y_x_oben  = y_x0 + usb_ueber + xiao_l + 0.3;                   // Oberkante XIAO-Tasche
tr_y0     = y_x0 + usb_ueber - tr_unten;                       // Plattenkoordinate der XIAO-Mitte
z_tr      = z_pf - xiao_d;                                     // Vorderseite Trägerplatine
y_ende    = y_in_unten - wand_u;                    // Unterkante Platte
z_usb     = z_pf + 1.63;                            // Mitte USB-C-Buchse

assert(bund_id > 2*sqrt(pow(k_breite/2,2)+pow(k_dicke/2,2)) + 1, "Bund innen zu eng für Schlüsselkopf");
assert(zb + 2 < zpin - 3, "Bund zu hoch – kollidiert mit Querschraube");
assert(boden - (rohr_d + 0.6)/2 >= 2.5, "Wand zwischen Gabelbohrung und Schraubenauflage zu dünn");
assert(mag_r - (mag_d + 0.2)/2 > (bund_d + 2*lager_spiel)/2 + 1, "Magnettasche zu nah an der Glocke");
assert(pcb_ri - pcb_sp > bund_d/2, "Platinentasche läuft unter den Bund");
assert(H - pcb_t > cav + 1, "Platinentasche zu tief für den Deckel");
assert(z_pf + xiao_bt + 2 <= Hx, "Elektronikfach zu hoch für die Plattendicke");
assert(!gestapelt || tr_y0 + tr_oben + tr_sp <= fach_oben - 1, "Trägerplatine passt nicht über den Akku");

/* ================= Platte ================= */
module stadion2d() hull() for (y = [-24, 24]) translate([0, y]) circle(d = pl_b);
module verl2d() hull() {
  translate([0, -24]) circle(d = pl_b);
  for (s = [-1, 1]) translate([s*(pl_b/2 - 4), y_ende + 4]) circle(r = 4);
}
module platten_koerper() hull() {
  linear_extrude(H - 1.5) stadion2d();
  translate([0,0,H - 1.5]) linear_extrude(1.5) offset(delta = -1.5) stadion2d();
  if (elektronik) {
    linear_extrude(Hx - 1.5) verl2d();
    translate([0,0,Hx - 1.5]) linear_extrude(1.5) offset(delta = -1.5) verl2d();
  }
}

// Tasche für die Akku-Messplatine: liegt mit der Bauteilseite an 1-mm-Auflagen (45°) links und rechts
module led_fenster() {
  translate([tr_led[0], tr_y0 + tr_led[1], z_tr + tr_bt - 0.01]) cylinder(d = fenster_d, h = H - (z_tr + tr_bt) + 0.01, $fn = 48);
}
module taster_loecher() translate([tr_tast[0], tr_y0 + tr_tast[1], 0]) {
  translate([0, 0, z_tr + tr_bt - 0.01]) cylinder(d = taster_loch, h = H, $fn = 24);
  translate([0, 0, H - 0.8]) cylinder(d1 = taster_loch, d2 = taster_loch + 1.6, h = 0.81, $fn = 24);   // Fase zum Einfädeln
}
// Tasche für die Trägerplatine: liegt mit der Vorderseite an 1-mm-Auflagen (45°) links und rechts
module traeger_tasche() {
  tb = tr_b + 2*tr_sp; y0 = tr_y0 + tr_unten - tr_sp; tl = tr_oben - tr_unten + 2*tr_sp;
  translate([-tb/2, y0, bat_h - 0.01]) cube([tb, tl, z_tr - bat_h + 0.01]);                    // Platine + Luft dahinter
  translate([-tb/2 + 1, y0, z_tr - 0.01]) cube([tb - 2, tl, tr_bt + 0.01]);                   // Bauteilraum, Lötstellen am XIAO-Rand
  hull() {
    translate([-tb/2,     y0, z_tr - 0.01]) cube([tb,     tl, 0.01]);
    translate([-tb/2 + 1, y0, z_tr + 0.99]) cube([tb - 2, tl, 0.01]);
  }
}

// Tasche für den XIAO: Platine liegt mit der Vorderseite (Bauteile) an 45°-Auflagen, Einsetzen von hinten.
// y0 = Vorderkante der USB-Buchse, z_unten = Unterkante der Tasche.
module xiao_tasche(y0, z_unten) {
  bx = xiao_b + 0.3;
  translate([-bx/2, y0 + usb_ueber, z_unten]) cube([bx, xiao_l + 0.3, z_pf - z_unten]);               // Platine + Raum dahinter
  translate([-bx/2 + 1, y0, z_pf - 0.01]) cube([bx - 2, xiao_l + 0.3 + usb_ueber, xiao_bt + 1]);       // Bauteilraum
  hull() {                                                                                             // 1 mm Auflage, 45°
    translate([-bx/2,     y0 + usb_ueber, z_pf - 0.01]) cube([bx,     xiao_l + 0.3, 0.01]);
    translate([-bx/2 + 1, y0 + usb_ueber, z_pf + 0.99]) cube([bx - 2, xiao_l + 0.3, 0.01]);
  }
  translate([-bx/2, y0 + usb_ueber, z_pf - 0.01]) cube([bx, 5, xiao_bt + 1]);                           // USB-Ende volle Breite (Taster)
  translate([-4.7, y0 - 0.5, z_unten]) cube([9.4, usb_ueber + 0.51, z_pf + xiao_bt + 1 - z_unten]);     // Durchgang USB-Buchse
}

module elektronikfach() {
  // Akkufach
  translate([-bat_b/2, fach_oben - bat_l, -1]) cube([bat_b, bat_l, bat_h + 1]);
  if (gestapelt && halter_sep) {
    // Raum für den XIAO-Halter über dem unteren Teil des Akkus
    translate([-bat_b/2, y_in_unten - 0.01, bat_h - 0.01]) cube([bat_b, halter_l + 2*halter_sp + 0.01, z_pf + xiao_bt - bat_h + 0.01]);
  } else if (gestapelt) {
    traeger_tasche();                           // Trägerplatine über dem Akku
    xiao_tasche(y_in_unten, z_tr - 0.01);       // XIAO darauf (Bauteile, USB-Durchgang)
    led_fenster();                              // Lichtfenster (separat als transparenter Körper)
    taster_loecher();                           // Reset mit der Büroklammer
  } else {
    translate([-8, y_x_oben - 0.1, -1]) cube([16, 1.7, 1 + 2.4]);   // Kabeldurchgang im Trennsteg
    xiao_tasche(y_in_unten, -1);
  }
  // Öffnung in der Bodenwand: so groß wie die Steckerummantelung, damit der Stecker immer ganz einrastet
  hull() for (sx = [-1, 1], sz = [-1, 1]) translate([sx*(usb_oeff[0]/2 - 1.5), y_in_unten + 0.01, z_usb + sz*(usb_oeff[1]/2 - 1.5)]) rotate([90,0,0]) cylinder(r = 1.5, h = wand_u + 1, $fn = 32);
}

// XIAO-Halter (nur bei gestapelt): separates Teil, wird mit eingesetztem XIAO von hinten ins Fach geschoben.
// Druck: so wie er liegt (Rückseite unten). Der Akku drückt ihn über einen Schaumstoffstreifen nach vorne.
module xiao_halter() {
  hb = bat_b - 2*halter_sp;
  difference() {
    translate([-hb/2, y_in_unten + halter_sp, bat_h]) cube([hb, halter_l, z_pf + xiao_bt - bat_h - 0.1]);
    xiao_tasche(y_x0, bat_h - 1);
  }
}

module platinen2d() intersection() {
  difference() { circle(r = pcb_ra + pcb_sp, $fn = 180); circle(r = pcb_ri - pcb_sp, $fn = 180); }
  translate([-(pcb_x + pcb_sp), -50]) square([2*(pcb_x + pcb_sp), 50]);
}
module sensortaschen() {
  translate([0, 0, H - pcb_t]) linear_extrude(pcb_t + 1) platinen2d();                    // Tasche von vorne
  xs = kabel_r*cos(kabel_a); ys = kabel_r*sin(kabel_a);
  translate([xs, ys, -1]) cylinder(d = 2.4, h = H, $fn = 24);                             // Kabelloch nach hinten
  translate([xs - 1.5, fach_oben - 1, -1]) cube([3, ys + 1.5 - (fach_oben - 1), 1 + 2.5]); // Kabelkanal bis ins Fach
}

module platte() {
  difference() {
    union() {
      platten_koerper();
      translate([0,0,H - 0.01]) cylinder(d = bund_d, h = bund_h - 0.6 + 0.02);
      translate([0,0,zb - 0.6]) cylinder(d1 = bund_d, d2 = bund_d - 1.2, h = 0.6);
    }
    translate([0,0,-1]) cylinder(d = fl_d + 2*spiel + 0.2, h = cav + 1);       // Flanschkammer
    translate([0,0,-1]) hull() { cylinder(d = 26, h = zf0 + 1);                 // Zylinder + Rosette
                                  translate([0,-19.5,0]) cylinder(d = 16, h = zf0 + 1); }
    cylinder(d = rohr_d + 2*spiel, h = zb + 1);                                  // Lagerbohrung Schaft (Deckel)
    translate([0,0,H]) cylinder(d = bund_id, h = bund_h + 1);                    // Bund innen frei
    for (y = [-schraub_abst/2, schraub_abst/2]) translate([0, y, 0]) {
      translate([0,0,-1]) cylinder(d = schraub_d, h = H + 2);
      translate([0,0,kopf_z - (kopf_d - schraub_d)/2]) cylinder(d1 = schraub_d, d2 = kopf_d, h = (kopf_d - schraub_d)/2 + 0.01);
      translate([0,0,kopf_z]) cylinder(d = kopf_d + 0.3, h = H);
    }
    if (elektronik) { elektronikfach(); sensortaschen(); }
  }
}

// Schnelltest: nur das untere Ende der Platte (XIAO-Tasche + USB) zum Probedrucken
module fach_test() intersection() {
  platte();
  translate([-30, y_ende - 1, -5]) cube([60, (tr_y0 + tr_oben + 3) - (y_ende - 1), 40]);
}

/* ================= Schaft ================= */
module schaft() {
  difference() {
    union() {
      translate([0,0,zf0]) cylinder(d = fl_d, h = fl_h);
      translate([0,0,zf1 - 0.01]) cylinder(d = rohr_d, h = ztop - zf1 - 0.5 + 0.02);
      translate([0,0,ztop - 0.5]) cylinder(d1 = rohr_d, d2 = rohr_d - 1, h = 0.5);
    }
    translate([-(k_hals + 2)/2, -schlitz/2, zf0 - 1]) cube([k_hals + 2, schlitz, fl_h + 2]); // Durchlass Hals
    translate([-rohr_d, -schlitz/2, zf1]) cube([2*rohr_d, schlitz, ztop]);                // Gabelschlitz
    translate([0,0,zpin]) rotate([90,0,0]) cylinder(d = pin_loch + 0.4, h = 40, center = true, $fn = 32);
  }
}

/* ================= Griff ================= */
module griff() {
  difference() {
    hull() {
      translate([0,0,zg0]) cylinder(d = gr_d - 2*fase_u, h = 0.01);
      translate([0,0,zg0 + fase_u]) cylinder(d = gr_d, h = zg1 - zg0 - fase_u - 1.5);
      translate([0,0,zg1 - 0.01]) cylinder(d = gr_d - 3, h = 0.01);
    }
    for (i = [0:riffel-1]) rotate([0,0,(i + 0.5)*360/riffel]) translate([gr_d/2 + 0.6, 0, zg0 + fase_u + 1])   // Griffmulden
      cylinder(d = 4, h = zg1 - zg0 - fase_u - 5, $fn = 24);
    translate([0,0,zg0 - 1]) cylinder(d = bund_d + 2*lager_spiel, h = zb + 0.6 - zg0 + 1); // Glocke
    translate([0,0,zg0 - 1]) cylinder(d = rohr_d + 0.6, h = ztop + 0.6 - zg0 + 1);         // Gabel
    translate([-(k_breite + 2)/2, -schlitz/2, zg0 - 1]) cube([k_breite + 2, schlitz, ztop + 0.6 - zg0 + 1]); // Kopf
    translate([0,0,zpin]) {
      rotate([90,0,0]) cylinder(d = pin_loch, h = gr_d + 2, center = true, $fn = 32);
      verschluss_bohrung(+1);   // Schraubenkopf auf +y
      verschluss_bohrung(-1);   // Mutter auf -y
    }
    // Magnettaschen: unter der Dachspitze (+x) und gegenüber, entgegengesetzt gepolt einkleben
    if (elektronik) for (a = [0, 180]) rotate([0,0,a]) translate([mag_r, 0, zg0 - 0.01]) cylinder(d = mag_d + 0.2, h = mag_h + 0.2, $fn = 32);
    // Tasche für das Haus (bündig mit der Oberfläche) – Einsatz siehe haus()
    translate([0,0,zg1 - haus_t]) linear_extrude(haus_t + 0.2) haus2d();
  }
}

// Stellungssymbol: Haus, Dachspitze in +x = Richtung der Schlüsselbreite.
// Steht der Schlüssel hochkant, zeigt das Dach nach oben (Griff beim Aufstecken entsprechend drehen).
haus_t = 1.0;
module haus2d() polygon([[-10,-8],[1,-8],[1,-10],[10,0],[1,10],[1,8],[-10,8],[-10,2.2],[-5,2.2],[-5,-2.2],[-10,-2.2]]);
module haus() translate([0,0,zg1 - haus_t]) linear_extrude(haus_t) haus2d();

// Gewinde (rechtsgängig, eingängig): versetzter Kreis, verdrillt. Achse = z. Für Bohrung UND Kappe.
gew_d = 8.0;       // Außen-Ø der Gewindebohrung
gew_t = 0.5;       // Gewindetiefe (radial) -> Kern-Ø 7,0
gew_p = 1.0;       // Steigung
gew_spiel = 0.25;  // radiales Spiel Kappe/Bohrung
e_g  = gew_t/2;
rc_b = gew_d/2 - e_g;
rc_c = rc_b - gew_spiel;
y_face  = boden + mutter_h;           // 15,4: Oberseite Schraubenkopf bzw. Außenseite Mutter
kappe_l = gr_d/2 - 0.8 - y_face;      // Kappe endet 0,8 mm unter der Griffoberfläche
module gewinde(rc, L) linear_extrude(height = L, twist = -360*L/gew_p, slices = ceil(20*L/gew_p), convexity = 10)
  translate([e_g,0]) circle(r = rc, $fn = 64);

module verschluss_bohrung(s) {
  rotate([s > 0 ? -90 : 90, 0, 0]) {
    translate([0,0,boden - 0.01]) {
      if (s > 0) cylinder(r = rc_b - e_g - 0.05, h = mutter_h + 0.02, $fn = 64);   // rund für den Kopf (Ø6,9)
      else rotate([0,0,30]) cylinder(d = mutter_e, h = mutter_h + 0.02, $fn = 6);  // Sechskant für die Mutter
    }
    translate([0,0,y_face - 0.01]) gewinde(rc_b, gr_d/2 + 2 - y_face);
  }
}

// Gewinde-Verschlusskappen. Zum Drucken um 180° drehen: Schlitzseite auf das Druckbett. Je 1x drucken.
module kappe_gewinde(mit_aussparung) {
  difference() {
    gewinde(rc_c, kappe_l);
    translate([-0.8,-6,kappe_l - 1.0]) cube([1.6,12,1.1]);                          // Schlitz
    if (mit_aussparung) translate([0,0,-0.01]) cylinder(d = 4, h = 2.5, $fn = 32);  // Raum für das Gewindeende
  }
}
module kappe_kopf()   kappe_gewinde(false);
module kappe_mutter() kappe_gewinde(true);

// Abdeckkappe für die Türschraubenlöcher (2x drucken, Kragen unten auf dem Druckbett)
module kappe() {
  plug_d = kopf_d + 0.3 - 0.8;   // 0,4 mm Luft je Seite
  plug_l = 6; fl_dk = 12.6; fl_hk = 1.2;
  cylinder(d = fl_dk, h = 0.8);
  translate([0,0,0.8]) cylinder(d1 = fl_dk, d2 = fl_dk - 0.8, h = 0.4);
  translate([0,0,fl_hk - 0.01]) cylinder(d = plug_d, h = plug_l - 0.6);
  translate([0,0,fl_hk + plug_l - 0.61]) cylinder(d1 = plug_d, d2 = plug_d - 1.2, h = 0.6);
}

if (teil == "platte") platte();
else if (teil == "fach_test") fach_test();
else if (teil == "led_fenster") led_fenster();
else if (teil == "xiao_halter") xiao_halter();
else if (teil == "kappe") kappe();
else if (teil == "schaft") schaft();
else if (teil == "griff")  griff();
else if (teil == "haus")   haus();
else if (teil == "kappe_kopf")   kappe_kopf();
else if (teil == "kappe_mutter") kappe_mutter();
else {
  color("white") platte();
  color("orange") translate([0,0,15]) schaft();
  color("steelblue") translate([0,0,45]) griff();
}

// Lüfter-Konsole – parametrische Vorlage (Ausgabe in Druckausrichtung: Plattenoberseite auf dem Druckbett)
// Koordinaten: X = "Breite" (0 = Raumseite -> 120 = Wandseite), Y = "Länge" (0..120), Z = Höhe (Oberseite der Konsole = 0)
$fn = 64;

plate_w   = 120;   // Breite (Richtung Wand)
plate_l   = 120;   // Länge
t_thick   = 5;     // Plattenstärke
t_thin    = 2;     // Stärke der dünnen Auflage
x_step    = 95;    // Übergang dick -> dünn (ab Raumseite gemessen) = Wandanlage

// Lüfterlöcher (Langlöcher, längs in Y)
slot_w      = 6;           // (65-53)/2
slot_pitch  = 59;          // Mitte-Mitte in X  (außen 65, innen 53)
slot_cx     = plate_w/2;   // Lochbild mittig über die gesamte Breite (60 mm)
slot_len    = 12;          // Länge des Langlochs in Y
slot_gap    = 54;          // Abstand der Löcher in Wandrichtung (Innenkante zu Innenkante), symmetrisch zur Mitte

// Stützträger (rechtwinklig, an der Wand abgestützt)
leg_h   = 46;   // Höhe ab Oberseite Konsole
legs    = [[15, 24], [81, 24]];  // Doppelträger [y0, Breite]: je einer pro Lochbahn, die beiden Rippen liegen beidseits der Langlöcher (ANNAHME)
leg_t   = 5;    // Stärke des Trägers in X
leg_r   = 9;   // Rundung der unteren Ecken
rib_a   = 70;   // Auskragung der Rundung in X (raumseitig ab Träger) – ANNAHME
rib_t   = 4;    // Stärke der beiden Rippen je Träger
screw_d = 5.5;  // Wandschrauben
cs_d    = 10;   // Senkung
screw_z = [-18, -34];  // Lochhöhen ab Oberseite
nut_af  = 7.2;  // M4-Mutter: Schlüsselweite 7 + Spiel (Flächen parallel zur Langlochrichtung, Mutter kann nicht mitdrehen)
nut_h   = 0;    // Taschentiefe von der Plattenunterseite (0 = keine Tasche; 3,4 = Tasche für M4-Mutter 3,2 mm). Aus: die Löcher liegen frei zwischen den Trägerhälften

module stadium(w, l, h) {   // Langloch, Länge l in Y, Breite w in X
  hull() { translate([0, -(l-w)/2]) cylinder(d=w, h=h); translate([0, (l-w)/2]) cylinder(d=w, h=h); }
}

module nutpocket() {        // Sechskanttasche, in Langlochrichtung (Y) um den Langlochhub verlängert -> Mutter gleitet mit
  R = nut_af / sqrt(3);
  hull() for (dy = [-(slot_len - slot_w)/2, (slot_len - slot_w)/2])
    translate([0, dy, 0]) rotate(90) cylinder(r=R, h=nut_h + 0.01, $fn=6);
}

module leg2d(w) {           // Profil in (Y,Z), Trägerbreite w
  union() {
    translate([0, -leg_h + leg_r]) square([w, leg_h - leg_r]);
    hull() { translate([leg_r, -leg_h + leg_r]) circle(r=leg_r);
             translate([w - leg_r, -leg_h + leg_r]) circle(r=leg_r); }
  }
}

module rib2d() {            // Profil in (X,Z): konkave Viertelellipse
  difference() {
    translate([x_step - leg_t - rib_a, -leg_h]) square([rib_a, leg_h - t_thick]);
    translate([x_step - leg_t - rib_a, -leg_h]) scale([rib_a, leg_h - t_thick]) circle(r=1, $fn=128);
  }
}

module rib(y0, w) {            // Rippe, außen auf die Trägerkontur (Rundung unten) beschnitten
  intersection() {
    translate([0, y0 + rib_t, 0]) rotate([90, 0, 0]) linear_extrude(rib_t) rib2d();
    translate([0, y0, 0]) rotate([90, 0, 90]) linear_extrude(plate_w) leg2d(w);
  }
}

module bracket(y0, w) { leg(y0, w); rib(y0, w); rib(y0 + w - rib_t, w); }

// Tropfenform (Spitze nach -Y2D = im Druck nach oben), 45°-Überhang -> stützenfrei druckbar
module tear2d(d) {
  r = d/2;
  union() { circle(d=d); polygon([[-r/sqrt(2), -r/sqrt(2)], [r/sqrt(2), -r/sqrt(2)], [0, -r*sqrt(2)]]); }
}

module leg(y0, w) {
  translate([x_step - leg_t, y0, 0])
  difference() {
    rotate([90, 0, 90]) linear_extrude(leg_t) leg2d(w);
    for (z = screw_z) translate([-0.01, w/2, z]) {
      rotate([90, 0, 90]) linear_extrude(leg_t + 0.02) tear2d(screw_d);          // Tropfenloch
      hull() {                                                                    // tropfenförmige Senkung
        rotate([90, 0, 90]) linear_extrude(0.01) tear2d(cs_d);
        translate([2.5, 0, 0]) rotate([90, 0, 90]) linear_extrude(0.01) tear2d(screw_d);
      }
    }
  }
}

// Druckausrichtung: Plattenoberseite (Lüfterseite) liegt auf dem Druckbett, Träger/Rippen zeigen nach oben
module body() {
difference() {
  union() {
    translate([0, 0, -t_thick]) cube([x_step, plate_l, t_thick]);                 // dicker Teil
    translate([x_step - 0.01, 0, -t_thin]) cube([plate_w - x_step + 0.01, plate_l, t_thin]);  // dünne Auflage
    for (l = legs) bracket(l[0], l[1]);
  }
  for (cx = [slot_cx - slot_pitch/2, slot_cx + slot_pitch/2])
    for (y = [plate_l/2 - slot_gap/2 - slot_len/2, plate_l/2 + slot_gap/2 + slot_len/2])
      translate([cx, y, 0]) {
        translate([0, 0, -t_thick - 1]) stadium(slot_w, slot_len, t_thick + 2);
        if (nut_h > 0) translate([0, 0, -t_thick - 0.01]) nutpocket();   // Mutter von der Unterseite (im Druck: oben offen, ohne Stützen)
      }
}
}

translate([0, plate_l, 0]) rotate([180, 0, 0]) body();

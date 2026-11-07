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
slot_y0     = 32;          // Beginn ab Kante
slot_y1     = 44;          // Ende ab Kante

// Stützträger (rechtwinklig, an der Wand abgestützt)
leg_h   = 46;   // Höhe ab Oberseite Konsole
leg_l   = 30;   // Breite des Trägers in Y (ANNAHME)
leg_t   = 5;    // Stärke des Trägers in X
leg_r   = 10;   // Rundung der unteren Ecken
rib_a   = 70;   // Auskragung der Rundung in X (raumseitig ab Träger) – ANNAHME
rib_t   = 5;    // Stärke der beiden Rippen je Träger
screw_d = 5.5;  // Wandschrauben
cs_d    = 10;   // Senkung
screw_z = [-18, -34];  // Lochhöhen ab Oberseite

module stadium(w, l, h) {   // Langloch, Länge l in Y, Breite w in X
  hull() { translate([0, -(l-w)/2]) cylinder(d=w, h=h); translate([0, (l-w)/2]) cylinder(d=w, h=h); }
}

module leg2d() {            // Profil in (Y,Z)
  union() {
    translate([0, -leg_h + leg_r]) square([leg_l, leg_h - leg_r]);
    hull() { translate([leg_r, -leg_h + leg_r]) circle(r=leg_r);
             translate([leg_l - leg_r, -leg_h + leg_r]) circle(r=leg_r); }
  }
}

module rib2d() {            // Profil in (X,Z): konkave Viertelellipse
  difference() {
    translate([x_step - leg_t - rib_a, -leg_h]) square([rib_a, leg_h - t_thick]);
    translate([x_step - leg_t - rib_a, -leg_h]) scale([rib_a, leg_h - t_thick]) circle(r=1, $fn=128);
  }
}

module rib(y0) {            // Rippe, außen auf die Trägerkontur (Rundung unten) beschnitten
  intersection() {
    translate([0, y0 + rib_t, 0]) rotate([90, 0, 0]) linear_extrude(rib_t) rib2d();
    translate([0, y0, 0]) rotate([90, 0, 90]) linear_extrude(plate_w) leg2d();
  }
}

module bracket(y0) { leg(y0); rib(y0); rib(y0 + leg_l - rib_t); }

// Tropfenform (Spitze nach -Y2D = im Druck nach oben), 45°-Überhang -> stützenfrei druckbar
module tear2d(d) {
  r = d/2;
  union() { circle(d=d); polygon([[-r/sqrt(2), -r/sqrt(2)], [r/sqrt(2), -r/sqrt(2)], [0, -r*sqrt(2)]]); }
}

module leg(y0) {
  translate([x_step - leg_t, y0, 0])
  difference() {
    rotate([90, 0, 90]) linear_extrude(leg_t) leg2d();
    for (z = screw_z) translate([-0.01, leg_l/2, z]) {
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
    bracket(0);
    bracket(plate_l - leg_l);
  }
  for (cx = [slot_cx - slot_pitch/2, slot_cx + slot_pitch/2])
    for (y = [(slot_y0 + slot_y1)/2, plate_l - (slot_y0 + slot_y1)/2])
      translate([cx, y, -t_thick - 1]) stadium(slot_w, slot_y1 - slot_y0, t_thick + 2);
}
}

translate([0, plate_l, 0]) rotate([180, 0, 0]) body();

/*
  Prüfgriff mit Ring-Turbine und Spulen-Generator (Demonstrator, ohne Baum).

  Der Griff besteht aus getrennten Teilen, damit der Generator ohne Druckstopp
  angebaut werden kann: Spulen vorher wickeln, von außen in den Spulenring
  setzen, Rotor und Leitrad 2 von der Auslassseite einsetzen.
  Siehe ../anleitung_demonstrator.md.

  Teile (Parameter teil=...):
    rohr       Turbinenrohr mit Stecker und Leitrad 1 (wasserführend, muss dicht sein)
    spulenring wird über das Rohr geschoben, 8 Spulenfenster
    huelse     Außenhülse über dem Spulenring
    rotor      Rotor (rotor.scad)
    leitrad2   Einsatz mit Nabe für den Stift, von unten eingeschoben
    kappe      Schraubkappe mit Drossel
    stift      Edelstahlstift Ø2 (nur zur Ansicht, kein Druckteil)
    montage    alles zusammen
    schnitt    Montage, halb aufgeschnitten

  Druckausrichtung (PETG): rohr mit dem Stecker nach OBEN (Auslass auf dem Bett,
  dazu `druck = true`), leitrad2 ebenfalls mit `druck = true` (Nabe unten),
  rotor stehend, kappe wie modelliert, spulenring und huelse stehend. Der Stecker stammt aus ../dusche-weihnachtsbaum/
  schnellkupplung_stecker.scad (Geometrie unverändert, ohne Bohrung).
*/
include <parameter.scad>
include <rotor.scad>
rotor_allein = false;

druck = false;   // true: Rohr zum Drucken drehen (Stecker nach oben)

// ---------- Stecker (aus dem Hauptprojekt, Bohrung wird im Rohr gebohrt) ----------
ueberlapp = 3;

module coupler() {
  cylinder(h = 30, d = 12.3);
  translate([0, 0, 6.5]) {
    cylinder(h = 4, d = 16.7);
    translate([0, 0, 4]) {
      cylinder(h = 1, d1 = 16.7, d2 = 14.5);
      cylinder(h = 10, d = 14.5);
      translate([0, 0, 4.5]) cube([3.4, 13, 6.6], center = true);
      translate([0, 0, 12.5]) {
        cylinder(h = 6, d = 14.5);
        translate([0, 0, 6]) cylinder(h = 1.2, d1 = 14.5, d2 = 12);
      }
    }
  }
}

module stecker_aussen() {
  union() {
    difference() {
      coupler();
      for (s = [1, -1]) translate([0, s*7, 15]) cube([8.5, 2.4, 6.6], center = true);
    }
    translate([0, 0, -ueberlapp]) cylinder(h = ueberlapp + 0.01, d = 12.3);
  }
}

// ---------- Nockengewinde ----------
module gewinde(d, h) {
  linear_extrude(height = h, twist = -360 * h / gew_steigung,
                 slices = ceil(h / gew_steigung * 18), convexity = 6)
    translate([gew_e, 0]) circle(d = d, $fn = 48);
}
gew_l = z_ende - z_gewinde_o;   // 9

// ---------- Turbinenrohr ----------
module kanal() {
  // Steckerbohrung
  translate([0, 0, -6]) cylinder(d = d_wasser, h = 45);
  // Kegel auf Ø9
  translate([0, 0, -z_kanal_d9_o]) cylinder(d1 = d_kanal, d2 = d_wasser, h = z_kanal_d9_o - 6);
  // Ø9-Kanal
  translate([0, 0, -z_kanal_d9_u]) cylinder(d = d_kanal, h = z_kanal_d9_u - z_kanal_d9_o + 0.01);
  // Kegel (45°) auf Ø15
  translate([0, 0, -z_schulter_u]) cylinder(d1 = d_bohrung, d2 = d_kanal, h = z_schulter_u - z_kanal_d9_u + 0.01);
  // Rotorkammer
  translate([0, 0, -z_ende - 1]) cylinder(d = d_bohrung, h = z_ende + 1 - z_schulter_u + 0.01);
}

module leitrad1() {
  l = z_leit1_u - z_leit1_o;
  difference() {
    union() {
      translate([0, 0, -z_leit1_u]) cylinder(d = d_nabe, h = l);
      for (i = [0 : n_leit-1])
        rotate(i * 360 / n_leit)
          translate([0, 0, -z_leit1_u])
            linear_extrude(height = l, twist = leit1_twist, slices = 8)
              translate([d_nabe/2 - 0.3, -t_leit/2])
                square([d_kanal/2 - d_nabe/2 + 0.6, t_leit]);
    }
    // Sackloch für den Stift (von unten)
    translate([0, 0, -z_leit1_u - 0.01]) cylinder(d = d_stift_loch, h = 5, $fn = 24);
  }
}

module rohr() {
  rotate(druck ? [180, 0, 0] : [0, 0, 0]) {
    difference() {
      union() {
        translate([0, 0, -z_kragen_o]) cylinder(d = d_rohr, h = z_kragen_o);
        translate([0, 0, -z_gewinde_o]) cylinder(d = d_kragen, h = z_gewinde_o - z_kragen_o + 0.01);
        translate([0, 0, -z_ende]) gewinde(d_gew, gew_l + 0.01);
        stecker_aussen();
      }
      kanal();
    }
    leitrad1();
  }
}

// ---------- Leitrad 2 (Einsatz) ----------
module leitrad2() {
  rotate(druck ? [180, 0, 0] : [0, 0, 0]) leitrad2_roh();
}

module leitrad2_roh() {
  z0 = -z_ende;
  l  = z_ende - z_insert_o;     // 21
  nabe_l = 10;
  sp_l   = 6;
  difference() {
    union() {
      // Außenrohr
      translate([0, 0, z0]) difference() {
        cylinder(d = d_insert, h = l, $fn = 96);
        translate([0, 0, -1]) cylinder(d = d_insert - 2*wand_insert, h = l + 2, $fn = 96);
      }
      // Nabe oben
      translate([0, 0, -z_insert_o - nabe_l]) cylinder(d = d_nabe, h = nabe_l);
      // Speichen oben
      for (i = [0 : n_leit-1])
        rotate(i * 360 / n_leit)
          translate([d_nabe/2 - 0.3, -t_leit/2, -z_insert_o - sp_l])
            cube([(d_insert - 2*wand_insert)/2 - d_nabe/2 + 0.6, t_leit, sp_l]);
    }
    // Sackloch für den Stift (von oben)
    translate([0, 0, -z_insert_o - 6]) cylinder(d = d_stift_loch, h = 6.01, $fn = 24);
  }
}

// ---------- Spulenring und Hülse ----------
module spulenring() {
  h = z_ring_u - z_ring_o;
  r_o = d_ring_a / 2;
  r_i = d_ring_i / 2;
  difference() {
    translate([0, 0, -z_ring_u]) cylinder(d = d_ring_a, h = h, $fn = 96);
    translate([0, 0, -z_ring_u - 1]) cylinder(d = d_ring_i, h = h + 2, $fn = 96);
    // 8 Spulenfenster, durchgehend bis zum Rohr
    for (i = [0 : n_mag-1])
      rotate(i * 360 / n_mag)
        translate([r_i - 0.05, -fenster_b/2, -z_fenster_m - fenster_l/2])
          cube([r_o - r_i + 1, fenster_b, fenster_l]);
    // Drahtkorridor rundum (außen, 2 mm tief)
    translate([0, 0, -z_korridor - 1]) rotate_extrude($fn = 96)
      translate([r_o - 2, 0]) square([3, 2]);
    // Schlitze vom Korridor zu den Fenstern
    for (i = [0 : n_mag-1])
      rotate(i * 360 / n_mag)
        translate([r_o - 3.2, -0.8, -z_fenster_m + fenster_l/2 - 0.1])
          cube([4, 1.6, 2.5]);
  }
}

module huelse() {
  h = z_ring_u - z_ring_o;
  difference() {
    translate([0, 0, -z_ring_u]) cylinder(d = d_huelse_a, h = h, $fn = 96);
    translate([0, 0, -z_ring_u - 1]) cylinder(d = d_huelse_i, h = h + 2, $fn = 96);
    // Kabelloch zwischen zwei Fenstern
    rotate(360 / n_mag / 2) translate([6, 0, -z_korridor])
      rotate([0, 90, 0]) cylinder(d = d_kabel, h = 10, $fn = 24);
  }
}

// ---------- Kappe mit Drossel ----------
module kappe() {
  h = z_kappe_u - z_gewinde_o;     // 11
  difference() {
    translate([0, 0, -z_kappe_u]) cylinder(d = d_kappe, h = h, $fn = 96);
    // Gewindehohlraum, gleiche Phasenlage wie am Rohr
    translate([0, 0, -z_ende]) gewinde(d_gew + gew_spiel, gew_l + 0.5);
    // Drossel im Boden
    if (drossel_variante == 1) {
      translate([0, 0, -z_kappe_u - 1]) cylinder(d = 10, h = 4, $fn = 64);
    } else {
      for (i = [0 : 3]) rotate(i * 90 + 45)
        translate([3.9, 0, -z_kappe_u - 1]) cylinder(d = 5, h = 4, $fn = 48);
    }
  }
}

// ---------- Stift ----------
module stift() {
  translate([0, 0, -z_stift_o - stift_l]) cylinder(d = d_stift, h = stift_l, $fn = 24);
}

// ---------- Montage ----------
module rotor_montiert() {
  translate([0, 0, -z_rotor_o]) rotate([180, 0, 0]) rotor();
}

module montage() {
  color("seagreen") rohr();
  color("orange") spulenring();
  color("khaki") huelse();
  color("royalblue") rotor_montiert();
  color("tomato") leitrad2();
  color("slategray") kappe();
  color("silver") stift();
}

if (teil == "rohr") rohr();
else if (teil == "spulenring") spulenring();
else if (teil == "huelse") huelse();
else if (teil == "rotor") rotor_montiert_fuer_druck();
else if (teil == "rotor_montage") rotor_montiert();
else if (teil == "leitrad2") leitrad2();
else if (teil == "kappe") kappe();
else if (teil == "stift") stift();
else if (teil == "montage") montage();
else if (teil == "schnitt")
  difference() { montage(); translate([0, -50, -100]) cube([50, 100, 200]); }

module rotor_montiert_fuer_druck() { rotor(); }

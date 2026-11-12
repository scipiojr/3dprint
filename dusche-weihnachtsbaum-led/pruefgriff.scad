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
  rotor stehend, kappe wie modelliert, spulenring und huelse stehend. Der Stecker ist nach den Messwerten des Nutzers neu modelliert
  (siehe Abschnitt Stecker unten), ohne Bohrung.
*/
include <parameter.scad>
include <rotor.scad>
rotor_allein = false;

druck = false;   // true: Rohr zum Drucken drehen (Stecker nach oben)

// ---------- Stecker (Maße vom Nutzer am Original gemessen, 12.11.2026) ----------
// Profil von der Anlagefläche (z = 0) zur Mündung. Alle Durchmesser in mm.
//   0    ..  7.2   Ø12.4        Rastnut (Schaft)
//   7.2  .. 10.2   Ø16.7        Bund
//   10.2 .. 10.9   Ø16.7 -> 14  Fase
//   10.9 .. 18.8   Ø14          Backenbereich (7.9 lang), Backen in Taschen
//   18.8 .. 20.6   Ø14.3        Ring (1.8)
//   20.6 .. 23.1   Ø11.3        O-Ring-Nut (2.5)
//   23.1 .. 27.9   Ø14.2        (4.8)
//   27.9 .. 30.4   Ø14.2 -> 12.2 Fase zur Öffnung (2.5)
// Die Backen sind zwei Flächen im Ø14-Bereich: nur 11.8 dick, 7.2 breit, 6.4 lang,
// oben und unten bleibt ein Rand von je 0.75 (Tasche ist axial geschlossen).
ueberlapp = 3;
st_profil = [[0, 12.4], [7.2, 12.4], [7.2, 16.7], [10.2, 16.7], [10.9, 14],
             [18.8, 14], [18.8, 14.3], [20.6, 14.3], [20.6, 11.3], [23.1, 11.3],
             [23.1, 14.2], [27.9, 14.2], [30.4, 12.2]];
st_backe_dicke = 11.8;
st_backe_breit = 7.2;
st_backe_lang  = 6.4;
st_backe_z0    = 10.9 + (7.9 - st_backe_lang)/2;

module coupler() {
  rotate_extrude($fn = 96)
    polygon(concat([[0, 0]],
                   [for (q = st_profil) [q[1]/2, q[0]]],
                   [[0, st_profil[len(st_profil)-1][0]]]));
}

module stecker_aussen() {
  union() {
    difference() {
      coupler();
      for (s = [1, -1])
        translate([-st_backe_breit/2, s > 0 ? st_backe_dicke/2 : -st_backe_dicke/2 - 5, st_backe_z0])
          cube([st_backe_breit, 5, st_backe_lang]);
    }
    translate([0, 0, -ueberlapp]) cylinder(h = ueberlapp + 0.01, d = 12.4, $fn = 96);
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
      translate([0, 0, -z_kappe_u - 1]) cylinder(d = sqrt(4 * drossel_flaeche / PI), h = 4, $fn = 64);
    } else {
      for (i = [0 : 3]) rotate(i * 90 + 45)
        translate([3.9, 0, -z_kappe_u - 1]) cylinder(d = sqrt(4 * drossel_flaeche / 4 / PI) , h = 4, $fn = 48);
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

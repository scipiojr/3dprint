/*
  Rotor der Ring-Turbine (Teil D).

  Lokale Koordinaten: Achse z von 0 (Einlaufseite) bis rotor_l, Wasser fließt
  nach +z. Gedruckt wird er stehend auf der Auslassseite. In der Montage wird er
  um 180° um x gedreht (pruefgriff.scad).

  Ring Ø14 außen / Ø9 innen, innen 4 schraubenförmige Schaufeln um eine Nabe,
  außen 8 Taschen für Magnete 5 x 4 x 1 mm, abwechselnd N/S nach außen.
  Die Steigung der Schaufeln bestimmt die Drehzahl: Leerlauf ≈ v_axial / Steigung.
*/
include <parameter.scad>

rotor_allein = true;   // pruefgriff.scad setzt das auf false

module rotor() {
  difference() {
    union() {
      cylinder(d = d_nabe, h = rotor_l);
      // Schaufeln: dünne Platten, über die Länge verdreht
      linear_extrude(height = rotor_l, twist = rotor_twist,
                     slices = rotor_slices, convexity = 8)
        for (i = [0 : n_rot-1])
          rotate(i * 360 / n_rot)
            translate([d_nabe/2 - 0.3, -t_rot/2])
              square([d_kanal/2 - d_nabe/2 + 0.6, t_rot]);
      // Ring
      difference() {
        cylinder(d = d_rotor, h = rotor_l, $fn = 96);
        translate([0, 0, -1]) cylinder(d = d_kanal, h = rotor_l + 2, $fn = 72);
      }
    }
    // Stiftbohrung durch die Nabe
    translate([0, 0, -1]) cylinder(d = d_stift_loch, h = rotor_l + 2, $fn = 24);
    // Magnettaschen
    for (i = [0 : n_mag-1])
      rotate(i * 360 / n_mag)
        translate([r_mag_boden, -mag_b/2, rotor_l/2 - mag_l/2])
          cube([d_rotor/2 - r_mag_boden + 1, mag_b, mag_l]);
  }
}

if (rotor_allein) rotor();

// =====================================================================
//  150er Durchfuehrung durch Plexiglas: Innenteil (Scheibe + Gewinderohr) und Aussenteil (Halteplatte mit Innengewinde)
//  Einzelnes Bauteil; Parameter und gemeinsame Bausteine stehen in abluft_system.scad (Basis).
//  part = inner | nut | oring150_plexi | assembly
// =====================================================================
include <abluft_system.scad>

module part_inner() {
    union() {
        mag_flange(disc_t, n_mag_150, R150, lobe150, body150, lobe_offset150, gr150_face, groove_depth_150, bore_r, groove_depth_plexi, gr150, true);
        // Zentrierbund: glatter Ring im Bereich der Plexiglasdicke
        if (collar)
            translate([0, 0, disc_t]) linear_extrude(height = plate_t)
                difference() { circle(r = hole_r - collar_clear, $fn = 240); circle(r = bore_r, $fn = 240); }
        // Gewinde darueber (stoesst plan auf, keine ueberlappenden Wandflaechen)
        translate([0, 0, disc_t + (collar ? plate_t : 0)]) thread_tube(tube_len - (collar ? plate_t : 0));
    }
}

nut_ring_out = hole_r + plexi_gap - 0.4;   // 77.7
lock_z = (nut_lip + nut_t - groove_depth_plexi) / 2;   // Mitte zwischen Steg und Plexiglas-Nut
module part_nut() {
    difference() {
        union() {
            // unten (Magnetflaeche) geschlossener Steg mit Dichtungsnut und Bohrung = Luftkanal, darueber der Gewindeabschnitt
            mag_flange(nut_t, n_mag_150, R150, lobe150, body150, lobe_offset150, gr150_face, groove_depth_150, bore_r, groove_depth_plexi, gr150, true, nut_lip, nut_ring_out - 0.2);
            translate([0, 0, nut_lip]) thread_nut_ring(nut_t - nut_lip, nut_ring_out);
        }
        // radiale Sicherungsschrauben (zwischen den Lappen, auf Hoehe der Gewindezone)
        if (lock_screw_n > 0)
            for (j = [0 : lock_screw_n - 1])
                rotate(lobe_offset150 + 180 / n_mag_150 + j * 360 / lock_screw_n)
                    translate([r_minor, 0, lock_z]) rotate([0, 90, 0]) cylinder(d = lock_screw_d, h = 20, $fn = 32);
    }
}

// Aussenprofil des Stutzens inkl. Wulste (r,z)

part = "assembly";      // inner | nut | oring150_plexi | assembly   (muss nach dem include stehen)
if (part == "inner") part_inner();
else if (part == "nut") part_nut();
else if (part == "oring150_plexi") translate([0, 0, 1.975]) oring(gr150);
else if (part == "assembly") {
    color("steelblue") part_inner();
    color("lightblue", 0.35) translate([-200, -200, disc_t]) difference() {
        cube([400, 400, plate_t]); translate([200, 200, -1]) cylinder(r = hole_r, h = plate_t + 2);
    }
    color("orange") translate([0, 0, disc_t + plate_t + nut_t]) rotate([180, 0, 0]) part_nut();
}


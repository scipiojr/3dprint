// =====================================================================
//  150er Durchfuehrung durch Plexiglas: Innenteil (Scheibe + Gewinderohr) und Aussenteil (Halteplatte mit Innengewinde)
//  Eigene Parameter (Scheibendicken, Bund, Gewinde-Aussendurchmesser, Plexiglas-Nut) stehen HIER; gemeinsame Bausteine/Gewinde/Magnetmuster in abluft_system.scad.
//  part = inner | nut | oring150_plexi | assembly
// =====================================================================
include <abluft_system.scad>

/* [150er Durchfuehrung] */
groove_depth_plexi = 2.8;  // Nuttiefe auf der Plexiglas-Seite
edge_free    = 20;      // frei verfuegbarer Rand ab Ausschnittkante (nur fuer Kontrollausgabe)
disc_t       = 12;      // Dicke der Innenscheibe (min. 5)
nut_t        = 12;      // Dicke der Aussen-Halteplatte (min. 5) - mehr Dicke = laengeres Gewinde = mehr Gaenge
collar       = true;    // Zentrierbund am Rohr (liegt im Bereich der Plexiglasdicke, leitet Seitenkraefte ins Plexiglas)
collar_clear = 0.8;     // radiales Spiel Bund <-> Ausschnitt
lock_screw_n = 2;       // Anzahl radialer Sicherungsschrauben in der Halteplatte (0 = keine)
lock_screw_d = 3.3;     // Kernloch fuer M4 (selbstschneidend in PETG) - Madenschraube mit Kunststoffspitze empfohlen
thread_major = 151;     // Gewinde-Aussendurchmesser (muss < hole_d)
tube_gap     = 0.3;     // Luft zwischen Rohrende und Steg der Halteplatte
plexi_gap    = 0.6;     // Abstand Dichtungsnut zur Ausschnittkante (klein halten: Steg nach aussen soll >= 1 mm bleiben)
land_wall    = 2.0;     // Steg zwischen Nut und Magnettasche / Tasche und Aussenrand
lobe_offset150 = 22.5;  // Drehlage der Scheiben-Lappen (22.5: Lappen liegen NICHT auf den Achsen, Ausdehnung 95.7 mm). Anschluss-Teile um 22.5 drehen aufsetzen.

// abgeleitete Werte
gr150       = hole_r + plexi_gap + groove_w/2;  // Nut-Mittenradius 150er Flaeche
nut_lip     = groove_depth_150 + 1.6;          // geschlossener Steg an der Magnetflaeche der Halteplatte (Nut + Boden)
tube_len    = plate_t + (nut_t - nut_lip) - tube_gap;      // gesamte Rohrlaenge ab Scheibe (Bund + Gewinde)
r_major     = thread_major / 2;
r_minor     = r_major - thread_depth;

function ext_dir(n, R, lr, br, off) =
    [ max(br, max([for(i=[0:n-1]) abs(R*cos(off+i*360/n)) + lr])),      // Ausdehnung in +-X
      max(br, max([for(i=[0:n-1]) abs(R*sin(off+i*360/n)) + lr])) ];    // Ausdehnung in +-Y
function ext_ref(off) = [ max([for(p=ref150_pts) abs(p[0]*cos(off) - p[1]*sin(off))]),
                          max([for(p=ref150_pts) abs(p[0]*sin(off) + p[1]*cos(off))]) ];
e150 = (use_ref_outline && n_mag_150 == 8) ? ext_ref(lobe_offset150) : ext_dir(n_mag_150, R150, lobe150, body150, lobe_offset150);
echo(str("150er Flaeche: Magnet-Teilkreis R=", R150, "  Nut Anschluss r=", gr150_face, "  Nut Plexi r=", gr150));
echo(str("Ausdehnung vom Mittelpunkt in X/Y: ", e150, "  -> ueber Ausschnittkante hinaus: ", e150 - [hole_r, hole_r],
         "  (frei: ", edge_free, ")"));
echo(str("Gewinde: major=", thread_major, " minor=", 2*r_minor, "  Wand am Gewindegrund=", r_minor - bore_r,
         "  Rohrlaenge=", tube_len, "  Gewindelaenge in Mutter=", nut_t - nut_lip, " (", (nut_t - nut_lip)/thread_pitch, " Gaenge)"));
echo(str("O-Ring 150 Plexi: ID=", 2*(gr150-oring_d/2), " AD=", 2*(gr150+oring_d/2), "   O-Ring 150 Anschluss: ID=", 2*(gr150_face-oring_d/2), " AD=", 2*(gr150_face+oring_d/2)));

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


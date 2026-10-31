// =====================================================================
//  Ventilator-Adapter: Muffe fuer 140-mm-Ventilatoranschluss -> Trichter -> 100er-Magnetflansch (jedes Teil mit passendem 100er-Magnetring kann angeschlossen werden: Rohr, Filterkasten, Schlauch)
//  Einzelnes Bauteil; Ventilator-Parameter stehen HIER (neue Anschluesse am Ventilator hier ergaenzen); gemeinsame Bausteine/Magnetmuster in abluft_system.scad.
//  part = adapter140 | oring_fan | oring110
// =====================================================================
include <abluft_system.scad>

/* [Ventilator-Adapter 140 -> 110 (abluft_ventilator_adapter.scad)] */
fan_socket_d   = 146.4; // Innendurchmesser der Muffe (schiebt sich ueber den Ventilatoranschluss)
fan_bore_d     = 140;   // Innendurchmesser des Ventilatoranschlusses = lichte Weite hinter der Muffe (Annahme)
socket_depth   = 36;    // Tiefe der Muffe (max. 36 mm)
socket_wall    = 4;     // Wandstaerke der Muffe (dick genug fuer Schrauben)
socket_chamfer = 1.5;   // Einfuehrfase am Muffenrand (innen)
ad_cone_len    = 35;    // axiale Laenge des Trichters (ca. 30 Grad Halbwinkel)
ad_cone_wall0  = 5.5;   // Wandstaerke (radial) des Trichters am 110er-Ende
fan_screw_n    = 4;     // Anzahl radialer Schraubloecher in der Muffe (0 = keine)
fan_screw_d    = 4.5;   // Lochdurchmesser (Durchgangsloch fuer M4 / Blechschraube 4,2 mit Unterlegscheibe)
fan_screw_from_mouth = 12;  // Abstand der Loecher vom Muffenrand
fan_screw_angle0 = 45;  // Drehlage des ersten Lochs
fan_groove     = true;  // O-Ring-Nut in der Muffenwand (dichtet radial gegen den Ventilatoranschluss)
fan_oring_d    = 3.0;   // Schnurdurchmesser des Muffen-O-Rings (TPU)
fan_groove_depth = 1.6; // Nuttiefe in der Wand (Restwand = socket_wall - Tiefe)
fan_groove_from_mouth = 24; // Lage der Nutmitte ab Muffenrand (zwischen Schraublochkreis und Schulter)
fan_flange_groove = true;   // Dichtungsnut auf dem 110er-Magnetflansch des Adapters (optional, wie Referenz)

echo(str("Ventilator-Adapter: Muffe ID=", fan_socket_d, " Tiefe=", socket_depth, " Wand=", socket_wall, "  Schulter=", (fan_socket_d - fan_bore_d)/2, "  Hoehe gesamt=", flange110_t + ad_cone_len + socket_depth));
echo(str("O-Ring Muffe: Schnur ", fan_oring_d, "  Mittenradius=", fan_socket_d / 2 + fan_groove_depth - fan_oring_d / 2, " -> ID=", fan_socket_d + 2 * fan_groove_depth - 2 * fan_oring_d, " AD=", fan_socket_d + 2 * fan_groove_depth, "  Nut: Restwand=", socket_wall - fan_groove_depth));

// Ventilator-Adapter: Magnetflansch (110er Muster) unten auf dem Druckbett, Trichter, Muffe oben
module part_adapter140() {
    T  = flange110_t;
    zc = T + ad_cone_len;           // Muffenboden (Schulter)
    zt = zc + socket_depth;         // Muffenrand
    rs_i = fan_socket_d / 2;
    rs_o = rs_i + socket_wall;
    rb   = fan_bore_d / 2;
    difference() {
        union() {
            mag_flange(T, n_mag_110, R110, lobe110, body110_r, 0, gr110, fan_flange_groove ? groove_depth_mag : 0, stub_bore_r, 0, 0, false, 0, 0, pr110);
            rotate_extrude($fn = 240)
                polygon([[stub_bore_r, T], [stub_bore_r + ad_cone_wall0, T], [rs_o, zc], [rs_o, zt],
                         [rs_i + socket_chamfer, zt], [rs_i, zt - socket_chamfer], [rs_i, zc], [rb, zc]]);
        }
        // O-Ring-Nut in der Muffenwand, Dach unter 45 Grad (ohne Stuetzen druckbar)
        if (fan_groove) {
            fw = fan_oring_d + 0.2;
            zg = zt - fan_groove_from_mouth;
            rotate_extrude($fn = 240)
                polygon([[rs_i - 0.2, zg - fw/2], [rs_i + fan_groove_depth, zg - fw/2],
                         [rs_i + fan_groove_depth, zg + fw/2 - fan_groove_depth], [rs_i - 0.2, zg + fw/2 + 0.2]]);
        }
        if (fan_screw_n > 0)
            for (j = [0 : fan_screw_n - 1])
                rotate(fan_screw_angle0 + j * 360 / fan_screw_n)
                    translate([rs_i - 1, 0, zt - fan_screw_from_mouth]) rotate([0, 90, 0])
                        cylinder(d = fan_screw_d, h = socket_wall + 2, $fn = 32);
    }
}


part = "adapter140";    // adapter140 | oring_fan | oring110   (muss nach dem include stehen)
if (part == "adapter140") part_adapter140();
else if (part == "oring110") translate([0, 0, 1.975]) oring(gr110);
else if (part == "oring_fan") translate([0, 0, fan_oring_d / 2 - 0.025]) oring(fan_socket_d / 2 + fan_groove_depth - fan_oring_d / 2, fan_oring_d);


// =====================================================================
//  Ventilator-Adapter: Muffe fuer 140-mm-Ventilatoranschluss -> Trichter -> 100er-Magnetflansch (jedes Teil mit passendem 100er-Magnetring kann angeschlossen werden: Rohr, Filterkasten, Schlauch)
//  Einzelnes Bauteil; Parameter und gemeinsame Bausteine stehen in abluft_system.scad (Basis).
//  part = adapter140 | oring_fan | oring110
// =====================================================================
include <abluft_system.scad>

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


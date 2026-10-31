// =====================================================================
//  Verjuengung 150 -> 100/110: 150er Magnetflansch + Trichter + 110er-Ende (Magnetflansch, Schlauchstutzen oder Rohrstumpf)
//  Einzelnes Bauteil; Parameter und gemeinsame Bausteine stehen in abluft_system.scad (Basis).
//  part = funnel | oring150_face | assembly
// =====================================================================
include <abluft_system.scad>

module funnel_body() {
    T = adapter_t;
    zc = T + cone_len;
    rc0 = bore_r + cone_wall0;
    ztop = zc + stub_len;
    beads = [for (k = [0 : bead_n - 1]) bead_first + k * bead_pitch];
    outer_stub = [ for (k = [0 : bead_n - 1]) each concat(
                        [[stub_r(beads[k] - bead_r), zc + beads[k] - bead_r]],
                        arc_pts(zc + beads[k], stub_r(beads[k]), bead_r),
                        [[stub_r(beads[k] + bead_r), zc + beads[k] + bead_r]]) ];
    if (end110 == "stub") {
        rotate_extrude($fn = 240)
            polygon(concat(
                [[bore_r, T - 1], [rc0, T - 1], [rc0, T], [stub_r0, zc], [stub_r0, zc + 0.01]],
                outer_stub,
                [[stub_r(stub_len), ztop - 1.5], [stub_r(stub_len) - 1.2, ztop],
                 [stub_bore_r + 1.0, ztop], [stub_bore_r, ztop - 1.0], [stub_bore_r, zc], [bore_r, T]]));
    } else if (end110 == "pipe") {
        rotate_extrude($fn = 240)
            polygon([[bore_r, T - 1], [rc0, T - 1], [rc0, T], [pipe_od / 2, zc], [pipe_bore_d / 2, zc], [bore_r, T]]);
        translate([0, 0, zc]) rotate(pipe_dir) pipe_stub();
    } else {
        rotate_extrude($fn = 240)
            polygon([[bore_r, T - 1], [rc0, T - 1], [rc0, T], [stub_r0, zc + 0.5],
                     [stub_bore_r, zc + 0.5], [stub_bore_r, zc], [bore_r, T]]);
    }
}
module part_funnel() {
    T = adapter_t;
    zc = T + cone_len;
    union() {
        mag_flange(T, n_mag_150, R150, lobe150, body150, lobe_offset_funnel, gr150_face, groove_depth_150, bore_r, 0, 0, true);
        funnel_body();
        if (end110 == "magnet")
            translate([0, 0, zc + flange110_t - 0.0]) mirror([0, 0, 1])
                mag_flange(flange110_t, n_mag_110, R110, lobe110, body110_r, 0, gr110, groove_depth_mag, stub_bore_r, 0, 0, false, 0, 0, pr110);
    }
}


part = "funnel";        // funnel | oring150_face | assembly   (muss nach dem include stehen)
if (part == "funnel") part_funnel();
else if (part == "oring150_face") translate([0, 0, 1.975]) oring(gr150_face);
else if (part == "assembly") part_funnel();


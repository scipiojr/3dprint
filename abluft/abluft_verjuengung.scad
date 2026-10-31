// =====================================================================
//  Verjuengung 150 -> 100/110: 150er Magnetflansch + Trichter + 110er-Ende (Magnetflansch, Schlauchstutzen oder Rohrstumpf)
//  Eigene Parameter (end110, Trichterwand, Rohrstumpf pipe_*) stehen HIER; gemeinsam genutzt (cone_len, stub_*, bead_*, adapter_t) in abluft_system.scad.
//  part = funnel | oring150_face | assembly
// =====================================================================
include <abluft_system.scad>

end110 = "magnet";      // 110er-Ende: "magnet" = Magnetflansch | "stub" = Schlauchstutzen mit Wulsten | "pipe" = glatter Rohrstumpf (gerade oder gewinkelt) zum Ueberstuelpen der Muffe eines 110er-Rohrs
cone_wall0   = 7.0;     // Wandstaerke (radial) am 150er-Ende

/* [Rohrstumpf am 110er-Ende (nur end110="pipe")] */
pipe_od      = 109;     // Aussendurchmesser des Stumpfs (Muffe des 110er-Rohrs wird darueber geschoben)
pipe_bore_d  = 100;     // Innendurchmesser (lichte Weite)
pipe_len     = 36;      // Laenge des geraden Stumpfs (bei Winkel: gemessen ab Ende des Bogens)
pipe_angle   = 0;       // 0 = gerade, sonst Winkel des Bogens in Grad (z. B. 45 oder 90)
pipe_straight = 0;      // "bend distance": ungebogene Strecke zwischen Trichter und Beginn des Bogens (nur bei pipe_angle > 0)
pipe_bend_r  = 80;      // Biegeradius der Mittellinie (muss groesser als pipe_od/2 sein)
pipe_dir     = 0;       // Richtung des Bogens um die Achse in Grad (0 = zur +X-Seite)
pipe_chamfer = 1.0;     // Einfuehrfase am Rohrende (aussen)


// ---- Rohrstumpf (gerade oder gewinkelt) als ein Polyeder ohne Boolesche Operationen ----
// Ringe senkrecht zum Pfad: [Mittelpunkt, Richtung e1 in der Biegeebene, Aussenradius]; Start bei z=0 in +Z-Richtung
NP = 240;
function pipe_path() =
    let(a = pipe_angle, Rb = pipe_bend_r,
        nb = a > 0 ? max(2, ceil(a / 5)) : 0,
        s  = a > 0 ? pipe_straight : 0,
        E  = [Rb * (1 - cos(a)), 0, s + Rb * sin(a)],
        t  = [sin(a), 0, cos(a)],
        e1 = [cos(a), 0, -sin(a)],
        ro = pipe_od / 2)
    concat([[[0, 0, 0], [1, 0, 0], ro]],
           s > 0 ? [[[0, 0, s], [1, 0, 0], ro]] : [],
           nb > 0 ? [for (k = [1 : nb]) let(f = a * k / nb) [[Rb * (1 - cos(f)), 0, s + Rb * sin(f)], [cos(f), 0, -sin(f)], ro]] : [],
           [[E + t * (pipe_len - pipe_chamfer), e1, ro]],
           [[E + t * pipe_len, e1, ro - pipe_chamfer]]);
module pipe_stub() {
    assert(pipe_angle == 0 || pipe_bend_r > pipe_od / 2 + 5, "pipe_bend_r muss deutlich groesser als pipe_od/2 sein");
    path = pipe_path();
    K = len(path);
    ri = pipe_bore_d / 2;
    // Punkte: erst alle Aussenringe, dann alle Innenringe (gleiche Winkelphase wie rotate_extrude)
    pts = concat(
        [for (k = [0 : K - 1]) for (i = [0 : NP - 1])
            path[k][0] + path[k][2] * (cos(360 * i / NP) * path[k][1] + sin(360 * i / NP) * [0, 1, 0])],
        [for (k = [0 : K - 1]) for (i = [0 : NP - 1])
            path[k][0] + ri * (cos(360 * i / NP) * path[k][1] + sin(360 * i / NP) * [0, 1, 0])]);
    faces = concat(
        [for (k = [0 : K - 2], i = [0 : NP - 1]) each let(j = (i + 1) % NP, a = k * NP + i, b = k * NP + j, c = (k + 1) * NP + j, d = (k + 1) * NP + i) [[a, d, c], [a, c, b]]],
        [for (k = [0 : K - 2], i = [0 : NP - 1]) each let(j = (i + 1) % NP, a = K * NP + k * NP + i, b = K * NP + k * NP + j, c = K * NP + (k + 1) * NP + j, d = K * NP + (k + 1) * NP + i) [[a, b, c], [a, c, d]]],
        [for (i = [0 : NP - 1]) each let(j = (i + 1) % NP) [[i, j, K * NP + j], [i, K * NP + j, K * NP + i]]],
        [for (i = [0 : NP - 1]) each let(j = (i + 1) % NP, o = (K - 1) * NP) [[o + i, K * NP + o + j, o + j], [o + i, K * NP + o + i, K * NP + o + j]]]);
    polyhedron(points = pts, faces = faces, convexity = 10);
}



echo(str("Magnete gesamt: inner=", n_mag_150, " nut=", n_mag_150, " funnel=", n_mag_150 + (end110=="magnet" ? n_mag_110 : 0)));


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


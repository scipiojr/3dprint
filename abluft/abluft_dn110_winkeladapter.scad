// =====================================================================
//  Winkeladapter fuer den Arbeitsplatten-Durchlass: Magnetflansch (110er-Muster, wie Verjuengung/Ventilator-Adapter) unten,
//  Bogen um wa_winkel aus der Senkrechten, danach Schlauchstutzen mit Wulsten (Schlauch wird ueber den Stutzen gezogen).
//  Der Flansch sitzt auf dem Flanschring (Teil 3) des Durchlasses; die Magnetflaeche liegt unten (= Druckbett).
//  Standard: 60 Grad aus der Senkrechten = Schlauch laeuft parallel zur 30-Grad-Dachschraege nach vorn (+x).
//  OpenSCAD 2021.01 oder neuer.   Export: werkzeuge/export_dn110_winkeladapter.sh -> dn110_arbeitsplatte/dn110_winkeladapter.stl
// =====================================================================
include <abluft_system.scad>
part = "keiner";

/* [Winkeladapter] */
// wa_winkel: Winkel der Stutzenachse zur Senkrechten (60 = Schlauch parallel zu einer 30-Grad-Dachschraege)
wa_winkel = 60;                  // [20:5:90]
// wa_r: Biegeradius der Mittellinie (mindestens Stutzenaussenradius + 5)
wa_r = 70;                       // [56:2:120]
// wa_ende: "stutzen" = Schlauchstutzen ø100 mit Wulsten | "rohr" = glatter Rohrstumpf ø109/100 (DN110-Rohr mit Muffe wird darueber geschoben)
wa_ende = "stutzen";             // ["stutzen", "rohr"]
// wa_rohr_od / wa_rohr_id / wa_rohr_len: Aussen-/Innendurchmesser und Laenge des Rohrstumpfs (wie Stumpf von Verjuengung/Doppelbogen: 109 / 100 / 36)
wa_rohr_od = 109;
wa_rohr_id = 100;
wa_rohr_len = 36;
wa_rohr_fase = 1.0;
// wa_np: Punkte je Ringquerschnitt
wa_np = 180;

wa_T  = flange110_t;                    // Flanschdicke
wa_z0 = wa_T - 1;                       // Beginn des Bogens (1 mm im Flansch)
wa_ro = wa_ende == "rohr" ? wa_rohr_od / 2 : stub_r0;     // Aussenradius im Bogen
wa_ri = wa_ende == "rohr" ? wa_rohr_id / 2 : stub_bore_r;  // Bohrung am Bogenende (Flanschbohrung bleibt ø90)
assert(wa_r >= wa_ro + 5, "wa_r zu klein");

// Ringe entlang des Pfades: [Mittelpunkt, e1 (in der Biegeebene), Radius]; Radiusprofil: aussen (Wulste) oder Bohrung
function wa_prof_aussen() = wa_ende == "rohr" ?
    [[0, wa_ro], [wa_rohr_len - wa_rohr_fase, wa_ro], [wa_rohr_len, wa_ro - wa_rohr_fase]] : wa_prof_stutzen();
function wa_prof_stutzen() =
    let(beads = [for (k = [0 : bead_n - 1]) bead_first + k * bead_pitch])
    concat([[0, stub_r(0)]],
           [for (k = [0 : bead_n - 1]) each concat(
               [[beads[k] - bead_r, stub_r(beads[k] - bead_r)]],
               [for (a = [-80 : 20 : 80]) [beads[k] + bead_r * sin(a), stub_r(beads[k]) + bead_r * cos(a)]],
               [[beads[k] + bead_r, stub_r(beads[k] + bead_r)]])],
           [[stub_len - 1.5, stub_r(stub_len)], [stub_len, stub_r(stub_len) - 1.2]]);
function wa_prof_bohrung(ext) = [[0, wa_ri], [(wa_ende == "rohr" ? wa_rohr_len : stub_len) + ext, wa_ri]];
function wa_pfad(zs, prof, r0, r1) =
    let(a = wa_winkel, nb = max(2, ceil(a / 4)),
        E = [wa_r * (1 - cos(a)), 0, wa_z0 + wa_r * sin(a)],
        t = [sin(a), 0, cos(a)], e1 = [cos(a), 0, -sin(a)])
    concat([[[0, 0, zs], [1, 0, 0], r0]],
           zs < wa_z0 ? [[[0, 0, wa_z0], [1, 0, 0], r0]] : [],
           [for (k = [1 : nb]) let(f = a * k / nb) [[wa_r * (1 - cos(f)), 0, wa_z0 + wa_r * sin(f)], [cos(f), 0, -sin(f)], r0 + (r1 - r0) * k / nb]],
           [for (p = prof) [E + t * p[0], e1, p[1]]]);
module wa_sweep(ringe) {
    K = len(ringe); NP = wa_np;
    pts = concat([for (k = [0 : K - 1]) for (i = [0 : NP - 1])
                    ringe[k][0] + ringe[k][2] * (cos(360 * i / NP) * ringe[k][1] + sin(360 * i / NP) * [0, 1, 0])],
                 [ringe[0][0], ringe[K - 1][0]]);
    c0 = K * NP; c1 = K * NP + 1;
    faces = concat(
        [for (k = [0 : K - 2], i = [0 : NP - 1]) each let(j = (i + 1) % NP, a = k * NP + i, b = k * NP + j, c = (k + 1) * NP + j, d = (k + 1) * NP + i) [[a, d, c], [a, c, b]]],
        [for (i = [0 : NP - 1]) let(j = (i + 1) % NP) [c0, i, j]],
        [for (i = [0 : NP - 1]) let(j = (i + 1) % NP, o = (K - 1) * NP) [c1, o + j, o + i]]);
    polyhedron(points = pts, faces = faces, convexity = 10);
}
// Ringe mit doppelten Positionen (Wulstenden) vermeiden: nur streng aufsteigende Pfadpunkte
module winkeladapter() {
    difference() {
        union() {
            mag_flange(wa_T, n_mag_110, R110, lobe110, body110_r, 0, gr110, groove_depth_mag, stub_bore_r - 1, 0, 0, false, 0, 0, pr110);
            wa_sweep(wa_pfad(wa_z0, wa_prof_aussen(), wa_ro, wa_ro));
        }
        wa_sweep(wa_pfad(-1, wa_prof_bohrung(1), stub_bore_r, wa_ri));
    }
}
if (part == "keiner") winkeladapter();

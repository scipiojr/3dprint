// =====================================================================
//  Abluft-System: Schraubkappe (Reduzierer) 110 -> 100 mm Schlauch.   OpenSCAD 2021.01 oder neuer.
//
//  Wird auf den Stutzen des vorhandenen 110er-Schlauchanschlusses (Anschluss_110mm_Schlauch) aufgeschraubt
//  und endet in einem Schlauchstutzen mit Wulsten fuer einen Schlauch mit Nominaldurchmesser hose_nom (100).
//  So muss der 110er-Anschluss nicht neu gedruckt werden.
//
//  Das Innengewinde wird aus dem Aussengewinde des 110er-Anschlusses berechnet (Rechtsgewinde, eine Gang,
//  Steigung ca. 10 mm, leicht konisch). Die Profiltabelle stammt aus der Vermessung der Referenz-STL
//  (Querschnitte entlang des Stutzens, mittlere Abweichung ca. 0,1 mm), die Kappe ist so ausgelegt, dass sie
//  bis zum Anschlag (Stutzenende an der Dichtflaeche) mit dem Spiel thread_clear aufgeschraubt werden kann.
//
//  Teile ("part"):  "kappe" = Schraubkappe,  "oring" = TPU-O-Ring fuer die Dichtflaeche am Stutzenende,
//                   "pruefung" = Kappe + Referenzmaße zum Ansehen (nicht drucken)
//  Druckrichtung: stehend, Gewindeseite unten. Maße in mm. Der Schlauchstutzen (Wulste, Konus) und der
//  Nominaldurchmesser kommen aus abluft_system.scad (hose_nom, bead_*, stub_len).
// =====================================================================

include <abluft_system.scad>
part = "keiner";            // Ausgabe der Hauptdatei aus (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe = "kappe";          // kappe | oring | pruefung

/* [Gewinde des 110er-Anschlusses (vermessen, nicht aendern, ausser der Anschluss ist ein anderer)] */
rt_pitch   = 10.04;         // Steigung (eine Gang, rechtsgaengig)
rt_taper   = -0.031;        // Radiusaenderung pro mm Hoehe (Stutzen wird zur Spitze duenner)
rt_z_ref   = 30;            // Hoehe (im Koordinatensystem der Referenz), fuer die die Profiltabelle gilt
rt_z_tip   = 50;            // Hoehe des Stutzenendes der Referenz
rt_phase   = 180;           // Winkel des Kammes bei z = rt_z_ref (Tabellenindex 0)
rt_bore_r  = 50;            // Innenradius des 110er-Stutzens (ID 100)
rt_tab = [
    56.97, 56.95, 56.94, 56.92, 56.91, 56.89, 56.86, 56.82, 56.79, 56.75, 56.72, 56.67, 56.62, 56.55, 56.49,
    56.43, 56.35, 56.25, 56.15, 56.05, 55.92, 55.76, 55.60, 55.42, 55.26, 55.14, 55.05, 54.98, 54.91, 54.85,
    54.80, 54.75, 54.72, 54.68, 54.66, 54.63, 54.62, 54.61, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60,
    54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.59, 54.60, 54.59, 54.59, 54.59,
    54.59, 54.59, 54.59, 54.60, 54.60, 54.59, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60,
    54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.60, 54.61, 54.61, 54.63, 54.65, 54.67, 54.70, 54.74, 54.78,
    54.84, 54.89, 54.96, 55.04, 55.14, 55.27, 55.47, 55.66, 55.84, 55.99, 56.10, 56.20, 56.30, 56.38, 56.44,
    56.50, 56.56, 56.67, 56.74, 56.78, 56.80, 56.84, 56.87, 56.90, 56.92, 56.93, 56.94, 56.95, 56.96, 56.97
];                          // Aussenradius des Gewindes, 3 Grad pro Wert, Hoehe rt_z_ref

/* [Kappe] */
thread_clear = 0.8;         // Radialspiel Innengewinde zu Aussengewinde
thr_len      = 34;          // Laenge des Innengewindes (ab Stutzenende abwaerts); Gewinde der Referenz: ca. 12 ... 46 mm
cap_wall     = 4;           // Wand ueber dem Gewindekamm
plate_t      = 4;           // Dicke der Deckplatte ueber dem Stutzenende
cone_len     = 16;          // Laenge des Konus von der Kappe auf den Schlauchstutzen
grip_n       = 12;          // Anzahl Griffrippen aussen
grip_h       = 1.6;         // Hoehe der Griffrippen
tip_groove   = true;        // Dichtungsnut in der Deckplatte fuer einen O-Ring auf dem Stutzenende
tip_oring_d  = 2.5;         // Schnurdurchmesser des O-Rings
tip_groove_r = 52;          // Radius der Nutmitte (Stutzenende liegt bei r 50 ... 54)
tip_groove_w = 3.0;
tip_groove_d = 1.6;

// ---------------- Rechnung ----------------
NT = 240;
dz = 0.4;
ntab = len(rt_tab);
function tabr(u) = let(x = (((u % 360) + 360) % 360) / (360 / ntab), i = floor(x), f = x - i)
                   rt_tab[i % ntab] * (1 - f) + rt_tab[(i + 1) % ntab] * f;
// Aussenradius des Anschluss-Stutzens bei Winkel th (Grad) und Referenzhoehe zs
function ext_r(th, zs) = tabr(th - rt_phase - 360 * (zs - rt_z_ref) / rt_pitch) + rt_taper * (zs - rt_z_ref);
// Innenradius der Kappe an der lokalen Hoehe z (Kappenhoehe 0 = offenes Ende; eingeschraubt: zs = z + rt_z_tip - thr_len)
function cap_r_in(th, z) = ext_r(th, z + rt_z_tip - thr_len) + thread_clear;

Rmajor = max(rt_tab) - rt_taper * (rt_z_tip - thr_len - rt_z_ref) + thread_clear;   // groesster Innenradius (offenes Ende)
Rcap   = Rmajor + cap_wall;
function cap_r_out(th) = Rcap + grip_h * (0.5 + 0.5 * cos(grip_n * th));

zb = thr_len;                       // Unterseite der Deckplatte
M  = ceil(zb / dz);
zk = [for (k = [0 : M]) zb * k / M];

module sleeve() {
    N = NT;
    pts = concat([for (z = zk) for (i = [0 : N - 1]) let(th = 360 * i / N) cap_r_out(th) * [cos(th), sin(th), 0] + [0, 0, z]],
                 [for (z = zk) for (i = [0 : N - 1]) let(th = 360 * i / N) cap_r_in(th, z) * [cos(th), sin(th), 0] + [0, 0, z]]);
    oI = (M + 1) * N;
    faces = concat(
        [for (k = [0 : M - 1], i = [0 : N - 1]) each let(j = (i + 1) % N, a = k * N + i, b = k * N + j, c = (k + 1) * N + j, d = (k + 1) * N + i) [[a, b, c], [a, c, d]]],
        [for (k = [0 : M - 1], i = [0 : N - 1]) each let(j = (i + 1) % N, a = oI + k * N + i, b = oI + k * N + j, c = oI + (k + 1) * N + j, d = oI + (k + 1) * N + i) [[a, c, b], [a, d, c]]],
        [for (i = [0 : N - 1]) each let(j = (i + 1) % N) [[i, oI + j, j], [i, oI + i, oI + j]]],
        [for (i = [0 : N - 1]) each let(j = (i + 1) % N, o = M * N) [[o + i, o + j, oI + o + j], [o + i, oI + o + j, oI + o + i]]]);
    polyhedron(pts, faces, convexity = 10);
}

// Deckplatte, Konus und Schlauchstutzen (Wulste wie das Abluft-System) als Drehprofil, stoesst bei z = zb plan auf die Huelse
module head() {
    z0 = zb + plate_t;
    zc = z0 + cone_len;
    ztop = zc + stub_len;
    beads = [for (k = [0 : bead_n - 1]) bead_first + k * bead_pitch];
    outer_stub = [for (k = [0 : bead_n - 1]) each concat(
                    [[stub_r(beads[k] - bead_r), zc + beads[k] - bead_r]],
                    arc_pts(zc + beads[k], stub_r(beads[k]), bead_r),
                    [[stub_r(beads[k] + bead_r), zc + beads[k] + bead_r]])];
    groove = tip_groove ? [[tip_groove_r - tip_groove_w / 2, zb], [tip_groove_r - tip_groove_w / 2, zb + tip_groove_d],
                           [tip_groove_r + tip_groove_w / 2, zb + tip_groove_d], [tip_groove_r + tip_groove_w / 2, zb]] : [];
    rotate_extrude($fn = NT)
        polygon(concat([[stub_bore_r, zb]], groove,
                       [[Rcap, zb], [Rcap, z0], [stub_r0, zc], [stub_r0, zc + 0.01]],
                       outer_stub,
                       [[stub_r(stub_len), ztop - 1.5], [stub_r(stub_len) - 1.2, ztop],
                        [stub_bore_r + 1.0, ztop], [stub_bore_r, ztop - 1.0]]));
}

module kappe() { union() { sleeve(); head(); } }

echo(str("Schraubkappe: Aussen ø", round(2 * Rcap * 10) / 10, " (mit Rippen ø", round(2 * (Rcap + grip_h) * 10) / 10,
         "), Hoehe ", round((zb + plate_t + cone_len + stub_len) * 10) / 10, " mm, Innengewinde ", thr_len, " mm, Schlauchstutzen ø", hose_od,
         " (innen ø", stub_bore_d, "), Spiel ", thread_clear, " mm"));
if (stub_bore_r > rt_bore_r)
    echo("WARNUNG: der Schlauchstutzen ist innen weiter als der 110er-Stutzen (hose_nom zu gross fuer diese Kappe).");
if (thr_len > rt_z_tip - 12)
    echo("WARNUNG: thr_len laenger als das Gewinde der Referenz (ca. 12 ... 46 mm).");

if (ausgabe == "oring") translate([0, 0, tip_oring_d / 2 - 0.025]) oring(tip_groove_r, tip_oring_d);
else if (ausgabe == "pruefung") { color("orange") kappe(); }
else kappe();

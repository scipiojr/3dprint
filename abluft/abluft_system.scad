// =====================================================================
//  Abluft-System: gemeinsame BASIS (Parameter, Hilfsfunktionen, Magnetflansch, Gewinde, O-Ring)
//  OpenSCAD 2021.01 oder neuer.   Diese Datei erzeugt selbst KEIN Teil; sie wird von den Teile-Dateien
//  per  include <abluft_system.scad>  eingebunden. Einzelne Bauteile liegen in eigenen Dateien:
//
//    abluft_durchfuehrung.scad        part = inner | nut | oring150_plexi | assembly   (150er Durchfuehrung im Plexiglas)
//    abluft_verjuengung.scad          part = funnel | oring150_face                    (Magnetflansch 150 + Trichter + 110er-Ende)
//    abluft_ventilator_adapter.scad   part = adapter140 | oring_fan | oring110         (Muffe fuer Ventilator + 100er Magnetflansch)
//    abluft_magnetring.scad           part = ring150 | ring100 | deckel150 | deckel100 (freie Magnetringe zum Anschrauben/Kombinieren)
//    abluft_fuss, _dn110_winkel, _dn110_arbeitsplatte, _fensterkanal, _ausstroemer_direkt, _schraubkappe, _ausmesshilfe
//
//  Parameter: jedes Teil hat seine eigenen in seiner Datei; hier stehen nur gemeinsam genutzte Maße.
//  Gemeinsame Bausteine dieser Basis (fuer eigene Teile wiederverwendbar):
//    mag_flange(...)   Magnetflansch mit Taschen/Nut/Bohrung (Magnetflaeche bei z=0)
//    outline2d, pocket2d, ring2d, ref150_pts   Umriss/Taschen/Nutring
//    thread_tube(L), thread_nut_ring(L, rout)   Aussen- und Innengewinde (Steigung thread_pitch)
//    stub_r/arc_pts    Profil des Schlauchstutzens mit Wulsten  (pipe_stub() liegt in abluft_verjuengung.scad)
//    oring(rc, d)      TPU-O-Ring liegend druckbar
//  Alle Teile sind in Druckrichtung modelliert: die Magnetflaeche liegt auf dem Druckbett (z=0). Masse in mm.
//  README.md beschreibt das System, agent.md den Arbeitsstand fuer KI-Agenten.
//
//  Hinweis: ref150_pts (Umriss der 150er-Magnetflansche) wurde aus dem Referenz-Adapter
//  "Magnetic_Hose_Adapter_150" uebernommen, damit Teile nahtlos aufeinander passen.
//  ACHTUNG: Ueberschreibt eine Datei Parameter NACH dem include, werden abgeleitete Werte dieser Basis
//  nicht neu berechnet (OpenSCAD wertet beim ersten Vorkommen aus) - nur Literale oder vorher definierte Variablen.
// =====================================================================

/* [Magnete] */
mag_d        = 15;      // Magnet-Durchmesser
mag_h        = 3;       // Magnet-Dicke
mag_clear    = 0.30;    // Spiel im Durchmesser (Tasche = mag_d + mag_clear)
mag_depth_extra = 0.20; // Tasche etwas tiefer als Magnet (Platz fuer Kleber), Magnet sitzt plan
crush_ribs   = 3;       // Anzahl feiner Klemmnasen je Tasche (0 = keine)
crush_rib_h  = 0.25;    // Hoehe der Klemmnasen (radial nach innen)
crush_rib_w  = 0.8;     // Breite der Klemmnasen am Fuss
n_mag_150    = 8;       // Magnete pro 150er-Flaeche
n_mag_110    = 6;       // Magnete pro 110er-Flaeche (Referenz = 6)
polarity_marks = true;  // Kerbe am Lappenrand bei jedem 2. Magnet (gleiche Polung nach aussen)

/* [Dichtung] */
oring_d      = 4.0;     // O-Ring-Schnurdurchmesser (TPU)
groove_w     = 4.2;     // Nutbreite
groove_depth_mag   = 1.3;  // Nuttiefe auf Magnetflaechen (wie Referenz)

/* [Fenster / Platte (gemeinsam)] */
hole_d       = 155;     // Ausschnitt in der Platte
plate_t      = 5;       // Plattendicke (Plexiglas)

/* [150er Flansch-Muster (gemeinsam)] */

adapter_t    = 10;      // Dicke des Magnetflanschs an der Verjuengung

bore_d       = 140;     // Innendurchmesser Luftkanal

thread_pitch = 4;       // Steigung (feiner als vorher)
thread_depth = 1.5;     // Gewindetiefe
thr_hr       = 0.34;    // Profil: halbe Zahnbreite am Grund (Anteil der Steigung)
thr_hc       = 0.14;    // Profil: halbe Zahnbreite an der Spitze
thread_clear = 0.35;    // Radialspiel Mutter
thread_widen = 0.03;    // Flankenspiel Mutter (Anteil der Steigung je Seite)

lobe_offset_funnel = 0; // Verjuengung: wie Referenz-Adapter (Lappen auf den Achsen)
groove_depth_150 = 1.9; // Nuttiefe auf 150er Anschluss-Flaechen (Referenz Magnetic_Hose_Adapter_150)
R150 = 91.0;            // Magnet-Teilkreisradius 150 (Referenz)
use_ref_outline = true; // 150er Umriss exakt wie Referenz-Adapter (nur fuer 8 Magnete)

/* [Schlauchseite / Trichter (gemeinsam, auch von Schraubkappe etc. genutzt)] */
cone_len     = 35;      // axiale Laenge des Trichters
hose_nom     = 100;     // Nominaldurchmesser des Schlauchs; 110 = Referenzmuster (passt auf Anschluss_110mm_Schlauch)
hose_od      = hose_nom;   // Stutzen-Aussendurchmesser (Schlauch wird ueber den Stutzen gezogen)
stub_taper   = 0.8;     // Verjuengung (Radius) ueber die Stutzenlaenge
stub_bore_d  = hose_nom - 10;   // Innendurchmesser Stutzen und Luftkanal (Referenz: 110 -> 100, Wand 5)
stub_len     = 50;      // Stutzenlaenge
bead_n       = 5;       // Anzahl Wulste
bead_pitch   = 6;
bead_r       = 2.0;
bead_first   = 10;      // erster Wulst ab Stutzenanfang

/* [110er Magnetflansch (Referenz-Muster, nur end110="magnet")] */
dh           = (110 - hose_nom) / 2;   // Verkleinerung des 110er-Referenzmusters (radial) fuer kleinere Schlauchgroesse
// Muster des Schlauch-Magnetflanschs: hose_nom 110 und 100 sind an den Referenz-Anschluessen vermessen,
// andere Groessen werden naeherungsweise verschoben.
R110         = hose_nom == 100 ? 66.0 : 70.9 - dh;    // Teilkreisradius der Magnete (Referenz: 110 -> 70.9, 100 -> 66.0)
gr110        = hose_nom == 100 ? 50.5 : 55.5 - dh;    // Nut-Mittenradius (Referenz: 110 -> 55.5, 100 -> 50.5)
flange110_t  = 8;
body110_r    = hose_nom == 100 ? 58.4 : 63.5 - dh;   // Koerperradius zwischen den Lappen (Referenz: 110 -> 63.4, 100 -> 58.4)
hose_mag_d   = mag_d;      // Magnetdurchmesser der Schlauch-Magnetflaechen (15; der alte 100er-Anschluss hatte Taschen fuer 10 mm)
hose_mag_clear = hose_nom == 100 ? 0.2 : mag_clear;   // Referenz 100: Taschen ø15,2
lobe110      = (hose_mag_d + hose_mag_clear) / 2 + (hose_nom == 100 ? 2.9 : 2.75);   // Lappenradius um die Magnete (Referenz 110: 10.4, 100: 10.5)

$fn = 96;
eps = 0.01;

// ---------------- abgeleitete Werte ----------------
pr          = (mag_d + mag_clear) / 2;          // Taschenradius
pdepth      = mag_h + mag_depth_extra;          // Taschentiefe
pr110       = (hose_mag_d + hose_mag_clear) / 2; // Taschenradius der Schlauch-Magnetflaechen
hole_r      = hole_d / 2;
bore_r      = bore_d / 2;

gr150_face  = bore_r + 5.5;                     // Nut-Mittenradius der Anschluss-Flaechen (Referenz: 75.5)
lobe150     = 10.5;                             // Lappenradius (Referenz)
body150     = 84.2;                             // Koerperradius (nur Fallback ohne Referenz-Umriss)

stub_r0     = hose_od / 2;
stub_bore_r = stub_bore_d / 2;

// ---------------- Kontrollausgabe ----------------
// Umriss des Referenz-Adapters Magnetic_Hose_Adapter_150 (Lappen auf +X, 8-zaehlig), aus dem STL uebernommen
ref150_pts = [[35.50,-76.40],[38.53,-74.20],[41.70,-72.23],[45.63,-79.04],[52.63,-79.29],[55.65,-79.23],[58.64,-78.81],[61.56,-78.04],[64.37,-76.93],[67.04,-75.51],[69.51,-73.78],[71.77,-71.77],[73.78,-69.51],[75.51,-67.04],[76.93,-64.37],[78.04,-61.56],[78.81,-58.64],[79.23,-55.65],[79.29,-52.63],[79.04,-45.63],[72.23,-41.70],[74.20,-38.53],[76.40,-35.50],[78.79,-32.64],[79.23,-28.17],[79.79,-24.86],[80.56,-21.59],[88.15,-23.62],[93.28,-18.85],[95.37,-16.67],[97.19,-14.26],[98.71,-11.65],[99.92,-8.88],[100.79,-5.99],[101.32,-3.02],[101.50,0.00],[101.32,3.02],[100.79,5.99],[99.92,8.88],[98.71,11.65],[97.19,14.26],[95.37,16.67],[93.28,18.85],[88.15,23.62],[80.56,21.59],[79.72,25.23],[79.13,28.91],[78.79,32.64],[76.40,35.50],[74.20,38.53],[72.23,41.70],[79.04,45.63],[79.29,52.63],[79.23,55.65],[78.81,58.64],[78.04,61.56],[76.93,64.37],[75.51,67.04],[73.78,69.51],[71.77,71.77],[69.51,73.78],[67.04,75.51],[64.37,76.93],[61.56,78.04],[58.64,78.81],[55.65,79.23],[52.63,79.29],[45.63,79.04],[41.70,72.23],[38.53,74.20],[35.50,76.40],[32.64,78.79],[28.91,79.13],[25.23,79.72],[21.59,80.56],[23.62,88.15],[18.85,93.28],[16.67,95.37],[14.26,97.19],[11.65,98.71],[8.88,99.92],[5.99,100.79],[3.02,101.32],[-0.00,101.50],[-3.02,101.32],[-5.99,100.79],[-8.88,99.92],[-11.65,98.71],[-14.26,97.19],[-16.67,95.37],[-18.85,93.28],[-23.62,88.15],[-21.59,80.56],[-25.23,79.72],[-28.91,79.13],[-32.64,78.79],[-35.50,76.40],[-38.53,74.20],[-41.70,72.23],[-45.63,79.04],[-52.63,79.29],[-55.65,79.23],[-58.64,78.81],[-61.56,78.04],[-64.37,76.93],[-67.04,75.51],[-69.51,73.78],[-71.77,71.77],[-73.78,69.51],[-75.51,67.04],[-76.93,64.37],[-78.04,61.56],[-78.81,58.64],[-79.23,55.65],[-79.29,52.63],[-79.04,45.63],[-72.23,41.70],[-74.20,38.53],[-76.40,35.50],[-78.79,32.64],[-79.13,28.91],[-79.72,25.23],[-80.56,21.59],[-88.15,23.62],[-93.28,18.85],[-95.37,16.67],[-97.19,14.26],[-98.71,11.65],[-99.92,8.88],[-100.79,5.99],[-101.32,3.02],[-101.50,-0.00],[-101.32,-3.02],[-100.79,-5.99],[-99.92,-8.88],[-98.71,-11.65],[-97.19,-14.26],[-95.37,-16.67],[-93.28,-18.85],[-88.15,-23.62],[-80.56,-21.59],[-79.72,-25.23],[-79.13,-28.91],[-78.79,-32.64],[-76.40,-35.50],[-74.20,-38.53],[-72.23,-41.70],[-79.04,-45.63],[-79.29,-52.63],[-79.23,-55.65],[-78.81,-58.64],[-78.04,-61.56],[-76.93,-64.37],[-75.51,-67.04],[-73.78,-69.51],[-71.77,-71.77],[-69.51,-73.78],[-67.04,-75.51],[-64.37,-76.93],[-61.56,-78.04],[-58.64,-78.81],[-55.65,-79.23],[-52.63,-79.29],[-45.63,-79.04],[-41.70,-72.23],[-38.84,-74.00],[-37.72,-74.77],[-35.02,-76.78],[-32.64,-78.79],[-28.91,-79.13],[-25.23,-79.72],[-21.59,-80.56],[-23.62,-88.15],[-18.85,-93.28],[-16.67,-95.37],[-14.26,-97.19],[-11.65,-98.71],[-8.88,-99.92],[-5.99,-100.79],[-3.02,-101.32],[0.00,-101.50],[3.02,-101.32],[5.99,-100.79],[8.88,-99.92],[11.65,-98.71],[14.26,-97.19],[16.67,-95.37],[18.85,-93.28],[23.62,-88.15],[21.59,-80.56],[25.23,-79.72],[28.91,-79.13],[32.64,-78.79]];

// ---------------- Hilfsfunktionen ----------------
function qsort(v) = len(v) <= 1 ? v :
    let(p = v[floor(len(v)/2)])
    concat(qsort([for(x=v) if (x < p) x]), [for(x=v) if (x == p) x], qsort([for(x=v) if (x > p) x]));

// ---------------- Magnettasche (2D) mit feinen Klemmnasen ----------------
module pocket2d(pr_ = pr) {
    difference() {
        circle(r = pr_, $fn = 72);
        for (k = [0 : crush_ribs - 1])
            rotate(90 + k * 360 / max(crush_ribs, 1))
                polygon([[pr_ - crush_rib_h, 0], [pr_ + 0.3, -crush_rib_w/2], [pr_ + 0.3, crush_rib_w/2]]);
    }
}

module ring2d(rc, w) { difference() { circle(r = rc + w/2, $fn = 240); circle(r = rc - w/2, $fn = 240); } }

// 2D-Umriss: Koerper + Magnet-Lappen, konkav verrundet, Kerben fuer Polung
module outline2d(n, R, lr, br, off, use_ref = false) {
    difference() {
        if (use_ref && use_ref_outline && n == 8) rotate(off) polygon(ref150_pts);
        else offset(r = -4) offset(delta = 4)
            union() {
                circle(r = br, $fn = 240);
                for (i = [0 : n - 1]) rotate(off + i * 360 / n) translate([R, 0]) circle(r = lr, $fn = 72);
            }
        if (polarity_marks)
            for (i = [0 : 2 : n - 1]) rotate(off + i * 360 / n) translate([R + lr, 0]) circle(d = 1.8, $fn = 24);
    }
}

// ---------------- Magnetflansch: Magnetflaeche bei z=0, optionale Nut auf der Gegenseite ----------------
module mag_flange(T, n, R, lr, br, off, gr_face, gd_face, hole_r, gd_far = 0, gr_far = 0, use_ref = false, hole_step_z = 0, hole_r2 = 0, pr_ = pr) {
    bps = qsort(concat([0, gd_face, pdepth, T - gd_far, T], hole_step_z > 0 ? [hole_step_z] : []));
    for (i = [0 : len(bps) - 2]) {
        z0 = bps[i]; z1 = bps[i+1];
        if (z1 - z0 > 1e-6) {
            zm = (z0 + z1) / 2;
            translate([0, 0, z0]) linear_extrude(height = z1 - z0)
                difference() {
                    outline2d(n, R, lr, br, off, use_ref);
                    circle(r = (hole_step_z > 0 && zm > hole_step_z) ? hole_r2 : hole_r, $fn = 240);
                    if (zm < pdepth)
                        for (j = [0 : n - 1]) rotate(off + j * 360 / n) translate([R, 0]) pocket2d(pr_);
                    if (gd_face > 0 && zm < gd_face) ring2d(gr_face, groove_w);
                    if (gd_far > 0 && zm > T - gd_far) ring2d(gr_far, groove_w);
                }
        }
    }
}

// ---------------- Gewinde ----------------
function tf(t, hr, hc) = let(d = min(abs(t - 0.3), 1 - abs(t - 0.3))) max(0, min(1, (hr - d) / (hr - hc)));
function thr_pts(rmin, depth, hr, hc, N) =
    [for (i = [0 : N - 1]) let(a = 360 * i / N) (rmin + depth * tf(i / N, hr, hc)) * [cos(a), sin(a)]];
function circ_pts(r, N) = [for (i = [0 : N - 1]) r * [cos(360 * i / N), sin(360 * i / N)]];

NT = 240;   // Punkte je Gewindeumfang
module helix_extrude(L, pts_a, pts_b) {
    turns = L / thread_pitch;
    linear_extrude(height = L, twist = -360 * turns, slices = ceil(turns * 40), convexity = 10)
        polygon(points = concat(pts_a, pts_b),
                paths = [[for (i = [0 : len(pts_a) - 1]) i], [for (i = [0 : len(pts_b) - 1]) len(pts_a) + i]]);
}
// Aussengewinde-Rohr (Luftkanal): innen glatt, aussen Gewinde (rechtsgaengig)
module thread_tube(L) {
    helix_extrude(L, thr_pts(r_minor, thread_depth, thr_hr, thr_hc, NT), circ_pts(bore_r, 240));
}
// Innengewinde-Ring: aussen glatt, innen Gewindekontur + Spiel
module thread_nut_ring(L, rout) {
    helix_extrude(L, circ_pts(rout, 180),
                  thr_pts(r_minor + thread_clear, thread_depth, thr_hr + thread_widen, thr_hc + thread_widen, NT));
}

function stub_r(z) = stub_r0 - stub_taper * z / stub_len;     // z ab Stutzenanfang
function arc_pts(zc, rc, br) = [for (a = [-80 : 20 : 80]) [rc + br * cos(a), zc + br * sin(a)]];
// TPU-O-Ring: liegend druckbar (kleine Abflachung oben/unten wie in deinen Vorlagen)
module oring(rc, d = oring_d) {
    h = d / 2 - 0.025;      // Abflachung oben/unten (Druckauflage)
    intersection() {
        rotate_extrude($fn = 240) translate([rc, 0]) circle(d = d, $fn = 48);
        translate([-rc - d, -rc - d, -h]) cube([2 * (rc + d), 2 * (rc + d), 2 * h]);
    }
}

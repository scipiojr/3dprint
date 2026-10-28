// =====================================================================
//  Abluft-System: magnetischer Schlauchanschluss fuer einen 150-mm-Fensterdurchlass
//  (Plexiglas im Dachfenster) mit Verjuengung 150 -> 110 mm.   OpenSCAD 2021.01 oder neuer.
//
//  Teile (Variable "part", jeweils ein STL, Dateinamen siehe werkzeuge/export_alle.sh):
//    "inner"           Durchfuehrung, Innenseite: Scheibe + Zentrierbund + Gewinderohr (= Luftkanal), Magnete zum Schlauch
//    "nut"             Durchfuehrung, Aussenseite: Halteplatte mit Innengewinde und Steg, Magnete z. B. fuer Umlenker
//    "funnel"          Verjuengung 150 -> 110: Magnetflansch 150, Trichter, am 110er-Ende Magnetflansch
//                      (end110="magnet", Standard), Schlauchstutzen mit Wulsten (end110="stub") oder glatter
//                      Rohrstumpf ø109 x 36 mm, optional gewinkelt (end110="pipe", pipe_*-Parameter)
//    "adapter140"      Ventilator-Adapter: Muffe fuer 140-mm-Ventilatoranschluss (Innendurchmesser 146,4 mm) ->
//                      Trichter -> 110er-Magnetflansch (Anschluss fuer 110-mm-Schlauch), Schraubloecher in der Muffe
//    "oring_fan"       TPU-O-Ring fuer die Nut in der Muffenwand des Ventilator-Adapters (3 mm Schnur)
//    "oring150_plexi"  TPU-Dichtung zwischen Scheibe und Plexiglas
//    "oring150_face"   TPU-Dichtung fuer 150er-Anschlussflaechen (Verjuengung/Adapter auf Scheibe)
//    "oring110"        TPU-Dichtung fuer 110er-Anschlussflaechen
//    "assembly"        Vorschau des zusammengebauten Systems (nicht drucken)
//
//  Alle Teile sind in Druckrichtung modelliert: die Magnetflaeche liegt auf dem Druckbett (z=0).
//  Masse in mm. README.md beschreibt das System, agent.md den Arbeitsstand fuer KI-Agenten.
//
//  Hinweis: ref150_pts (Umriss der 150er-Magnetflansche) wurde aus dem Referenz-Adapter
//  "Magnetic_Hose_Adapter_150" uebernommen, damit Teile nahtlos aufeinander passen.
// =====================================================================

part = "assembly";      // inner | nut | funnel | adapter140 | oring_fan | oring150_plexi | oring150_face | oring110 | assembly
end110 = "magnet";      // funnel, 110er-Ende: "magnet" = Magnetflansch (Referenz-Muster, passt auf Anschluss_110mm_Schlauch) | "stub" = Schlauchstutzen mit Wulsten | "pipe" = glatter Rohrstumpf (gerade oder gewinkelt) zum Ueberstuelpen der Muffe eines 110er-Rohrs

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
groove_depth_plexi = 2.8;  // Nuttiefe auf der Plexiglas-Seite

/* [Fenster / Platte] */
hole_d       = 155;     // Ausschnitt in der Platte
plate_t      = 5;       // Plattendicke (Plexiglas)
edge_free    = 20;      // frei verfuegbarer Rand ab Ausschnittkante (nur fuer Kontrollausgabe)

/* [150er Durchfuehrung] */
disc_t       = 12;      // Dicke der Innenscheibe (min. 5)
nut_t        = 12;      // Dicke der Aussen-Halteplatte (min. 5) - mehr Dicke = laengeres Gewinde = mehr Gaenge
adapter_t    = 10;      // Dicke des Magnetflanschs an der Verjuengung
collar       = true;    // Zentrierbund am Rohr (liegt im Bereich der Plexiglasdicke, leitet Seitenkraefte ins Plexiglas)
collar_clear = 0.8;     // radiales Spiel Bund <-> Ausschnitt
lock_screw_n = 2;       // Anzahl radialer Sicherungsschrauben in der Halteplatte (0 = keine)
lock_screw_d = 3.3;     // Kernloch fuer M4 (selbstschneidend in PETG) - Madenschraube mit Kunststoffspitze empfohlen
bore_d       = 140;     // Innendurchmesser Luftkanal
thread_major = 151;     // Gewinde-Aussendurchmesser (muss < hole_d)
thread_pitch = 4;       // Steigung (feiner als vorher)
thread_depth = 1.5;     // Gewindetiefe
thr_hr       = 0.34;    // Profil: halbe Zahnbreite am Grund (Anteil der Steigung)
thr_hc       = 0.14;    // Profil: halbe Zahnbreite an der Spitze
thread_clear = 0.35;    // Radialspiel Mutter
thread_widen = 0.03;    // Flankenspiel Mutter (Anteil der Steigung je Seite)
tube_gap     = 0.3;     // Luft zwischen Rohrende und Steg der Halteplatte
plexi_gap    = 0.6;     // Abstand Dichtungsnut zur Ausschnittkante (klein halten: Steg nach aussen soll >= 1 mm bleiben)
land_wall    = 2.0;     // Steg zwischen Nut und Magnettasche / Tasche und Aussenrand
lobe_offset150 = 22.5;  // Drehlage der Scheiben-Lappen (22.5: Lappen liegen NICHT auf den Achsen, Ausdehnung 95.7 mm). Anschluss-Teile um 22.5 drehen aufsetzen.
lobe_offset_funnel = 0; // Verjuengung: wie Referenz-Adapter (Lappen auf den Achsen)
groove_depth_150 = 1.9; // Nuttiefe auf 150er Anschluss-Flaechen (Referenz Magnetic_Hose_Adapter_150)
R150 = 91.0;            // Magnet-Teilkreisradius 150 (Referenz)
use_ref_outline = true; // 150er Umriss exakt wie Referenz-Adapter (nur fuer 8 Magnete)

/* [Verjuengung 150 -> 110] */
cone_len     = 35;      // axiale Laenge des Trichters
cone_wall0   = 7.0;     // Wandstaerke (radial) am 150er-Ende
hose_nom     = 100;     // Nominaldurchmesser des Schlauchs; 110 = Referenzmuster (passt auf Anschluss_110mm_Schlauch)
hose_od      = hose_nom;   // Stutzen-Aussendurchmesser (Schlauch wird ueber den Stutzen gezogen)
stub_taper   = 0.8;     // Verjuengung (Radius) ueber die Stutzenlaenge
stub_bore_d  = hose_nom - 10;   // Innendurchmesser Stutzen und Luftkanal (Referenz: 110 -> 100, Wand 5)
stub_len     = 50;      // Stutzenlaenge
bead_n       = 5;       // Anzahl Wulste
bead_pitch   = 6;
bead_r       = 2.0;
bead_first   = 10;      // erster Wulst ab Stutzenanfang

/* [Rohrstumpf am 110er-Ende (nur end110="pipe")] */
pipe_od      = 109;     // Aussendurchmesser des Stumpfs (Muffe des 110er-Rohrs wird darueber geschoben)
pipe_bore_d  = 100;     // Innendurchmesser (lichte Weite)
pipe_len     = 36;      // Laenge des geraden Stumpfs (bei Winkel: gemessen ab Ende des Bogens)
pipe_angle   = 0;       // 0 = gerade, sonst Winkel des Bogens in Grad (z. B. 45 oder 90)
pipe_straight = 0;      // "bend distance": ungebogene Strecke zwischen Trichter und Beginn des Bogens (nur bei pipe_angle > 0)
pipe_bend_r  = 80;      // Biegeradius der Mittellinie (muss groesser als pipe_od/2 sein)
pipe_dir     = 0;       // Richtung des Bogens um die Achse in Grad (0 = zur +X-Seite)
pipe_chamfer = 1.0;     // Einfuehrfase am Rohrende (aussen)

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

/* [Ventilator-Adapter 140 -> 110 (part = "adapter140")] */
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

$fn = 96;
eps = 0.01;

// ---------------- abgeleitete Werte ----------------
pr          = (mag_d + mag_clear) / 2;          // Taschenradius
pdepth      = mag_h + mag_depth_extra;          // Taschentiefe
pr110       = (hose_mag_d + hose_mag_clear) / 2; // Taschenradius der Schlauch-Magnetflaechen
hole_r      = hole_d / 2;
bore_r      = bore_d / 2;
gr150       = hole_r + plexi_gap + groove_w/2;  // Nut-Mittenradius 150er Flaeche
gr150_face  = bore_r + 5.5;                     // Nut-Mittenradius der Anschluss-Flaechen (Referenz: 75.5)
lobe150     = 10.5;                             // Lappenradius (Referenz)
body150     = 84.2;                             // Koerperradius (nur Fallback ohne Referenz-Umriss)
nut_lip     = groove_depth_150 + 1.6;          // geschlossener Steg an der Magnetflaeche der Halteplatte (Nut + Boden)
tube_len    = plate_t + (nut_t - nut_lip) - tube_gap;      // gesamte Rohrlaenge ab Scheibe (Bund + Gewinde)
r_major     = thread_major / 2;
r_minor     = r_major - thread_depth;
stub_r0     = hose_od / 2;
stub_bore_r = stub_bore_d / 2;

// ---------------- Kontrollausgabe ----------------
// Umriss des Referenz-Adapters Magnetic_Hose_Adapter_150 (Lappen auf +X, 8-zaehlig), aus dem STL uebernommen
ref150_pts = [[35.50,-76.40],[38.53,-74.20],[41.70,-72.23],[45.63,-79.04],[52.63,-79.29],[55.65,-79.23],[58.64,-78.81],[61.56,-78.04],[64.37,-76.93],[67.04,-75.51],[69.51,-73.78],[71.77,-71.77],[73.78,-69.51],[75.51,-67.04],[76.93,-64.37],[78.04,-61.56],[78.81,-58.64],[79.23,-55.65],[79.29,-52.63],[79.04,-45.63],[72.23,-41.70],[74.20,-38.53],[76.40,-35.50],[78.79,-32.64],[79.23,-28.17],[79.79,-24.86],[80.56,-21.59],[88.15,-23.62],[93.28,-18.85],[95.37,-16.67],[97.19,-14.26],[98.71,-11.65],[99.92,-8.88],[100.79,-5.99],[101.32,-3.02],[101.50,0.00],[101.32,3.02],[100.79,5.99],[99.92,8.88],[98.71,11.65],[97.19,14.26],[95.37,16.67],[93.28,18.85],[88.15,23.62],[80.56,21.59],[79.72,25.23],[79.13,28.91],[78.79,32.64],[76.40,35.50],[74.20,38.53],[72.23,41.70],[79.04,45.63],[79.29,52.63],[79.23,55.65],[78.81,58.64],[78.04,61.56],[76.93,64.37],[75.51,67.04],[73.78,69.51],[71.77,71.77],[69.51,73.78],[67.04,75.51],[64.37,76.93],[61.56,78.04],[58.64,78.81],[55.65,79.23],[52.63,79.29],[45.63,79.04],[41.70,72.23],[38.53,74.20],[35.50,76.40],[32.64,78.79],[28.91,79.13],[25.23,79.72],[21.59,80.56],[23.62,88.15],[18.85,93.28],[16.67,95.37],[14.26,97.19],[11.65,98.71],[8.88,99.92],[5.99,100.79],[3.02,101.32],[-0.00,101.50],[-3.02,101.32],[-5.99,100.79],[-8.88,99.92],[-11.65,98.71],[-14.26,97.19],[-16.67,95.37],[-18.85,93.28],[-23.62,88.15],[-21.59,80.56],[-25.23,79.72],[-28.91,79.13],[-32.64,78.79],[-35.50,76.40],[-38.53,74.20],[-41.70,72.23],[-45.63,79.04],[-52.63,79.29],[-55.65,79.23],[-58.64,78.81],[-61.56,78.04],[-64.37,76.93],[-67.04,75.51],[-69.51,73.78],[-71.77,71.77],[-73.78,69.51],[-75.51,67.04],[-76.93,64.37],[-78.04,61.56],[-78.81,58.64],[-79.23,55.65],[-79.29,52.63],[-79.04,45.63],[-72.23,41.70],[-74.20,38.53],[-76.40,35.50],[-78.79,32.64],[-79.13,28.91],[-79.72,25.23],[-80.56,21.59],[-88.15,23.62],[-93.28,18.85],[-95.37,16.67],[-97.19,14.26],[-98.71,11.65],[-99.92,8.88],[-100.79,5.99],[-101.32,3.02],[-101.50,-0.00],[-101.32,-3.02],[-100.79,-5.99],[-99.92,-8.88],[-98.71,-11.65],[-97.19,-14.26],[-95.37,-16.67],[-93.28,-18.85],[-88.15,-23.62],[-80.56,-21.59],[-79.72,-25.23],[-79.13,-28.91],[-78.79,-32.64],[-76.40,-35.50],[-74.20,-38.53],[-72.23,-41.70],[-79.04,-45.63],[-79.29,-52.63],[-79.23,-55.65],[-78.81,-58.64],[-78.04,-61.56],[-76.93,-64.37],[-75.51,-67.04],[-73.78,-69.51],[-71.77,-71.77],[-69.51,-73.78],[-67.04,-75.51],[-64.37,-76.93],[-61.56,-78.04],[-58.64,-78.81],[-55.65,-79.23],[-52.63,-79.29],[-45.63,-79.04],[-41.70,-72.23],[-38.84,-74.00],[-37.72,-74.77],[-35.02,-76.78],[-32.64,-78.79],[-28.91,-79.13],[-25.23,-79.72],[-21.59,-80.56],[-23.62,-88.15],[-18.85,-93.28],[-16.67,-95.37],[-14.26,-97.19],[-11.65,-98.71],[-8.88,-99.92],[-5.99,-100.79],[-3.02,-101.32],[0.00,-101.50],[3.02,-101.32],[5.99,-100.79],[8.88,-99.92],[11.65,-98.71],[14.26,-97.19],[16.67,-95.37],[18.85,-93.28],[23.62,-88.15],[21.59,-80.56],[25.23,-79.72],[28.91,-79.13],[32.64,-78.79]];
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
echo(str("Ventilator-Adapter: Muffe ID=", fan_socket_d, " Tiefe=", socket_depth, " Wand=", socket_wall, "  Schulter=", (fan_socket_d - fan_bore_d)/2, "  Hoehe gesamt=", flange110_t + ad_cone_len + socket_depth));
echo(str("O-Ring Muffe: Schnur ", fan_oring_d, "  Mittenradius=", fan_socket_d / 2 + fan_groove_depth - fan_oring_d / 2, " -> ID=", fan_socket_d + 2 * fan_groove_depth - 2 * fan_oring_d, " AD=", fan_socket_d + 2 * fan_groove_depth, "  Nut: Restwand=", socket_wall - fan_groove_depth));
echo(str("Magnete gesamt: inner=", n_mag_150, " nut=", n_mag_150, " funnel=", n_mag_150 + (end110=="magnet" ? n_mag_110 : 0)));

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

// ---------------- Teile ----------------
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
function stub_r(z) = stub_r0 - stub_taper * z / stub_len;     // z ab Stutzenanfang
function arc_pts(zc, rc, br) = [for (a = [-80 : 20 : 80]) [rc + br * cos(a), zc + br * sin(a)]];
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

// TPU-O-Ring: liegend druckbar (kleine Abflachung oben/unten wie in deinen Vorlagen)
module oring(rc, d = oring_d) {
    h = d / 2 - 0.025;      // Abflachung oben/unten (Druckauflage)
    intersection() {
        rotate_extrude($fn = 240) translate([rc, 0]) circle(d = d, $fn = 48);
        translate([-rc - d, -rc - d, -h]) cube([2 * (rc + d), 2 * (rc + d), 2 * h]);
    }
}

// ---------------- Ausgabe ----------------
if (part == "inner") part_inner();
else if (part == "nut") part_nut();
else if (part == "funnel") part_funnel();
else if (part == "adapter140") part_adapter140();
else if (part == "oring150_plexi") translate([0, 0, 1.975]) oring(gr150);
else if (part == "oring150_face") translate([0, 0, 1.975]) oring(gr150_face);
else if (part == "oring110") translate([0, 0, 1.975]) oring(gr110);
else if (part == "oring_fan") translate([0, 0, fan_oring_d / 2 - 0.025]) oring(fan_socket_d / 2 + fan_groove_depth - fan_oring_d / 2, fan_oring_d);
else if (part == "assembly") {
    color("steelblue") part_inner();
    color("lightblue", 0.35) translate([-200, -200, disc_t]) difference() {
        cube([400, 400, plate_t]); translate([200, 200, -1]) cylinder(r = hole_r, h = plate_t + 2);
    }
    color("orange") translate([0, 0, disc_t + plate_t + nut_t]) rotate([180, 0, 0]) part_nut();
    color("seagreen") translate([0, 0, disc_t + plate_t + nut_t]) part_funnel();
}

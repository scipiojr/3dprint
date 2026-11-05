// =====================================================================
//  K40+-Abluftanschluss: ersetzt das Abluftblech samt Luefter an der Rueckwand des OMTech K40+ und fuehrt die
//  Luft kompakt in einem 90-Grad-Bogen nach LINKS (von hinten auf den Laser gesehen) in den Filterkasten.
//  OpenSCAD 2021.01 oder neuer.
//
//  Ein Druckteil: Platte (Lochbild des K40+) -> Uebergang Rechteck -> Kreis -> Bogen nach links -> Ende.
//  Ende ("ende"):
//    "muffe"   Muffe ueber den ø100-Stutzen des Filterkasten-Einlasses (einlass_typ="stutzen"). Der Stutzen steckt
//              bis zu "muffe_l" mm tief, der Kasten kann also um diesen Betrag in der Laenge nachgeben (Toleranz).
//              Anschlag am Muffengrund, optionale O-Ring-Nut (3-mm-TPU-Schnur, part = "oring_muffe").
//    "magnet"  100er Magnetflansch des Systems (Magnetflaeche zeigt nach links), passt auf den Einlass mit
//              einlass_typ="magnet". Etwa 8 mm laenger als die Muffe, aber ohne Einstecktoleranz.
//
//  Koordinaten (montiert): x nach RECHTS (von hinten auf den Laser gesehen), z nach oben, y von der Rueckwand
//  WEG. Ursprung: Mitte der Platte auf der Rueckwand (Platte y = 0 .. pl_t). Strömung: +y, dann Bogen nach -x.
//
//  ausgabe:  "druck" (Platte flach auf dem Druckbett, Rueckwandseite unten, Stuetzen unter dem Bogen noetig)
//            | "montiert" (Weltlage) | "oring" (TPU-Ring) | "info"
//  Export:   werkzeuge/export_k40_anschluss.sh
//
//  Herkunft der Maße: Lochbild und Ausschnitt aus den STL "VerticalExhaust-K40" (MakerWorld 1289939):
//  Schlitze 5 x 8, Abstand 145 x 113; Ausschnitt in der Rueckwand ca. 124 x 121. Nicht am Laser geprueft!
// =====================================================================
include <abluft_system.scad>
part = "keiner";                 // Hauptdatei: keine Ausgabe des Systems (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe = "druck";               // ["druck", "montiert", "oring", "info"]
ende = "muffe";                  // ["muffe", "magnet"]

/* [Platte und Lochbild K40+] */
pl_w = 160;                      // Plattenbreite (x)
pl_h = 135.5;                    // Plattenhoehe (z)
pl_t = 4;                        // Plattendicke
slot_dx = 145;                   // Schlitzabstand waagerecht (Mitte zu Mitte)
slot_dz = 113;                   // Schlitzabstand senkrecht
slot_b = 5;                      // Schlitzbreite (M4)
slot_l = 8;                      // Schlitzlaenge (senkrecht)
pocket_w = 124;                  // Ausschnitt in der Rueckwand, Breite
pocket_h = 121;                  // Ausschnitt in der Rueckwand, Hoehe
pocket_dz = -0.75;               // Mitte des Ausschnitts relativ zur Plattenmitte (+ = oben)
rand = 2;                        // Abstand Oeffnung zu Ausschnittkante (Auflage der Platte rundum)
oe_rc = 10;                      // Eckenradius der Oeffnung

/* [Luftweg] */
bore_d = 90;                     // Durchmesser des runden Luftkanals (wie der 100er Magnetflansch)
wand = 2.4;                      // Wandstaerke des Kanals
rb = 50;                         // Biegeradius der Kanalmitte (min. bore_d/2 + wand + 2 = 49,4)
x_ax = 10;                       // Lage der Rundachse in x (+ = nach rechts, spart Laenge nach links; max. ca. 12, sonst ragt der Kanal ueber die Oeffnung)
z_ax = 0;                        // Hoehe der Rundachse relativ zur Plattenmitte (Hoehe des Kastens: Fuesschen)

/* [Filterkasten (Maße aus abluft_filterkasten.scad)] */
kasten_w = 169.8;                // box_w
scharnier_ueber = 9;             // hinge_y - box_w: Scharnierachse ausserhalb der Kastenwand
scharnier_frei = 20;             // Abstand Scharnierachse zur Laserrueckwand (Deckel offen 90 Grad: 12,5 mm + Reserve)
// Abstand der Kastenachse von der Rueckwand = Achse bis Scharnierachse + Freiraum:
y_ax = kasten_w/2 + scharnier_ueber + scharnier_frei;

/* [Muffe auf den Einlass-Stutzen] */
stutzen_d = 100;                 // Aussendurchmesser des Stutzens (in_pipe_id im Filterkasten)
muffe_spiel = 0.5;               // Durchmesserspiel
muffe_wand = 4;                  // Muffenwand (Platz fuer die O-Ring-Nut)
muffe_l = 20;                    // Muffentiefe = Laenge des Einlass-Stutzens (in_tube_len im Kasten = 20); tiefer bringt nichts, dahinter beginnt der Konus
muffe_grund = 3;                 // Dicke des Anschlagrings am Muffengrund
muffe_nut = true;                // O-Ring-Nut in der Muffe
muffe_nut_von = 7;               // Nutmitte, Abstand von der Muffenmuendung (Stutzen muss mind. 9 mm stecken)
oring_muffe_d = 3;               // Schnurdurchmesser
muffe_nut_t = 1.6;               // Nuttiefe

/* [Qualitaet] */
NR = 96;                         // Punkte je Querschnitt
M1 = 14;                         // Ringe im Uebergang
M2 = 18;                         // Ringe im Bogen

// ---------------- abgeleitet ----------------
a_i = pocket_w/2 - rand;         // halbe Breite der Oeffnung
b_i = pocket_h/2 - rand;         // halbe Hoehe
R_i = bore_d/2;
x_b = x_ax - rb;                 // Ende des Bogens (Anschlag der Muffe / Flaechenmitte Magnetflansch-Rueckseite)
yb0 = y_ax - rb;                 // Beginn des Bogens
lt = yb0 - pl_t;                 // Laenge des Uebergangs
muffe_id = stutzen_d + muffe_spiel;
muffe_od = muffe_id + 2*muffe_wand;
x_mund = x_b - muffe_l;          // Muendung der Muffe
x_flansch = x_b - flange110_t;   // Magnetflaeche (bei ende = "magnet")
x_ende = ende == "muffe" ? x_mund : x_flansch;

// ---------------- Querschnitt: abgerundetes Rechteck -> Kreis ----------------
function ss(t) = t*t*(3 - 2*t);
function rr_r(th, a, b, rc) =
    let(c = abs(cos(th)), s = abs(sin(th)), cx = a - rc, cy = b - rc,
        tx = c > 1e-9 ? a/c : 1e9, ty = s > 1e-9 ? b/s : 1e9,
        p = c*cx + s*cy, q = cx*cx + cy*cy - rc*rc,
        tc = p + sqrt(max(0, p*p - q)))
    tx <= ty ? (s*tx <= cy ? tx : tc) : (c*ty <= cx ? ty : tc);
function secr(th, s, off) = (1 - s)*rr_r(th, a_i + off, b_i + off, oe_rc + off) + s*(R_i + off);

// Stationen: [Mittelpunkt, u-Achse, Verlauf s]
function stationen(y_start) = concat(
    [[[0, y_start, pocket_dz], [1, 0, 0], 0]],
    [for (i = [0 : M1]) let(t = i/M1, s = ss(t))
        [[x_ax*s, pl_t + lt*t, pocket_dz + (z_ax - pocket_dz)*s], [1, 0, 0], s]],
    [for (j = [1 : M2 - 1]) let(f = j*90/M2)
        [[x_ax - rb*(1 - cos(f)), yb0 + rb*sin(f), z_ax], [cos(f), sin(f), 0], 1]],
    [[[x_b, y_ax, z_ax], [0, 1, 0], 1]]
);

module sweep(st, off, verl_ende = 0) {
    st2 = verl_ende > 0
        ? concat(st, [[[x_b - verl_ende, y_ax, z_ax], [0, 1, 0], 1]])
        : st;
    m = len(st2);
    pts = [for (k = [0 : m - 1]) for (j = [0 : NR - 1])
        let(th = j*360/NR, r = secr(th, st2[k][2], off))
        st2[k][0] + r*cos(th)*st2[k][1] + [0, 0, r*sin(th)]];
    faces = concat(
        [for (k = [0 : m - 2]) for (j = [0 : NR - 1])
            let(a = k*NR + j, b = k*NR + (j + 1)%NR, c = (k + 1)*NR + (j + 1)%NR, d = (k + 1)*NR + j)
            each [[a, c, b], [a, d, c]]],
        [[for (j = [0 : NR - 1]) j]],
        [[for (j = [NR - 1 : -1 : 0]) (m - 1)*NR + j]]
    );
    polyhedron(pts, faces, convexity = 6);
}

// ---------------- Platte ----------------
module platte() {
    difference() {
        translate([-pl_w/2, 0, -pl_h/2]) cube([pl_w, pl_t, pl_h]);
        for (sx = [-1, 1], sz = [-1, 1])
            hull() for (dz = [-(slot_l - slot_b)/2, (slot_l - slot_b)/2])
                translate([sx*slot_dx/2, -1, sz*slot_dz/2 + dz]) rotate([-90, 0, 0]) cylinder(d = slot_b, h = pl_t + 2, $fn = 32);
    }
}

// ---------------- Enden ----------------
module muffe_koerper() {
    translate([x_b + muffe_grund, y_ax, z_ax]) rotate([0, -90, 0]) cylinder(d = muffe_od, h = muffe_l + muffe_grund, $fn = 180);
}
module muffe_bohrung() {
    translate([x_b + 0.0, y_ax, z_ax]) rotate([0, -90, 0]) translate([0, 0, -0.0]) cylinder(d = muffe_id, h = muffe_l + 1, $fn = 180);
    if (muffe_nut)
        translate([x_mund + muffe_nut_von, y_ax, z_ax]) rotate([0, -90, 0])
            rotate_extrude($fn = 180) translate([muffe_id/2 - 0.1, -(oring_muffe_d + 0.4)/2]) square([muffe_nut_t + 0.1, oring_muffe_d + 0.4]);
}
module magnet_ende() {
    translate([x_flansch, y_ax, z_ax]) rotate([0, 90, 0])
        mag_flange(flange110_t, n_mag_110, R110, lobe110, body110_r, 90, gr110, groove_depth_mag, 1, 0, 0, false, 0, 0, pr110);
}

module anschluss() {
    st_i = stationen(-1);
    st_a = stationen(pl_t/2);
    difference() {
        union() {
            platte();
            sweep(st_a, wand);
            if (ende == "muffe") muffe_koerper(); else magnet_ende();
        }
        sweep(st_i, 0, ende == "muffe" ? 0 : flange110_t + 1);
        if (ende == "muffe") muffe_bohrung();
    }
}

// TPU-O-Ring fuer die Muffen-Nut: Mittenradius so, dass die Schnur auf dem Nutgrund liegt
module oring_muffe() oring(muffe_id/2 + muffe_nut_t - oring_muffe_d/2, oring_muffe_d);

if (ausgabe == "druck")          rotate([90, 0, 0]) anschluss();
else if (ausgabe == "montiert")  anschluss();
else if (ausgabe == "oring")     oring_muffe();

echo(str("K40-Anschluss: Achse ", y_ax, " mm von der Rueckwand, Bogenende bei x = ", x_b,
         " (Pocketkante links bei x = ", -pocket_w/2, "), Ende bei x = ", x_ende,
         ende == "muffe" ? str(", Muffe ", muffe_l, " tief, Kastenkonus beginnt bei Einstecktiefe 20 / 15 / 10 bei x = ", x_b - 20 + 20 - 20, " / ", x_b - 25, " / ", x_b - 30)
                         : str(", Magnetflaeche bei x = ", x_flansch, ", Kastenkonus bei x = ", x_flansch - 20)));

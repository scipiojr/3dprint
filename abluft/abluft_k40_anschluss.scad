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
//  Ausgangsrichtung (beide Enden): stufenlos einstellbar mit aus_yaw (Waagerechte gegen die x-Achse) und aus_pitch
//  (Neigung nach oben/unten, Drehung um die y-Achse). 0/0 = 90 Grad nach links, parallel zur Wand.
//
//  Koordinaten (montiert): x nach RECHTS (von hinten auf den Laser gesehen), z nach oben, y von der Rueckwand
//  WEG. Ursprung: Mitte der Platte auf der Rueckwand (Platte y = 0 .. pl_t). Strömung: +y, dann Bogen nach -x.
//
//  ausgabe:  "druck" (Platte flach auf dem Druckbett, Rueckwandseite unten, Stuetzen unter dem Bogen noetig)
//            | "montiert" (Weltlage) | "oring" (TPU-Ring) | "info"
//  Export:   werkzeuge/export_k40_anschluss.sh
//
//  Herkunft der Maße: Lochbild und Ausschnitt aus den STL "VerticalExhaust-K40" (MakerWorld 1289939):
//  Schlitze 5 x 8, Abstand 145 x 113; Ausschnitt in der Rueckwand 124 x 124 (gemessen). Lage/Hoehe am Laser pruefen!
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
kopf_d = 0;                      // optionale Senkung fuer den Schraubenkopf (M4 Linsenkopf ISO 7380: ø8,4 passt); 0 = keine (Standard, mit M4x10 nicht noetig)
kopf_rest = 1.5;                 // Restdicke der Platte unter dem Kopf, nur bei kopf_d > 0
pocket_w = 124;                  // Ausschnitt in der Rueckwand, Breite
pocket_h = 124;                  // Ausschnitt in der Rueckwand, Hoehe (gemessen: 124 x 124)
pocket_dz = 0;                   // Mitte des Ausschnitts relativ zur Plattenmitte (+ = oben; angenommen mittig zwischen den Schlitzen)
rand = 2;                        // Abstand Oeffnung zu Ausschnittkante (Auflage der Platte rundum)
oe_rc = 10;                      // Eckenradius der Oeffnung

/* [Ausgangsrichtung] */
// aus_yaw: Winkel des Ausgangs in der Waagerechten gegen die x-Achse (Draufsicht). 0 = parallel zur Wand nach links (-x);
//          + = schraeg von der Wand WEG (kleinerer Bogen, spart Platz in x); - = zur Wand hin (groesserer Bogen)
aus_yaw = 0;                     // [-45:1:80]
// aus_pitch: Neigung des Ausgangs nach oben (+) oder unten (-), Drehung um die y-Achse (Betrag max. 70)
aus_pitch = 0;                   // [-70:1:70]

/* [Luftweg] */
bore_d = 90;                     // Durchmesser des runden Luftkanals (wie der 100er Magnetflansch)
wand = 2.4;                      // Wandstaerke des Kanals
rb = 50;                         // Biegeradius der Kanalmitte (min. bore_d/2 + wand + 2 = 49,4)
x_ax = 10;                       // Lage der Rundachse in x (+ = nach rechts, spart Laenge nach links; max. ca. 12, sonst ragt der Kanal ueber die Oeffnung)
z_ax = 0;                        // Hoehe der Rundachse am Bogenanfang relativ zur Plattenmitte (Hoehe des Kastens: Fuesschen)

/* [Filterkasten (Maße aus abluft_filterkasten.scad)] */
kasten_w = 169.8;                // box_w
scharnier_ueber = 9;             // hinge_y - box_w: Scharnierachse ausserhalb der Kastenwand
scharnier_frei = 20;             // Abstand Scharnierachse zur Laserrueckwand (Deckel offen 90 Grad: 12,5 mm + Reserve)
// y_ax: Abstand des Bogenendes (Anschlusspunkt, Kastenachse) von der Rueckwand. Standard fuer aus_yaw = 0:
// Achse bis Scharnierachse + Freiraum. Bei anderen Winkeln liegt der Kasten schraeg: y_ax selbst anpassen und
// werkzeuge/pruefung_k40_anschluss.py laufen lassen (Abstand zur Rueckwand, Kollision).
y_ax = kasten_w/2 + scharnier_ueber + scharnier_frei;

/* [Muffe auf den Einlass-Stutzen] */
stutzen_d = 98.7;                // Aussendurchmesser des gedruckten Stutzens am Filterkasten (gemessen; Modell 100)
muffe_spiel = 0.8;               // gewuenschtes Durchmesserspiel nach dem Druck
muffe_korr = 3.6;                // Druckkorrektur: die Muffe (Modell-ID 100,5) wurde mit 96,9 mm gemessen, also 3,6 mm zu eng
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
muffe_id = stutzen_d + muffe_spiel + muffe_korr;   // Modell-Innendurchmesser 103,1 -> gedruckt ca. 99,5
muffe_od = muffe_id + 2*muffe_wand;

// Richtung: Start +y (aus der Wand), Ende t_out; ebener Bogen vom Radius rb dazwischen
t0 = [0, 1, 0];
t_out = [-cos(aus_pitch)*cos(aus_yaw), cos(aus_pitch)*sin(aus_yaw), sin(aus_pitch)];
beta = acos(max(-1, min(1, t_out[1])));                     // Bogenwinkel (90 bei 0/0)
sb = sin(beta);
mm = sb > 1e-4 ? (t_out - t_out[1]*t0)/sb : [-1, 0, 0];     // Einheitsvektor im Bogen, quer zu t0, zum Ausgang hin
nax = cross(t0, mm);                                        // Drehachse des Bogens
function rot_ax(ang, v) = v*cos(ang) + cross(nax, v)*sin(ang) + nax*(nax*v)*(1 - cos(ang));
y0 = y_ax - rb*sb;               // Bogenbeginn (y)
lt = y0 - pl_t;                  // Laenge des Uebergangs
p0 = [x_ax, y0, z_ax];
E = p0 + rb*(sb*t0 + (1 - cos(beta))*mm);                   // Bogenende = Anschlusspunkt (Muffengrund / Flanschrueckseite)
u_e = rot_ax(beta, [1, 0, 0]);
v_e = rot_ax(beta, [0, 0, 1]);
// Waagerechter Bezugsrahmen der Enden (Z = Ausgangsrichtung, x = "oben", y = waagerecht): bei 0/0 wie bisher
u_h = cross(t_out, [0, 0, 1]) / norm(cross(t_out, [0, 0, 1]));
v_h = cross(u_h, t_out);
Mend = [[v_h[0], u_h[0], t_out[0], E[0]], [v_h[1], u_h[1], t_out[1], E[1]], [v_h[2], u_h[2], t_out[2], E[2]], [0, 0, 0, 1]];
Mb = max(2, ceil(M2*beta/90));

// ---------------- Querschnitt: abgerundetes Rechteck -> Kreis ----------------
function ss(t) = t*t*(3 - 2*t);
function rr_r(th, a, b, rc) =
    let(c = abs(cos(th)), s = abs(sin(th)), cx = a - rc, cy = b - rc,
        tx = c > 1e-9 ? a/c : 1e9, ty = s > 1e-9 ? b/s : 1e9,
        p = c*cx + s*cy, q = cx*cx + cy*cy - rc*rc,
        tc = p + sqrt(max(0, p*p - q)))
    tx <= ty ? (s*tx <= cy ? tx : tc) : (c*ty <= cx ? ty : tc);
function secr(th, s, off) = (1 - s)*rr_r(th, a_i + off, b_i + off, oe_rc + off) + s*(R_i + off);

// Stationen: [Mittelpunkt, u-Achse, v-Achse, Verlauf s]; ext = Verlaengerung ueber das Bogenende (in Ausgangsrichtung)
function stationen(y_start, ext) = concat(
    [[[0, y_start, pocket_dz], [1, 0, 0], [0, 0, 1], 0]],
    [for (i = [0 : M1]) let(t = i/M1, s = ss(t))
        [[x_ax*s, pl_t + lt*t, pocket_dz + (z_ax - pocket_dz)*s], [1, 0, 0], [0, 0, 1], s]],
    [for (j = [1 : Mb - 1]) let(f = j*beta/Mb)
        [p0 + rb*(sin(f)*t0 + (1 - cos(f))*mm), rot_ax(f, [1, 0, 0]), rot_ax(f, [0, 0, 1]), 1]],
    [[E, u_e, v_e, 1]],
    ext > 0 ? [[E + ext*t_out, u_e, v_e, 1]] : []
);

module sweep(st, off) {
    m = len(st);
    pts = [for (k = [0 : m - 1]) for (j = [0 : NR - 1])
        let(th = j*360/NR, r = secr(th, st[k][3], off))
        st[k][0] + r*cos(th)*st[k][1] + r*sin(th)*st[k][2]];
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
        if (kopf_d > 0)
            for (sx = [-1, 1], sz = [-1, 1])
                hull() for (dz = [-(slot_l - slot_b)/2, (slot_l - slot_b)/2])
                    translate([sx*slot_dx/2, kopf_rest, sz*slot_dz/2 + dz]) rotate([-90, 0, 0]) cylinder(d = kopf_d, h = pl_t, $fn = 48);
    }
}

// ---------------- Enden (lokaler Rahmen: z = Ausgangsrichtung, Ursprung = Bogenende E) ----------------
// Der Muffengrund liegt 0,07 mm vor dem letzten Kanalquerschnitt (E): bei schraegen Winkeln waeren beide Ebenen sonst
// bis auf Rundungsfehler deckungsgleich und es entstuende eine nicht-manifolde Kante.
mg = 0.07;
module muffe_koerper() translate([0, 0, -muffe_grund]) cylinder(d = muffe_od, h = muffe_l + muffe_grund + mg, $fn = 180);
module muffe_bohrung() {
    translate([0, 0, mg]) cylinder(d = muffe_id, h = muffe_l + 1, $fn = 180);
    if (muffe_nut)
        translate([0, 0, mg + muffe_l - muffe_nut_von]) rotate_extrude($fn = 180)
            translate([muffe_id/2 - 0.1, -(oring_muffe_d + 0.4)/2]) square([muffe_nut_t + 0.1, oring_muffe_d + 0.4]);
}
// Magnetflansch: Magnetflaeche bei z = flange110_t (zeigt in Ausgangsrichtung), Koerper z = -0,5 .. flange110_t
module magnet_ende()
    translate([0, 0, flange110_t]) rotate([0, 180, 0])
        mag_flange(flange110_t + 0.5, n_mag_110, R110, lobe110, body110_r, 90, gr110, groove_depth_mag, 1, 0, 0, false, 0, 0, pr110);

// ---------------- Nase: Stuetzrippe von der Platte unter das Bogenende (druckt ohne Stuetzen) ----------------
// Liegt in der Bogenebene (Rippe in a = Druck-hoch, b = Richtung der Kruemmung), Querschnitt V-foermig: unten nase_d breit,
// Flanken 45 Grad bis nase_breite. Der Kanal wird danach herausgeschnitten, sichtbar bleibt nur der Teil ausserhalb der Wand.
nase = true;                     // Nase an/aus
nase_d = 6;                      // Breite der Rippe an der Platte
nase_breite = 50;                // Breite oben (unter dem Bogenende); 45-Grad-Flanken, oben senkrecht
module nase() {
    bk = (ende == "muffe") ? muffe_grund : 0;
    ml = (ende == "muffe") ? muffe_l + mg : flange110_t;
    Rm = (ende == "muffe") ? muffe_od/2 : body110_r;
    Ea = rb*sb;  Eb = rb*(1 - cos(beta));
    tb = sb;  ta = t_out[1];  n = [ta, -tb];
    P1 = [Eb - bk*tb + Rm*n[0], Ea - bk*ta + Rm*n[1]];
    P2 = [Eb + (ml - 0.6)*tb + (Rm - 0.3)*n[0], Ea + (ml - 0.6)*ta + (Rm - 0.3)*n[1]];   // knapp innerhalb der Endflaeche (keine deckungsgleichen Flaechen)
    a_pl = pl_t/2 - y0;  b0 = Eb - 10;
    hw = nase_breite/2;  hd = nase_d/2;  hh = hw - hd;            // Hoehe, bis die 45-Grad-Flanke die volle Breite erreicht
    if (P1[1] > a_pl + 5 && P2[1] > a_pl + 5)
    multmatrix([[mm[0], t0[0], -nax[0], p0[0]], [mm[1], t0[1], -nax[1], p0[1]], [mm[2], t0[2], -nax[2], p0[2]], [0, 0, 0, 1]])
    intersection() {
        linear_extrude(height = nase_breite + 2, center = true) hull() polygon([[b0, a_pl], [b0, P1[1]], P1, P2, [P2[0], a_pl]]);
        translate([b0 - 1, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = max(P2[0], P1[0]) - b0 + 2)
            polygon([[a_pl, -hd], [a_pl, hd], [a_pl + hh, hw], [a_pl + 200, hw], [a_pl + 200, -hw], [a_pl + hh, -hw]]);
    }
}

module anschluss() {
    difference() {
        union() {
            platte();
            sweep(stationen(pl_t/2, 1), wand);
            multmatrix(Mend) { if (ende == "muffe") muffe_koerper(); else magnet_ende(); }
            if (nase) nase();
        }
        sweep(stationen(-1, ende == "muffe" ? 1 : flange110_t + 1), 0);
        if (ende == "muffe") multmatrix(Mend) muffe_bohrung();
    }
}

// TPU-O-Ring fuer die Muffen-Nut: Mittenradius so, dass die Schnur auf dem Nutgrund liegt
module oring_muffe() oring(muffe_id/2 + muffe_nut_t - oring_muffe_d/2, oring_muffe_d);

if (ausgabe == "druck")          rotate([90, 0, 0]) anschluss();
else if (ausgabe == "montiert")  anschluss();
else if (ausgabe == "oring")     oring_muffe();

ende_r = ende == "muffe" ? muffe_od/2 : 76.5;               // Radius des Endstuecks in der Flanschebene
echo(str("K40-Anschluss: Bogenwinkel ", round(beta*10)/10, " Grad, Ausgangsrichtung ", t_out, ", Bogenende E = ", E,
         ", Bogenbeginn y = ", y0, ", Uebergang ", round(lt*10)/10, " mm lang"));
echo(str("ENDE E=", E, " T=", t_out, " U=", u_h, " V=", v_h));
if (lt < 5) echo("WARNUNG: Uebergang kuerzer als 5 mm (y_ax zu klein fuer rb/Winkel)");
if (E[1] - ende_r*sb < pl_t + 2) echo("WARNUNG: Endstueck ragt in die Rueckwand (y_ax vergroessern oder aus_yaw erhoehen)");
if (abs(aus_pitch) > 70) echo("WARNUNG: aus_pitch ueber 70 Grad nicht unterstuetzt");

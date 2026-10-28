// =====================================================================
//  Abluft-System: Fensterkanal.   OpenSCAD 2021.01 oder neuer.
//
//  Aufbau (alles ein durchgehender Luftkanal, Wandstaerke fk_wall):
//    150er Magnetflansch (wie Verjuengung/Adapter des Abluft-Systems, passt auf die Durchfuehrung)
//      -> Rundrohr  fk_L1  -> Bogen fk_angle Grad (Radius fk_bend_r) -> Rundrohr
//      -> Uebergang (Loft) rund -> flach  -> Flachkanal (Rechteck, abgerundete Ecken, Stuetzstege)
//    Zwischen Bogenende und Kanalende liegen insgesamt fk_after_total mm.
//    Der Flachkanal darf asymmetrisch zur Rohrachse sein (fk_WL links, fk_WR rechts, fk_H hoch).
//
//  Ausgabe ("ausgabe"):
//    "gesamt"  Vorschau des ganzen Kanals in einem Stueck (nicht druckbar, wenn er den Druckraum ueberschreitet)
//    "info"    nur Konsolenausgabe: Querschnittspruefung, Teileplan fuer den Druckraum fk_bed
//    "montage" alle Teile in Einbaulage, eingefaerbt (Vorschau);  "montiert" nur Teil teil_nr in Einbaulage (zur Pruefung)
//    "teil"    Druckteil Nr. teil_nr (1 ... Anzahl laut "info"); Teile werden automatisch so geteilt,
//              dass jedes in den Druckraum passt, und bekommen Steckverbindungen zum Verkleben:
//                - Laengsstoss: Spigot (duenne Huelse, Laenge fk_joint_len) am Ende, Muffe am Anfang des Folgeteils
//                - Breitenstoss (Flachkanal breiter als Druckraum): Ueberlappung (Halbwand-Falz) in der Teilungsebene
//
//  Alle Masse in mm. Geplante Druckrichtung: Rundteile und Uebergang stehend auf der Stossflaeche,
//  Flachkanal-Teile flach liegend (Stege senkrecht, stuetzen die Decke).
//  Siehe README.md ("Fensterkanal") und agent.md.
// =====================================================================

include <abluft_system.scad>
part = "keiner";            // Hauptdatei: keine eigene Ausgabe (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe  = "gesamt";        // gesamt | info | teil
teil_nr  = 1;               // bei ausgabe="teil": Nummer des Teils (Liste mit ausgabe="info")

/* [Rundkanal und Winkel] */
fk_wall      = 2.8;         // Wandstaerke (rund und flach); Rundrohr innen = bore_d (Hauptdatei, 140)
fk_L1        = 40;          // gerades Rohr zwischen 150er-Flansch und Bogen
fk_angle     = 90;          // Winkel des Bogens in Grad (0 = kein Bogen)
fk_bend_r    = 100;         // Biegeradius der Mittellinie

/* [Flachkanal] */
fk_after_total = 300;       // Gesamtstrecke vom Bogenende bis zum Ende des Auslasses (Rohr + Uebergang + Flachkanal)
fk_trans     = 120;         // Laenge des Uebergangs rund -> flach
fk_flat_len  = 100;         // Laenge des Flachkanals am Ende (Rest der Strecke = gerades Rohr vor dem Uebergang)
fk_H         = 75;          // Aussenhoehe des Flachkanals
fk_WL        = 125;         // Breite links der Rohrachse (aussen); Gesamtbreite <= Druckraum - Steckverbindung = ein Stueck
fk_WR        = 120;         // Breite rechts der Rohrachse (aussen)
fk_corner_r  = 6;           // Aussen-Eckenradius des Flachkanals
fk_flat_in_plane = false;   // false: Breite quer zur Bogenebene, true: Breite in der Bogenebene
fk_rib_t     = 2.0;         // Stegdicke
fk_rib_pitch = 50;          // gewuenschter Stegabstand (Anzahl = Breite / Abstand - 1)

/* [Druckraum und Verbindungen] */
fk_bed       = [260, 260, 260];  // Druckraum x, y, z
fk_joint_len = 12;          // Laenge der Steckverbindungen (Spigot/Muffe/Falz)
fk_joint_gap = 0.25;        // Spiel in den Steckverbindungen (Klebespalt)
fk_n         = 180;         // Punkte pro Querschnittsring

// ---------------- abgeleitete Groessen ----------------
fk_L2   = fk_after_total - fk_trans - fk_flat_len;      // gerades Rundrohr nach dem Bogen
Rout    = bore_r + fk_wall;
Larc    = fk_angle > 0 ? fk_bend_r * fk_angle * PI / 180 : 0;
S_b0    = fk_L1;
S_b1    = S_b0 + Larc;
S_L0    = S_b1 + fk_L2;
S_F0    = S_L0 + fk_trans;
S_END   = S_F0 + fk_flat_len;
W_tot   = fk_WL + fk_WR;
jl      = fk_joint_len;
hw      = fk_wall / 2;
EPS     = 1e-6;

// Querschnittspruefung
A_round = PI * bore_r * bore_r;
Win     = W_tot - 2 * fk_wall;
Hin     = fk_H - 2 * fk_wall;
n_ribs  = max(0, round(Win / fk_rib_pitch) - 1);
A_flat  = Win * Hin - (4 - PI) * pow(max(0.3, fk_corner_r - fk_wall), 2) - n_ribs * fk_rib_t * Hin;
wlim    = max(fk_bed[0], fk_bed[1]) - jl - 1;           // nutzbare Breite pro Teil
ncol    = W_tot > wlim ? ceil(W_tot / wlim) : 1;

echo(str("Querschnitt: rund innen ", round(A_round), " mm2 (d=", bore_d, "), flach innen ", round(A_flat),
         " mm2 (", n_ribs, " Stege) = ", round(100 * A_flat / A_round), " %"));
if (A_flat < A_round)
    echo("WARNUNG: Querschnitt des Flachkanals ist KLEINER als der des Rundkanals -> Stroemungswiderstand/Druckverlust. Hoehe oder Breite vergroessern.");
if (fk_L2 < 0)
    echo("FEHLER: fk_after_total ist kleiner als fk_trans + fk_flat_len (Rohrstueck vor dem Uebergang waere negativ).");
if (fk_angle > 0 && fk_bend_r < Rout + 10)
    echo("WARNUNG: Biegeradius zu klein fuer den Rohrdurchmesser (mindestens Aussenradius + 10).");
if (atan((max(fk_WL, fk_WR) - Rout) / max(fk_trans, 1)) > 45)
    echo("WARNUNG: Uebergang sehr steil (>45 Grad Ueberhang beim Druck) -> fk_trans vergroessern.");
if (fk_corner_r < fk_wall + 1)
    echo("WARNUNG: fk_corner_r sollte mindestens fk_wall + 1 sein.");

// ---------------- Hilfsfunktionen ----------------
function sm(t) = let(u = min(1, max(0, t))) u * u * (3 - 2 * u);
function dedup(l) = [for (i = [0 : len(l) - 1]) if (i == 0 || l[i] - l[i - 1] > EPS) l[i]];
function lin(a, b, n) = n > 1 ? [for (j = [1 : n - 1]) a + (b - a) * j / n] : [];

K = dedup(concat([0, S_b0],
                 fk_angle > 0 ? lin(S_b0, S_b1, ceil(fk_angle / 4)) : [],
                 [S_b1, S_L0],
                 lin(S_L0, S_F0, max(1, ceil(fk_trans / 5))),
                 [S_F0, S_END]));
// Stuetzstellen (Ringe) zwischen a und b, einschliesslich a und b
function knots(a, b) = concat([a], [for (k = K) if (k > a + EPS && k < b - EPS) k], [b]);

function tt(s) = fk_trans > 0 ? sm((s - S_L0) / fk_trans) : (s >= S_L0 ? 1 : 0);

// Rahmen der Mittellinie bei s: [Position, e1 (in der Bogenebene, quer zur Achse), Tangente]
function frame(s) =
    s <= S_b0 ? [[0, 0, s], [1, 0, 0], [0, 0, 1]] :
    s <= S_b1 ? let(f = (s - S_b0) / fk_bend_r * 180 / PI)
                [[fk_bend_r * (1 - cos(f)), 0, S_b0 + fk_bend_r * sin(f)], [cos(f), 0, -sin(f)], [sin(f), 0, cos(f)]] :
    let(a = fk_angle, Pe = [fk_bend_r * (1 - cos(a)), 0, S_b0 + fk_bend_r * sin(a)],
        t = [sin(a), 0, cos(a)], e1 = [cos(a), 0, -sin(a)])
    [Pe + t * (s - S_b1), e1, t];

// Treffer eines Strahls vom Ursprung (Winkel th) auf ein Rechteck mit abgerundeten Ecken
function rect_hit(th, hl, hr, hh, rc) =
    let(dx = cos(th), dy = sin(th),
        tx = abs(dx) < 1e-9 ? 1e9 : (dx > 0 ? hr / dx : -hl / dx),
        ty = abs(dy) < 1e-9 ? 1e9 : hh / abs(dy),
        t0 = min(tx, ty), px = t0 * dx, py = t0 * dy,
        cx = px > 0 ? hr - rc : -(hl - rc),
        cy = py > 0 ? hh - rc : -(hh - rc),
        incorner = rc > 0 && (px > 0 ? px > hr - rc : px < -(hl - rc)) && abs(py) > hh - rc,
        dc = dx * cx + dy * cy,
        tc = dc + sqrt(max(0, dc * dc - (cx * cx + cy * cy) + rc * rc)))
    incorner ? [tc * dx, tc * dy] : [px, py];

// Querschnittspunkt (a = Breite, b = Hoehe) zum Winkel th, Mischung t (0 rund, 1 flach), Abstand off nach innen
function outline(th, t, off) =
    let(r = Rout - off, c = [r * cos(th), r * sin(th)],
        q = t > 0 ? rect_hit(th, fk_WL - off, fk_WR - off, fk_H / 2 - off, max(0.3, fk_corner_r - off)) : c)
    t > 0 ? (1 - t) * c + t * q : c;

function w3(o, fr) = fk_flat_in_plane ? o[0] * fr[1] + o[1] * [0, 1, 0] : o[0] * [0, 1, 0] - o[1] * fr[1];

// Punkt im lokalen Rahmen des Teils (Start s0, Achse = +z). exact: gerade Strecke -> exakte Koordinaten
function lpt(s, off, i, s0, exact) =
    let(o = outline(360 * i / fk_n, tt(s), off))
    exact ? (fk_flat_in_plane ? [o[0], o[1], s - s0] : [-o[1], o[0], s - s0])
          : let(fr = frame(s), f0 = frame(s0), v = fr[0] - f0[0] + w3(o, fr))
            [v * f0[1], v[1], v * f0[2]];
function ringpts(list, s0, ex) = [for (r = list) for (i = [0 : fk_n - 1]) lpt(r[0], r[1], i, s0, ex)];

// Schalenkoerper aus Ringen: ol = Aussenringe [[s, off], ...], il = Innenringe
module sweep(ol, il, s0, ex) {
    N = fk_n; Ko = len(ol); Ki = len(il);
    pts = concat(ringpts(ol, s0, ex), ringpts(il, s0, ex));
    oI = Ko * N;
    faces = concat(
        [for (k = [0 : Ko - 2], i = [0 : N - 1]) each let(j = (i + 1) % N, a = k * N + i, b = k * N + j, c = (k + 1) * N + j, d = (k + 1) * N + i) [[a, d, c], [a, c, b]]],
        [for (k = [0 : Ki - 2], i = [0 : N - 1]) each let(j = (i + 1) % N, a = oI + k * N + i, b = oI + k * N + j, c = oI + (k + 1) * N + j, d = oI + (k + 1) * N + i) [[a, b, c], [a, c, d]]],
        [for (i = [0 : N - 1]) each let(j = (i + 1) % N) [[i, j, oI + j], [i, oI + j, oI + i]]],
        [for (i = [0 : N - 1]) each let(j = (i + 1) % N, o = (Ko - 1) * N, q = oI + (Ki - 1) * N) [[o + i, q + j, o + j], [o + i, q + i, q + j]]]);
    polyhedron(pts, faces, convexity = 10);
}

// Hohlteil s0..s1; sock: Muffe am Anfang, spig: Spigot (verlaengert um jl) am Ende
module p_hollow(s0, s1, sock, spig) {
    ex  = s0 >= S_b1 - EPS;
    s1e = spig ? s1 + jl : s1;
    ol = concat([for (k = knots(s0, s1)) [k, 0]], spig ? [for (k = knots(s1, s1e)) [k, hw]] : []);
    il = concat(sock ? [for (k = knots(s0, s0 + jl)) [k, hw - fk_joint_gap]] : [],
                [for (k = knots(sock ? s0 + jl : s0, s1e)) [k, fk_wall]]);
    sweep(ol, il, s0, ex);
}
// Schicht zwischen Innenflaeche und off_a (fuer Falz: Zunge und Aussparung)
module p_layer(sa, sb, s0, off_a) {
    sweep([for (k = knots(sa, sb)) [k, off_a]], [for (k = knots(sa, sb)) [k, fk_wall]], s0, s0 >= S_b1 - EPS);
}

// ---------------- Stege und Teilung ----------------
rib_all = n_ribs > 0 ? [for (k = [1 : n_ribs]) -fk_WL + fk_wall + k * Win / (n_ribs + 1)] : [];
function seam(k) = -fk_WL + k * W_tot / ncol;
function rib_ok(a) = ncol < 2 || len([for (k = [1 : ncol - 1]) if (a > seam(k) - fk_rib_t / 2 - 1 && a < seam(k) + jl + fk_joint_gap + fk_rib_t / 2 + 1) 1]) == 0;

module ribs_local(s0, sa, sb, lo, hi, filt) {
    hh = fk_H / 2 - fk_wall + 0.8;      // 0,8 mm in Ober-/Unterwand eingebettet
    for (a = rib_all) if (a > lo && a < hi && (!filt || rib_ok(a)))
        if (fk_flat_in_plane) translate([a - fk_rib_t / 2, -hh, sa - s0]) cube([fk_rib_t, 2 * hh, sb - sa]);
        else translate([-hh, a - fk_rib_t / 2, sa - s0]) cube([2 * hh, fk_rib_t, sb - sa]);
}
module strip(a1, a2) {
    if (fk_flat_in_plane) translate([a1, -3000, -3000]) cube([a2 - a1, 6000, 6000]);
    else translate([-3000, a1, -3000]) cube([6000, a2 - a1, 6000]);
}

// Teilkoerper im lokalen Rahmen: Laengs-Steckverbindung + Breiten-Falz (Spalte lo..hi) + Stege
module piece_body(s0, s1, sock, spig, lo, hi, wide, flat) {
    sT = sock ? s0 + jl : s0;
    difference() {
        union() {
            if (wide) intersection() { p_hollow(s0, s1, sock, spig); strip(lo, hi); }
            else p_hollow(s0, s1, sock, spig);
            if (wide && hi < 1000) intersection() { p_layer(sT, s1, s0, hw); strip(hi, hi + jl); }          // Zunge
            if (flat) ribs_local(s0, sT, s1, lo, hi, wide);
        }
        if (wide && lo > -1000) intersection() { p_layer(sT, s1, s0, hw - fk_joint_gap); strip(lo, lo + jl + fk_joint_gap); }   // Aussparung
    }
}

// ---------------- Teileplan ----------------
function fit2(u, v, x, y) = (u <= x && v <= y) || (u <= y && v <= x);
function eaL(s) = let(t = tt(s)) (1 - t) * Rout + t * fk_WL;
function eaR(s) = let(t = tt(s)) (1 - t) * Rout + t * fk_WR;
function ebb(s) = let(t = tt(s)) (1 - t) * Rout + t * fk_H / 2;
function cpts(s) = let(fr = frame(s), A = fk_flat_in_plane ? fr[1] : [0, 1, 0], B = fk_flat_in_plane ? [0, 1, 0] : -fr[1])
    [for (sa = [-eaL(s), eaR(s)], sb = [-ebb(s), ebb(s)]) fr[0] + sa * A + sb * B];

// Teile stehen auf der Stossflaeche (Achse = z); nur Flachkanal-Teile liegen, wenn sie stehend nicht passen
// oder in Spalten geteilt werden muessen
function fits(s0, c) =
    let(spig = c < S_END - EPS, s1e = spig ? min(c + jl, S_END) : c, bx = fk_bed[0], by = fk_bed[1], bz = fk_bed[2])
    (ncol > 1 && s0 >= S_L0 - EPS) ?
        let(len_ = s1e - s0, cw = W_tot / ncol + jl, bh = 2 * ebb(s1e))
        (s0 >= S_F0 - EPS ? (bh <= bz && fit2(cw, len_, bx, by)) : (len_ <= bz && fit2(cw, bh, bx, by)))
    : (fits_stand(s0, s1e) || (s0 >= S_F0 - EPS && fits_lying(s0, s1e)));
function fits_lying(s0, s1e) = let(bh = 2 * ebb(s1e)) bh <= fk_bed[2] && fit2(eaL(s1e) + eaR(s1e), s1e - s0, fk_bed[0], fk_bed[1]);
function fits_stand(s0, s1e) =
    let(bx = fk_bed[0], by = fk_bed[1], bz = fk_bed[2])
        let(f0 = frame(s0),
            lp = concat(s0 < EPS ? [for (x = [-101.5, 101.5], y = [-101.5, 101.5]) [x, y, -adapter_t]] : [],
                        [for (s = knots(s0, s1e)) for (p = cpts(s)) let(v = p - f0[0]) [v * f0[1], v[1], v * f0[2]]]),
            ex_ = max([for (p = lp) p[0]]) - min([for (p = lp) p[0]]),
            ey_ = max([for (p = lp) p[1]]) - min([for (p = lp) p[1]]),
            ez_ = max([for (p = lp) p[2]]) - min([for (p = lp) p[2]]))
        ez_ <= bz && fit2(ex_, ey_, bx, by);

function bound_next(s0) = ncol < 2 ? S_END : (s0 < S_L0 - EPS ? S_L0 : (s0 < S_F0 - EPS ? S_F0 : S_END));
function best(s0, j, B, last) =
    let(c = min(s0 + 5 * j, B), ok = fits(s0, c))
    !ok ? (last < 0 ? min(s0 + 5, B) : last)
        : (c >= B - EPS ? c : best(s0, j + 1, B, (B - c >= 3 * jl) ? c : last));
function plan(s0) = s0 >= S_END - EPS ? [] :
    let(B = bound_next(s0), s1 = best(s0, 1, B, -1)) concat([[s0, s1]], plan(s1));

RNG = plan(0);
PL = [for (r = RNG) each (r[0] >= S_L0 - EPS && ncol > 1 ? [for (j = [0 : ncol - 1]) [r[0], r[1], j]] : [[r[0], r[1], 0]])];

module report() {
    for (k = [0 : len(PL) - 1]) {
        p = PL[k];
        echo(str("Teil ", k + 1, ": s = ", round(p[0] * 10) / 10, " ... ", round(p[1] * 10) / 10,
                 p[0] >= S_F0 - EPS ? (ncol > 1 || !fits_stand(p[0], min(S_END, p[1] + jl)) ? " (Flachkanal, liegend" : " (Flachkanal, stehend") : (p[0] >= S_L0 - EPS ? " (Uebergang, stehend" : " (Rund, stehend"),
                 ncol > 1 && p[0] >= S_L0 - EPS ? str(", Spalte ", p[2] + 1, " von ", ncol) : "", ")"));
    }
    if (max(fk_bed[0], fk_bed[1]) < 204 || fk_bed[2] < adapter_t + 40)
        echo("WARNUNG: Der 150er-Magnetflansch (ca. 203 mm breit) passt nicht in den Druckraum.");
    if (max(fk_bed[0], fk_bed[1]) < 204 || fk_bed[2] < adapter_t + 40)
        echo("WARNUNG: Der 150er-Magnetflansch (ca. 203 mm breit) passt nicht in den Druckraum.");
    echo(str("Anzahl Teile: ", len(PL), ";  Gesamtlaenge Mittellinie: ", round(S_END), " mm;  Druckraum ", fk_bed));
    echo(str("Zusaetzlich: gleiche TPU-Dichtungen wie das Abluft-System fuer die 150er-Flaeche (dichtung_150_anschluss_tpu.stl)."));
}

// ---------------- Ausgabe ----------------
module flange150() {
    mag_flange(adapter_t, n_mag_150, R150, lobe150, body150, lobe_offset_funnel, gr150_face, groove_depth_150, bore_r, 0, 0, true);
}

module piece(k) {
    p = PL[k]; s0 = p[0]; s1 = p[1]; j = p[2];
    sock = s0 > EPS; spig = s1 < S_END - EPS;
    wide = s0 >= S_L0 - EPS && ncol > 1;
    flat = s0 >= S_F0 - EPS;
    lo = (wide && j > 0) ? seam(j) : -2000;
    hi = (wide && j < ncol - 1) ? seam(j + 1) : 2000;
    lying = flat && (ncol > 1 || !fits_stand(s0, spig ? s1 + jl : s1));
    if (lying) {
        // liegend: x = Breite, y = -Achse, z = Hoehe
        M = fk_flat_in_plane ? [[1, 0, 0, 0], [0, 0, -1, 0], [0, 1, 0, 0], [0, 0, 0, 1]]
                             : [[0, 1, 0, 0], [0, 0, -1, 0], [-1, 0, 0, 0], [0, 0, 0, 1]];
        translate([-max(lo, -fk_WL), (spig ? s1 + jl : s1) - s0, fk_H / 2])
            multmatrix(M) piece_body(s0, s1, sock, spig, lo, hi, wide, true);
    } else if (s0 < EPS) {
        union() { flange150(); translate([0, 0, adapter_t]) piece_body(s0, s1, sock, spig, lo, hi, wide, s0 >= S_F0 - EPS); }
    } else piece_body(s0, s1, sock, spig, lo, hi, wide, s0 >= S_F0 - EPS);
}

// Teil in der Einbaulage (globale Koordinaten, Magnetflaeche des 150er-Flanschs auf z=0)
module piece_montiert(k) {
    p = PL[k]; s0 = p[0]; s1 = p[1]; j = p[2];
    wide = s0 >= S_L0 - EPS && ncol > 1;
    lo = (wide && j > 0) ? seam(j) : -2000;
    hi = (wide && j < ncol - 1) ? seam(j + 1) : 2000;
    fr = frame(s0);
    translate([0, 0, adapter_t])
        multmatrix([[fr[1][0], 0, fr[2][0], fr[0][0]], [fr[1][1], 1, fr[2][1], fr[0][1]], [fr[1][2], 0, fr[2][2], fr[0][2]], [0, 0, 0, 1]])
            piece_body(s0, s1, s0 > EPS, s1 < S_END - EPS, lo, hi, wide, s0 >= S_F0 - EPS);
    if (s0 < EPS) flange150();
}

module gesamt() {
    translate([0, 0, adapter_t]) {
        p_hollow(0, S_END, false, false);
        fr = frame(S_F0);
        multmatrix([[fr[1][0], 0, fr[2][0], fr[0][0]], [fr[1][1], 1, fr[2][1], fr[0][1]], [fr[1][2], 0, fr[2][2], fr[0][2]], [0, 0, 0, 1]])
            ribs_local(S_F0, S_F0, S_END, -2000, 2000, false);
    }
    flange150();
}

if (ausgabe == "info") report();
else if (ausgabe == "teil") piece(teil_nr - 1);
else if (ausgabe == "montiert") piece_montiert(teil_nr - 1);     // Pruefung: Teil in Einbaulage
else if (ausgabe == "montage") for (k = [0 : len(PL) - 1]) color([0.3 + 0.12 * k, 0.6, 1 - 0.1 * k]) piece_montiert(k);
else { report(); gesamt(); }

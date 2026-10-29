// =====================================================================
//  Abluft-System: Ausstroemer direkt (Keil ohne Bogen).   OpenSCAD 2021.01 oder neuer.
//
//  Der Kanal geht GERADE vom 150er-Magnetflansch zum flachen Ausstroemer am Dachfenster, ohne Rohr
//  und ohne Bogen. Er besteht nur aus ebenen Flaechen (rechteckiger Querschnitt, scharfe Kanten):
//    * Rund ist nur der 150er-Flansch (Bohrung bore_d). Der Keil sitzt direkt darauf; sein Anfang ist
//      schraeg an der Flanschflaeche abgeschnitten (bis zu 30 Grad ueber der Waagerechten am Flansch).
//    * Der Keil weitet sich bis S_F0 von ca. 150 mm auf die volle Breite (links m_s - m_margin,
//      rechts Rest) auf und von der Hoehe am Flansch auf die Spalthoehe m_gap (Verjuengung).
//    * Danach folgt der gerade Flachkanal (Laenge m_reach + m_frame_depth). Stroemungsstege verlaufen strahlenfoermig
//      im Keil und parallel im Flachkanal: sie verteilen die Luft ueber die Breite und stuetzen Ober- und Unterwand.
//  Lage am Fenster: die UNTERSEITE des Flachkanals liegt auf der Unterkante des Fensterrahmens (Punkt E,
//  gemessen mit der Ausmesshilfe: m_a, m_beta, m_h), das Fenster liegt auf dem Kanal. Der Kanal ragt
//  m_reach hinter E hinaus (Abtropfrand: mindestens 50 mm). Die Richtung ergibt sich aus der Geraden
//  Flansch -> E; ist E tiefer als der Flansch, zeigt der Kanal nach unten (Winkel > 90 Grad zur Achse).
//
//  Der Kanal wird in hoechstens fk_max_cols Spalten nebeneinander geteilt (Standard 3); ist das Fenster
//  breiter, wird der Kanal auf der breiten Seite gekuerzt (Warnung). Die Teile haben Steckverbindungen
//  (Spigot/Muffe laengs, Halbwand-Falz in der Breite) zum Verkleben. Teil 1 (mit Flansch) steht mit
//  der Flanschflaeche auf dem Druckbett (Stuetzen noetig), alle anderen Teile liegen flach.
//
//  Ausgabe ("ausgabe"): gesamt | info | teil (teil_nr) | montiert (teil_nr) | montage
//  Alle Masse in mm. Siehe README.md ("Ausstroemer direkt") und agent.md.
// =====================================================================

include <abluft_system.scad>
part = "keiner";            // Hauptdatei: keine eigene Ausgabe (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe  = "gesamt";        // gesamt | info | teil | montiert | montage
teil_nr  = 1;

/* [Messwerte vom Fenster (Ausmesshilfe, siehe README)] */
m_a          = 270;         // waagerechter Abstand Mittelstab -> Unterkante Fensterrahmen
m_beta       = 60;          // Winkel Mittelstab / Waagerechte (Dachneigung = 90 - m_beta)
m_h          = 10;          // Hoehe des Schnittpunkts auf dem Mittelstab ab Oberkante der Ausmesshilfe-Platte
m_plate_t    = 4.2;         // Plattendicke der Ausmesshilfe (0, wenn m_h ab Plattenunterseite gemessen)
m_s          = 120;         // Abstand Mittelstab -> seitlicher Fensterrand
m_s_side     = "links";     // Seite dieses Randes ("links"/"rechts"), von innen gesehen
m_B          = 1140;        // Gesamtbreite des Fensters
m_margin     = 10;          // Abstand des Kanals zum seitlichen Fensterrand
m_gap        = 30;          // Spalthoehe = Aussenhoehe des Flachkanals
m_reach      = 60;          // Ueberstand des Kanals hinter der Rahmenkante (Abtropfrand: >= 50)
m_frame_depth = 30;         // Strecke des Flachkanals innen bis zur Rahmenkante (Rahmen-/Fluegeltiefe)

/* [Kanal und Druck] */
fk_wall      = 2.8;         // Wandstaerke
fk_max_cols  = 3;           // hoechstens so viele Teile nebeneinander (0 = unbegrenzt); breiter wird gekuerzt
fk_rib_t     = 2.0;         // Stegdicke im Flachkanal
fk_rib_pitch = 50;          // gewuenschter Stegabstand
fk_bed       = [260, 260, 260];   // Druckraum x, y, z
fk_joint_len = 12;          // Laenge der Steckverbindungen
fk_joint_gap = 0.25;        // Spiel in den Steckverbindungen (Klebespalt)

EPS  = 1e-6;
CUT  = -1000;               // Kennung fuer den schraegen Anfangsschnitt an der Flanschflaeche
jl   = fk_joint_len;
hw   = fk_wall / 2;

// ---------------- Messwerte -> Geometrie ----------------
// Ebene x (waagerecht Richtung Dachkante) / z (Achse des Flanschs = senkrecht zur Scheibe), y = Breite.
phi_w = 90 - m_beta;
uF    = m_a * cos(phi_w);                                        // Rahmenkante E: Lage in Richtung Dachkante
zF    = m_plate_t + m_h + m_a * sin(phi_w) - adapter_t;          // und Hoehe ab Oberkante des 150er-Flanschs
function alpha_it(a, k) = k == 0 ? a : alpha_it(atan2(uF - (m_gap / 2) * cos(a), zF + (m_gap / 2) * sin(a)), k - 1);
al  = alpha_it(60, 25);                                          // Winkel der Mittellinie zur Flanschachse
ca  = cos(al);  sa = sin(al);
Cx  = uF - (m_gap / 2) * ca;  Cz = zF + (m_gap / 2) * sa;        // Kanalmitte ueber E (Unterseite liegt auf E)
sE  = sqrt(Cx * Cx + Cz * Cz);
flat_len = m_reach + m_frame_depth;
S_END = sE + m_reach;
S_F0  = S_END - flat_len;                                        // Ende der Aufweitung, Beginn Flachkanal

Rout  = bore_r + fk_wall;
Ws_o  = 2 * (bore_r + 3 + fk_wall);                              // Aussenbreite am Flansch
Hs_o  = max(m_gap, 2 * ((bore_r + 4) * abs(ca) + fk_wall));      // Aussenhoehe am Flansch (senkrecht zur Achse)

sL_m  = m_s_side == "links" ? m_s : m_B - m_s;
WL0   = max(Ws_o / 2, sL_m - m_margin);
WR0   = max(Ws_o / 2, m_B - sL_m - m_margin);
wlim  = max(fk_bed[0], fk_bed[1]) - jl - 1;                      // nutzbare Breite pro Teil
Wmax  = fk_max_cols > 0 ? fk_max_cols * wlim : 1e9;
exc   = max(0, WL0 + WR0 - Wmax);
e_WL  = WR0 >= WL0 ? WL0 : WL0 - exc;
e_WR  = WR0 >= WL0 ? WR0 - exc : WR0;
W_tot = e_WL + e_WR;
ncol  = max(1, ceil(W_tot / wlim - 1e-9));
e_H   = m_gap;

// Querschnittsfunktionen (aussen; off = Abstand nach innen). Lineare Aufweitung bis S_F0 -> ebene Flaechen.
T0    = (Hs_o / 2) * abs(sa / ca) + 8;                         // bis hier bleibt der Querschnitt wie am Flansch (symmetrischer Schnitt)
function frac(s) = s < T0 ? 0 : (s < S_F0 ? (s - T0) / (S_F0 - T0) : 1);
function hh(s, off) = Hs_o / 2 + (m_gap / 2 - Hs_o / 2) * frac(s) - off;
function yL(s, off) = Ws_o / 2 + (e_WL - Ws_o / 2) * frac(s) - off;
function yR(s, off) = Ws_o / 2 + (e_WR - Ws_o / 2) * frac(s) - off;
// Achsposition s, bei der die Eckkante (sg = +1 Fensterseite, -1 Raumseite) die Flanschebene z=0 schneidet
function cutS(sg, off) = -sg * (Hs_o / 2 - off) * sa / ca;
// Eckpunkt i (0..3, gegen den Uhrzeigersinn) im Teilrahmen: [x (zum Raum), y (Breite), s (Achse)]
function cpt(s, off, i) =
    let(sg = i < 2 ? 1 : -1, sc = s == CUT ? cutS(sg, off) : s,
        h = sg * hh(sc, off), y = (i == 0 || i == 3) ? yR(sc, off) : -yL(sc, off))
    [-h, y, sc];
function cut_x(sg, off) = let(s = cutS(sg, off)) s * sa + (-sg * hh(s, off)) * ca;   // x der Schnittecke in Weltkoordinaten
zmin_cut = min(cutS(1, 0), cutS(-1, 0));

// Querschnittspruefung gegenueber dem Schlauch
A_hose = PI * pow(stub_bore_d / 2, 2);
Win    = W_tot - 2 * fk_wall;
Hin    = m_gap - 2 * fk_wall;
n_ribs = max(0, round(Win / fk_rib_pitch) - 1);
A_flat = Win * Hin - n_ribs * fk_rib_t * Hin;
Hmin   = A_hose / max(1, Win - n_ribs * fk_rib_t) + 2 * fk_wall;   // Hoehe, bei der der Flachkanal so gross ist wie der Schlauch

if (al > 80) echo("WARNUNG: Der Kanal liegt fast parallel zum Flansch (Winkel > 80 Grad). Dafuer ist abluft_fensterkanal.scad (mit Bogen) besser.");
if (S_F0 < 100) echo(str("WARNUNG: Aufweitung nur ", round(S_F0), " mm lang (empfohlen mindestens 100)."));
if (WL0 + WR0 > Wmax + 1) echo(str("WARNUNG: Fenster zu breit fuer ", fk_max_cols, " Teile: Kanal auf ", round(W_tot), " mm gekuerzt (volle Breite waere ", round(WL0 + WR0), " mm)."));
if (min(abs(cut_x(1, fk_wall)), abs(cut_x(-1, fk_wall))) < bore_r + 1)
    echo("WARNUNG: Die Oeffnung am Flansch ist kleiner als die Flanschbohrung.");
if (e_WL < 102 && m_s_side == "links" || e_WR < 102 && m_s_side != "links")
    echo("HINWEIS: Die schmale Seite ist schmaler als der 150er-Flansch (203 mm); der Flansch ragt seitlich ueber den Kanal.");

// ---------------- Hilfsfunktionen ----------------
function knots(a, b) = concat([a], [for (k = [T0, S_F0]) if (k > a + EPS && k < b - EPS) k], [b]);

// Schalenkoerper aus Ringen (je 4 Eckpunkte): ol = Aussenringe [[s, off], ...], il = Innenringe
module sweep4(ol, il, s0) {
    N = 4; Ko = len(ol); Ki = len(il);
    pts = concat([for (r = ol) for (i = [0 : 3]) let(p = cpt(r[0], r[1], i)) [p[0], p[1], p[2] - s0]],
                 [for (r = il) for (i = [0 : 3]) let(p = cpt(r[0], r[1], i)) [p[0], p[1], p[2] - s0]]);
    oI = Ko * N;
    faces = concat(
        [for (k = [0 : Ko - 2], i = [0 : N - 1]) each let(j = (i + 1) % N, a = k * N + i, b = k * N + j, c = (k + 1) * N + j, d = (k + 1) * N + i) [[a, d, c], [a, c, b]]],
        [for (k = [0 : Ki - 2], i = [0 : N - 1]) each let(j = (i + 1) % N, a = oI + k * N + i, b = oI + k * N + j, c = oI + (k + 1) * N + j, d = oI + (k + 1) * N + i) [[a, b, c], [a, c, d]]],
        [for (i = [0 : N - 1]) each let(j = (i + 1) % N) [[i, j, oI + j], [i, oI + j, oI + i]]],
        [for (i = [0 : N - 1]) each let(j = (i + 1) % N, o = (Ko - 1) * N, q = oI + (Ki - 1) * N) [[o + i, q + j, o + j], [o + i, q + i, q + j]]]);
    polyhedron(pts, faces, convexity = 10);
}

// Hohlteil s0..s1 (s0 = CUT: schraeger Anfang); sock: Muffe am Anfang, spig: Spigot (verlaengert um jl) am Ende
module p_hollow(s0, s1, s0l, sock, spig) {
    s1e = spig ? s1 + jl : s1;
    ol = concat([for (k = knots(s0, s1)) [k, 0]], spig ? [for (k = knots(s1, s1e)) [k, hw]] : []);
    il = concat(sock ? [for (k = knots(s0, s0 + jl)) [k, hw - fk_joint_gap]] : [],
                [for (k = knots(sock ? s0 + jl : s0, s1e)) [k, fk_wall]]);
    sweep4(ol, il, s0l);
}
// Schicht zwischen Innenflaeche und off_a (fuer Falz: Zunge und Aussparung)
module p_layer(sa_, sb_, s0l, off_a) {
    sweep4([for (k = knots(sa_, sb_)) [k, off_a]], [for (k = knots(sa_, sb_)) [k, fk_wall]], s0l);
}

// ---------------- Stroemungsstege und Teilung ----------------
// Die Stege stuetzen Ober- und Unterwand UND fuehren die Luft: im Keil fachen sie strahlenfoermig vom Flansch auf
// (y = a * Aufweitungsanteil), im Flachkanal verlaufen sie parallel. Abstand am Stegbeginn mindestens ca. 22 mm.
rib_all = n_ribs > 0 ? [for (k = [1 : n_ribs]) -e_WL + fk_wall + k * Win / (n_ribs + 1)] : [];
rib_s0  = min(S_F0 - 20, T0 + 22 / fk_rib_pitch * (S_F0 - T0));      // Beginn der Stege (Anstroemkante)
function seam(k) = -e_WL + k * W_tot / ncol;
function vy(a, s) = a * frac(s);
module strip(a1, a2) { translate([-3000, a1, -3000]) cube([6000, a2 - a1, 6000]); }

// ein Steg (Mittelebene y = vy(a, s)), Hoehe bis 0,8 mm in Ober-/Unterwand eingebettet, in Teilkoordinaten
module vane(a, sa_, sb_, s0l) {
    ks = knots(sa_, sb_); K = len(ks);
    pts = [for (s = ks) each let(X = hh(s, fk_wall) + 0.8, y = vy(a, s), z = s - s0l)
           [[X, y - fk_rib_t / 2, z], [X, y + fk_rib_t / 2, z], [-X, y + fk_rib_t / 2, z], [-X, y - fk_rib_t / 2, z]]];
    e = (K - 1) * 4;
    faces = concat([for (k = [0 : K - 2], i = [0 : 3]) each let(j = (i + 1) % 4, a_ = k * 4 + i, b = k * 4 + j, c = (k + 1) * 4 + j, d = (k + 1) * 4 + i) [[a_, d, c], [a_, c, b]]],
                   [[0, 1, 2], [0, 2, 3], [e, e + 3, e + 2], [e, e + 2, e + 1]]);
    polyhedron(pts, faces, convexity = 6);
}
// Stege im Bereich sT..s1 des Teils; bei Spalten werden sie auf den Kern der Spalte (ohne Falzbereiche) begrenzt
module ribs_piece(s0l, sT, s1, lo, hi, wide) {
    sa_ = max(sT, rib_s0);
    lo_ = (wide && lo > -1000) ? lo + jl + fk_joint_gap + 0.5 : -3000;
    hi_ = (wide && hi < 1000) ? hi - 0.5 : 3000;
    if (s1 - sa_ > 1)
        for (a = rib_all) if (max(vy(a, sa_), vy(a, s1)) > lo_ + fk_rib_t / 2 && min(vy(a, sa_), vy(a, s1)) < hi_ - fk_rib_t / 2)
            intersection() { vane(a, sa_, s1, s0l); strip(lo_, hi_); }
}

module piece_body(s0, s1, s0l, sock, spig, lo, hi, wide) {
    sT = sock ? s0 + jl : s0;
    difference() {
        union() {
            if (wide) intersection() { p_hollow(s0, s1, s0l, sock, spig); strip(lo, hi); }
            else p_hollow(s0, s1, s0l, sock, spig);
            if (wide && hi < 1000) intersection() { p_layer(sT, s1, s0l, hw); strip(hi, hi + jl); }          // Zunge
            ribs_piece(s0l, sT, s1, lo, hi, wide);
        }
        if (wide && lo > -1000) intersection() { p_layer(sT, s1, s0l, hw - fk_joint_gap); strip(lo, lo + jl + fk_joint_gap); }   // Aussparung
    }
}

// ---------------- Teileplan ----------------
function fit2(u, v, x, y) = (u <= x && v <= y) || (u <= y && v <= x);
function colb(j) = [j > 0 ? seam(j) : -2000, j < ncol - 1 ? seam(j + 1) + jl : 2000];     // Spalte inkl. Zunge
function col_w(j, s1e) = min(colb(j)[1], yR(s1e, 0)) - max(colb(j)[0], -yL(s1e, 0));
function col_ok(j, s1e) = col_w(j, s1e) > 4;

// Weltkoordinaten eines Teilpunkts [x, y, s]
function wpt(p) = [p[2] * sa + p[0] * ca, p[1], p[2] * ca - p[0] * sa + adapter_t];
// Teil 1 (Flansch, Flanschflaeche unten): Bounding-Box in Weltkoordinaten
function fit_first(s1e) =
    let(hi_ = colb(0)[1],
        pts = concat([for (x = [-101.5, 101.5], y = [-101.5, 101.5]) [x, y, 0]],
                     [for (s = knots(CUT, s1e)) for (i = [0 : 3]) let(w = wpt(cpt(s, 0, i))) [w[0], min(hi_, w[1]), w[2]]]),
        ex = max([for (p = pts) p[0]]) - min([for (p = pts) p[0]]),
        ey = max([for (p = pts) p[1]]) - min([for (p = pts) p[1]]),
        ez = max([for (p = pts) p[2]]))
    ez <= fk_bed[2] && fit2(ex, ey, fk_bed[0], fk_bed[1]);
// liegende Teile: Breite x Laenge x Hoehe
function fit_lying(j, s0, s1e) =
    let(a0 = s0 == CUT ? zmin_cut : s0, hm = max(hh(s0 == CUT ? min(cutS(1, 0), cutS(-1, 0)) : s0, 0), hh(s1e, 0)))
    2 * hm <= fk_bed[2] && fit2(col_w(j, s1e), s1e - a0, fk_bed[0], fk_bed[1]);
function fits(s0, c) =
    let(spig = c < S_END - EPS, s1e = spig ? min(c + jl, S_END) : c)
    len([for (j = [0 : ncol - 1]) if (col_ok(j, s1e) && !((s0 == CUT && j == 0) ? fit_first(s1e) : fit_lying(j, s0, s1e))) 1]) == 0;

function best(s0, j, B, last) =
    let(base = s0 == CUT ? 95 : s0, c = min(base + 5 * j, B), ok = fits(s0, c))
    !ok ? (last < 0 ? min(base + 5, B) : last)
        : (c >= B - EPS ? c : best(s0, j + 1, B, (B - c >= 3 * jl) ? c : last));
// Teilende nach vorne ruecken, damit keine Schnipsel-Teile (< 25 mm breite Spalte) entstehen
function sliver(c) = let(s1e = min(c + jl, S_END)) len([for (j = [0 : ncol - 1]) if (col_w(j, s1e) > 4 && col_w(j, s1e) < 25) 1]) > 0;
function nosliver(c, lim, B) = (c < B - EPS && sliver(c) && c - 5 > lim) ? nosliver(c - 5, lim, B) : c;
function plan(s0) = s0 >= S_END - EPS ? [] :
    let(B = s0 < S_F0 - EPS ? S_F0 : S_END, s1 = nosliver(best(s0, 1, B, -1), (s0 == CUT ? 95 : s0) + 30, B)) concat([[s0, s1]], plan(s1));
RNG = plan(CUT);
PL  = [for (r = RNG) for (j = [0 : ncol - 1]) if (col_ok(j, min(r[1] + jl, S_END))) [r[0], r[1], j]];

module report() {
    echo(str("Messung: Dachneigung ", round(phi_w * 10) / 10, " Grad; Rahmenkante E ", round(uF), " mm seitlich und ",
             round(zF + adapter_t), " mm ueber der Kupplungsflaeche; Kanal ", round(al * 10) / 10, " Grad zur Flanschachse",
             al > 90 ? " (nach unten gerichtet)" : ""));
    echo(str("Laenge Mittellinie ", round(S_END), " mm: Aufweitung ", round(S_F0), " mm, Flachkanal ", round(flat_len),
             " mm; Breite ", round(e_WL), " (links) + ", round(e_WR), " (rechts) = ", round(W_tot), " mm, Hoehe ", m_gap,
             " mm, Hoehe am Flansch ", round(Hs_o), " mm"));
    echo(str("Querschnitt: Schlauch innen ", round(A_hose), " mm2 (d=", stub_bore_d, "), Flachkanal innen ", round(A_flat), " mm2 (",
             n_ribs, " Stege) = ", round(100 * A_flat / A_hose), " %; Hoehe fuer gleichen Querschnitt: ", round(Hmin), " mm"));
    if (A_flat < A_hose)
        echo("WARNUNG: Querschnitt des Flachkanals ist KLEINER als der des Schlauchs -> Stroemungswiderstand. Hoehe oder Breite vergroessern.");
    for (k = [0 : len(PL) - 1]) {
        p = PL[k];
        echo(str("Teil ", k + 1, ": s = ", p[0] == CUT ? "Flansch" : str(round(p[0] * 10) / 10), " ... ", round(p[1] * 10) / 10,
                 p[0] == CUT && p[2] == 0 ? " (Keil mit Flansch, Flansch unten" : (p[0] >= S_F0 - EPS ? " (Flachkanal, liegend" : " (Keil, liegend"),
                 ncol > 1 ? str(", Spalte ", p[2] + 1, " von ", ncol) : "", ")"));
    }
    if (max(fk_bed[0], fk_bed[1]) < 204 || fk_bed[2] < adapter_t + 40)
        echo("WARNUNG: Der 150er-Magnetflansch (ca. 203 mm breit) passt nicht in den Druckraum.");
    echo(str("Anzahl Teile: ", len(PL), ";  Gesamtlaenge Mittellinie: ", round(S_END), " mm;  Druckraum ", fk_bed));
    echo("Zusaetzlich: gleiche TPU-Dichtungen wie das Abluft-System fuer die 150er-Flaeche (dichtung_150_anschluss_tpu.stl).");
}

// ---------------- Ausgabe ----------------
module flange150() {
    mag_flange(adapter_t, n_mag_150, R150, lobe150, body150, lobe_offset_funnel, gr150_face, groove_depth_150, bore_r, 0, 0, true);
}
// Teilkoordinaten (x zum Raum, y Breite, z Achse) -> Welt (Flanschflaeche auf z=0)
function Mw(s0l) = [[ca, 0, sa, s0l * sa], [0, 1, 0, 0], [-sa, 0, ca, s0l * ca + adapter_t], [0, 0, 0, 1]];

function pcols(p) = let(j = p[2], wide = ncol > 1)
    [(wide && j > 0) ? seam(j) : -2000, (wide && j < ncol - 1) ? seam(j + 1) : 2000, wide];

module piece(k) {
    p = PL[k]; s0 = p[0]; s1 = p[1]; c = pcols(p);
    first = s0 == CUT; s0l = first ? 0 : s0;
    sock = !first; spig = s1 < S_END - EPS;
    if (first && c[0] < -1000) {
        union() { flange150(); multmatrix(Mw(0)) piece_body(s0, s1, s0l, sock, spig, c[0], c[1], c[2]); }
    } else {
        s1e = spig ? min(s1 + jl, S_END) : s1;
        hm = max(hh(first ? min(cutS(1, 0), cutS(-1, 0)) : s0, 0), hh(s1e, 0));
        ylo = max(c[0], -e_WL);
        multmatrix([[0, 1, 0, -ylo], [0, 0, 1, first ? -zmin_cut : 0], [1, 0, 0, hm], [0, 0, 0, 1]])
            piece_body(s0, s1, s0l, sock, spig, c[0], c[1], c[2]);
    }
}

module piece_montiert(k) {
    p = PL[k]; s0 = p[0]; s1 = p[1]; c = pcols(p);
    first = s0 == CUT; s0l = first ? 0 : s0;
    multmatrix(Mw(s0l)) piece_body(s0, s1, s0l, !first, s1 < S_END - EPS, c[0], c[1], c[2]);
    if (first && c[0] < -1000) flange150();
}

module gesamt() {
    multmatrix(Mw(0)) {
        p_hollow(CUT, S_END, 0, false, false);
        ribs_piece(0, CUT, S_END, -2000, 2000, false);
    }
    flange150();
}

if (ausgabe == "info") report();
else if (ausgabe == "teil") piece(teil_nr - 1);
else if (ausgabe == "montiert") piece_montiert(teil_nr - 1);
else if (ausgabe == "montage") for (k = [0 : len(PL) - 1]) color([0.3 + 0.1 * k, 0.6, 1 - 0.08 * k]) piece_montiert(k);
else { report(); gesamt(); }

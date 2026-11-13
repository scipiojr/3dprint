// =====================================================================
//  Aufhaengung fuer Magnetmuffen (Schlauchanschluss, Ventilator-Adapter, Filterkasten-Einlass ...)
//  Die Muffe wird von UNTEN gegen die Magnete der Platte geschnappt. Die Platte ist geschlossen
//  (keine Bohrung), die Oberseite ist flach.
//
//  part = wand | regal | wand_teil | regal_teil   (muss nach dem include stehen)
//    wand        Platte mit Haengewinkel zur Wand (90 Grad, Winkel zeigt von der flachen Oberseite nach unten,
//                Schraublochform wie bei abluft_ventilator_konsole.scad: Tropfenloch + Tropfensenkung).
//                ah_stil = "winkel": zwei seitliche Winkel (Bein + 2 Rippen) links und rechts der Muffen
//                ah_stil = "voll"  : durchgehende Wandplatte ueber die ganze Breite (Schrauben je Muffe)
//    regal       Platte ohne Winkel; Schrauben senkrecht von unten (Senkung auf der Magnetseite) gegen ein Regal
//    *_teil      ein Segment (teil_nr = 1 ... ah_n) fuer lange Reihen: Segmente werden mit einem
//                Schwalbenschwanz (Steckrichtung = senkrecht zur Platte) zu einer durchlaufenden Flaeche verbunden
//
//  Luefter (ah_luefter = true, nur Wand): die Platte nimmt zusaetzlich das Lochbild der Luefterkonsole auf
//                (4 Langloecher 6 x 12 mm, Mitte-Mitte 59 mm Richtung Wand, 54 mm Innenkante-Innenkante in Reihenrichtung).
//                Der Luefter sitzt auf der flachen Oberseite ueber der Muffe fan_muffe; die Muttern liegen in Sechskant-
//                taschen auf der Magnetseite (fan_nut_h), stehen also nicht ueber und stoeren die angesetzte Muffe nicht.
//  Auflagezunge (ah_zunge_l > 0, nur Wand): wie hinten an der Luefterkonsole eine duenne Zunge (ah_zunge_t, buendig mit der
//                Oberseite) hinter der Wandplatte; sie liegt auf der Oberkante der Wand/Platte auf und traegt die Last.
//
//  Mehrere Muffen: ah_n > 1 (Reihe parallel zur Wand, durchlaufende Platte, Abstand ah_pitch bzw. automatisch).
//  Muster: ah_muster = 100 (Schlauchmuster, folgt hose_nom: 100 oder 110) oder 150 (150er Referenzumriss).
//  Taschen, Umriss-Ausdehnung und Polungsmarken kommen aus der Basis abluft_system.scad (R110, lobe110, ref150_pts ...).
//
//  Koordinaten (= Druckpose): z = 0 ist die flache OBERSEITE (liegt auf dem Druckbett), z = ah_t die Magnetseite
//  (im Gebrauch unten). Taschen sind nach oben offen: Magnete von oben einkleben, plan mit der Magnetseite.
//  Wandwinkel wachsen nach oben (im Gebrauch nach unten). x = Reihenrichtung, y = von der Wand weg (Wand bei y = 0).
//  Polung: Kerbe (kleine Mulde auf der Magnetseite) auf Kerbe stoesst ab, Kerbe auf glatt zieht an (wie im ganzen System).
// =====================================================================
include <abluft_system.scad>

part     = "wand";    // wand | regal | wand_teil | regal_teil
teil_nr  = 1;         // bei *_teil: Nummer des Segments, 1 ... ah_n (von der linken Seite der Reihe)

/* [Muffe / Reihe] */
ah_muster   = 100;    // 100 = Schlauchmuster (6 Magnete, folgt hose_nom), 150 = 150er Muster (8 Magnete, Referenzumriss)
ah_n        = 1;      // Anzahl Muffen nebeneinander (durchlaufende Platte)
ah_rot      = ah_muster == 150 ? 22.5 : 0;   // Drehlage des Musters in der Platte (0 / 22.5 = schmale Seite zur Wand)
ah_muffe_gap = 4;     // Luft zwischen den Umrissen benachbarter Muffen
ah_pitch    = 0;      // Mittenabstand der Muffen (0 = automatisch aus Umriss + ah_muffe_gap)

/* [Platte] */
ah_t        = 8;      // Plattendicke (min. Tasche 3,2 + 3 mm Boden)
ah_rand     = 12;     // Plattenrand ueber den Muffen-Umriss hinaus (wand)
ah_rand_regal = 14;   // dto. beim Regal (Platz fuer Schrauben mit Senkung)
ah_r        = 8;      // Eckenrundung der Platte
ah_marke_t  = 0.8;    // Tiefe der Polungsmulde (0 = keine)

/* [Wand] */
ah_stil     = "winkel";   // winkel = zwei seitliche Winkel | voll = durchgehende Wandplatte
ah_h        = 46;     // Hoehe der Wandplatte ab Oberseite (wie leg_h der Luefterkonsole)
ah_ft       = 5;      // Dicke der Wandplatte (leg_t)
ah_wand_spiel = 3;    // Luft zwischen Muffen-Umriss und Wand (winkel) bzw. Wandplatte (voll)
ah_leg_w    = 20;     // Breite eines Winkels (Bein) = 4 + Schraubenfeld 12 + 4
ah_leg_gap  = 3;      // Luft zwischen Muffen-Umriss und Winkel
ah_leg_r    = 9;      // Rundung der freien Ecken (leg_r)
ah_rib_t    = 4;      // Dicke der beiden Rippen je Winkel (rib_t)
ah_rib_a    = 70;     // Auskragung der Rippen von der Wand (rib_a)
ah_voll_fx  = 0.55;   // Schraubenspalten je Muffe bei "voll": x = Muffenmitte +/- ah_voll_fx * halbe Umrissbreite
ah_schraube_d = 5.5;  // Wandschrauben (screw_d)
ah_cs_d     = 10;     // Senkung (cs_d)
ah_cs_t     = 2.5;    // Tiefe der Senkung
ah_schraube_z = [18, 34];   // Lochhoehen ab Oberseite (wie screw_z der Luefterkonsole)

/* [Luefter (Lochbild der Luefterkonsole, nur Wand)] */
ah_luefter  = false;  // true = Langloecher fuer den Luefter in die Platte
fan_muffe   = 1;      // Nummer der Muffe (1 ... ah_n), ueber der der Luefter sitzt
fan_dx      = 0;      // Versatz der Lochmitte gegenueber der Muffenmitte in Reihenrichtung
fan_dy      = 0;      // dto. quer zur Reihe (+ = von der Wand weg)
fan_slot_w  = 6;      // Breite der Langloecher (slot_w der Konsole)
fan_slot_len = 12;    // Laenge der Langloecher in Reihenrichtung (slot_len)
fan_pitch_y = 59;     // Mitte-Mitte quer zur Reihe = Richtung Wand (slot_pitch; aussen 65 / innen 53)
fan_gap_x   = 54;     // Abstand Innenkante zu Innenkante in Reihenrichtung (slot_gap)
fan_nut_h   = 3.4;    // Tiefe der Sechskanttasche fuer die Mutter auf der Magnetseite (M4: 3,2 mm); 0 = keine Tasche
fan_nut_af  = 7.2;    // Schluesselweite M4 (7) + Spiel

/* [Auflagezunge (wie hinten an der Luefterkonsole, nur Wand)] */
ah_zunge_l  = 0;      // Laenge der Zunge hinter der Wandplatte (Konsole: 25); 0 = keine
ah_zunge_t  = 2;      // Dicke, buendig mit der Oberseite (t_thin der Konsole)

/* [Regal] */
ah_loch_fx  = 0.6;    // Lochspalten je Muffe: x = Muffenmitte +/- ah_loch_fx * halbe Umrissbreite; je 2 Loecher (vorn/hinten)

/* [Teilung / Schwalbenschwanz (nur *_teil)] */
ah_dt_wn    = 10;     // Breite am Hals
ah_dt_wh    = 18;     // Breite am Kopf
ah_dt_l     = 8;      // Laenge
ah_dt_y     = [0.28, 0.72];   // Lage der Schwalben in Anteilen der Plattentiefe
ah_fuge     = 0.25;   // Spiel je Seite

/* [Druckraum] */
ah_bed      = [240, 240, 250];

// ---------------- abgeleitete Werte ----------------
mn  = ah_muster == 150 ? n_mag_150 : n_mag_110;
mR  = ah_muster == 150 ? R150 : R110;
mlr = ah_muster == 150 ? lobe150 : lobe110;
mbr = ah_muster == 150 ? body150 : body110_r;
mpr = ah_muster == 150 ? pr : pr110;

// Ausdehnung des Muffen-Umrisses in Richtung phi (Grad) ab Mitte
function ext(phi) =
    (ah_muster == 150 && use_ref_outline && n_mag_150 == 8)
        ? max([for (p = ref150_pts) p[0] * cos(phi - ah_rot) + p[1] * sin(phi - ah_rot)])
        : max(mbr, max([for (i = [0 : mn - 1]) mR * cos(ah_rot + i * 360 / mn - phi) + mlr]));

ex_x  = max(ext(0), ext(180));     // halbe Breite in Reihenrichtung
ex_y  = max(ext(90), ext(270));    // halbe Tiefe quer zur Reihe
pitch = ah_pitch > 0 ? ah_pitch : 2 * ex_x + ah_muffe_gap;

ist_wand = (part == "wand" || part == "wand_teil");
ist_voll = ist_wand && ah_stil == "voll";

y_c   = ist_wand ? ex_y + ah_wand_spiel + (ist_voll ? ah_ft : 0) : ex_y + ah_rand_regal;   // Muffenmitte ab Wand/Rand
D     = y_c + ex_y + (ist_wand ? ah_rand : ah_rand_regal);                                 // Plattentiefe
endx  = ist_wand ? (ist_voll ? ah_rand : ah_leg_gap + ah_leg_w) : ah_rand_regal;           // Abstand Umriss -> Plattenende
x_lo  = -(ex_x + endx);
x_hi  = (ah_n - 1) * pitch + ex_x + endx;

function cx(i) = i * pitch;                 // Mitte der Muffe i (0-basiert)
function xc(k) = (k - 0.5) * pitch;         // Trennlinie links von Muffe k

// ---------------- Kontrollausgabe ----------------
echo(str("Aufhaengung ", part, ": Muster ", ah_muster, ", ", ah_n, " Muffe(n), Umriss halbe Breite ", round(ex_x * 10) / 10,
         " x halbe Tiefe ", round(ex_y * 10) / 10, ", Pitch ", round(pitch * 10) / 10, " mm"));
echo(str("  Platte gesamt ", round((x_hi - x_lo) * 10) / 10, " x ", round(D * 10) / 10, " x ",
         ist_wand ? ah_h : ah_t, " mm, Muffenmitte ", round(y_c * 10) / 10, " mm von der Wand"));
if (ist_wand && ah_stil == "winkel" && ah_n > 1)
    echo("HINWEIS: Bei mehreren Muffen mit ah_stil=\"winkel\" tragen nur die Winkel an den beiden Enden; ah_stil=\"voll\" schraubt je Muffe.");
if ((part == "wand" || part == "regal") && ((x_hi - x_lo) > ah_bed[0] || D > ah_bed[1] || (ist_wand ? ah_h : ah_t) > ah_bed[2]))
    echo("WARNUNG: Teil passt nicht in den Druckraum -> part=\"wand_teil\" bzw. \"regal_teil\" je Muffe drucken (ah_stil=\"voll\" bzw. regal).");

if (ah_luefter && !ist_wand) echo("HINWEIS: ah_luefter wirkt nur bei part=\"wand\"/\"wand_teil\".");
if (ah_luefter && (fan_muffe < 1 || fan_muffe > ah_n)) echo("FEHLER: fan_muffe muss zwischen 1 und ah_n liegen");
if (ah_luefter && ist_wand) echo(str("Luefter: Lochmitte x = ", round((cx(fan_muffe - 1) + fan_dx) * 10) / 10, ", ", round((y_c + fan_dy) * 10) / 10,
         " mm von der Wand; Langloecher bei x = Mitte +/- ", fan_gap_x / 2 + fan_slot_len / 2, ", y = Mitte +/- ", fan_pitch_y / 2));

// ---------------- 2D-Bausteine ----------------
module platte2d() {   // Gesamtumriss der Platte; Wandkante (y=0) bleibt scharf
    hull() {
        if (ist_wand) translate([x_lo, 0]) square([x_hi - x_lo, 1]);
        else { translate([x_lo + ah_r, ah_r]) circle(r = ah_r, $fn = 48); translate([x_hi - ah_r, ah_r]) circle(r = ah_r, $fn = 48); }
        translate([x_lo + ah_r, D - ah_r]) circle(r = ah_r, $fn = 48);
        translate([x_hi - ah_r, D - ah_r]) circle(r = ah_r, $fn = 48);
    }
}

module schwalben2d(x0) {   // Schwalbenschwaenze an der Trennlinie x0, zeigen nach +x
    for (f = ah_dt_y) translate([x0, f * D])
        polygon([[-1, -ah_dt_wn / 2], [0, -ah_dt_wn / 2], [ah_dt_l, -ah_dt_wh / 2],
                 [ah_dt_l, ah_dt_wh / 2], [0, ah_dt_wn / 2], [-1, ah_dt_wn / 2]]);
}

module segment2d(xa, xb, links_teilung, rechts_teilung) {
    difference() {
        union() {
            intersection() { platte2d(); translate([xa, -1]) square([xb - xa, D + 2]); }
            if (rechts_teilung) intersection() { platte2d(); schwalben2d(xb); }
        }
        if (links_teilung) offset(delta = ah_fuge) schwalben2d(xa);
    }
}

// ---------------- Magnettaschen und Polungsmarken (Muffe i) ----------------
module muffe_taschen(i) {
    translate([cx(i), y_c, 0]) {
        for (j = [0 : mn - 1]) rotate(ah_rot + j * 360 / mn) translate([mR, 0, ah_t - pdepth])
            linear_extrude(pdepth + eps) pocket2d(mpr);
        if (polarity_marks && ah_marke_t > 0)
            for (j = [0 : 2 : mn - 1]) rotate(ah_rot + j * 360 / mn) translate([mR + mlr, 0, ah_t - ah_marke_t])
                cylinder(d = 1.8, h = ah_marke_t + eps, $fn = 24);
    }
}

// ---------------- Wandplatte / Winkel ----------------
module tropfen2d(d) {   // Spitze nach +z (Druck: oben) -> 45 Grad, stuetzenfrei
    r = d / 2;
    union() { circle(d = d, $fn = 48); polygon([[-r / sqrt(2), r / sqrt(2)], [r / sqrt(2), r / sqrt(2)], [0, r * sqrt(2)]]); }
}

module wandloch(x, z) {   // Tropfenloch durch die Wandplatte (y = 0 ... ah_ft) + Tropfensenkung auf der Raumseite (y = ah_ft)
    translate([x, ah_ft + 0.01, z]) rotate([90, 0, 0]) linear_extrude(ah_ft + 0.02) tropfen2d(ah_schraube_d);
    hull() {
        translate([x, ah_ft + 0.01, z]) rotate([90, 0, 0]) linear_extrude(0.01) tropfen2d(ah_cs_d);
        translate([x, ah_ft - ah_cs_t, z]) rotate([90, 0, 0]) linear_extrude(0.01) tropfen2d(ah_schraube_d);
    }
}

module bein2d(w) {   // Profil (x, z) eines Winkels, freie Ecken oben abgerundet
    union() {
        square([w, ah_h - ah_leg_r]);
        hull() { translate([ah_leg_r, ah_h - ah_leg_r]) circle(r = ah_leg_r, $fn = 64);
                 translate([w - ah_leg_r, ah_h - ah_leg_r]) circle(r = ah_leg_r, $fn = 64); }
    }
}

module rippe2d() {   // Profil (y, z): konkave Viertelellipse zwischen Wandplatte und Platte
    difference() {
        translate([ah_ft - 0.01, ah_t - 0.01]) square([ah_rib_a + 0.01, ah_h - ah_t + 0.01]);
        translate([ah_ft + ah_rib_a, ah_h]) scale([ah_rib_a, ah_h - ah_t]) circle(r = 1, $fn = 128);
    }
}

module winkel_bein(x0) {   // Bein (Wandplatte) + zwei Rippen, linke Kante bei x0
    translate([x0, ah_ft, 0]) rotate([90, 0, 0]) linear_extrude(ah_ft) bein2d(ah_leg_w);
    for (xr = [x0, x0 + ah_leg_w - ah_rib_t])
        intersection() {
            translate([xr, 0, 0]) rotate([90, 0, 90]) linear_extrude(ah_rib_t) rippe2d();
            translate([x0, ah_ft + ah_rib_a + 1, 0]) rotate([90, 0, 0]) linear_extrude(ah_ft + ah_rib_a + 2) bein2d(ah_leg_w);
        }
}

module flansch_voll(xa, xb) {   // durchgehende Wandplatte, oben nur an den Reihenenden abgerundet
    translate([0, ah_ft, 0]) rotate([90, 0, 0]) linear_extrude(ah_ft)
        intersection() {
            union() {
                translate([x_lo, 0]) square([x_hi - x_lo, ah_h - ah_leg_r]);
                hull() { translate([x_lo + ah_leg_r, ah_h - ah_leg_r]) circle(r = ah_leg_r, $fn = 64);
                         translate([x_hi - ah_leg_r, ah_h - ah_leg_r]) circle(r = ah_leg_r, $fn = 64); }
            }
            translate([xa, -1]) square([xb - xa, ah_h + 2]);
        }
}

// ---------------- Regalschrauben (senkrecht, Senkung auf der Magnetseite) ----------------
module regalloch(x, y) {
    translate([x, y, -1]) cylinder(d = ah_schraube_d, h = ah_t + 2, $fn = 40);
    // ein einziger Kegel, ueber die Magnetseite hinaus verlaengert (keine Teilflaechen bei z = ah_t)
    translate([x, y, ah_t - ah_cs_t]) cylinder(d1 = ah_schraube_d, d2 = ah_schraube_d + (ah_cs_d - ah_schraube_d) * (ah_cs_t + 1) / ah_cs_t, h = ah_cs_t + 1, $fn = 40);
}

// ---------------- Luefterloecher (Lochbild der Luefterkonsole, Langloch in Reihenrichtung) ----------------
module langloch2d(w, l) {
    hull() for (s = [-1, 1]) translate([s * (l - w) / 2, 0]) circle(d = w, $fn = 48);
}

module mutter2d() {   // Sechskant, Flaechen parallel zum Langloch (Mutter dreht nicht mit), um den Langlochhub verlaengert
    R = fan_nut_af / sqrt(3);
    hull() for (s = [-1, 1]) translate([s * (fan_slot_len - fan_slot_w) / 2, 0]) circle(r = R, $fn = 6);
}

module fan_loecher(x0, y0) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([x0 + sx * (fan_gap_x / 2 + fan_slot_len / 2), y0 + sy * fan_pitch_y / 2, 0]) {
            translate([0, 0, -1]) linear_extrude(ah_t + 2) langloch2d(fan_slot_w, fan_slot_len);
            if (fan_nut_h > 0) translate([0, 0, ah_t - fan_nut_h]) linear_extrude(fan_nut_h + 1) mutter2d();
        }
}

// ---------------- Koerper: Muffen k0 ... k1 ----------------
module koerper(k0, k1) {
    xa = k0 == 0 ? x_lo : xc(k0);
    xb = k1 == ah_n - 1 ? x_hi : xc(k1 + 1);
    difference() {
        union() {
            linear_extrude(ah_t) segment2d(xa, xb, k0 > 0, k1 < ah_n - 1);
            if (ist_wand && ah_zunge_l > 0)   // Auflagezunge hinter der Wandplatte, buendig mit der flachen Oberseite
                translate([xa, -ah_zunge_l, 0]) cube([xb - xa, ah_zunge_l + 1, ah_zunge_t]);
            if (ist_wand) {
                if (ist_voll) flansch_voll(xa, xb);
                else {
                    if (k0 == 0) winkel_bein(x_lo);
                    if (k1 == ah_n - 1) winkel_bein(x_hi - ah_leg_w);
                }
            }
        }
        for (i = [k0 : k1]) muffe_taschen(i);
        if (ah_luefter && ist_wand && fan_muffe - 1 >= k0 && fan_muffe - 1 <= k1) fan_loecher(cx(fan_muffe - 1) + fan_dx, y_c + fan_dy);
        if (ist_wand) {
            if (ist_voll) {
                for (i = [k0 : k1]) for (s = [-1, 1]) for (z = ah_schraube_z) wandloch(cx(i) + s * ah_voll_fx * ex_x, z);
            } else {
                if (k0 == 0) for (z = ah_schraube_z) wandloch(x_lo + ah_leg_w / 2, z);
                if (k1 == ah_n - 1) for (z = ah_schraube_z) wandloch(x_hi - ah_leg_w / 2, z);
            }
        } else {
            for (i = [k0 : k1]) for (s = [-1, 1]) for (y = [ah_rand_regal / 2, D - ah_rand_regal / 2])
                regalloch(cx(i) + s * ah_loch_fx * ex_x, y);
        }
    }
}

if (part == "wand" || part == "regal") koerper(0, ah_n - 1);
else if (part == "wand_teil" || part == "regal_teil") {
    if (teil_nr < 1 || teil_nr > ah_n) echo("FEHLER: teil_nr muss zwischen 1 und ah_n liegen");
    else koerper(teil_nr - 1, teil_nr - 1);
}

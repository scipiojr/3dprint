// =====================================================================
//  DN110-Durchlass durch die Arbeitsplatte, Ausfuehrung "buendig": der Ring verschwindet komplett in der Platte (Magnetflaeche = Plattenoberseite),
//  der Deckel liegt plan oben auf (nur 4,6 mm), Befestigung ausschliesslich VON UNTEN (keine Senkung/Oberfraese noetig: nur ein durchgehendes Loch ø155).
//  OpenSCAD 2021.01 oder neuer.
//
//  Aufbau (Seitenansicht, z = 0 Plattenoberseite, Platte dp_platte = 30 mm dick):
//    Ring (ø153 x 5, Magnetflaeche oben bei z = 0) haengt im Loch ø155; sein Hals (Innengewinde fuer das Rohr = wie bisher) laeuft nach unten
//    durch die Platte und hat unten ein Aussengewinde; darauf sitzt der HALTEFLANSCH (flache Scheibe, flach an die Plattenunterseite geschraubt).
//    Die Hoehe des Rings wird durch Drehen im Halteflansch eingestellt (bis die Magnetflaeche buendig mit der Platte ist).
//    6 Rippen (45 Grad) stuetzen den Ringteller gegen den Hals.
//    Deckel (ø168 x 4,6, nur 2 Magnete): liegt auf Platte und Ring; eine Klapplasche (Filmscharnier, in einem Stueck gedruckt) zum Abziehen.
//  Teile (v2_teil): 1 = Ring, 2 = Halteflansch, 3 = Deckel mit Klapplasche, 4 = Rohr 2 (Senkrechte 5 mm laenger als bei der versenkten Ausfuehrung); Rohr 1 unveraendert (dn110_arbeitsplatte_teil_1.stl).
//  Export: werkzeuge/export_dn110_buendig.sh
// =====================================================================
include <abluft_dn110_arbeitsplatte.scad>
dp_flaeche_h = 0;                 // Magnetflaeche des Rings liegt buendig mit der Plattenoberseite (ueberschreibt die Formel der Datei oben)
ausgabe = "info";                 // die Teile der Versenkt-Ausfuehrung hier nicht ausgeben

/* [Ausgabe] */
v2_teil = 1;                      // [1:Ring, 2:Halteflansch, 3:Deckel, 4:Rohr 2]

/* [Befestigung von unten] */
// v2_loch: Loch in der Platte (Ring ø153 + 2 mm Spiel), mm
v2_loch = 155;
// v2_hals_unten: Ende des Halses unter der Plattenoberseite (Plattenunterseite 30 + Halteflansch 5 + 0,5), mm
v2_hals_ende = 35.5;
// v2_hf_t: Dicke des Halteflanschs = Gewindeeingriff (die Platte ist 30 mm dick, Halteflansch liegt direkt an der Unterseite)
v2_hf_t = 5;
// v2_hf_r: Aussenradius des Halteflanschs (liegt ab Lochrand r 77,5 auf der Plattenunterseite)
v2_hf_r = 95;                    // (nur Info: aeusserster Schraubenradius + 9)
// v2_schrauben: Zahl der Befestigungsschrauben (Senkkopf-Holzschrauben 4 mm) auf dem Radius v2_schr_r
v2_schrauben = 6;
v2_schr_r = 86;
// v2_rippen: Rippen unter dem Ringteller
v2_rippen = 6;
v2_rippe_t = 3;

/* [Deckel] */
v2_deckel_r = 84;                 // Aussenradius des Deckels (liegt 6,5 mm ueber den Lochrand auf der Platte)
v2_deckel_t = 4.6;                // 3,2 Magnettasche + 1,4 Deckschicht
v2_deckel_mag = [0, 120];         // Winkel der Magnete auf dem Teilkreis R110 (gleiche Polung, 120 Grad Abstand; Deckel in 60-Grad-Schritten drehen, bis er anzieht)
v2_deckel_nut = true;             // Dichtungsnut auf der Unterseite (nimmt den TPU-Ring des Rings auf, Deckel dann plan)
v2_lasche_winkel = 240;           // Lage der Klapplasche
v2_lasche_x1 = 52;                // Radius des freien Endes
v2_lasche_x2 = 77;                // Radius des Scharniers
v2_lasche_b = 24;                 // Breite
v2_lasche_spalt = 0.5;            // Schnittspalt rund um die Lasche
v2_film_t = 0.8;                  // Dicke des Filmscharniers (unten, durchgehend)
v2_film_l = 2.0;                  // Breite des Scharnierspalts (Biegezone)
v2_griff_r = 7;                   // Fingermulde am freien Ende (Radius), 2,5 mm tief

// ---------------- Ring ----------------
module v2_ring() {
    zt = lip + Lr;                                         // Ende des Innengewindes (z von der Magnetflaeche nach unten)
    z_aus = v2_hals_ende - v2_hf_t - 0.5 - 0.5;            // Beginn des Aussengewindes
    union() {
        teil3_ring();
        // glatte Verlaengerung des Halses mit Bohrung ø110,4 (Rohr ø109 + Spiel)
        translate([0, 0, zt - 0.01]) difference() {
            cylinder(r = rrout, h = z_aus - zt + 0.02, $fn = 180);
            translate([0, 0, -1]) cylinder(r = ro + 0.7, h = z_aus - zt + 2, $fn = 180);
        }
        // Aussengewinde am unteren Ende (gleiches Profil wie das Rohrgewinde, Grund = rrout)
        translate([0, 0, z_aus]) helix_extrude(v2_hals_ende - z_aus, thr_pts(rrout, thread_depth, thr_hr, thr_hc, NT), circ_pts(ro + 0.7, 180));
        // Rippen (45 Grad) zwischen Ringteller und Hals
        for (i = [0 : v2_rippen - 1]) rotate(i * 360 / v2_rippen + 30)
            rotate([90, 0, 0]) translate([0, 0, -v2_rippe_t / 2]) linear_extrude(height = v2_rippe_t)
                polygon([[rrout - 0.5, T - 0.01], [wk_ring_r - 2, T - 0.01], [rrout - 0.5, T + (wk_ring_r - 2 - rrout + 0.5)]]);
    }
}

// ---------------- Halteflansch ----------------
module v2_halteflansch() {
    rn = rrout + thread_depth + 8;                         // Nabenradius
    difference() {
        union() {
            helix_extrude(v2_hf_t, circ_pts(rn, 240), thr_pts(rrout + thread_clear, thread_depth, thr_hr + thread_widen, thr_hc + thread_widen, NT));
            // 6 Arme zu den Schrauben, ab Lochrand (r 77,5) auf der Plattenunterseite
            linear_extrude(height = v2_hf_t) difference() {
                for (i = [0 : v2_schrauben - 1]) rotate(i * 360 / v2_schrauben + 30)
                    hull() { translate([v2_schr_r, 0]) circle(r = 9, $fn = 48); translate([rn, 0]) circle(r = 7, $fn = 48); }
                circle(r = rn - 2, $fn = 240);
            }
        }
        for (i = [0 : v2_schrauben - 1]) rotate(i * 360 / v2_schrauben + 30) translate([v2_schr_r, 0, 0]) {
            translate([0, 0, -0.01]) cylinder(d = 4.5, h = v2_hf_t + 0.02, $fn = 32);
            translate([0, 0, v2_hf_t - 2.3]) cylinder(d1 = 4.5, d2 = 9, h = 2.31, $fn = 32);   // Senkung (Druck: oben = Unterseite der Platte abgewandt)
        }
    }
}

// ---------------- Deckel mit Klapplasche ----------------
module v2_deckel() {
    t = v2_deckel_t; g = v2_lasche_spalt; b = v2_lasche_b;
    difference() {
        cylinder(r = v2_deckel_r, h = t, $fn = 240);
        // Magnettaschen unten offen
        for (a = v2_deckel_mag) rotate(a) translate([R110, 0, -0.01]) linear_extrude(height = pdepth + 0.01) pocket2d(pr110);
        // Dichtungsnut unten
        if (v2_deckel_nut) translate([0, 0, -0.01]) linear_extrude(height = groove_depth_mag + 0.01) ring2d(gr110, groove_w);
        rotate(v2_lasche_winkel) {
            // Schnittspalt rund um die Lasche (seitlich und am freien Ende), durchgehend
            translate([0, 0, -0.01]) linear_extrude(height = t + 0.02) difference() {
                translate([v2_lasche_x1 - g, -b / 2 - g]) square([v2_lasche_x2 - v2_lasche_x1 + g, b + 2 * g]);
                translate([v2_lasche_x1, -b / 2]) square([v2_lasche_x2 - v2_lasche_x1 + 1, b]);
            }
            // Scharnierspalt: von oben bis auf den Film (v2_film_t) offen
            translate([v2_lasche_x2, -b / 2 - g, v2_film_t]) cube([v2_film_l, b + 2 * g, t]);
            // Fingermulde am freien Ende
            translate([v2_lasche_x1 - 3, 0, t - 2.5]) cylinder(r = v2_griff_r, h = 3, $fn = 64);
        }
    }
}

if (v2_teil == 1) v2_ring();
else if (v2_teil == 2) v2_halteflansch();
else if (v2_teil == 3) v2_deckel();
else teil2_druck();
echo(str("Buendig: wk_v = ", round(wk_v * 10) / 10, " mm (Rohr 2); Hals ", v2_hals_ende, " mm unter der Flaeche; Halteflansch ø", 2 * v2_hf_r, " x ", v2_hf_t, "; Loch ø", v2_loch));

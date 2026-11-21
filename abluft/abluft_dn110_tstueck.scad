// =====================================================================
//  DN110-T-Stueck mit zwei Muffen und 6er-Magnetflansch im Abgang
//  OpenSCAD 2021.01 oder neuer.
//
//  Zum Einbau in ein durchgehendes DN110-Rohr: Das Rohr wird aufgetrennt, beide Rohrenden (glatt, AD 110) stecken in je eine
//  Muffe des T-Stuecks. Der Abgang (T-Fuss) endet in einem Magnetflansch im Muster des 100er-Schlauchanschlusses
//  (6 Magnete 15x3, Dichtungsnut r 50,5, Bohrung ø90 = Flansch wie Ventilator-Adapter / DN110-Muffenanschluss), darauf passt die
//  6er-Magnetmuffe des Systems.
//
//  Druckpose = Einbaulage (Rohr senkrecht, Abgang waagerecht nach +Y), ohne Drehen:
//    - Muffenmuendung unten auf dem Druckbett, beide Muffen senkrecht -> runde Bohrungen, O-Ring-Nuten (Dach 45 Grad), Anschlagringe (45 Grad) ohne Stuetzen
//    - Magnetflaeche steht senkrecht (Taschen und Nut liegen seitlich, kurze Bruecken)
//    - Echter Abgangsstutzen (Rohr, Aussenform Kreis mit 45-Grad-Spitze unten, Bohrung Kreis mit 45-Grad-Dach oben) vom Rohr bis zum Flansch
//    - Eine gerundete Stuetznase mittig unter dem Abgang waechst aus dem unteren Rohr in Stutzen und Flanschunterkante (45 Grad)
//  Einzige Stelle mit Bruecke: die Decke der ø90-Bohrung im Flansch (nur 8 mm tief, siehe README).
//
//  ausgabe: "druck" | "oring" (TPU-Ring fuer die Muffen-Nut) | "rohre" (T-Stueck mit zwei eingesteckten DN110-Rohrenden, Pruefung) | "info"
//  Export: werkzeuge/export_dn110_tstueck.sh
// =====================================================================
include <abluft_system.scad>
part = "keiner";                 // keine Ausgabe des Systems (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe = "druck";               // ["druck", "oring", "rohre", "info"]

/* [Muffen] */
// tm_rohr_ad: Aussendurchmesser des DN110-Rohrs (glattes Ende)
tm_rohr_ad = 110;
// tm_spiel: Spiel je Seite zwischen Rohr und Muffe (Muffe ID = tm_rohr_ad + 2 * tm_spiel; O-Ring-Nut dichtet)
tm_spiel = 0.30;                 // [0.1:0.05:0.6]
// tm_wand: Wandstaerke der Muffe und des Mittelstuecks
tm_wand = 4;                     // [2.5:0.5:8]
// tm_muffe_t: Muffentiefe (Einstecktiefe des Rohrs)
tm_muffe_t = 40;                 // [25:1:60]
// tm_mitte: lichte Laenge zwischen den beiden Anschlagringen (muss den Abgang ø90 samt Rand aufnehmen)
tm_mitte = 100;                  // [96:1:200]
// tm_anschlag_id: lichte Weite der Anschlagringe (Rohr stoesst an; Rohr-Innendurchmesser HT/KG ca. 104)
tm_anschlag_id = 104;            // [96:0.5:108]
// tm_anschlag_h: zylindrischer Teil des Anschlagrings (nach dem 45-Grad-Kegel)
tm_anschlag_h = 3;               // [0:0.5:8]
// tm_fase: Einfuehrfase am Muffenrand (innen) und kleine Fase aussen
tm_fase = 1.5;                   // [0:0.5:3]

/* [O-Ring-Nut in den Muffen] */
// tm_nut: Nut in der Muffenwand (dichtet radial gegen das Rohr), Profil wie beim Ventilator-Adapter, Dach unter 45 Grad
tm_nut = true;
tm_oring_d = 3.0;                // Schnurdurchmesser (TPU)
tm_nut_tiefe = 1.6;              // Nuttiefe in der Wand
tm_nut_von_rand = 20;            // Lage der Nutmitte ab Muffenrand

/* [Abgang] */
// tm_flansch_winkel: Drehlage der 6 Magnetlappen (30 = je ein Lappen genau oben und unten; 0 = Lappen links und rechts)
tm_flansch_winkel = 30;          // [0:30:30]
// tm_stutzen_l: Laenge des Abgangsstutzens vom Rohr-Aussenrand bis zur Rueckseite des Flanschs
tm_stutzen_l = 20;               // [8:1:60]
// tm_stutzen_r: Aussenradius des Stutzens (Flanschkoerper 58,4; muss die Bohrung samt Decke umschliessen)
tm_stutzen_r = 56;               // [52:0.5:58.4]
// tm_decke_z: Hoehe der Bohrungsdecke ueber der Achse: Bohrung = Kreis ø90 + 45-Grad-Dach bis zu dieser Hoehe (Bruecke 2 * (63,6 - Wert) mm)
tm_decke_z = 52;                 // [46:0.5:54]
// tm_nasen: eine gerundete Stuetznase mittig unter dem Abgang (Hull aus Kugeln): waechst aus der Wand des unteren Durchgangs, geht in die Unterkante
// des Stutzens und den unteren Flanschrand ueber, hoechstens 45 Grad geneigt (stuetzfrei druckbar), am Druckbett abgeschnitten
tm_nasen = true;
tm_nase_r = 6;                   // Verrundung der Nase am Rohrfuss (am Stutzen 5, am Flansch 2,8)
tm_nase_b = 14;                  // Breite (X) des massiven Kerns der Nase (geschlossen gegen Rohrwand, Stutzen und Flansch)
// tm_nasen_seitlich: zusaetzlich je eine Nase aus dem Rohr unter den unteren Seitenlappen (diese haengen sonst frei neben dem Stutzen)
tm_nasen_seitlich = false;

// ---------------- abgeleitet ----------------
rs   = (tm_rohr_ad + 2 * tm_spiel) / 2;    // Muffen-Innenradius
ro   = rs + tm_wand;                       // Aussenradius
ra   = tm_anschlag_id / 2;                 // Anschlagring-Innenradius
dr   = rs - ra;                            // Radialbreite des Anschlagrings (= Hoehe des 45-Grad-Kegels)
L    = 2 * tm_muffe_t + 2 * (dr + tm_anschlag_h) + tm_mitte;   // Gesamthoehe
zb   = L / 2;                              // Hoehe der Abgangsachse
T    = flange110_t;                        // Flanschdicke
yf   = ro + tm_stutzen_l + T;              // Lage der Magnetflaeche (Y)
yb   = yf - T;                             // Rueckseite des Flanschs = Ende des Stutzens
rsn  = tm_stutzen_r;
fn   = 240;                                // gleiche Facettenzahl wie die Flanschbohrung

// Lappenmitten (X, Z relativ zur Abgangsachse) und tiefster Punkt der Flanschkontur bei X
function lobe_c(i) = [R110 * cos(tm_flansch_winkel + i * 360 / n_mag_110), R110 * sin(tm_flansch_winkel + i * 360 / n_mag_110)];
function zl_body(x) = abs(x) < body110_r ? -sqrt(body110_r * body110_r - x * x) : 1e9;
function zl_lobe(x, i) = abs(x - lobe_c(i)[0]) < lobe110 ? lobe_c(i)[1] - sqrt(lobe110 * lobe110 - pow(x - lobe_c(i)[0], 2)) : 1e9;
function zlow(x) = min(zl_body(x), min([for (i = [0 : n_mag_110 - 1]) zl_lobe(x, i)]));

// Untere Rand des Stutzens (Teardrop mit Spitze nach unten) bei X
function zstutzen(x) = abs(x) < rsn / sqrt(2) ? -(rsn * sqrt(2) - abs(x)) : (abs(x) < rsn ? -sqrt(rsn * rsn - x * x) : 0);
// Lappen, die unten neben dem Stutzen frei haengen -> Stuetznase
nase_x = [for (i = [0 : n_mag_110 - 1]) let(c = lobe_c(i)) if (c[1] - lobe110 < zstutzen(c[0]) - 0.5 + 0 && c[1] - lobe110 < 0) c[0]];

// Pruefungen
assert(rsn >= stub_bore_r + 4, "tm_stutzen_r zu klein");
assert(tm_decke_z + 3.5 <= rsn, "tm_decke_z: Wand ueber der Bohrungsdecke unter 3,5 mm (Stutzenradius vergroessern oder Decke senken)");
assert(ra >= stub_bore_r, "tm_anschlag_id darf nicht kleiner als die Flanschbohrung sein");
assert(tm_mitte >= stub_bore_d + 6, "tm_mitte zu klein fuer den Abgang");

echo(str("DN110-T-Stueck: Muffe ID ", 2 * rs, " (Rohr ", tm_rohr_ad, " + ", 2 * tm_spiel, " Spiel), Tiefe ", tm_muffe_t, ", AD ", 2 * ro, ", Anschlagring ID ", tm_anschlag_id));
echo(str("Hoehe ", L, " mm, Abgangsachse bei z = ", zb, ", Magnetflaeche bei y = ", yf, " (Rohrachse y = 0), Stutzen ", tm_stutzen_l, " mm lang, Aussen-r ", rsn));
if (!tm_nasen_seitlich && len(nase_x) > 0) echo(str("HINWEIS: Lappen bei X = ", nase_x, " haengen unten neben dem Stutzen frei (tm_nasen_seitlich = true stuetzt sie, sonst ggf. kleine Stuetzen im Slicer)"));
echo(str("O-Ring Muffe: Schnur ", tm_oring_d, ", Mittenradius ", rs + tm_nut_tiefe - tm_oring_d / 2, " -> ID ", 2 * rs + 2 * tm_nut_tiefe - 2 * tm_oring_d, " AD ", 2 * rs + 2 * tm_nut_tiefe, ", Restwand an der Nut ", tm_wand - tm_nut_tiefe));

// ---------------- Bausteine ----------------
// Hohlraum des Durchgangs (Drehkoerper): Muffe unten, Anschlagring, Mittelstueck, Anschlagring, Muffe oben
module durchgang() {
    f = tm_fase; h = tm_anschlag_h; t = tm_muffe_t;
    zu = L - t - dr - h;                      // Beginn des oberen Anschlagrings (Kegel)
    rotate_extrude($fn = fn)
        polygon([[0, -1], [rs + f + 1, -1], [rs + f, 0], [rs, f],
                 [rs, t], [ra, t + dr], [ra, t + dr + h], [rs, t + dr + h],
                 [rs, zu], [ra, zu + dr], [ra, zu + dr + h], [rs, zu + dr + h],
                 [rs, L - f], [rs + f, L], [rs + f + 1, L + 1], [0, L + 1]]);
}

// O-Ring-Nuten (Profil wie fan_muffe_schnitte: Dach unter 45 Grad)
module nuten() {
    if (tm_nut) {
        fw = tm_oring_d + 0.2;
        for (zg = [tm_nut_von_rand, L - tm_nut_von_rand])
            rotate_extrude($fn = fn)
                polygon([[rs - 0.2, zg - fw / 2], [rs + tm_nut_tiefe, zg - fw / 2],
                         [rs + tm_nut_tiefe, zg + fw / 2 - tm_nut_tiefe], [rs - 0.2, zg + fw / 2 + 0.2]]);
    }
}

// Aussenkoerper des Rohrs (kleine Fase an beiden Enden)
module rohr_aussen() {
    c = min(tm_fase, 1);
    rotate_extrude($fn = fn) polygon([[0, 0], [ro - c, 0], [ro, c], [ro, L - c], [ro - c, L], [0, L]]);
}

// Magnetflansch (Flaeche zeigt nach +Y, Lappen um tm_flansch_winkel gedreht): lokal z -> -y, lokal y -> +z
module flansch() {
    translate([0, yf, zb]) rotate([90, 0, 0])
        mag_flange(T, n_mag_110, R110, lobe110, body110_r, tm_flansch_winkel, gr110, groove_depth_mag, stub_bore_r, 0, 0, false, 0, 0, pr110);
}

// Abgangsstutzen aussen: Kreis mit 45-Grad-Spitze nach unten (stuetzfrei), von der Rohrachse bis in den Flansch
module stutzen_aussen() {
    translate([0, yb + 0.5, zb]) rotate([90, 0, 0]) linear_extrude(height = yb + 0.5)
        hull() { circle(r = rsn, $fn = fn); translate([0, -rsn * sqrt(2)]) square(0.02, center = true); }
}
// Bohrung des Stutzens: Kreis ø90 mit 45-Grad-Dach nach oben (Decke bei tm_decke_z), 2D-y = Hoehe z
module stutzen_bohrung() {
    xr = stub_bore_r * sqrt(2) - tm_decke_z;
    translate([0, yb + 0.5, zb]) rotate([90, 0, 0]) linear_extrude(height = yb + 0.5)
        hull() { circle(r = stub_bore_r, $fn = fn); for (sx = [-1, 1]) translate([sx * xr, tm_decke_z]) square(0.02, center = true); }
}
// Stuetznase unter einem Lappen (Mitte cx, cz relativ zur Abgangsachse): Hull aus drei Kugeln
//   A am tiefsten Punkt des Lappens, S im Stutzen (Unterkante), B in der Wand des Rohrs; B liegt so tief, dass A-B und S-B hoechstens 45 Grad geneigt sind
module nase(cx, cz) {
    sg = cx < 0 ? -1 : 1;
    ra = 2.8; rS = 5; rB = tm_nase_r;
    A  = [cx, yb + 1.8, zb + cz - lobe110 + ra];
    x2 = 0.7 * cx;
    A2 = [x2, yb + 1.8, zb + zl_body(x2) + ra];          // zweiter Punkt unter dem Flanschkoerper: macht aus der Strebe eine Rippe
    xs = sg * min(abs(cx), 38);
    S  = [xs, yb - 8, zb + zstutzen(xs) + 3];
    xb = 0.8 * cx;
    yB = sqrt(pow(ro - 1.5, 2) - xb * xb);
    zB = min(A[2] - norm([A[0] - xb, A[1] - yB]), A2[2] - norm([A2[0] - xb, A2[1] - yB]), S[2] - norm([S[0] - xb, S[1] - yB]));
    if (zB - rB < 1) echo(str("WARNUNG: Stuetznase bei X = ", cx, " reicht unter das Druckbett (tm_mitte vergroessern)"));
    hull() {
        translate(A) sphere(r = ra, $fn = 32);
        translate(A2) sphere(r = ra, $fn = 32);
        translate(S) sphere(r = rS, $fn = 32);
        translate([xb, yB, zB]) sphere(r = rB, $fn = 32);
    }
}

// Mittige Stuetznase unter dem Abgang (X = 0): A am tiefsten Punkt des Flanschs, S in der Stutzenunterkante, B in der Rohrwand
module nase_mitte() {
    ra = 2.8; rS = 5; rB = tm_nase_r;
    A  = [0, yb + 1.8, zb + zlow(0) + ra];
    S  = [0, yb - 10, zb + zstutzen(0) + 3];
    yB = ro - 1.5;
    zB = min(A[2] - (A[1] - yB), S[2] - (S[1] - yB));
    zf = zb + zlow(0);                                  // tiefster Punkt des Flanschs
    yv = yb + 1.8;                                      // vordere Kante (vor den Magnettaschen)
    intersection() {
        translate([-60, -1, 0]) cube([120, 200, 400]);          // am Druckbett abschneiden
        union() {
            hull() {
                translate(A) sphere(r = ra, $fn = 32);
                translate(S) sphere(r = rS, $fn = 32);
                translate([0, yB, zB]) sphere(r = rB, $fn = 32);
            }
            // massiver Kern: Schnitt (y, z) vom Bett bis in Flansch und Stutzen, hinten in der Rohrwand, Schraege 45 Grad
            translate([0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = tm_nase_b, center = true)
                polygon([[yB, 0], [yv - zf, 0], [yv, zf], [yv, zf + 3], [yB, zf + 3]]);
        }
    }
}

module koerper() {
    difference() {
        union() {
            rohr_aussen();
            stutzen_aussen();
            flansch();
            if (tm_nasen) nase_mitte();
            if (tm_nasen_seitlich) for (i = [0 : n_mag_110 - 1]) let(c = lobe_c(i)) if (len([for (x = nase_x) if (abs(x - c[0]) < 0.01) 1]) > 0) nase(c[0], c[1]);
        }
        durchgang();
        nuten();
        stutzen_bohrung();
        // runde Bohrung durch Flansch und Rohrwand (gleiche Facettenzahl wie die Flanschbohrung, sonst Nullvolumen-Splitter)
        translate([0, 0, zb]) rotate([-90, 0, 0]) cylinder(r = stub_bore_r, h = yf + 1, $fn = fn);
    }
}

if (ausgabe == "druck") koerper();
else if (ausgabe == "oring") translate([0, 0, tm_oring_d / 2 - 0.025]) oring(rs + tm_nut_tiefe - tm_oring_d / 2, tm_oring_d);
else if (ausgabe == "rohre") {
    koerper();
    // eingesteckte Rohrenden (Pruefung der Passung): AD 110, ID 104, bis zum Anschlag (Muffengrund)
    for (z0 = [[-50, tm_muffe_t], [L - tm_muffe_t, L + 50]])
        difference() {
            translate([0, 0, z0[0]]) cylinder(d = tm_rohr_ad, h = z0[1] - z0[0], $fn = fn);
            translate([0, 0, z0[0] - 1]) cylinder(d = 104, h = z0[1] - z0[0] + 2, $fn = fn);
        }
}

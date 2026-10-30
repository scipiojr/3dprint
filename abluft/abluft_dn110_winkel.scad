// =====================================================================
//  DN110-Rohr -> Doppelbogen -> Magnetflansch fuer den Schlauchanschluss (6 Magnete, wie Verjuengung/Adapter).
//  OpenSCAD 2021.01 oder neuer.
//
//  Verlauf in Stroemungsrichtung (vom Rohr zum Schlauch):
//    Rohrstumpf (steckt in die Muffe des DN110-Rohrs)  ->  90 Grad nach LINKS  ->  waagerechte Strecke
//    ->  90 Grad nach OBEN  ->  senkrechte Strecke  ->  Magnetflansch (Magnetflaeche zeigt nach oben).
//
//  Zwei Druckteile (Teilung mitten in der waagerechten Strecke, Steckverbindung = Halbwand-Spigot/Muffe, Klebespalt):
//    Teil 1: Stumpf + linker Bogen + Anfang der Waagerechten (liegt flach auf der Platte, Stuetzen unter dem Rohr)
//    Teil 2: Rest der Waagerechten + Bogen nach oben + Senkrechte + Magnetflansch (Flansch unten auf dem Druckbett)
//
//  ausgabe: "gesamt" (beide Teile nebeneinander in Druckpose) | "teil" (nur Teil teil_nr) | "montiert" | "info"
//  Export: werkzeuge/export_dn110_winkel.sh
// =====================================================================
include <abluft_system.scad>
part = "keiner";                 // keine Ausgabe des Systems (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe = "gesamt";              // ["gesamt", "teil", "montiert", "info"]
teil_nr = 1;                     // [1, 2]  (nur bei ausgabe="teil")

/* [Verlauf] */
// wk_links: true = Bogen nach links (von oben gesehen, in Stroemungsrichtung), false = nach rechts
wk_links = true;
// wk_h: gerade Strecke der Waagerechten zwischen den beiden Boegen (Rohrmitte), mm
wk_h = 100;                      // [20:5:300]
// wk_v: gerade Strecke der Senkrechten zwischen Bogen und Magnetflansch (Rueckseite), mm
wk_v = 30;                       // [0:5:150]
// wk_r: Biegeradius der Rohrmittellinie beider Boegen (muss > Rohraussenradius + 5 sein)
wk_r = 70;                       // [60:5:150]
// wk_stumpf: Laenge des Rohrstumpfs fuer das DN110-Rohr (hinter dem Bogen)
wk_stumpf = pipe_len;            // [20:1:80]

/* [Rohr] */
// wk_od / wk_id: Aussen-/Innendurchmesser (wie Rohrstumpf der Verjuengung: 109 / 100)
wk_od = pipe_od;
wk_id = pipe_bore_d;
// wk_fase: Einfuehrfase am Stumpfende (aussen), mm
wk_fase = 1.0;

/* [Teilung und Druck] */
// wk_split: Laenge der Waagerechten, die zu Teil 1 gehoert (Rest = Teil 2); bestimmt die Plattenbelegung
wk_split = 50;                   // [20:5:250]
// wk_joint_len: Laenge der Steckverbindung
wk_joint_len = 12;
// wk_joint_gap: Spiel (radial) in der Steckverbindung = Klebespalt
wk_joint_gap = 0.25;
// wk_bed: nutzbarer Druckraum [x,y,z]
wk_bed = [240, 240, 250];

// ---------------- abgeleitet ----------------
ro = wk_od / 2;  ri = wk_id / 2;  rm = (ro + ri) / 2;
T  = flange110_t;                         // Flanschdicke
Rc = wk_r;
jl = wk_joint_len; jg = wk_joint_gap;
h1 = min(wk_split, wk_h - jl);            // Waagerechte in Teil 1
hb = wk_h - h1 + jl;                      // gerade Laenge in Teil 2 (inkl. Spigot, der in Teil 1 steckt)
fn = 80;
assert(Rc > ro + 5, "wk_r muss groesser als Rohraussenradius + 5 sein");
assert(wk_h > 2 * jl, "wk_h zu kurz fuer die Teilung");

// ---- Rohrbausteine (lokal: Fahrtrichtung +y, links = -x) ----
module tube_s(L, r) { rotate([-90, 0, 0]) cylinder(r = r, h = L, $fn = fn); }
module tube_b(r) {   // 90 Grad nach links, Mittelkreisradius Rc, Start im Ursprung
    translate([-Rc, 0, 0]) rotate_extrude(angle = 90, $fn = fn * 2) translate([Rc, 0]) circle(r = r, $fn = fn);
}
// Teil 1: Stumpf (+y) -> Linksbogen -> Waagerechte (-x), mit Rueckschnitt der Muffe am Ende
module teil1_solid(r, mit_fase = false) {
    if (mit_fase)
        rotate([-90, 0, 0]) rotate_extrude($fn = fn) polygon([[0, -0.01], [ro - wk_fase, -0.01], [ro, wk_fase], [ro, wk_stumpf + 0.01], [0, wk_stumpf + 0.01]]);
    else tube_s(wk_stumpf + 0.01, r);
    translate([0, wk_stumpf, 0]) {
        tube_b(r);
        translate([-Rc, Rc, 0]) rotate([0, 0, 90]) tube_s(h1, r);
    }
}
module teil1_lokal() {
    difference() {
        teil1_solid(ro, true);
        translate([0, -0.5, 0]) tube_s(wk_stumpf + 0.6, ri);
        translate([0, wk_stumpf, 0]) {
            tube_b(ri);
            translate([-Rc, Rc, 0]) rotate([0, 0, 90]) {
                translate([0, -0.01, 0]) tube_s(h1 + 0.02, ri);
                // Muffe: Innenhaelfte der Wand am Ende entfernen
                translate([0, h1 - jl - jg, 0]) tube_s(jl + jg + 0.01, rm + jg / 2);
            }
        }
    }
}
// Teil 2 (lokal: Start im Ursprung, +y, dann Bogen nach oben, dann +z). Spigot am Anfang: Aussenhaelfte entfernt.
module bend_up(r) { rotate([0, 90, 0]) tube_b(r); }
module teil2_lokal() {
    zf = Rc + wk_v;                       // Rueckseite des Flansches
    yc = hb + Rc;                         // Flanschmitte in y
    union() {
        difference() {
            union() {
                difference() {            // Spigot: aussen abdrehen
                    tube_s(hb + 0.01, ro);
                    translate([0, -0.01, 0]) difference() { tube_s(jl + 0.01, ro + 1); tube_s(jl + 0.01, rm - jg / 2); }
                }
                translate([0, hb, 0]) { bend_up(ro); translate([0, Rc, Rc]) rotate([90, 0, 0]) tube_s(wk_v + 0.5, ro); }
            }
            translate([0, -0.5, 0]) tube_s(hb + 0.5, ri);
            translate([0, hb, 0]) { bend_up(ri); translate([0, Rc, Rc]) rotate([90, 0, 0]) tube_s(wk_v + 1.0, ri); }
        }
        translate([0, yc, zf + T]) mirror([0, 0, 1])
            mag_flange(T, n_mag_110, R110, lobe110, body110_r, 0, gr110, groove_depth_mag, stub_bore_r, 0, 0, false, 0, 0, pr110);
    }
}
// Druckpose Teil 2: Flansch unten (Magnetflaeche z=0), Flanschmitte im Ursprung
module teil2_druck() { translate([0, hb + Rc, Rc + wk_v + T]) rotate([180, 0, 0]) teil2_lokal(); }
module teil1_druck() { translate([0, 0, ro]) teil1_lokal(); }

// Montierte Lage (Fliessrichtung Stumpf = +x, nach links = +y)
module montiert() {
    mirror([0, wk_links ? 0 : 1, 0]) {
        rotate([0, 0, -90]) {
            color("steelblue") teil1_lokal();
            color("orange") translate([-Rc - h1 + jl, wk_stumpf + Rc, 0]) rotate([0, 0, 90]) teil2_lokal();
        }
    }
}

echo(str("Teil 1: Stumpf ", wk_stumpf, " + Bogen + ", h1, " mm Waagerechte;  Teil 2: ", hb - jl, " mm Waagerechte + Bogen + ", wk_v, " mm Senkrechte + Flansch"));
if (ausgabe == "info") { }
else if (ausgabe == "montiert") montiert();
else if (ausgabe == "teil") { if (teil_nr == 1) teil1_druck(); else teil2_druck(); }
else { teil1_druck(); translate([0, 300, 0]) teil2_druck(); }

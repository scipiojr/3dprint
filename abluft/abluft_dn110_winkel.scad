// =====================================================================
//  DN110-Rohr -> Doppelbogen -> Magnetflansch fuer den Schlauchanschluss (6 Magnete, wie Verjuengung/Adapter).
//  OpenSCAD 2021.01 oder neuer.
//
//  Verlauf in Stroemungsrichtung (vom Rohr zum Schlauch):
//    Rohrstumpf (steckt in die Muffe des DN110-Rohrs)  ->  90 Grad nach LINKS  ->  waagerechte Strecke
//    ->  90 Grad nach OBEN  ->  senkrechte Strecke mit Aussengewinde  ->  aufgeschraubter Flanschring
//    (Magnetflansch, Magnetflaeche zeigt nach oben; Prinzip wie die Halteplatte der Plexiglas-Durchfuehrung).
//
//  Drei Druckteile (Teilung mitten in der waagerechten Strecke, Steckverbindung = Halbwand-Spigot/Muffe, Klebespalt):
//    Teil 1: Stumpf + linker Bogen + Anfang der Waagerechten (liegt flach auf der Platte, Stuetzen unter dem Rohr)
//    Teil 2: Rest der Waagerechten + Bogen nach oben + Senkrechte mit Aussengewinde (Gewindeende unten auf dem Druckbett)
//    Teil 3: Flanschring mit Magneten und Innengewinde (Magnetflaeche unten auf dem Druckbett)
//
//  ausgabe: "gesamt" (beide Teile nebeneinander in Druckpose) | "teil" (nur Teil teil_nr) | "montiert" | "info"
//  Export: werkzeuge/export_dn110_winkel.sh
// =====================================================================
include <abluft_system.scad>
part = "keiner";                 // keine Ausgabe des Systems (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe = "gesamt";              // ["gesamt", "teil", "montiert", "info"]
teil_nr = 1;                     // [1, 2, 3]  (nur bei ausgabe="teil")

/* [Verlauf] */
// wk_links: true = Bogen nach links (von oben gesehen, in Stroemungsrichtung), false = nach rechts
wk_links = true;
// wk_h: LAENGE WAAGERECHT: gerade Strecke zwischen den beiden Boegen (Rohrmitte), mm
wk_h = 100;                      // [30:5:400]
// wk_v: LAENGE SENKRECHT: gerade Strecke zwischen dem Bogen nach oben und der Rueckseite des Magnetflansches, mm (0 = Flansch sitzt direkt am Bogen)
wk_v = 30;                       // [0:5:300]
// wk_r: Biegeradius der Rohrmittellinie beider Boegen (mindestens Rohraussenradius + 4,5)
wk_r = 70;                       // [60:5:150]
// wk_stumpf: Laenge des Rohrstumpfs fuer das DN110-Rohr (hinter dem Bogen)
wk_stumpf = pipe_len;            // [20:1:80]

// wk_kegel_l: Laenge des inneren Uebergangskegels am oberen Rohrende (Innen-Durchmesser wk_id -> Bohrung des Flanschrings), mm; 0 = Absatz statt Kegel
wk_kegel_l = 15;                 // [0:1:30]
// wk_thread_l: Laenge des Aussengewindes am oberen Rohrende (= Einschraubtiefe des Flanschrings), mm; max. wk_v
wk_thread_l = 20;                // [8:1:60]

/* [Rohr] */
// wk_od / wk_id: Aussen-/Innendurchmesser (wie Rohrstumpf der Verjuengung: 109 / 100)
wk_od = pipe_od;
wk_id = pipe_bore_d;
// wk_fase: Einfuehrfase am Stumpfende (aussen), mm
wk_fase = 1.0;

/* [Teilung und Druck] */
// wk_split: Laenge der Waagerechten, die zu Teil 1 gehoert (Rest = Teil 2). 0 = automatisch (Haelfte von wk_h)
wk_split = 0;                    // [0:5:300]
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
h1 = max(jl, min(wk_split > 0 ? wk_split : wk_h / 2, wk_h - jl));   // Waagerechte in Teil 1
hb = wk_h - h1 + jl;                      // gerade Laenge in Teil 2 (inkl. Spigot, der in Teil 1 steckt)
fn = 80;
assert(Rc >= ro + 4.5, "wk_r muss mindestens Rohraussenradius + 4,5 sein");
assert(wk_v >= 8, "wk_v mindestens 8 mm (Gewinde)");
assert(wk_h >= 2 * jl + 2, "wk_h zu kurz fuer die Teilung");

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
// Am oberen Ende sitzt ein Aussengewinde, auf das der Flanschring (Teil 3) geschraubt wird.
module bend_up(r) { rotate([0, 90, 0]) tube_b(r); }
ztop = Rc + wk_v;                         // Oberkante des Rohrs (Anlage des Flanschrings)
yc   = hb + Rc;                           // Achse der Senkrechten in y
Lt   = min(wk_thread_l, wk_v);            // Gewindelaenge am Rohrende
Lk   = min(wk_kegel_l, wk_v - 1);         // Laenge des inneren Uebergangskegels
module teil2_lokal() {
    difference() {
        union() {
            difference() {            // Spigot: aussen abdrehen
                tube_s(hb + 0.3, ro);
                translate([0, -0.01, 0]) difference() { tube_s(jl + 0.01, ro + 1); tube_s(jl + 0.01, rm - jg / 2); }
            }
            translate([0, hb, 0]) {
                bend_up(ro);
                translate([0, Rc, Rc]) rotate([90, 0, 0]) translate([0, -0.3, 0]) tube_s(wk_v - Lt + 0.31, ro);   // glatter Teil der Senkrechten
            }
            // Aussengewinde (Gewindegrund = Aussenradius - Gewindetiefe) als Vollkoerper, Bohrung folgt unten in einem Zug
            translate([0, yc, ztop - Lt])
                helix_extrude(Lt, thr_pts(ro - thread_depth, thread_depth, thr_hr, thr_hc, NT), circ_pts(20, 48));
        }
        // eine durchgehende Bohrung (kein Absatz an der Gewindegrenze)
        translate([0, -0.5, 0]) tube_s(hb + 1.5, ri);
        translate([0, hb, 0]) {
            bend_up(ri);
            translate([0, Rc, Rc]) rotate([90, 0, 0]) {
                translate([0, -1, 0]) tube_s(wk_v - Lk + 1.0, ri);
                if (Lk > 0) translate([0, wk_v - Lk, 0]) rotate([-90, 0, 0]) cylinder(h = Lk + 0.01, r1 = ri, r2 = stub_bore_r, $fn = fn);
                translate([0, wk_v - 0.01, 0]) tube_s(2.0, stub_bore_r);
            }
        }
    }
}

// ---------------- Teil 3: Flanschring (Magnetflansch mit Innengewinde) ----------------
// Magnetflaeche z = 0 unten; Lippe mit Bohrung ø(hose_nom-10) und Dichtungsnut; darueber Innengewinde (Gegenstueck zum Rohrende).
Lr   = max(Lt - 0.0, 8);                                  // Einschraubtiefe (Gewindelaenge im Ring)
lip  = groove_depth_mag + 1.6;                            // geschlossener Steg an der Magnetflaeche
rrin = ro - thread_depth + thread_clear;                  // Gewindegrund innen (wie Mutter im System)
rrout = body110_r - 0.4;                                  // Halsradius aussen (innerhalb des Flanschkoerpers)
module teil3_ring() {
    union() {
        // Flanschplatte (Dicke T) mit Magnettaschen; oberhalb der Lippe grosse Bohrung, in die der Gewindering eingreift
        mag_flange(T, n_mag_110, R110, lobe110, body110_r, 0, gr110, groove_depth_mag, stub_bore_r, 0, 0, false, lip, rrout - 1.5, pr110);
        // Hals mit Innengewinde (ueber die Platte hinaus bis lip + Lr)
        translate([0, 0, lip])
            helix_extrude(Lr, circ_pts(rrout, 180),
                          thr_pts(rrin, thread_depth, thr_hr + thread_widen, thr_hc + thread_widen, NT));
    }
}
// Druckposen
module teil2_druck() { translate([0, yc, ztop]) rotate([180, 0, 0]) translate([0, -yc, 0]) teil2_lokal(); }
module teil1_druck() { translate([0, 0, ro]) teil1_lokal(); }

// Montierte Lage (Fliessrichtung Stumpf = +x, nach links = +y)
module montiert() {
    mirror([0, wk_links ? 0 : 1, 0]) {
        rotate([0, 0, -90]) {
            color("steelblue") teil1_lokal();
            translate([-Rc - h1 + jl, wk_stumpf + Rc, 0]) rotate([0, 0, 90]) {
                color("orange") teil2_lokal();
                color("seagreen") translate([0, yc, ztop + lip]) rotate([180, 0, 0]) teil3_ring();
            }
        }
    }
}

// Plattenpruefung (Naeherung der Aussenmasse in Druckpose)
function fits(u, v, x, y) = (u <= x && v <= y) || (u <= y && v <= x);
b1 = [Rc + h1 + ro, wk_stumpf + Rc + ro, 2 * ro];
b2 = [2 * ro, hb + Rc + ro, ztop + ro];
b3 = [153, 153, lip + Lr];
if (!(fits(b1[0], b1[1], wk_bed[0], wk_bed[1]) && b1[2] <= wk_bed[2])) echo(str("WARNUNG: Teil 1 (", round(b1[0]), " x ", round(b1[1]), " x ", round(b1[2]), ") passt nicht in wk_bed - wk_split verkleinern oder wk_r/wk_stumpf kleiner"));
if (!(fits(b2[0], b2[1], wk_bed[0], wk_bed[1]) && b2[2] <= wk_bed[2])) echo(str("WARNUNG: Teil 2 (", round(b2[0]), " x ", round(b2[1]), " x ", round(b2[2]), ") passt nicht in wk_bed - wk_split vergroessern bzw. wk_v/wk_r verkleinern"));
echo(str("Teil 1: Stumpf ", wk_stumpf, " + Bogen + ", h1, " mm Waagerechte;  Teil 2: ", hb - jl, " mm Waagerechte + Bogen + ", wk_v, " mm Senkrechte (Gewinde ", Lt, " mm);  Teil 3: Flanschring"));
echo(str("Gewinde: Rohr Aussen ø", wk_od, ", Gewindegrund ø", 2 * (ro - thread_depth), ", Steigung ", thread_pitch, ", Wand am Grund ", ro - thread_depth - ri, " mm; Flansch-Magnetflaeche liegt ", wk_v + lip, " mm ueber dem Bogenende"));
if (ausgabe == "info") { }
else if (ausgabe == "montiert") montiert();
else if (ausgabe == "teil") { if (teil_nr == 1) teil1_druck(); else if (teil_nr == 2) teil2_druck(); else teil3_ring(); }
else { teil1_druck(); translate([0, 300, 0]) teil2_druck(); translate([300, 0, 0]) teil3_ring(); }

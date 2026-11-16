// =====================================================================
//  DN110-Muffenseite -> Magnetflansch fuer den 6er Schlauchanschluss (6 Magnete, wie Verjuengung/Adapter/Doppelbogen).
//  OpenSCAD 2021.01 oder neuer.
//
//  Ein einziges, gerades Druckteil:
//    Rohrstumpf (steckt in die Muffe des DN110-Rohrs, Stumpf wie bei Verjuengung/Doppelbogen: ø109 / ø100, 36 mm)
//    + Magnetflansch (6 Magnete, Muster des 100er Schlauchanschlusses, Magnetflaeche mit Dichtungsnut).
//  Die Rueckseite des Flanschs ist der Anschlag fuer die Stirnflaeche der Muffe (Muffe AD ca. 128 mm < Flansch).
//  Innen geht die Bohrung des Flanschs (ø90) ueber einen kurzen Kegel auf den Innendurchmesser des Stumpfs (ø100) ueber.
//
//  Druckpose: Magnetflaeche auf dem Druckbett, Stumpf nach oben, ohne Stuetzen (Taschen werden ueberbrueckt,
//  der Innenkegel hat ca. 27 Grad Neigung zur Senkrechten).
//  Dichtung der Magnetflaeche: dichtung_100_anschluss_tpu.stl (wie an allen 100er Flaechen).
//
//  ausgabe: "druck" (Druckpose) | "montiert" (Stumpf nach unten, Flansch oben; Magnetflaeche zeigt nach oben) | "info"
//  Export: werkzeuge/export_dn110_muffe.sh
// =====================================================================
include <abluft_system.scad>
part = "keiner";                 // keine Ausgabe des Systems (muss nach dem include stehen)

/* [Ausgabe] */
ausgabe = "druck";               // ["druck", "montiert", "info"]

/* [Stumpf] */
// mf_od / mf_id: Aussen-/Innendurchmesser des Stumpfs (wie Rohrstumpf der Verjuengung: 109 / 100)
mf_od = 109;
mf_id = 100;
// mf_len: Laenge des Stumpfs ab der Rueckseite des Flanschs (= Einstecktiefe in die Muffe)
mf_len = 36;                     // [20:1:70]
// mf_fase: Einfuehrfase am Stumpfende (aussen), mm
mf_fase = 1.0;                   // [0:0.5:3]
// mf_kegel_l: Laenge des inneren Uebergangskegels (Bohrung des Flanschs -> mf_id), mm; 0 = Absatz
mf_kegel_l = 10;                 // [0:1:25]

/* [Flansch] */
// mf_t: Dicke des Magnetflanschs (Referenz 8, wie Verjuengung/Adapter)
mf_t = flange110_t;              // [5:0.5:12]
// mf_nut: Dichtungsnut auf der Magnetflaeche
mf_nut = true;

// ---------------- abgeleitet ----------------
ro = mf_od / 2;  ri = mf_id / 2;
kl = min(mf_kegel_l, mf_len - 2);
fn = 240;                         // gleiche Facettenzahl wie die Bohrung des Flanschs (sonst Nullvolumen-Splitter)
assert(ro < body110_r - 2, "mf_od zu gross fuer den Flanschkoerper");
assert(ri >= stub_bore_r, "mf_id darf nicht kleiner als die Flanschbohrung sein");
assert(mf_t >= groove_depth_mag + 1.6 && mf_t >= mag_h + mag_depth_extra + 1.2, "mf_t zu klein: Taschentiefe + 1,2 mm Deckschicht noetig");

echo(str("DN110-Muffe: Stumpf ø", mf_od, "/ø", mf_id, " x ", mf_len, " mm, Flansch ", mf_t, " mm, Magnetflaeche ø", 2 * (R110 + lobe110), " mm, Bohrung ø", stub_bore_d, " mm"));
echo(str("Gesamthoehe ", mf_t + mf_len, " mm, Wand am Stumpfende ", (ro - ri), " mm, am Flansch ", (ro - stub_bore_r), " mm"));

// Stumpf: Drehkoerper (Profil in mm: [r, z], z ab Rueckseite des Flanschs)
module stumpf() {
    // Profil [r, z]; mit kl = 0 faellt der Kegelpunkt (ri, kl) auf (ri, 0): Absatz statt Kegel
    pts = [[stub_bore_r, 0], [ro, 0], [ro, mf_len - mf_fase], [ro - mf_fase, mf_len], [ri, mf_len], [ri, kl]];
    rotate_extrude($fn = fn) polygon(pts);
}

module teil() {
    union() {
        // Magnetflansch: Magnetflaeche bei z = 0, Flanschdicke mf_t
        mag_flange(mf_t, n_mag_110, R110, lobe110, body110_r, 0, gr110, mf_nut ? groove_depth_mag : 0, stub_bore_r, 0, 0, false, 0, 0, pr110);
        // Stumpf: Anschluss koplanar an der Rueckseite (z = mf_t)
        translate([0, 0, mf_t]) stumpf();
    }
}

if (ausgabe == "druck") teil();
else if (ausgabe == "montiert") translate([0, 0, mf_t + mf_len]) rotate([180, 0, 0]) teil();

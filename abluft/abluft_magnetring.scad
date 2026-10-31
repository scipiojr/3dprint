// =====================================================================
//  Freie Magnetringe (ohne Trichter/Rohr): flache Flansche im Muster des Systems zum Anschrauben,
//  Ankleben oder Einbauen in eigene Teile (Rohr, Filterkasten, Ventilator-Adapter, Deckel ...).
//  part = ring150 | ring100 | deckel150 | deckel100
//    ring150   Muster 150 (8 Magnete, Referenz-Umriss) - passt auf Verjuengung/Durchfuehrung (Lappen auf den Achsen)
//    ring100   Muster 100/110 (6 Magnete, hose_nom) - passt auf Ventilator-Adapter / Schlauchanschluss
//    deckel*   dasselbe ohne Bohrung (Verschlussdeckel)
//  Magnetflaeche liegt bei z=0 (auf dem Druckbett). Polung: Kerbe auf Kerbe stoesst ab, Kerbe auf glatt zieht an.
//  Befestigung: optional Schraubloecher (ring_screw_n > 0) auf Radius ring_screw_r, zwischen den Magneten.
// =====================================================================
include <abluft_system.scad>

part = "ring150";       // ring150 | ring100 | deckel150 | deckel100   (muss nach dem include stehen)

/* [Magnetring] */
ring_t        = 8;      // Dicke des Rings (min. 5: Tasche 3,2 + Boden)
ring150_bore_d = 140;   // Bohrung Muster 150 (= Luftkanal)
ring100_bore_d = 90;    // Bohrung Muster 100
ring_groove   = true;   // Dichtungsnut auf der Magnetflaeche
ring_screw_n  = 0;      // Anzahl Schraubloecher (0 = keine)
ring_screw_d  = 4.5;    // Lochdurchmesser (M4)
ring150_screw_r = 84;   // Lochkreisradius Muster 150 (zwischen den Lappen; pruefen!)
ring100_screw_r = 58;   // Lochkreisradius Muster 100 (pruefen!)
ring_offset150 = 0;     // Drehlage Muster 150 (0 = wie Verjuengung, 22.5 = wie Durchfuehrung)

module magnetring(muster, bohrung_d, zu = false) {
    is150 = muster == 150;
    hole = zu ? 0.01 : bohrung_d / 2;
    sr = is150 ? ring150_screw_r : ring100_screw_r;
    off = is150 ? ring_offset150 : 0;
    nn = is150 ? n_mag_150 : n_mag_110;
    difference() {
        if (is150)
            mag_flange(ring_t, n_mag_150, R150, lobe150, body150, ring_offset150, gr150_face, ring_groove ? groove_depth_150 : 0, hole, 0, 0, true);
        else
            mag_flange(ring_t, n_mag_110, R110, lobe110, body110_r, 0, gr110, ring_groove ? groove_depth_mag : 0, hole, 0, 0, false, 0, 0, pr110);
        if (ring_screw_n > 0)
            for (j = [0 : ring_screw_n - 1])
                rotate(off + 180 / nn + j * 360 / ring_screw_n)
                    translate([sr, 0, -1]) cylinder(d = ring_screw_d, h = ring_t + 2, $fn = 32);
    }
}

if (part == "ring150") magnetring(150, ring150_bore_d);
else if (part == "ring100") magnetring(100, ring100_bore_d);
else if (part == "deckel150") magnetring(150, 0, true);
else if (part == "deckel100") magnetring(100, 0, true);

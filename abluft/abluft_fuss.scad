// =====================================================================
//  Ersatz-Fuss (Magnetlappen) fuer die Magnetflaechen des Abluft-Systems.   OpenSCAD 2021.01 oder neuer.
//  Zweck: ein Lappen ("Fuss") wurde mit verpoltem Magnet bestueckt -> Lappen absaegen und diesen Ersatz ankleben.
//  Der Fuss ist ein Lappen samt Randsegment (Umriss exakt wie am Flansch) mit Magnettasche, in Druckrichtung
//  modelliert (Magnetflaeche z=0 unten). Koordinaten wie am Flansch: Flanschmitte im Ursprung, Lappen auf +x.
//  Die Saegekante ist eine gerade Sehne senkrecht zur Lappenrichtung im Abstand r_saege von der Flanschmitte.
//
//  Ausgabe:  fuss = "6er" | "8er" | "beide"  (beide: nebeneinander auf einer Platte)
//  Export:   werkzeuge/export_fuss.sh   ->   fuesse/fuss_6er.stl, fuesse/fuss_8er.stl
//
//  Einbau: Lappen samt Randsegment mit EINEM geraden Schnitt (Sehne, rechtwinklig zur Lappenrichtung, Abstand
//  r_saege von der Flanschmitte, ca. 40 mm lang) abtrennen. Saegestelle und Fuss plan schleifen,
//  mit Zweikomponenten-Kleber (PETG: z. B. Epoxid oder Sekundenkleber + Aktivator) fuegen, Magnet erst DANACH
//  einkleben (richtige Polung mit den Nachbarn bzw. der Gegenflaeche pruefen: Kerbe auf Kerbe stoesst ab).
// =====================================================================
include <abluft_system.scad>
part = "keiner";                     // Hauptdatei: keine Ausgabe des Systems (muss nach dem include stehen)

/* [Ausgabe] */
// fuss: welcher Fuss erzeugt wird: "6er" (Schlauchflansch 100/110), "8er" (150er Flansch) oder "beide" nebeneinander
fuss = "beide";             // ["6er", "8er", "beide"]

/* [Gemeinsame Einstellungen] */
// fuss_kerbe: Polungskerbe am Lappenrand (Dreiecksmarke wie bei den uebrigen Teilen). Nur an jedem 2. Lappen
//             vorhanden: true, wenn der ersetzte Lappen eine Kerbe hatte, sonst false
fuss_kerbe   = false;
// fuss_zugabe: Zugabe in der Saegerichtung (mm): Der Fuss ist so viel laenger, damit die Saegekante nachgeschliffen werden kann
fuss_zugabe  = 0.0;         // [0:0.5:3]
// fuss_nase: Stuetznase auf der RUECKSEITE (z = Dicke): Lasche in Richtung Flanschmitte, die ueber der Saegestelle
//            auf dem Flansch aufliegt (Klebefläche vergroessert, Fuss reisst nicht ab). 0 = keine. Achtung: steht
//            um fuss_nase_t ueber die Rueckseite; nur verwenden, wo die Rueckseite frei ist.
fuss_nase_l  = 0;           // [0:1:25]
// fuss_nase_b: Breite der Stuetznase (mm)
fuss_nase_b  = 20;          // [10:1:40]
fuss_nase_t  = 1.6;         // [0.8:0.2:3]

/* [6er Fuss: Schlauchflansch (Parameter hose_nom in abluft_system.scad)] */
// f6_dicke: Dicke des Flansches an dieser Stelle (flange110_t = 8)
f6_dicke     = flange110_t;
// f6_r_saege: Abstand des geraden Saegeschnitts (Sehne) von der Flanschmitte. Standard = Nutaussenkante + 2 mm Steg;
//             der Schnitt muss ausserhalb der Dichtungsnut bleiben und vor der Magnettasche (Rand bei R - Taschenradius) liegen
f6_r_saege   = gr110 + groove_w / 2 + 2;

/* [8er Fuss: 150er Flansch] */
// f8_dicke: Dicke des Flansches (Verjuengung/Adapter: adapter_t = 10, Durchfuehrung innen: disc_t = 12)
f8_dicke     = adapter_t;
// f8_r_saege: Abstand des geraden Saegeschnitts (Sehne) von der Flanschmitte (Standard = Nutaussenkante + 2 mm Steg)
f8_r_saege   = gr150_face + groove_w / 2 + 2;

// ---------------- Geometrie ----------------
polarity_marks = false;             // Kerbe des Systems aus (OpenSCAD wertet Zuweisungen an der ersten Stelle aus: nur Literale!); eigene Kerbe unten

// Umriss des Fusses (2D): Flanschumriss mit nur einem Lappen auf +x, begrenzt durch die gerade Saegekante x >= rs
module fuss_umriss(n, R, lr, br, rs) {
    difference() {
        intersection() {
            outline2d(n, R, lr, br, 0, true);
            translate([rs - fuss_zugabe, -200]) square([400, 400]);
        }
        if (fuss_kerbe) translate([R + lr, 0]) circle(d = 1.8, $fn = 24);   // wie outline2d des Systems
    }
}
module fuss(n, R, lr, br, rs, T, pr_) {
    // unten: mit Magnettasche (Taschentiefe), oben: massiv
    linear_extrude(height = pdepth)
        difference() { fuss_umriss(n, R, lr, br, rs); translate([R, 0]) pocket2d(pr_); }
    translate([0, 0, pdepth]) linear_extrude(height = T - pdepth) fuss_umriss(n, R, lr, br, rs);
    if (fuss_nase_l > 0)
        intersection() {
            translate([rs - fuss_zugabe - fuss_nase_l, -fuss_nase_b / 2, T]) cube([fuss_nase_l + 1, fuss_nase_b, fuss_nase_t]);
            translate([0, 0, T - 0.5]) cylinder(r = br, h = fuss_nase_t + 1, $fn = 240);
        }
}

module fuss6() { fuss(6, R110, lobe110, body110_r, f6_r_saege, f6_dicke, pr110); }
module fuss8() { fuss(8, R150, lobe150, body150, f8_r_saege, f8_dicke, pr); }

if (fuss == "6er") fuss6();
else if (fuss == "8er") fuss8();
else { translate([-f6_r_saege + 10, 0, 0]) fuss6(); translate([-f8_r_saege + 10, 60, 0]) fuss8(); }

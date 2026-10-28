// =====================================================================
//  Abluft-System: Ausmesshilfe.   OpenSCAD 2021.01 oder neuer.
//
//  Duenne Platte, die auf eine Magnetkupplungsstelle aufgelegt wird (Magnete unten buendig, wie bei
//  den Abluft-Teilen) und in der Mitte einen senkrechten Stift traegt (Standard 5 mm Durchmesser).
//  Damit laesst sich die Mitte der Kupplung anpeilen, z. B. um sie zu einem Fensterausschnitt oder
//  Rohr auszurichten oder Abstaende zu messen.
//
//  Magnetart, Anzahl, Durchmesser, Teilkreis und Stiftlaenge sind frei waehlbar.
//  Voreinstellungen: preset = "150" (8 Magnete, Teilkreisradius 91), "100" (6 Magnete, Radius 66,0) oder "110" (Radius 70,9),
//  jeweils wie die Magnetflansche des Abluft-Systems; "frei" nimmt n_mag und R_mag.
//  Die Platte liegt mit den Magneten unten auf z=0, der Stift zeigt nach oben (Druckrichtung).
// =====================================================================

preset = "150";         // "150" | "100" | "110" | "frei"

/* [Magnete] */
mag_shape = "rund";     // "rund" (Scheibe, mag_d) | "quader" (mag_d lang x mag_w breit, Laenge tangential)
mag_d     = 15;         // Durchmesser bzw. Laenge
mag_w     = 5;          // Breite (nur "quader")
mag_h     = 3;          // Hoehe
mag_clear = 0.3;        // Spiel der Tasche
crush_ribs = 3;         // Quetschrippen pro runder Tasche (0 = keine)
n_mag     = 8;          // Anzahl (nur preset "frei")
R_mag     = 91;         // Teilkreisradius der Magnetmitten (nur preset "frei")
mag_angle0 = 0;         // Drehung des ersten Magneten in Grad
polarity_marks = true;  // Kerbe oben an jedem zweiten Magneten (Polung abwechselnd)

/* [Platte] */
wall     = 2.0;         // Rand um die Taschen
floor_t  = 1.2;         // Decke ueber den Magneten
openings = true;        // Fenster zwischen den Speichen (spart Material, Sicht auf die Kupplung)
spoke_w  = 8;           // Speichenbreite
hub_r    = 7;           // Radius der Nabe in der Mitte
plate_d  = 0;           // 0 = automatisch (Teilkreis + Magnet + Rand), sonst Aussendurchmesser

/* [Stift] */
pin_mode = "gedruckt";  // "gedruckt" = Stift aus PETG | "loch" = Bohrung fuer Nadel/Draht aus Metall
pin_d    = 5;           // Durchmesser des Stifts (5 mm = 0,5 cm)
pin_len  = 150;         // Laenge ueber der Platte
pin_hole_d = 5.2;       // Bohrung fuer einen Metallstift (nur "loch")
pin_base_d = 12;        // Fuss (Kegel) des gedruckten Stifts
pin_base_h = 4;

n  = preset == "150" ? 8 : (preset == "100" || preset == "110") ? 6 : n_mag;
R  = preset == "150" ? 91 : preset == "100" ? 66.0 : preset == "110" ? 70.9 : R_mag;
mext = mag_shape == "rund" ? mag_d / 2 : mag_w / 2;   // radiale Ausdehnung der Tasche (Quader: Laenge tangential)
plate_t = mag_h + floor_t;
ro = plate_d > 0 ? plate_d / 2 : R + mext + mag_clear / 2 + wall;
$fn = 96;

module pocket2d() {
    if (mag_shape == "rund") difference() {
        circle(d = mag_d + mag_clear);
        if (crush_ribs > 0) for (a = [0 : crush_ribs - 1]) rotate(a * 360 / crush_ribs + 90)
            translate([(mag_d + mag_clear) / 2 - 0.25, -0.2]) square([0.6, 0.4]);
    } else square([mag_d + mag_clear, mag_w + mag_clear], center = true);
}

module plate2d() {
    difference() {
        circle(r = ro, $fn = 180);
        if (openings) {
            // Fenster zwischen den Speichen, innerhalb des Magnetrings
            ri = R - mext - mag_clear / 2 - wall;
            difference() {
                difference() { circle(r = ri, $fn = 180); circle(r = hub_r, $fn = 96); }
                for (k = [0 : n - 1]) rotate(mag_angle0 + (k + 0.5) * 360 / n) translate([0, -spoke_w / 2]) square([ro, spoke_w]);
            }
        }
    }
}

module ausmesshilfe() {
    difference() {
        union() {
            linear_extrude(plate_t) plate2d();
            // Nabe immer geschlossen, bei Metallstift hoeher zur Fuehrung
            cylinder(r = hub_r, h = plate_t);
            if (pin_mode == "loch") cylinder(d = pin_hole_d + 4, h = plate_t + 6);
        }
        for (k = [0 : n - 1]) rotate(mag_angle0 + k * 360 / n) translate([R, 0, -0.01]) {
            rotate(mag_shape == "rund" ? 0 : 90) linear_extrude(mag_h + 0.01) pocket2d();
            if (polarity_marks && k % 2 == 1) translate([0, 0, plate_t - 0.6]) cylinder(d1 = 0.01, d2 = 3, h = 0.61, $fn = 3);
        }
        if (pin_mode == "loch") translate([0, 0, -1]) cylinder(d = pin_hole_d, h = plate_t + 8, $fn = 24);
    }
    if (pin_mode == "gedruckt") {
        translate([0, 0, plate_t - 0.01]) cylinder(d1 = pin_base_d, d2 = pin_d, h = pin_base_h, $fn = 48);
        translate([0, 0, plate_t + pin_base_h - 0.01]) cylinder(d = pin_d, h = max(0.1, pin_len - pin_base_h + 0.01), $fn = 16);
    }
}

echo(str("Ausmesshilfe: Platte ø", round(2 * ro * 10) / 10, " x ", plate_t, " mm, ", n, " Magnete ", mag_shape, " ", mag_d, "x", mag_h,
         " auf R=", R, ", Stift ø", pin_d, " x ", pin_len, " mm (", pin_mode, ")"));
if (pin_mode == "gedruckt" && pin_len > 12 * pin_d)
    echo("HINWEIS: der gedruckte Stift ist sehr schlank (Laenge > 12 x Durchmesser) und biegt sich leicht -> pin_mode=\"loch\" mit Metallstift verwenden.");
if (plate_d > 0 && plate_d / 2 < R + mext)
    echo("WARNUNG: plate_d ist zu klein, die Magnete ragen ueber den Rand.");
ausmesshilfe();

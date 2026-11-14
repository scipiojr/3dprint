// ============================================================
//  Kleinteilebox für Eurobox 60x40 + Einhängewand (Stege)
//  - Länge/Breite im festen Raster (Haken + Etiketteneinschub eingerechnet)
//  - Höhe fest, Tragsteg immer gleich (Höhe, Tiefe, Position)
//  - Leichtbau: dünne Wände; massiver Tragrahmen oben (Haken + Rand)
//  - Bodenstärke automatisch aus der Traglast (Metallschrauben)
//  Koordinaten: X = Breite (entlang der Wand)
//               Y = Länge/Tiefe (Y=0 = Wandseite/Haken, Ltot = Vorderseite)
//               Z = Höhe (Druckrichtung, Box steht aufrecht auf dem Bett)
//  Quelle der Wahrheit für alle STL/3MF in diesem Ordner.
// ============================================================

/* [Ausgabe] */
// box = die Box, modifier = Volumen der Tragzone (nur für den Slicer),
// support_zone = Bereich, in dem der Slicer Stützen erzeugen soll (Support-Enforcer, nur für den Slicer)
part = "box"; // [box, modifier, support_zone]

/* [Box-Größe in Rastereinheiten] */
units_w = 2;      // Breite  (entlang der Wand) in Rastereinheiten
units_l = 3;      // Länge   (von der Wand weg)  in Rastereinheiten

/* [Raster / Eurobox] */
grid    = 40;     // Rastermaß [mm]
tol     = 0.5;    // Spiel pro Box (Box ist um tol kleiner als ihr Raster)
eb_x    = 560;    // nutzbares Innenmaß Eurobox am BODEN, lange Seite  -> nachmessen!
eb_y    = 360;    // nutzbares Innenmaß Eurobox am BODEN, kurze Seite  -> nachmessen!
eb_h    = 75;     // nutzbare Innenhöhe Eurobox                        -> nachmessen!

/* [Feste Höhe] */
H       = 70;     // Gesamthöhe Box inkl. Haken (für ALLE Boxen gleich)

/* [Wände / Leichtbau] */
wall      = 1.2;  // Wandstärke der leichten Box (3 Perimeter à 0,4)
wall_band = 2.4;  // Wandstärke im Tragrahmen oben (6 Perimeter; Modifier macht den Rest massiv)
band_h    = 20;   // Höhe des Tragrahmens von der Oberkante nach unten [mm]. Mehr = mehr massive Schichten, Gesamthöhe H bleibt
band_ring = false; // false = nur die Rückwand (Hakenseite) wird im Tragrahmen dick, Seiten/Front bleiben leicht (Standard);
                   // true  = Tragrahmen läuft um alle vier Wände (steifer Rand, aber ca. 18 cm³ = 23 g mehr bei 2x3)
floor_t   = 0;    // Bodenstärke [mm]; 0 = automatisch aus Traglast und Spannweite
r         = 4;    // Eckradius vorne (außen)

/* [Last (für die automatische Bodenstärke)] */
rho_bulk = 4.0;   // Schüttdichte Füllgut, lose Metallschrauben [kg/Liter]
E_mod    = 1800;  // E-Modul PETG, gedruckt [MPa]
sag_max  = 2.0;   // zulässige Bodendurchbiegung bei voller Box [mm]

/* [Tragsteg / Haken – für alle Boxen identisch] */
rail_pitch = 76;  // Stegabstand an der Wand, Oberkante zu Oberkante
rail_t     = 2.0; // Dicke des Wandstegs                               -> nachmessen!
hook_clear = 2.1; // Luft im Hakenschlitz
hook_drop  = 8;   // Steglänge: wie weit der Haken hinter den Steg greift
hook_t     = 2.0; // Dicke der Hakenlippe
hook_top   = 4.0; // Dicke des Hakendachs (Tragkante)
support_rib = false; // Abstützleiste unten hinten (standardmäßig aus)
rib_h      = 6;   // Höhe der Abstützleiste

/* [Trennwände (optional)] */
n_laengs = 0;     // Anzahl Längswände (laufen von hinten nach vorne, teilen die Breite)
n_quer   = 0;     // Anzahl Querwände  (laufen von links nach rechts, teilen die Länge)
div_t    = 1.2;   // Dicke Trennwand
div_h    = 60;    // Höhe Trennwand (wird auf max. Boxhöhe H begrenzt)

/* [Beschriftungseinschub vorne] */
label_on   = true;
label_h    = 12;  // Etikettenhöhe [mm] [6, 9, 12, 19, 24]
label_w    = 0;   // Etikettenbreite [mm]; 0 = automatisch: Boxbreite − 20 mm
label_gap  = 1.0; // Spalt für das Etikett (Dicke Etikett + Luft)
label_lip  = 1.2; // Dicke der vorderen Halteleiste
label_ovl  = 1.5; // wie weit die Halteleiste das Etikett oben/unten/seitlich überdeckt
label_rail = 2.0; // Höhe der oberen/unteren Rahmenleiste
label_open_left  = true;  // Einschub links offen
label_open_right = true;  // Einschub rechts offen (false = Anschlag rechts)
label_bridge_max = 40;    // max. freie Brückenlänge der oberen Leiste; darüber dünne Stützstege
label_post_w     = 1.2;   // Breite der Stützstege im Sichtfenster
label_top_margin = 2;     // Mindestabstand Rahmen-Oberkante zum Boxrand

$fn = 48;

// ---------- abgeleitete Maße ----------
hook_over  = hook_t + rail_t + hook_clear;          // Hakenüberstand nach hinten
front_over = label_on ? label_gap + label_lip : 0;  // Überstand Etikettenrahmen vorne
W    = units_w * grid - tol;                        // Außenbreite
Ltot = units_l * grid - tol;                        // Außenlänge inkl. Haken+Rahmen (= Rasterfläche)
y0   = hook_over;                                   // Rückwand-Außenseite
L    = Ltot - hook_over - front_over;               // Länge des Boxkörpers
yf   = y0 + L;                                      // Vorderwand-Außenseite

lw     = label_w > 0 ? label_w : W - 20;            // Einschubbreite
fw     = lw + 2*label_rail;                         // Rahmenbreite außen
fh     = label_h + 2*label_rail;                    // Rahmenhöhe (oben geschlossen)
// Rahmen mittig im oberen Drittel; bei hohen Etiketten rutscht er nach unten
fz_top = min(H - H/6 + fh/2, H - label_top_margin);
fz_bot = fz_top - fh;                               // Unterkante Rahmen
dh     = min(div_h, H);                             // Trennwandhöhe begrenzt

// ---------- Bodenstärke aus der Traglast ----------
// Rechteckplatte, allseitig gelenkig gelagert, Gleichlast (Timoshenko, ν = 0,3):
//   Durchbiegung f = a' * q * b^4 / (E * t^3),  a' = 10,92 * alpha(Seitenverhältnis)
function plate_a(v) = lookup(v, [[1.0, 0.04434], [1.2, 0.06159], [1.4, 0.07699], [1.6, 0.09064],
                                  [1.8, 0.10167], [2.0, 0.11062], [3.0, 0.13355], [5.0, 0.14218]]);
iw0   = W - 2*wall;                                  // Innenbreite
il0   = L - 2*wall;                                  // Innenlänge
bs    = min(iw0, il0);                               // kurze Spannweite
as    = max(iw0, il0);
q_f   = rho_bulk * 9.81e-6 * (H - 2);                // Bodendruck bei voller Box [N/mm²]
t_req = pow(plate_a(as / bs) * q_f * pow(bs, 4) / (E_mod * sag_max), 1/3);
ft    = floor_t > 0 ? floor_t : max(1.0, ceil(t_req / 0.2 - 0.001) * 0.2);   // Schichtraster 0,2

zl    = H - hook_top - hook_drop;                    // Unterkante der Hakenlippe
dr    = wall_band - wall;                            // Höhe des 45°-Übergangs zum Tragrahmen
zb    = H - band_h - dr;                             // Beginn des Übergangs
vin   = iw0 * il0 * (H - ft) / 1e6;                  // Innenvolumen [Liter] (ohne Tragrahmen-Verengung)

// ---------- Prüfungen ----------
echo(str("Box außen: ", W, " x ", Ltot, " x ", H, " mm (Körper ", L, " mm tief)"));
echo(str("Raster in Eurobox: ", floor(eb_x/grid), " x ", floor(eb_y/grid), " Einheiten"));
echo(str("Boden: ", ft, " mm (nötig ", t_req, " mm für ", sag_max, " mm Durchbiegung); Innenvolumen ",
         vin, " l, voll mit Schrauben ca. ", vin*rho_bulk, " kg"));
echo(str("Tragrahmen: Z ", H - band_h, "–", H, " mm (", band_h, " mm, ", round(band_h/0.2), " Schichten bei 0,2 mm), Wand ", wall_band, " mm"));
if (label_on) {
    echo(str("Etikett: ", lw, " x ", label_h, " mm, Rahmen Z ", fz_bot, "–", fz_top, " mm"));
}
assert(H <= eb_h, "Box ist höher als die Eurobox!");
assert(H <= rail_pitch, "Box ist höher als der Stegabstand – kollidiert mit der Reihe darunter!");
assert(L > 2*wall_band + 5, "Box zu kurz.");
assert(band_h >= hook_top + hook_drop + 2, "Tragrahmen muss mindestens bis 2 mm unter die Hakenlippe reichen.");
assert(zb > ft + 5, "Tragrahmen zu hoch für die Box (band_h verkleinern).");
assert(wall_band >= wall, "wall_band darf nicht dünner als wall sein.");
assert(len(search(label_h, [6, 9, 12, 19, 24])) > 0, "label_h muss 6, 9, 12, 19 oder 24 sein.");
assert(!label_on || fw <= W, "Etikett breiter als die Box.");
assert(!label_on || fz_bot > ft, "Etikett zu hoch für die Box.");

// ---------- Geometrie ----------
// Grundriss: hinten eckig (Hakenanschluss), vorne gerundet
module footprint(w, l, rr) {
    hull() {
        square([w, l - rr]);
        translate([rr, l - rr])     circle(rr);
        translate([w - rr, l - rr]) circle(rr);
    }
}

// Hohlraum-Grundriss: Rückwand hat Stärke t_rear, die übrigen Wände t_side (beide Formen konvex -> hull möglich)
module cavity2d(t_rear, t_side) {
    intersection() {
        offset(r = -t_side) footprint(W, L, r);
        translate([-1, t_rear]) square([W + 2, L]);
    }
}

module body() {
    ts = band_ring ? wall_band : wall;      // Seiten/Front im Tragrahmen
    translate([0, y0, 0]) difference() {
        linear_extrude(H) footprint(W, L, r);
        // Hohlraum der leichten Box (dünne Wand)
        translate([0, 0, ft]) linear_extrude(zb - ft + 0.01) cavity2d(wall, wall);
        // 45°-Übergang zur dicken Wand (Hohlraum verjüngt sich nach oben, druckbar ohne Stütze)
        hull() {
            translate([0, 0, zb])      linear_extrude(0.01) cavity2d(wall, wall);
            translate([0, 0, zb + dr]) linear_extrude(0.01) cavity2d(wall_band, ts);
        }
        // Hohlraum im Tragrahmen (dicke Rückwand)
        translate([0, 0, zb + dr]) linear_extrude(H) cavity2d(wall_band, ts);
    }
}

// Volumen der Tragzone: im Slicer als Modifier mit 100 % Füllung und mehr Wänden
module modifier_volume() {
    translate([-0.5, 0, zb]) cube([W + 1, yf, H - zb + 0.4]);
}

module hook() {
    // Dach: liegt auf dem Wandsteg auf
    translate([0, 0, H - hook_top])
        cube([W, hook_over + wall_band, hook_top]);
    // Lippe: greift hinter den Steg (vollflächig über die ganze Breite)
    translate([0, 0, H - hook_top - hook_drop])
        cube([W, hook_t, hook_drop + hook_top]);
    // Abstützleiste unten (optional)
    if (support_rib)
        cube([W, hook_over + wall, rib_h]);
}

// gleichmäßig verteilte Trennwände
module dividers() {
    iw = W - 2*wall;                 // Innenbreite
    il = L - 2*wall;                 // Innenlänge
    e  = 0.3;                        // Überlappung in die Außenwand
    if (n_laengs > 0) {
        c = (iw - n_laengs*div_t) / (n_laengs + 1);   // Fachbreite
        for (i = [1 : n_laengs])
            translate([wall + i*c + (i-1)*div_t, y0 + wall - e, 0])
                cube([div_t, il + 2*e, dh]);
    }
    if (n_quer > 0) {
        c = (il - n_quer*div_t) / (n_quer + 1);       // Fachlänge
        for (i = [1 : n_quer])
            translate([wall - e, y0 + wall + i*c + (i-1)*div_t, 0])
                cube([iw + 2*e, div_t, dh]);
    }
}

// Etiketteneinschub: Rahmen auf der Vorderwand, oben geschlossen,
// Etikett wird seitlich eingeschoben
module label_holder() {
    x0 = (W - fw) / 2;
    d  = front_over;
    zs = fz_bot + label_rail;                 // Unterkante Schacht
    // Sichtfenster
    wx0 = x0 + label_rail + label_ovl;
    ww  = fw - 2*(label_rail + label_ovl);
    wz0 = zs + label_ovl;
    wh  = label_h - 2*label_ovl;
    // Stützstege, damit die obere Leiste nicht zu weit frei überbrückt
    n_posts = max(0, ceil(ww / label_bridge_max) - 1);
    seg     = (ww - n_posts*label_post_w) / (n_posts + 1);
    difference() {
        translate([x0, yf - 0.01, fz_bot]) cube([fw, d + 0.01, fh]);
        // Schacht für das Etikett (seitlich offen)
        sx0 = label_open_left  ? x0 - 1 : x0 + label_rail;
        sx1 = label_open_right ? x0 + fw + 1 : x0 + fw - label_rail;
        translate([sx0, yf, zs]) cube([sx1 - sx0, label_gap, label_h]);
        // Sichtfenster in der Halteleiste, unterbrochen von Stützstegen
        for (i = [0 : n_posts])
            translate([wx0 + i*(seg + label_post_w), yf + label_gap - 0.01, wz0])
                cube([seg, label_lip + 0.1, wh]);
    }
    // 45°-Fase unter dem Rahmen -> druckbar ohne Stützen
    hull() {
        translate([x0, yf - 0.01, fz_bot]) cube([fw, d + 0.01, 0.01]);
        translate([x0, yf - 0.01, fz_bot - d]) cube([fw, 0.01, 0.01]);
    }
}

// Bereich für Stützen unter der Hakenlippe (in der 3MF ein Support-Enforcer):
// Die Lippe beginnt frei in der Luft, nur dort soll der Slicer Stützen bis zum Bett bauen.
// Der Quader liegt um die Lippenunterkante (Z) und über der Lippenfläche (X, Y).
module support_zone() {
    translate([0, -0.5, zl - 1]) cube([W, hook_t + 1, 2]);
}

module box() {
    union() {
        body();
        hook();
        dividers();
        if (label_on) label_holder();
    }
}

if (part == "box") box();
else if (part == "modifier") modifier_volume();
else if (part == "support_zone") support_zone();
else assert(false, "part muss box, modifier oder support_zone sein.");

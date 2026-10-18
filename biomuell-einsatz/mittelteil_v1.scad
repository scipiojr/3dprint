// =====================================================================
//  BIOMÜLL-TRICHTER – MITTELTEIL für die Trichterhälften VERSION 1
//  (gleich dicke Wand, Schraublöcher an den alten Positionen, Eimerlänge 278)
// =====================================================================
//  Das Mittelteil wird je Längsseite zwischen die beiden Trichterhälften
//  geschraubt und verlängert den Trichter um "mittelteil". Profil, Schräge,
//  Kragen, Haltekragen, Lasche und Schraublöcher sind exakt aus der
//  Original-Konstruktion (biomuell_system.scad, Stand 16.10.2026) abgeleitet.
//
//  Ausgabe: "stueck = -1" beide Mittelteile, 0 / 1 = einzeln (druckfertig:
//  Profil flach aufs Bett, Schraublöcher senkrecht). Zweimal drucken bzw.
//  beide Stücke ausgeben – sie sind spiegelgleich.
//
//  Verschraubung: M3 x 20 (bei 5 mm), Länge siehe ECHO.
//  Hinweis: Bei Version 1 sitzt das obere Loch jeder Lasche teilweise
//  außerhalb der Lasche (angeschnitten). Das Mittelteil hat die Löcher an
//  denselben Stellen, damit sie fluchten. Wer das obere Loch nicht nutzt,
//  schraubt nur durch das untere.
// =====================================================================

/* [Mittelteil] */
// Dicke des Mittelteils = Verlängerung des Trichters (mm)
mittelteil = 5;
// -1 = beide, 0 = Längsseite +y, 1 = Längsseite -y
stueck = -1;
// obere (angeschnittene) Löcher weglassen
obere_loecher = true;

/* [Eimer und Trichter – Werte der Version 1, nicht ändern] */
eimer_l = 278;
eimer_b = 210;
eimer_gerade_l = 240;
eimer_gerade_b = 170;
absatz = 3;
platte_l = 206;
platte_b = 166;
platte_fase = 16;
trichter_tiefe = 40;
oeffnung_spiel = 3;
kragen_unten_h = 15;
wand = 2.5;
kragen_t = 4;
flansch_spiel = 1.25;
trichter_spiel = 1.0;
rippe_h = 8;
rippe_t = 5;
schraube_d = 3.4;

/* [Hidden] */
$fn = 48;
EPS = 0.01;

function okt(o) = let(hx = o[0], hy = o[1], cx = o[2], cy = o[3])
    [[-hx + cx, -hy], [hx - cx, -hy], [hx, -hy + cy], [hx, hy - cy],
     [hx - cx, hy], [-hx + cx, hy], [-hx, hy - cy], [-hx, -hy + cy]];
function okt_off(o, d) = let(
    hx = o[0] - d, hy = o[1] - d, cx = o[2], cy = o[3], s = sqrt(cx * cx + cy * cy),
    k = (cy * o[0] + cx * o[1] - cx * cy) / s - d,
    xa = (k * s - cx * hy) / cy, yb = (k * s - cy * hx) / cx)
    [hx, hy, hx - xa, hy - yb];
function okt_k(o) = (o[3] * o[0] + o[2] * o[1] - o[2] * o[3]) / sqrt(o[2] * o[2] + o[3] * o[3]);
module okt_poly(o) polygon(okt(o));
module okt_scheibe(o, z) translate([0, 0, z]) linear_extrude(EPS) okt_poly(o);
module okt_prisma(o, z0, z1) translate([0, 0, z0]) linear_extrude(z1 - z0) okt_poly(o);

L2 = platte_l / 2;
W2 = platte_b / 2;
RIM = [eimer_l / 2, eimer_b / 2, (eimer_l - eimer_gerade_l) / 2, (eimer_b - eimer_gerade_b) / 2];
T_TOP = okt_off(RIM, absatz + trichter_spiel);
RATIO = T_TOP[3] / T_TOP[2];
LIP = [L2 + oeffnung_spiel, W2 + oeffnung_spiel, platte_fase, platte_fase * RATIO];
ALPHA_X = atan(trichter_tiefe / (T_TOP[0] - LIP[0]));
ALPHA_Y = atan(trichter_tiefe / (T_TOP[1] - LIP[1]));
ALPHA_C = atan(trichter_tiefe / (okt_k(T_TOP) - okt_k(LIP)));
ALPHA_MIN = min(ALPHA_X, ALPHA_Y, ALPHA_C);
DELTA = wand / sin(ALPHA_MIN);
T_BOT = okt_off(LIP, -DELTA);
function o_at(z) = T_TOP + (T_TOP - T_BOT) * (z / trichter_tiefe);
function fin(z) = okt_off(o_at(z), DELTA);

module tropfenloch2d(d) hull() { circle(d = d, $fn = 24); translate([0, -d / 2 * sqrt(2)]) circle(0.01); }

// Lasche an der Fuge x = 0 (wie Version 1)
module lasche(a, za, b, zb, clip) intersection() {
    translate([-rippe_t, -500, zb]) cube([2 * rippe_t, 1000, za - zb]);
    hull() { okt_scheibe(okt_off(a, -rippe_h), za - EPS); okt_scheibe(okt_off(b, -rippe_h), zb); }
    okt_prisma(clip, zb - 1, za + 1);
}
// Schraublöcher wie Version 1: bei 30 % und 72 % der Trichtertiefe
module lasche_loecher(a, za, b, zb) {
    zs = obere_loecher ? [za + 0.3 * (zb - za), za + 0.72 * (zb - za)] : [za + 0.72 * (zb - za)];
    for (s = [-1, 1], z = zs)
        let(yo = b[1] + (a[1] - b[1]) * (z - zb) / (za - zb))
        translate([0, s * (yo + rippe_h / 2 + 0.3), z]) rotate([90, 0, 90])
            linear_extrude(2 * rippe_t + 2, center = true) tropfenloch2d(schraube_d);
}

// Trichter Version 1 (ganz, ohne Teilung), Absatzebene z = 0
module trichter_v1() {
    difference() {
        union() {
            hull() { okt_scheibe(T_TOP, -EPS); okt_scheibe(T_BOT, -trichter_tiefe); }
            linear_extrude(kragen_t) okt_poly(okt_off(RIM, flansch_spiel));
            lasche(T_TOP, 0, T_BOT, -trichter_tiefe, T_TOP);
            okt_prisma(okt_off(LIP, -wand), -trichter_tiefe - kragen_unten_h, -trichter_tiefe + EPS);
        }
        okt_prisma(LIP, -trichter_tiefe - kragen_unten_h - 1, -trichter_tiefe + 1);
        intersection() {
            hull() { okt_scheibe(fin(kragen_t + 1), kragen_t + 1); okt_scheibe(fin(-trichter_tiefe - 1), -trichter_tiefe - 1); }
            okt_prisma(okt_off(RIM, flansch_spiel + 1.5), -trichter_tiefe - 2, kragen_t + 3);
        }
        lasche_loecher(T_TOP, 0, T_BOT, -trichter_tiefe);
    }
}

// Profil an der Fuge (gerader Bereich der Langseite) auf "mittelteil" verlängert
module mittelteil_roh() scale([mittelteil, 1, 1]) intersection() {
    trichter_v1();
    translate([-0.5, -500, -200]) cube([1, 1000, 400]);
}
module mittelteil_stueck(k) {
    s = k == 0 ? 1 : -1;
    translate([0, 0, mittelteil / 2]) rotate([0, 90, 0]) intersection() {
        mittelteil_roh();
        translate([-50, s > 0 ? 0 : -500, -200]) cube([100, 500, 400]);
    }
}

SCHRAUBE_L = let(n = 2 * rippe_t + mittelteil + 2.4 + 1.5) [for (l = [12, 16, 20, 25, 30, 35, 40]) if (l >= n) l][0];
echo(str("Mittelteil V1: ", mittelteil, " mm -> Trichter ", 2 * (RIM[0] - flansch_spiel) + mittelteil,
         " mm lang, Öffnung ", 2 * LIP[0] + mittelteil, " x ", 2 * LIP[1], " mm, Schrauben M3 x ", SCHRAUBE_L));
if (mittelteil <= 0) echo("WARNUNG: mittelteil muss größer als 0 sein.");

for (k = (stueck < 0 ? [0, 1] : [stueck])) mittelteil_stueck(k);

// =====================================================================
//  Dach-Hub (Halbrund-Mittelpunkt) fuer Bestway 56448 Oval 488x305
//  parametrisch, print-in-place (flach liegend, Bauhoehe 40 mm)
//  Version 3: Gestaltung im Stil der Ausgangsmodelle - flache Taschen auf
//  den Keilen, Mittelloch, verrundete Aussenecken, Hohlkehle am Kragen,
//  gravierte Kennzeichnung der Nasen. Alles ueber die Gruppe Gestaltung
//  abschaltbar; die Funktion (Gelenke, Zapfen, Druckbarkeit) bleibt gleich.
//
//  - 5 Kranz-Nasen mit eigener waagerechter Gelenkachse (tangential),
//    damit sich die Stangen auf den Anstellwinkel des Dachs neigen.
//  - 1 fester First-Zapfen (waagerecht) zum zweiten Hub.
//  - Kegellager wie im Clip-Scharnier: Kegel an den Wangen,
//    Kegelsenkungen in der Nasenzunge, Spalt = gelenk_spiel.
//
//  Koordinaten: Hubmitte = Ursprung, +x zeigt zur Poolspitze,
//  -x (180 Grad) zum zweiten Hub, z nach oben. Die Peilungen der
//  Nasen sind die Richtungen von der Hubmitte zu den Randclips.
//  Beide Hubs sind identisch (zweiter Hub um 180 Grad gedreht);
//  der Spitzen-Clip sitzt dann punktsymmetrisch auf der anderen Seite.
//
//  Vorgabe der Peilungen: Rahmen laut Bestway-Anleitung (Gerade D-A-D,
//  je Ende 4 gleiche Bogenrohre C), Pfostenmitten 263 x 280 cm, Laenge
//  466 cm (bitte nachmessen). Hub 135 cm von Poolmitte. Clips beginnen
//  7 cm neben dem Knoten (Pfeiler-Uebergangsstueck): Gerade neben dem
//  Eckknoten auf der Geraden, Schraege neben dem Knoten Richtung Spitze,
//  Spitze neben dem Spitzenknoten (+y-Seite). Clip-Arm zur Stange
//  gedreht, Stangengelenk 93 mm ueber der Rohrachse.
//  Fuer andere Masse die Werte aus dem Pooldach-Rechner uebernehmen.
// =====================================================================

/* [Kranz-Zapfen (Dachstangen)] */
// Zapfendurchmesser [mm]; 44,3 = Innenmaß HT-Rohr DN 50, 50 = Muffe
kranz_zapfen_d = 44.3; // [32:0.1:60]
// Zapfenlänge [mm]
kranz_zapfen_laenge = 40; // [25:1:80]
// Kragenradius (Abstand Hubmitte bis Zapfenkragen) [mm]; größer = größerer Hub
kranz_kragen_radius = 88; // [80:1:200]

/* [First-Zapfen] */
// Zapfendurchmesser [mm]
first_zapfen_d = 44.3; // [32:0.1:60]
// Zapfenlänge [mm]
first_zapfen_laenge = 40; // [25:1:80]
// Kragenradius (Abstand Hubmitte bis Zapfenkragen) [mm]
first_kragen_radius = 62; // [50:1:150]

/* [Peilungen] */
// Peilungen (Richtung jeder Dachstange ab Hubmitte) [°]; 0 = Poolspitze, ±90 = quer; Werte aus dem Pooldach-Rechner
kranz_peilungen = [95.4, 49.1, 4.0, -49.1, -95.4];
// Peilung des Firsts [°]; 180 = zum zweiten Hub
first_peilung = 180;

/* [Gelenke] */
// Gelenkradius (Abstand Hubmitte bis Gelenkachse) [mm]
gelenk_radius = 62; // [50:1:110]
// Breite der Zunge (beweglicher Teil der Nase) [mm]
zunge_b = 20; // [16:1:30]
// Wangendicke (feste Wand neben der Zunge) [mm]
wange_t = 6; // [4:0.5:10]
// Radius der Lagerkegel (halten die Zunge in den Wangen) [mm]
kegel_r = 10; // [6:0.5:14]
// Höhe der Lagerkegel [mm]
kegel_h = 5; // [3:0.5:7]
// Gelenkspiel (Luftspalt zwischen beweglichen Teilen) [mm]; bei klemmendem Gelenk erhöhen
gelenk_spiel = 0.48; // [0.3:0.02:0.7]

/* [Gestaltung] */
// Fase (abgeschrägte Kante) am Hub-Körper [mm]; 0 = scharfkantig
fase = 1.5; // [0:0.25:3]
// Fase an den Zungen [mm]
zungen_fase = 1.0; // [0:0.25:2]
// Taschentiefe (flache Vertiefung auf den Keilen) [mm]; 0 = keine Taschen
taschen_tiefe = 1.5; // [0:0.25:3]
// Taschenrand (Abstand zu Außenkante und Wangen) [mm]
taschen_rand = 3.5; // [2:0.5:8]
// Eckenradius der Taschen [mm]
taschen_ecke = 2; // [0:0.5:6]
// Durchmesser des Mittellochs [mm]; 0 = kein Loch
mitte_d = 40; // [0:1:60]
// Eckenradius der senkrechten Außenkanten [mm]; 0 = eckig
rundung_r = 3; // [0:0.5:8]
// Hohlkehle (Innenrundung) zwischen Zunge und Kragen [mm]; wird auf den freien Platz begrenzt
kehle_r = 3; // [0:0.5:6]
// Tiefe der Zierrillen [mm]; nur aktiv ohne Taschen bzw. ohne Beschriftung
rillen_tiefe = 0.6; // [0:0.1:1.2]
// Gravurtiefe der Beschriftung [mm]; 0 = keine Beschriftung
beschriftung_tiefe = 0.6; // [0:0.1:1.2]
// Beschriftung der Zungen, Reihenfolge wie die Peilungen
kranz_texte = ["2a", "2b", "2c", "2b", "2a"];
// Beschriftung des First-Arms
first_text = "56448";
// Schrifthöhe [mm]
schrift_h = 7; // [4:0.5:10]

/* [Zapfensicherung] */
// Querbohrung für Sicherungsschraube durch Rohr und Zapfen [mm]; 0 = keine
sicherung_d = 5.5; // [0:0.5:8]
// Druckfase (45°-Abflachung unten am Zapfen, druckbar ohne Stützen)
zapfen_druckfase = true; // [false, true]

/* [Druck] */
// Drehung auf dem Druckbett [°]; bei 45° passt der Hub auf 260 × 260 mm
druck_drehung = 45; // [0:1:90]

/* [Ansicht] */
// Zungen in der Vorschau geneigt darstellen [°]; zum Export 0
vorschau_neigung = 0; // [-10:1:70]

/* [Hidden] */
$fn = 96;
H   = 40;                       // Bauhoehe
zm  = H/2;                      // Hoehe der Gelenk- und Zapfenachsen
g   = gelenk_spiel;
rk  = H/2;                      // Radius des Zungenknochens
w2  = zunge_b/2;
r_kern = gelenk_radius - rk - g;            // Radius des festen Kerns
gs2 = g*sqrt(2);                            // axialer Versatz fuer Normalspalt g

function dir(a) = [cos(a), sin(a)];
// kleinster Winkelabstand zwischen allen Richtungen (inkl. First)
alle = concat(kranz_peilungen, [first_peilung]);
function wd(a, b) = let(d = abs(((a - b) % 360 + 540) % 360 - 180)) d;
min_abstand = min([for (i = [0:len(alle)-1]) for (j = [0:len(alle)-1]) if (i < j) wd(alle[i], alle[j])]);

// Platzbedarf pruefen
// (1) Schlitze duerfen die Nachbarwange nicht anschneiden
assert(2*(gelenk_radius - kegel_r - 2)*sin(min_abstand/2) >= 2*(w2 + g) + wange_t + 2,
       "Nasen zu dicht: gelenk_radius vergroessern");
// (2) Kragen benachbarter Nasen duerfen sich im Druck nicht beruehren
kr_k = kranz_zapfen_d/2 + 4;
assert(2*kranz_kragen_radius*sin(min_abstand/2) >= 2*kr_k + 3,
       "Kragen/Zapfen zu dicht: kranz_kragen_radius vergroessern");
assert(kranz_kragen_radius > gelenk_radius + rk + 5, "Kragen zu nah am Gelenk");
assert(kegel_h + gs2 + 2 < w2, "Kegel zu hoch fuer die Zungenbreite");
assert(kegel_r + 2 < rk, "Kegel zu gross fuer den Zungenknochen");
echo(str("Hub: kleinster Winkelabstand ", min_abstand, " Grad, Kernradius ", r_kern, " mm"));
// Mittelloch: der verbleibende Kernring muss mindestens 10 mm breit sein
mitte_r = mitte_d/2;
assert(mitte_d == 0 || r_kern - mitte_r - fase >= 10, "Mittelloch zu gross: Kernring unter 10 mm");
schrift = "Liberation Sans:style=Bold";
ra_k = kranz_kragen_radius + 4 + kranz_zapfen_laenge;      // Spitzenradius Kranz
ra_f = first_kragen_radius + 4 + first_zapfen_laenge;      // Spitzenradius First
bk = kranz_zapfen_d/2 + 4;  bf = first_zapfen_d/2 + 4;     // halbe Kragenbreite
// grobe Huellpunkte: Zapfenspitzen +/- halbe Kragenbreite quer zur Richtung
hp = concat([for (b = kranz_peilungen) for (q = [-bk, bk]) ra_k*dir(b) + q*[-sin(b), cos(b)]],
            [for (q = [-bf, bf]) ra_f*dir(first_peilung) + q*[-sin(first_peilung), cos(first_peilung)]]);
hpd = [for (p = hp) [p[0]*cos(druck_drehung) - p[1]*sin(druck_drehung),
                     p[0]*sin(druck_drehung) + p[1]*cos(druck_drehung)]];
echo(str("Hub: Druckflaeche ca. ", round(max([for (p = hpd) p[0]]) - min([for (p = hpd) p[0]])), " x ",
         round(max([for (p = hpd) p[1]]) - min([for (p = hpd) p[1]])), " mm (bei druck_drehung = ", druck_drehung, ")"));

// ---------------------------------------------------------------------
// Zapfen mit Kragen, Achse +x ab x0, auf Hoehe zm, flach auf 0..H gekappt,
// mit senkrechtem Federschlitz (wie am Randhalter)
// Keilprisma entlang x: behaelt nur z >= |y| - k (45-Grad-Flanken zum Druckbett)
module druckkeil(x0, len, k)
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = len)
        polygon([[-k, -1], [k, -1], [k, 0], [k + 300, 300], [-(k + 300), 300], [-k, 0]]);
function sehne(r) = sqrt(max(r*r - zm*zm, 0));   // halbe Auflagebreite eines liegenden Zylinders
// Liegende Bohrung quer (Achse y) bei x, Tropfenspitze nach oben
module querbohrung(x, r, len)
    translate([x, 0, zm]) rotate([90, 0, 0]) linear_extrude(height = len, center = true) union() {
        circle(r = r, $fn = 32);
        polygon([[r*cos(45), r*sin(45)], [0, r*sqrt(2)], [-r*cos(45), r*sin(45)], [0, 0]]);
    }

module zapfen(d, l, x0) {
    rz = d/2;
    difference() {
        intersection() {
            union() {
                intersection() {                                                   // Kragen
                    translate([x0, 0, zm]) rotate([0, 90, 0]) cylinder(r = rz + 4, h = 4, $fn = 120);
                    if (zapfen_druckfase) druckkeil(x0 - 1, 6, sehne(rz + 4));
                }
                intersection() {
                    translate([x0 + 4, 0, zm]) rotate([0, 90, 0]) rotate_extrude($fn = 120)
                        polygon([[0, 0], [rz, 0], [rz, l - 1.5], [rz - 1.5, l], [0, l]]);
                    if (zapfen_druckfase) druckkeil(x0 + 3, l + 2, sehne(rz));
                }
            }
            translate([x0 - 1, -100, 0]) cube([l + 10, 200, H]);
        }
        translate([0, 0, -1]) linear_extrude(height = H + 2) hull() {
            translate([x0 + 4 + 15, 0]) circle(r = 0.2*d);
            translate([x0 + 4 + l - 3 - 0.2*d, 0]) circle(r = 0.2*d);
        }
        if (sicherung_d > 0) querbohrung(x0 + 4 + l/2, sicherung_d/2, d + 10);
    }
}

// Prisma entlang x mit gefasten Laengskanten
module fase_prisma(x0, x1, w, h, c) hull() {
    translate([x0, -w/2, c]) cube([x1 - x0, w, h - 2*c]);
    translate([x0, -w/2 + c, 0]) cube([x1 - x0, w - 2*c, h]);
}
// Uebergang (Hohlkehle als Schraege) von Breite w1 bei xa auf w2 bei xb
module uebergang(xa, w1, xb, w2, c) hull() {
    fase_prisma(xa, xa + 0.01, w1, H, c);
    fase_prisma(xb - 0.01, xb, w2, H, c);
}

// Lagerkegel (stumpf, 45 Grad), Grundflaeche bei y = yb, Spitze Richtung -sg*y
module kegel(sg, yb, rb, h)
    translate([gelenk_radius, yb, zm]) rotate([sg*90, 0, 0])
        cylinder(r1 = rb, r2 = rb - h, h = h, $fn = 64);

// ---------------------------------------------------------------------
// Fester Hub-Koerper
// Grundriss: konvexe Huelle aus Kern, Wangen aller Nasen und First-Arm
// -> zwischen den Scharnieren massive Dreiecke wie im alten Modell;
// danach die Schlitze fuer die Nasenzungen herausgeschnitten.
wangen_aussen = gelenk_radius + kegel_r + 4;     // Radius bis Wangenende
// konvexe Huelle; Aussenecken optional verrundet (Rundung nur an der Huelle,
// die Schlitzkanten neben den Lagerkegeln bleiben unveraendert)
module huelle2d() {
    module roh() hull() {
        circle(r = r_kern, $fn = 160);
        for (b = kranz_peilungen) rotate(b)
            translate([r_kern - 2, -(w2 + g + wange_t)])
                square([wangen_aussen - (r_kern - 2), 2*(w2 + g + wange_t)]);
        rotate(first_peilung) translate([0, -first_zapfen_d*0.3])
            square([first_kragen_radius + 1, first_zapfen_d*0.6]);
    }
    if (rundung_r > 0) offset(r = rundung_r, $fn = 32) offset(delta = -rundung_r) roh();
    else roh();
}
module schlitze2d() for (b = kranz_peilungen) rotate(b)
    translate([gelenk_radius - rk - g, -(w2 + g)]) square([500, 2*(w2 + g)]);
module umriss2d() difference() {
    huelle2d();
    schlitze2d();
    if (mitte_d > 0) circle(r = mitte_r, $fn = 96);
}
// Grundriss der Taschen: Keile zwischen den Nasen, Abstand taschen_rand zu
// Aussenkante, Wangen, First-Arm und Mittelloch
module taschen2d() {
    sperr = w2 + g + wange_t + taschen_rand;
    module roh_t() difference() {
        offset(delta = -(taschen_rand + fase)) huelle2d();
        for (b = kranz_peilungen) rotate(b) translate([0, -sperr]) square([500, 2*sperr]);
        rotate(first_peilung) translate([0, -(first_zapfen_d*0.3 + taschen_rand)])
            square([500, 2*(first_zapfen_d*0.3 + taschen_rand)]);
        circle(r = max(mitte_r + fase, 6) + taschen_rand, $fn = 96);
    }
    if (taschen_ecke > 0) offset(r = taschen_ecke, $fn = 24) offset(delta = -taschen_ecke) roh_t();
    else roh_t();
}
// Tasche mit 45-Grad-Waenden, von der Oberseite (z = H) aus
module taschen_schnitt() {
    n = max(1, ceil(taschen_tiefe/0.25));
    dz = taschen_tiefe/n;
    for (i = [0:n-1])
        translate([0, 0, H - taschen_tiefe + i*dz]) linear_extrude(height = (i == n-1) ? dz + 1 : dz + 0.01)
            offset(delta = -(taschen_tiefe - (i + 1)*dz)) taschen2d();
}
// Extrusion mit 45-Grad-Fase oben und unten. Die Fase entsteht aus duennen
// Schichten (0,2 mm, wie beim Druck); das rendert auch in OpenSCAD 2021 schnell.
module fase_extrude(h, c) {
    if (c <= 0) linear_extrude(height = h) children();
    else {
        n = max(1, ceil(c/0.2));
        dz = c/n;
        translate([0, 0, c - 0.01]) linear_extrude(height = h - 2*c + 0.02) children();
        for (i = [0:n-1]) {
            ins = c - (i + 0.5)*dz;                 // Einzug dieser Schicht
            translate([0, 0, i*dz - 0.01]) linear_extrude(height = dz + 0.02) offset(delta = -ins) children();
            translate([0, 0, h - (i + 1)*dz - 0.01]) linear_extrude(height = dz + 0.02) offset(delta = -ins) children();
        }
    }
}
module hub_fest() {
    difference() {
        fase_extrude(H, fase) umriss2d();
        // Mittelloch: oben und unten 45-Grad-Fase (unten = 45-Grad-Ueberhang, druckbar)
        if (mitte_d > 0 && fase > 0) {
            translate([0, 0, -0.01]) cylinder(r1 = mitte_r + fase, r2 = mitte_r, h = fase + 0.01, $fn = 96);
            translate([0, 0, H - fase]) cylinder(r1 = mitte_r, r2 = mitte_r + fase, h = fase + 0.01, $fn = 96);
        }
        if (taschen_tiefe > 0) taschen_schnitt();
        // dezenter Zierring auf der Oberseite (nur ohne Taschen)
        if (rillen_tiefe > 0 && taschen_tiefe == 0 && r_kern - 8.6 > mitte_r + fase + 2)
            translate([0, 0, H - rillen_tiefe]) difference() {
                cylinder(r = r_kern - 7.4, h = 1, $fn = 160);
                translate([0, 0, -0.5]) cylinder(r = r_kern - 8.6, h = 2, $fn = 160);
            }
        // Beschriftung auf dem First-Arm
        if (beschriftung_tiefe > 0 && first_text != "")
            rotate([0, 0, first_peilung])
                translate([(max(mitte_r + fase, 0) + first_kragen_radius - 10)/2 + 1, 0, H - beschriftung_tiefe])
                    linear_extrude(height = beschriftung_tiefe + 1) rotate(cos(first_peilung) < 0 ? 180 : 0)
                        text(first_text, size = schrift_h, font = schrift, halign = "center", valign = "center");
    }
    // First-Zapfen (ohne Fase) mit schraegem Uebergang vom Arm zum Kragen
    rotate([0, 0, first_peilung]) {
        uebergang(first_kragen_radius - 10, first_zapfen_d*0.6, first_kragen_radius + 0.5,
                  min(1.8*first_zapfen_d/2, 2*(first_zapfen_d/2 + 4) - 4), fase);
        zapfen(first_zapfen_d, first_zapfen_laenge, first_kragen_radius);
    }
    // Lagerkegel an den Wangeninnenseiten, mit 1 mm Verankerung in der Wange
    for (b = kranz_peilungen) rotate([0, 0, b]) for (sg = [-1, 1]) {
        kegel(sg, sg*(w2 + g), kegel_r, kegel_h);
        translate([gelenk_radius, sg*(w2 + g), zm]) rotate([-sg*90, 0, 0])
            cylinder(r = kegel_r, h = 1, $fn = 64);
    }
}

// ---------------------------------------------------------------------
// Nase (beweglich), lokal in Richtung +x, Gelenkachse bei (gelenk_radius, *, zm)
xa_z = wangen_aussen + 2 + 2*zungen_fase;              // Beginn der gefasten Zunge
// Verbreiterung zum Kragen erst ausserhalb des Radius, den die Wangen beim
// Neigen (bis 70 Grad) erreichen koennen -> keine Kollision mit den Wangen
xg_z = max(xa_z, gelenk_radius + sqrt(pow(wangen_aussen - gelenk_radius, 2) + rk*rk) + 0.5);
wg_z = min(zunge_b + 2*max(kranz_kragen_radius + 0.5 - xg_z, 0), 1.8*kranz_zapfen_d/2);
// Hohlkehle: nur so gross, wie die Wangen beim Neigen Platz lassen
kehle_eff = max(0, min(kehle_r, kranz_kragen_radius - xg_z, kranz_zapfen_d/2 + 4 - w2 - 1));
if (kehle_r > 0) echo(str("Hub: Hohlkehle am Kragen wirksam mit r = ", kehle_eff,
    " mm (groesser nur mit groesserem kranz_kragen_radius)"));
module kehle_lokal() if (kehle_eff > 0.2)
    intersection() {
        for (sg = [-1, 1]) translate([0, 0, -1]) linear_extrude(height = H + 2) difference() {
            translate([kranz_kragen_radius - kehle_eff, sg > 0 ? w2 - 0.01 : -w2 - kehle_eff + 0.01])
                square([kehle_eff + 0.01, kehle_eff]);
            translate([kranz_kragen_radius - kehle_eff, sg*(w2 + kehle_eff)]) circle(r = kehle_eff, $fn = 32);
        }
        translate([kranz_kragen_radius - kehle_eff - 1, 0, zm]) rotate([0, 90, 0])
            cylinder(r = kranz_zapfen_d/2 + 4, h = kehle_eff + 2, $fn = 120);
        translate([0, -100, 0]) cube([500, 200, H]);
    }
module nase_lokal() {
    difference() {
        union() {
            // Zungenknochen um die Gelenkachse
            translate([gelenk_radius, w2, zm]) rotate([90, 0, 0])
                cylinder(r = rk, h = zunge_b, $fn = 120);
            // Zunge: im Gelenkbereich voll, danach mit gefasten Laengskanten
            translate([gelenk_radius, -w2, 0]) cube([wangen_aussen + 2 - gelenk_radius, zunge_b, H]);
            hull() {
                translate([wangen_aussen + 2, -w2, 0]) cube([0.01, zunge_b, H]);
                fase_prisma(xa_z, xa_z + 0.01, zunge_b, H, zungen_fase);
            }
            if (kehle_eff > 0.2) fase_prisma(xa_z, kranz_kragen_radius + 0.5, zunge_b, H, zungen_fase);
            else if (xg_z > xa_z + 0.1) fase_prisma(xa_z, min(xg_z, kranz_kragen_radius) + 0.01, zunge_b, H, zungen_fase);
            // Uebergang zum Kragen: Hohlkehle oder 45-Grad-Verbreiterung (nur wenn Platz)
            if (kehle_eff > 0.2) kehle_lokal();
            else if (kranz_kragen_radius + 0.5 > xg_z + 0.5)
                uebergang(xg_z, zunge_b, kranz_kragen_radius + 0.5, wg_z, zungen_fase);
            zapfen(kranz_zapfen_d, kranz_zapfen_laenge, kranz_kragen_radius);
        }
        // 45-Grad-Unterseite hinten am Zungenknochen (druckbar ohne Stuetzen)
        translate([0, 0, 0]) rotate([90, 0, 0]) linear_extrude(height = zunge_b + 2, center = true)
            polygon([[gelenk_radius + 0.01, -1], [gelenk_radius + 0.01, 0],
                     [gelenk_radius - rk - 2, rk + 2], [gelenk_radius - rk - 2, -1]]);
        // dezente Rille auf der Zungenoberseite (nur ohne Beschriftung)
        if (rillen_tiefe > 0 && beschriftung_tiefe == 0 && xg_z - 4 > xa_z + 6)
            translate([0, 0, H - rillen_tiefe]) linear_extrude(height = 1) hull() {
                translate([xa_z + 6, 0]) circle(r = 2, $fn = 24);
                translate([xg_z - 4, 0]) circle(r = 2, $fn = 24);
            }
        // Kegelsenkungen, um gs2 tiefer versetzt -> Normalspalt g
        for (sg = [-1, 1])
            translate([gelenk_radius, sg*(w2 + g - kegel_h - gs2), zm]) rotate([-sg*90, 0, 0])
                cylinder(r1 = kegel_r - kegel_h, r2 = kegel_r - kegel_h + (kegel_h + gs2 + 2),
                         h = kegel_h + gs2 + 2, $fn = 64);
    }
}

module nase(b, neig, txt = "")
    rotate([0, 0, b])
        translate([gelenk_radius, 0, zm]) rotate([0, neig, 0]) translate([-gelenk_radius, 0, -zm])
            difference() {
                nase_lokal();
                // Gravur auf der Zungenoberseite, liest sich von der Hubmitte nach aussen
                if (beschriftung_tiefe > 0 && txt != "")
                    translate([(gelenk_radius + 3 + kranz_kragen_radius - 1)/2, 0, H - beschriftung_tiefe])
                        linear_extrude(height = beschriftung_tiefe + 1) rotate(cos(b) < 0 ? 180 : 0)
                            text(txt, size = min(schrift_h, zunge_b - 2*zungen_fase - 4), font = schrift,
                                 halign = "center", valign = "center");
            }

// ---------------------------------------------------------------------
rotate([0, 0, druck_drehung]) {
    hub_fest();
    for (i = [0:len(kranz_peilungen) - 1])
        nase(kranz_peilungen[i], vorschau_neigung, i < len(kranz_texte) ? kranz_texte[i] : "");
}

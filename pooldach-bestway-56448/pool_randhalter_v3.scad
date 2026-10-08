// =====================================================================
//  Randhalter mit Rundrohr-Clip und Stangen-Zapfen  -  parametrisch
//  Print-in-place: Clip-Scharnier, Rastverschluss und Stangengelenk
//  werden in einem Stueck gedruckt (liegend, Bauhoehe 40 mm).
//  Neigegelenk (Stange) waehlbar: "scheibe" (bewaehrter Stangenkopf
//  zwischen zwei Platten, nach dem Druck losbrechen) oder "knoechel"
//  (drei Knoechel mit 45-Grad-Kegeln). Nach dem Druck einmal durchbewegen.
//
//  Version 3: Gestaltung im Stil der Ausgangsmodelle - flache Tasche auf
//  der Gabel und verrundete senkrechte Aussenkanten an Flansch und Gabel,
//  abschaltbar in der Gruppe Gestaltung.
//
//  v2: Drehgelenk (Gierachse) zwischen Clip und Stangengelenk.
//  Die Gabel dreht um die Armachse, das Stangengelenk um seinen
//  Bolzen -> Kreuzgelenk. Die Stange stellt sich selbst auf die
//  Richtung zum Hub ein; ein Clip-Typ fuer alle Knoten.
//
//  Verbindung Clip - Gabel (Parameter "verbindung"), Gabel jeweils separat gedruckt:
//  "steckachse": gedruckte Achse Ø12 mit Kopf + gedruckter Sicherungsriegel,
//     ganz ohne Metall. Achse bei OFFENEM Clip von innen (Rohrbohrung) durch
//     Flansch und Gabel stecken, Riegel seitlich in die Gabeltasche schieben,
//     bis er ueber der Nut einrastet. Gierachse bleibt frei drehbar.
//  "schraube": Zylinderschraube M8 (DIN 912) + Sicherungsmutter (DIN 985).
//     Schraube bei offenem Clip von innen mit SW6 eindrehen; nach dem
//     Ausrichten maessig anziehen (ca. 4-5 Nm) -> Gierachse fixiert.
// =====================================================================

/* [Ausgabe] */
// Auszugebendes Teil; zum Export jedes Teil einzeln wählen
teil = 0; // [0:alles, 1:Clip, 2:Gabel mit Stange, 3:Steckachse, 4:Riegel]
// Lage der Gabel neben dem Clip bei „alles“ [mm]
gabel_versatz = [125, -10];
// Lage von Steckachse und Riegel bei „alles“ [mm]
achse_versatz = [70, -75];
// Montagevorschau (Teile zusammengebaut, nicht zum Export)
vorschau_montage = false; // [false, true]
// Gierwinkel (Drehung der Gabel um die Armachse) in der Montagevorschau [°]
vorschau_gier = 12; // [-60:1:60]

/* [Testdrucke] */
// Nur Passring (5 mm hoher Clip-Ring zum Testen des Sitzes am Rohr)
nur_passring = false; // [false, true]
// Nur Passbolzen (5 mm Zapfenscheibe zum Testen des Sitzes in der Muffe)
nur_passbolzen = false; // [false, true]

/* [Rohr-Clip] */
// Außendurchmesser des Poolrohrs [mm]
rohr_d = 49.5; // [34:0.1:70]
// Klemm-Untermaß (Clip-Innendurchmesser kleiner als Rohr) [mm]; größer = fester
klemm_untermass = 2.0; // [0:0.1:4]
// Wandstärke des Clip-Rings [mm]
wandstaerke = 8.25; // [7:0.25:12]

/* [Stangen-Zapfen] */
// Zapfendurchmesser [mm]; 50 = Muffe HT DN 50
zapfen_d = 50; // [32:0.5:60]
// Zapfenlänge [mm]
zapfen_laenge = 55; // [30:1:80]
// Querbohrung für Sicherungsschraube durch Muffe und Zapfen [mm]; 0 = keine
sicherung_d = 5.5; // [0:0.5:8]

/* [Drehgelenk (Clip – Gabel)] */
// Drehgelenk (Gabel dreht um die Armachse); aus = Stange direkt am Clip
drehgelenk = true; // [false, true]
// Verbindung Clip – Gabel: gedruckte Steckachse oder Schraube M8
verbindung = "steckachse"; // [steckachse, schraube]
// Flanschabstand (Anlagefläche der Gabel über dem Clip-Ring) [mm]
flansch_abstand = 12.5; // [10:0.5:25]
// Halbe Breite von Flansch und Gabel [mm]
flansch_halbbreite = 20; // [16:0.5:25]
// Sockeldicke der Gabel [mm]
sockel_t = 20; // [16:0.5:26]
// Fase (abgeschrägte Kante) an Flansch und Gabel [mm]
fase = 1.2; // [0:0.2:2]

/* [Steckachse] */
// Schaftdurchmesser [mm]
achse_d = 12; // [10:0.5:16]
// Kopfdurchmesser [mm]
achse_kopf_d = 20; // [16:0.5:26]
// Kopfhöhe [mm]
achse_kopf_h = 6; // [4:0.5:8]
// Spiel (Luftspalt) in den Bohrungen [mm]
achse_spiel = 0.3; // [0.2:0.05:0.6]
// Spalt zwischen Flansch und Gabel [mm]
achse_spalt = 0.5; // [0.3:0.1:1.5]
// Tiefe der Nut für den Sicherungsriegel [mm]
nut_tiefe = 2; // [1.5:0.25:3]
// Riegeldicke [mm]
riegel_t = 3; // [2.5:0.5:4]
// Lage der Nut ab Anlagefläche der Gabel [mm]
nut_lage = 6; // [4:0.5:10]

/* [Schraubversion] */
// Dicke der Unterlegscheibe [mm]
scheibe_t = 1.6; // [0:0.1:3]
// Schraubendurchmesser [mm]; M8 = 8
schraube_d = 8; // [6:1:10]
// Kopfdurchmesser der Zylinderschraube [mm]; M8 = 13
kopf_d = 13; // [10:0.5:17]
// Kopfhöhe der Zylinderschraube [mm]; M8 = 8
kopf_h = 8; // [5:0.5:10]
// Schlüsselweite der Mutter [mm]; M8 = 13
mutter_sw = 13; // [10:0.5:17]
// Höhe der Sicherungsmutter [mm]; M8 = 8
mutter_h = 8; // [5:0.5:10]
// Lage der Mutter ab Anlagefläche der Gabel [mm]
mutter_abstand = 4; // [3:0.5:8]

/* [Gestaltung] */
// Taschentiefe (flache Vertiefung auf der Gabel) [mm]; 0 = keine
taschen_tiefe = 1.5; // [0:0.25:3]
// Taschenrand (Abstand zu Außenkante und Gelenk) [mm]
taschen_rand = 3; // [2:0.5:6]
// Eckenradius der Tasche [mm]
taschen_ecke = 2; // [0:0.5:5]
// Eckenradius der senkrechten Außenkanten an Flansch und Gabel [mm]; 0 = eckig
rundung_r = 2; // [0:0.5:4]

/* [Neigegelenk (Stange)] */
// Bauart: scheibe (bewährt, nach dem Druck mit etwas Kraft lösen) oder knoechel (drei Kegelknöchel, ungetestet)
neigegelenk = "scheibe"; // [scheibe, knoechel]
// Nur scheibe: Spalt über und unter dem Stangenkopf [mm]; größer = leichter zu lösen
scheibe_spalt = 0.48; // [0.3:0.02:1.0]
// Nur knoechel: Knöchelradius [mm]
ng_r = 12; // [9:0.5:15]
// Nur knoechel: Kegelhöhe zwischen den Knöcheln [mm]
ng_hk = 8; // [4:0.5:10]
// Nur knoechel: halbe Halsbreite (Ansatz an den Knöcheln) [mm]; kleiner = größerer Schwenkbereich
ng_hals = 8.4; // [6:0.2:10]

/* [Spiel und Druckstellung] */
// Spiel (Luftspalt) in Clip-Scharnier und Verschluss [mm]
spiel = 0.4; // [0.25:0.05:0.6]
// Spiel im Neigegelenk [mm]
gelenk_spiel = 0.48; // [0.3:0.02:0.7]
// Höhe des Rastzahns im Verschluss [mm]; größer = rastet fester
zahn_hoehe = 1.3; // [0.8:0.1:2.0]
// Öffnungswinkel des Clips in Druckstellung [°]
druck_offen = 46; // [30:1:60]
// Winkel der Stange in Druckstellung [°]
stangen_winkel = 132.8; // [45:0.5:135]

/* [Hidden] */
$fn = 96;
H = nur_passring ? 5 : 40;            // Bauhoehe dynamisch anpassen
R  = (rohr_d - klemm_untermass)/2;    // Clip-Innenradius
Ro = R + wandstaerke;                 // Clip-Aussenradius
g  = spiel;
assert(2*R >= 30, "Clip-Innendurchmesser muss mindestens 30 mm sein");
assert(2*R <= 70, "Clip-Innendurchmesser darf hoechstens 70 mm sein");
assert(wandstaerke >= 7, "Wandstaerke mindestens 7 mm");

// ---------------- Scharnier ----------------
rk  = 7;                                      // Radius Scharnierglieder
hk  = nur_passring ? 0.6 : 4;                 // Kegelhoehe (fuer 5mm Hoehe flacher)
dzh = g*0.7;                                  // halber vertikaler Kegelspalt (Normalspalt = g)
RH  = R + 3.35 + rk + g;                      // Abstand Scharnierachse - Rohrmitte
phH = 211.3;                                  // Lage des Scharniers [Grad]
A   = RH*[cos(phH), sin(phH)];
u   = [cos(phH), sin(phH)];                   // Richtung Rohrmitte -> Achse
nv  = [-u[1], u[0]];
sF  = -1;                                     // Seite der festen Haelfte (bzgl. nv)

// Dynamische Anzahl der Gelenke (3 Gelenke beim 5mm Test, sonst 5)
Zb  = nur_passring ? [0, 1.5, 3.5, 5] : [0, 8, 16, 24, 32, 40]; 
own = nur_passring ? [0, 1, 0] : [0, 1, 0, 1, 0]; // 0 = fest, 1 = beweglich
num_k = len(own);

psiP = phH - 180;                             // Richtung Achse -> Rohrmitte

// ---------------- Verschluss ----------------
rs   = RH + R + 2.25;         // Gleitradius Zunge/Lasche (um Scharnierachse)
rho4 = rs - 2.42;
psi4 = psiP - acos((RH*RH + rho4*rho4 - R*R)/(2*RH*rho4));   // Zungenspitze
kd   = 180/(PI*rs);           // Grad je mm auf Radius rs
function pa(s) = psi4 - s*kd; // Winkel s mm vor der Zungenspitze
gm   = g*1.146;               // Winkelspalt als Bogenlaenge [mm]
e    = zahn_hoehe;
psiA = pa(42.54);  psi1 = pa(26.18);  psiB = pa(-8.73);

// ---------------- Arm / Gelenk ----------------
Dp  = Ro + 36.2;              // Abstand Rohrmitte - Gelenkachse
Pv  = [0, Dp];
kn_r  = 25;                   // Radius Gelenkkopf (Bauart scheibe); legt auch die Lage des Gelenks fest
pin_r = 12.5;                 // Bolzen (Bauart scheibe)
knoechel = neigegelenk == "knoechel";

// ---------------- Neigegelenk (print-in-place) ----------------
// Drei Knoechel um eine senkrechte Achse: unten und oben Gabel/Arm (Besitzer 0),
// in der Mitte die Stange (Besitzer 1). Die Knoechel beruehren sich nur ueber
// 45-Grad-Kegel mit Normalspalt gelenk_spiel - wie beim Clip-Scharnier.
// Beide Blaetter stehen in voller Hoehe auf dem Druckbett; es gibt keine
// flach uebereinanderliegenden Flaechen, die verschmelzen koennten.
ng_own = [0, 1, 0];
ng_Z   = [0, H/3, 2*H/3, H];
ng_dz  = gelenk_spiel*0.7;                    // halber senkrechter Kegelspalt
if (!nur_passring) {
    assert(ng_hk < ng_r - 1, "ng_hk muss kleiner als ng_r - 1 sein");
    assert(ng_hals < ng_r - 1, "ng_hals muss kleiner als ng_r - 1 sein");
    assert(H/3 - ng_hk - 2*ng_dz >= 3, "ng_hk zu gross fuer die Knoechelhoehe");
}
// Schwenkbereich (Stangenrichtung in Grad ab Querachse, 90 = entlang des Arms), grob:
ng_halb = asin(ng_hals/(ng_r + gelenk_spiel));
echo(str("Neigegelenk: Haelse belegen je +/-", round(ng_halb), " Grad am Knoechel"));
function ng_bnd(j, r) = ng_Z[j] + min(ng_r - r, ng_hk);
function ng_bot(i, r) = i == 0 ? 0 : ng_bnd(i, r) + ng_dz;
function ng_top(i, r) = i == 2 ? H : ng_bnd(i + 1, r) - ng_dz;
module ng_knuckle(i) rotate_extrude($fn = 96)
    polygon([[0, ng_bot(i, 0)], [ng_r - ng_hk, ng_bot(i, ng_r - ng_hk)], [ng_r, ng_bot(i, ng_r)],
             [ng_r, ng_top(i, ng_r)], [ng_r - ng_hk, ng_top(i, ng_r - ng_hk)], [0, ng_top(i, 0)]]);
module ng_knuckles(o) for (i = [0:2]) if (ng_own[i] == o) ng_knuckle(i);
// Freischnitt im Blatt des Besitzers o (Achse im Ursprung)
module ng_clear(o) {
    translate([0, 0, -1]) cylinder(r = ng_r - 0.05, h = H + 2, $fn = 96);
    for (i = [0:2]) if (ng_own[i] != o)
        translate([0, 0, i == 0 ? -1 : ng_Z[i] - 0.3])
            cylinder(r = ng_r + gelenk_spiel,
                     h = (i == 0 ? 1 : 0.3) + (ng_Z[i + 1] - ng_Z[i]) + (i == 2 ? 1 : 0.3), $fn = 96);
}

// ======================= Hilfsfunktionen =======================
function dir(a) = [cos(a), sin(a)];
function pt(psi, rho) = A + rho*dir(psi);
function rfar(psi, r) =
    let(b = A*dir(psi), c = A*A - r*r, dsc = b*b - c)
    dsc > 0 ? -b + sqrt(dsc) : -b;
function smooth(t) = let(x = max(0, min(1, t))) x*x*(3 - 2*x);
function prof(psi) =
    let(base = rfar(psi, Ro),
        tA = pa(42.54), t1 = pa(28.36),
        tgt = lookup(psi, [[pa(28.36), rs+7.1], [pa(16.36), rs+7.1], [pa(10.91), rs+5.1],
                           [pa(-2.18), rs+5.1], [pa(-8.73), 0]]),
        k = psi < t1 ? base + (tgt - base)*smooth((psi - tA)/(t1 - tA)) : tgt)
    max(k, base);
function rin(psi) = rfar(psi, R) - 1;
function lo_of(m, p) = m == 0 ? rin(p) : m == 1 ? rs + g : m == 2 ? rfar(p, R) - 2 : 0;
function hi_of(m, p) = m == 0 ? prof(p) : m == 1 ? rs : m == 2 ? rs + 12 : 0;
function steps(a, b) = let(n = max(2, ceil(abs(b - a)/0.25))) [for (i = [0:n]) a + (b - a)*i/n];
function region(a, b, mlo, mhi) =
    let(ps = steps(a, b), n = len(ps))
    concat([for (i = [0:n-1]) pt(ps[i], hi_of(mhi, ps[i]))],
           [for (i = [0:n-1]) pt(ps[n-1-i], lo_of(mlo, ps[n-1-i]))]);
function capsule(p0, p1, r) =
    let(dd = (p1 - p0)/norm(p1 - p0), b = atan2(dd[0], -dd[1]))
    concat([for (i = [0:24]) p1 + r*dir(b - 180*i/24)],
           [for (i = [0:24]) p0 + r*dir(b + 180 - 180*i/24)]);

// ======================= Clip-Bauteile =======================
module ext(h = H) linear_extrude(height = h) children();

module annulus() difference() {
    cylinder(r = Ro, h = H, $fn = 240);
    translate([0, 0, -1]) cylinder(r = R - 0.5, h = H + 2, $fn = 240);
}
module halfplane(sg) {      
    o = sg*nv*g/2; f = 300;
    translate([0, 0, -1]) ext(H + 2)
        polygon([o - u*f, o + u*RH, o + u*RH + sg*nv*f, o - u*f + sg*nv*f]);
}
module nearside() {
    f = 300;
    translate([0, 0, -1]) ext(H + 2)
        polygon([A + nv*f, A - nv*f, A - nv*f - u*f, A + nv*f - u*f]);
}
module ear(sg) ext() polygon(concat(
    [for (a = [0:0.5:35]) (Ro + (RH + 1 - Ro)*pow(max(0, 1 - a/22), 1.5))*dir(phH + sg*a)],
    [for (a = [35:-0.5:0]) (R - 1)*dir(phH + sg*a)]));
module bore() translate([0, 0, -1]) cylinder(r = R/cos(180/360), h = H + 2, $fn = 360);  

function bnd(j, r) = Zb[j] + min(rk - r, hk);
function kbot(i, r) = i == 0 ? 0 : bnd(i, r) + dzh;
function ktop(i, r) = i == (num_k - 1) ? H : bnd(i + 1, r) - dzh;
module knuckle(i) translate([A[0], A[1], 0]) rotate_extrude($fn = 128)
    polygon([[0, kbot(i, 0)], [rk - hk, kbot(i, rk - hk)], [rk, kbot(i, rk)],
             [rk, ktop(i, rk)], [rk - hk, ktop(i, rk - hk)], [0, ktop(i, 0)]]);
module knuckles(o) for (i = [0:num_k - 1]) if (own[i] == o) knuckle(i);
module hinge_clear(o) {
    translate([A[0], A[1], -1]) cylinder(r = rk - 0.05, h = H + 2, $fn = 128);
    for (i = [0:num_k - 1]) if (own[i] != o)
        translate([A[0], A[1], i == 0 ? -1 : Zb[i] - 0.3])
            cylinder(r = rk + g, h = (i == 0 ? 1 : 0.3) + (Zb[i + 1] - Zb[i]) + (i == (num_k - 1) ? 1 : 0.3), $fn = 128);
}

latch_zone_pts = region(pa(40.36), pa(-6.54), 2, 2);
module latch_zone() translate([0, 0, -1]) ext(H + 2) polygon(latch_zone_pts);
module fixed_latch() {
    difference() {
        ext() polygon(region(psi1, pa(-gm - 1.09), 1, 0));          
        translate([0, 0, -1]) ext(H + 2) polygon([pt(pa(21.16), rs - 0.01), pt(pa(21.16), rs + g),
            pt(pa(21.51), rs + e + g), pt(pa(17.89), rs + e + g), pt(pa(13.85), rs + g), pt(pa(13.85), rs - 0.01)]);
    }
    ext() polygon(region(pa(-gm), psiB, 0, 0));                            
    pf = pa(23.56);
    ext() polygon(capsule(pt(pf, prof(pf) - 3.5), pt(pf, prof(pf) + 4.0), 2.2));   
}
module moving_latch() {
    ext() polygon(region(psiA, pa(26.18 + gm), 0, 0));                    
    ext() polygon(region(pa(27.73), psi4, 0, 1));                         
    ext() polygon([pt(pa(20.73), rs - 0.3), pt(pa(20.73), rs), pt(pa(21.05), rs + e),
                   pt(pa(18.0), rs + e), pt(pa(14.18), rs), pt(pa(14.18), rs - 0.3)]);   
    pm = pa(33.27);
    ext() polygon(capsule(pt(pm, prof(pm) - 4.5), pt(pm, prof(pm) + 3.2), 2.6));   
}

// ======================= Arm mit Gelenkachse =======================
module arm() { if (!knoechel) arm_scheibe(); else arm_knoechel(); }
module arm_scheibe() {
    difference() {
        ext() hull() {
            translate(Pv) circle(r = 13);
            polygon([for (a = [40:5:140]) (Ro - 1.5)*dir(a)]);
        }
        translate([Pv[0], Pv[1], 10 - scheibe_spalt]) cylinder(r = kn_r + gelenk_spiel, h = 20 + 2*scheibe_spalt, $fn = 160);
        translate([Pv[0], Pv[1], 10 - scheibe_spalt]) linear_extrude(height = 20 + 2*scheibe_spalt)
            polygon(concat([[0, 0]], [for (a = [-50:2:230]) (33.2 + gelenk_spiel)*dir(a)]));
    }
    translate([Pv[0], Pv[1], 0]) cylinder(r = pin_r, h = H, $fn = 128);
}
module arm_knoechel() {
    difference() {
        ext() hull() {
            translate([-ng_hals, Pv[1] - 1]) square([2*ng_hals, 1]);
            polygon([for (a = [40:5:140]) (Ro - 1.5)*dir(a)]);
        }
        translate([Pv[0], Pv[1], 0]) ng_clear(0);
    }
    translate([Pv[0], Pv[1], 0]) ng_knuckles(0);
}

// ======================= Drehgelenk (v2) =======================
// Clip-Seite: Flansch auf der Armachse (+y), Anlageflaeche bei y = Df.
// Gabel-Seite (eigenes Druckteil): Anlageflaeche bei y = 0, Stangengelenk bei Pb.
Df    = Ro + flansch_abstand;                 // Flanschflaeche (Clip-Koordinaten)
zm    = H/2;                                  // Hoehe der Drehachse
cb_y  = R + kopf_h + 0.5;                     // Boden der Kopfsenkung (Clip)
Pb    = [0, sockel_t + kn_r + gelenk_spiel + 2];   // Stangengelenk in der Gabel
mut_e = mutter_sw/cos(30);                    // Eckmass der Mutter
steck = drehgelenk && verbindung == "steckachse";
spalt = steck ? achse_spalt : scheibe_t;       // Abstand Flansch - Gabel
// Steckachse (Gabel-Koordinaten: y = 0 an der Gabel-Anlageflaeche)
ak_y   = R + achse_kopf_h + 0.5;               // Boden der Kopfsenkung (Clip-Koordinaten)
a_kern = achse_d/2 - nut_tiefe;                // Radius im Nutgrund
a_ende = nut_lage + riegel_t + 0.2 + 3;        // Achsende in der Gabel
achse_l = (Df - ak_y) + spalt + a_ende;        // Schaftlaenge unter dem Kopf
assert(flansch_halbbreite <= H/2 + 2, "Flansch zu breit");
if (steck) {
    assert(a_ende + 2 <= sockel_t, "Sockel zu duenn fuer die Steckachse");
    assert(a_kern >= 3.5, "Nut zu tief fuer den Achsdurchmesser");
    assert(achse_kopf_d/2 + 0.6 < H/2, "Achskopf zu gross");
} else if (drehgelenk) {
    assert(mutter_abstand + mutter_h + 2 < sockel_t, "Sockel zu duenn fuer die Mutter");
}
if (steck) echo(str("Steckachse: Schaft Ø", achse_d, " x ", achse_l, " mm, Kopf Ø", achse_kopf_d, " x ", achse_kopf_h, " mm"));
// Rechnerische Schraubenlaenge (Kopfauflage bis Ende) und Ende in der Gabel
schraube_l_min = (Df - cb_y) + scheibe_t + mutter_abstand + mutter_h + 1.5;
if (drehgelenk && !steck)
    echo(str("Drehgelenk: Schraube M", schraube_d, " DIN 912, Laenge >= ", schraube_l_min,
             " mm  (Ende max. ", sockel_t - 1, " mm hinter Gabel-Anlageflaeche)"));
if (drehgelenk)
    echo(str("Stangengelenk liegt ", Df + spalt + Pb[1], " mm ueber der Rohrmitte (in Armrichtung)"));

// Tropfenprofil fuer liegende Bohrungen (Achse y, Spitze zeigt nach +z)
module teardrop2d(r) union() {
    circle(r = r, $fn = 48);
    polygon([[r*cos(45), -r*sin(45)], [0, -r*sqrt(2)], [-r*cos(45), -r*sin(45)], [0, 0]]);
}
module bohrung_y(r, y0, y1)
    translate([0, y0, zm]) rotate([-90, 0, 0]) linear_extrude(height = y1 - y0) teardrop2d(r);

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
// verrundet die (konvexen) Ecken eines 2D-Umrisses
module rund2d(r) if (r > 0) offset(r = r, $fn = 24) offset(delta = -r) children(); else children();
module arm_flansch() {
    fase_extrude(H, fase) rund2d(rundung_r) hull() {
        polygon([for (a = [40:5:140]) (Ro - 1.5)*dir(a)]);
        translate([-flansch_halbbreite, Df - 2]) square([2*flansch_halbbreite, 2]);
    }
}
// Bohrung + Kopfsenkung, wird nach der Vereinigung vom Clip abgezogen
module flansch_bohrungen() {
    bohrung_y(schraube_d/2 + 0.25, -1, Df + 1);
    bohrung_y(kopf_d/2 + 0.6, -1, cb_y);
}

// ---- Gedruckte Steckachse ----
// Achse (eigenes Druckteil), liegend gedruckt: Achse entlang x, unten 1,5 mm abgeflacht.
achse_flach = 1.5;                                 // Abflachung unten (Druckauflage)
module steckachse() {
    fl = achse_flach;
    difference() {
        union() {
            rotate([0, 90, 0]) cylinder(d = achse_kopf_d, h = achse_kopf_h, $fn = 96);
            translate([achse_kopf_h, 0, 0]) rotate([0, 90, 0]) {
                cylinder(d = achse_d, h = achse_l - 1, $fn = 64);
                translate([0, 0, achse_l - 1]) cylinder(d1 = achse_d, d2 = achse_d - 2, h = 1, $fn = 64);
            }
        }
        // Nut fuer den Riegel (Abstand vom Kopf = Schaftlaenge bis Nutbeginn)
        translate([achse_kopf_h + achse_l - a_ende + nut_lage, 0, 0]) rotate([0, 90, 0])
            difference() {
                cylinder(r = achse_d, h = riegel_t + 0.2, $fn = 64);
                translate([0, 0, -1]) cylinder(r = a_kern, h = riegel_t + 2.2, $fn = 64);
            }
        // gemeinsame Auflageflaeche fuer Kopf und Schaft
        translate([-1, -50, -50]) cube([achse_l + achse_kopf_h + 2, 100, 50 - (achse_d/2 - fl)]);
    }
}
// Sicherungsriegel (eigenes Druckteil, flach). Lage in der Gabel: Achsmitte bei x = 0,
// Riegel wird von +x eingeschoben; der Schlitz ist zum vorderen Ende (-x) offen.
riegel_b  = 2*a_kern + 12;                        // Hoehe (z in der Gabel)
riegel_x0 = -(flansch_halbbreite - 3);            // vorderes Ende
riegel_l  = flansch_halbbreite - riegel_x0;       // bis zur Gabelseite
module riegel() {
    difference() {
        union() {
            translate([riegel_x0, -riegel_b/2, 0]) cube([riegel_l, riegel_b, riegel_t]);
            translate([flansch_halbbreite - 0.01, -riegel_b/2, 0]) cube([2.5, riegel_b, riegel_t + 2]);   // Griffleiste
        }
        translate([0, 0, -1]) linear_extrude(height = riegel_t + 2) hull() {
            circle(r = a_kern + 0.15, $fn = 48);
            translate([riegel_x0 - 5, 0]) circle(r = a_kern + 0.15, $fn = 48);
        }
    }
    // Rastnasen am Schlitz kurz vor der Mitte: verengen auf ca. Nutgrund - 0,8 mm
    for (sg = [-1, 1]) translate([-(a_kern + 1.2), sg*(a_kern + 0.15), 0])
        cylinder(r = 0.55, h = riegel_t, $fn = 16);
}
// Ausschnitte in der Gabel fuer die Steckachse
module steck_gabel_cuts() {
    bohrung_y(achse_d/2 + achse_spiel, -1, a_ende + 0.5);
    // Riegeltasche, seitlich offen (+x)
    translate([riegel_x0 - 0.3, nut_lage - 0.1, zm - riegel_b/2 - 0.3])
        cube([riegel_l + 20, riegel_t + 0.4, riegel_b + 0.6]);
}
// Ausschnitte im Clip-Flansch: Bohrung und Kopfsenkung
module steck_clip_cuts() {
    bohrung_y(achse_d/2 + achse_spiel, -1, Df + 1);
    bohrung_y(achse_kopf_d/2 + 0.6, -1, ak_y);
}

// Gelenkgabel mit Stangenhalterung (print-in-place)
module gabel_umriss2d() hull() {
    translate([-flansch_halbbreite, 0]) square([2*flansch_halbbreite, sockel_t]);
    if (knoechel) translate([-ng_hals, Pb[1] - 1]) square([2*ng_hals, 1]);
    else translate(Pb) circle(r = 13);
}
// Tasche auf der Gabel-Oberseite: Abstand zum Rand und zum Gelenkbereich
module gabel_tasche2d() rund2d(taschen_ecke) difference() {
    offset(delta = -(taschen_rand + fase)) rund2d(rundung_r) gabel_umriss2d();
    translate(Pb) circle(r = (knoechel ? ng_r + gelenk_spiel : pin_r) + taschen_rand, $fn = 64);
}
module gabel_tasche() {
    n = max(1, ceil(taschen_tiefe/0.25));
    dz = taschen_tiefe/n;
    for (i = [0:n-1])
        translate([0, 0, H - taschen_tiefe + i*dz]) linear_extrude(height = (i == n-1) ? dz + 1 : dz + 0.01)
            offset(delta = -(taschen_tiefe - (i + 1)*dz)) gabel_tasche2d();
}
module gabel() {
    difference() {
        fase_extrude(H, fase) rund2d(rundung_r) gabel_umriss2d();
        if (taschen_tiefe > 0) gabel_tasche();
        if (knoechel) translate([Pb[0], Pb[1], 0]) ng_clear(0);
        else {
            translate([Pb[0], Pb[1], 10 - scheibe_spalt]) cylinder(r = kn_r + gelenk_spiel, h = 20 + 2*scheibe_spalt, $fn = 160);
            translate([Pb[0], Pb[1], 10 - scheibe_spalt]) linear_extrude(height = 20 + 2*scheibe_spalt)
                polygon(concat([[0, 0]], [for (a = [-50:2:230]) (33.2 + gelenk_spiel)*dir(a)]));
        }
        if (steck) steck_gabel_cuts();
        else {
            // Schraubenbohrung (endet im Sockel)
            bohrung_y(schraube_d/2 + 0.25, -1, sockel_t - 1);
            // Mutterntasche, seitlich offen (+x) zum Einschieben der Mutter
            translate([0, mutter_abstand, zm]) rotate([-90, 0, 0]) linear_extrude(height = mutter_h + 0.4)
                hull() {
                    circle(d = mut_e + 0.6, $fn = 6);
                    translate([flansch_halbbreite + 5, 0]) circle(d = mut_e + 0.6, $fn = 6);
                }
        }
    }
    if (knoechel) translate([Pb[0], Pb[1], 0]) ng_knuckles(0);
    else translate([Pb[0], Pb[1], 0]) cylinder(r = pin_r, h = H, $fn = 128);
    translate([Pb[0], Pb[1], 0]) rotate([0, 0, stangen_winkel]) bar_local();
}
// Lage der Gabel am Clip (Montagevorschau)
module gabel_montiert(gier)
    translate([0, Df + spalt, zm]) rotate([0, gier, 0]) translate([0, 0, -zm]) gabel();

// ======================= Bauteile =======================
module fixed_part() difference() {
    union() {
        difference() {
            union() {
                intersection() { annulus(); halfplane(sF); }
                intersection() { ear(sF); halfplane(sF); nearside(); }
            }
            hinge_clear(0);
            latch_zone();
        }
        knuckles(0);
        fixed_latch();
        // Arm nicht generieren, wenn wir nur den Passring testen wollen
        if (!nur_passring) { if (drehgelenk) arm_flansch(); else arm(); }
    }
    bore();
    if (!nur_passring && drehgelenk) { if (steck) steck_clip_cuts(); else flansch_bohrungen(); }
}
module moving_part() difference() {
    union() {
        difference() {
            union() {
                intersection() { annulus(); halfplane(-sF); }
                intersection() { ear(-sF); halfplane(-sF); nearside(); }
            }
            hinge_clear(1);
            latch_zone();
        }
        knuckles(1);
        moving_latch();
    }
    bore();
}

// ======================= Stangenhalterung =======================
Rz = zapfen_d/2;
zc = min(0.8*Rz, 40/2);                // feste Z-Berechnung fuer volles Bauteil 
ztop = min(zc + 0.8*Rz, 40);
module bar_local() { if (!knoechel) bar_local_scheibe(); else bar_local_knoechel(); }
module bar_local_scheibe() {
    difference() {
        union() {
            translate([0, 0, 10]) linear_extrude(height = 20) hull() {
                circle(r = kn_r, $fn = 160);
                translate([0, -kn_r]) square([20.3, 2*kn_r]);
            }
            intersection() {
                translate([20, 0, zc]) rotate([0, 90, 0]) rotate_extrude($fn = 160)
                    polygon([[0, 0], [Rz, 0], [Rz, zapfen_laenge - 1.5], [Rz - 1.5, zapfen_laenge], [0, zapfen_laenge]]);
                translate([0, -50, 0]) cube([zapfen_laenge + 30, 100, ztop]);
            }
            intersection() {
                rotate([90, 0, 0]) translate([0, 0, -kn_r]) linear_extrude(height = 2*kn_r)
                    polygon([[15, 10], [20.3, 4.7], [20.3, 35.3], [15, 30]]);
                translate([14, 0, 20]) rotate([0, 90, 0]) cylinder(r = kn_r, h = 7, $fn = 160);
                translate([0, -50, 0]) cube([40, 100, max(ztop, 30)]);
            }
        }
        translate([0, 0, -1]) cylinder(r = pin_r + gelenk_spiel, h = 40 + 2, $fn = 128); // feste Hoehe
        // Querbohrung fuer Sicherungsschraube (liegend, Tropfenform)
        if (sicherung_d > 0) translate([20 + zapfen_laenge/2, 0, zc]) rotate([90, 0, 0])
            linear_extrude(height = zapfen_d + 10, center = true) union() {
                circle(r = sicherung_d/2, $fn = 32);
                polygon([[sicherung_d/2*cos(45), sicherung_d/2*sin(45)], [0, sicherung_d/2*sqrt(2)],
                         [-sicherung_d/2*cos(45), sicherung_d/2*sin(45)], [0, 0]]);
            }
        translate([0, 0, -1]) linear_extrude(height = 40 + 2) hull() {
            translate([35, 0]) circle(r = 0.2*zapfen_d);
            translate([20 + zapfen_laenge - 13 - 0.2*zapfen_d + 10, 0]) circle(r = 0.2*zapfen_d);
        }
    }
}
module bar_local_knoechel() {
    difference() {
        union() {
            // Blatt der Stange: steht in voller Hoehe auf dem Bett, mittlerer Knoechel
            difference() {
                translate([1, -ng_hals, 0]) cube([19.5, 2*ng_hals, H]);
                ng_clear(1);
            }
            ng_knuckles(1);
            intersection() {
                translate([20, 0, zc]) rotate([0, 90, 0]) rotate_extrude($fn = 160)
                    polygon([[0, 0], [Rz, 0], [Rz, zapfen_laenge - 1.5], [Rz - 1.5, zapfen_laenge], [0, zapfen_laenge]]);
                translate([0, -50, 0]) cube([zapfen_laenge + 30, 100, ztop]);
            }
        }
        // Querbohrung fuer Sicherungsschraube (liegend, Tropfenform)
        if (sicherung_d > 0) translate([20 + zapfen_laenge/2, 0, zc]) rotate([90, 0, 0])
            linear_extrude(height = zapfen_d + 10, center = true) union() {
                circle(r = sicherung_d/2, $fn = 32);
                polygon([[sicherung_d/2*cos(45), sicherung_d/2*sin(45)], [0, sicherung_d/2*sqrt(2)],
                         [-sicherung_d/2*cos(45), sicherung_d/2*sin(45)], [0, 0]]);
            }
        translate([0, 0, -1]) linear_extrude(height = 40 + 2) hull() {
            translate([35, 0]) circle(r = 0.2*zapfen_d);
            translate([20 + zapfen_laenge - 13 - 0.2*zapfen_d + 10, 0]) circle(r = 0.2*zapfen_d);
        }
    }
}
module bar_holder() translate([Pv[0], Pv[1], 0]) rotate([0, 0, stangen_winkel]) bar_local();

// ======================= Test-Module =======================
module test_passbolzen() {
    linear_extrude(height = 5)
    difference() {
        circle(r = zapfen_d / 2, $fn = 160);
        circle(r = 15, $fn = 160); // 3 cm Greifloch = 15 mm Radius
    }
}

// ======================= Ausgabe =======================
// Parameter "teil" (oben in der Gruppe Ausgabe) waehlt das Druckteil:
//   0 = alles in Druckanordnung (Vorschau)
//   1 = Clip: beide Haelften mit Scharnier (print-in-place; ohne Drehgelenk inkl. Stange)
//   2 = Gelenkgabel mit Stange (print-in-place)
//   3 = Steckachse (nur bei verbindung = "steckachse")
//   4 = Sicherungsriegel (nur bei verbindung = "steckachse")
// export_randhalter_teile.bat erzeugt alle vier Dateien auf einmal.

module clip_teil() {
    fixed_part();
    translate([A[0], A[1], 0]) rotate([0, 0, -druck_offen]) translate([-A[0], -A[1], 0]) moving_part();
    if (!drehgelenk) bar_holder();
}
module achse_teil()  translate([0, 0, achse_d/2 - achse_flach]) steckachse();

if (teil > 0 && !nur_passring && !nur_passbolzen)
    echo(str("Export: Teil ", teil, " = ",
             teil == 1 ? "Clip" : teil == 2 ? "Gelenkgabel mit Stange" : teil == 3 ? "Steckachse" : "Sicherungsriegel"));
if ((teil == 2 && !drehgelenk) || ((teil == 3 || teil == 4) && !steck))
    echo("HINWEIS: Dieses Teil gibt es bei den gewaehlten Einstellungen nicht - die Ausgabe ist leer.");

if (nur_passring) {
    // Generiert nur die beiden Clip-Hälften im Druckwinkel
    fixed_part();
    translate([A[0], A[1], 0]) rotate([0, 0, -druck_offen]) translate([-A[0], -A[1], 0]) moving_part();
} else if (nur_passbolzen) {
    // Generiert nur die Bolzenscheibe
    test_passbolzen();
} else if (vorschau_montage) {
    // Montagevorschau (nicht zum Drucken)
    fixed_part();
    translate([A[0], A[1], 0]) rotate([0, 0, -druck_offen]) translate([-A[0], -A[1], 0]) moving_part();
    if (!drehgelenk) bar_holder();
    else {
        gabel_montiert(vorschau_gier);
        if (steck) {
            // Achse von innen durch Flansch und Gabel, Riegel in der Tasche
            translate([0, ak_y - achse_kopf_h, zm]) rotate([0, 0, 90]) steckachse();
            translate([0, Df + spalt, zm]) rotate([0, vorschau_gier, 0]) translate([0, 0, -zm])
                translate([0, nut_lage + riegel_t + 0.1, zm]) rotate([90, 0, 0]) riegel();
        }
    }
} else if (teil == 0) {
    clip_teil();
    if (drehgelenk) translate([gabel_versatz[0], gabel_versatz[1], 0]) gabel();
    if (steck) translate([achse_versatz[0], achse_versatz[1], 0]) {
        achse_teil();
        translate([55, 0, 0]) riegel();
    }
} else if (teil == 1) clip_teil();
else if (teil == 2 && drehgelenk) gabel();
else if (teil == 3 && steck) achse_teil();
else if (teil == 4 && steck) riegel();

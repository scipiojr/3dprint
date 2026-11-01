// =====================================================================
//  Kompakte Lasercutter-Filterbox (100er Schlauch -> Ventilator-Muffe), DRUCKOPTIMIERT UND MODULAR
//  OpenSCAD 2021.01 oder neuer.   Baut auf dem Abluft-System auf (Basis + Ventilator-Datei).
//
//  Statt eines 510-cm3-Gehaeuses mit sehr vielen Stuetzen (ca. 1,5 Tage) besteht der Kasten jetzt aus
//  drei stuetzfrei druckbaren Gehaeuseteilen, die ineinandergesteckt, eingerastet (Rastwulst und -nut, keine Schrauben) und verklebt werden:
//
//    rahmen    Filterrahmen: Kammer fuer Kassette + G4-Vlies, Stuetzgitter, Deckelkragen, Scharnier, Verschluss
//    einlass   Einlass: 100er Magnetflansch des Systems (passt auf Schlauchanschluss / Ventilator-Adapter)
//              -> Trichter -> Steckzapfen mit Kassettenanschlag
//    auslass   Auslass: Trichter -> Ventilator-Muffe (146,4 mm, O-Ring-Nut, Schraublöcher wie Ventilator-Adapter)
//    lid       Klappdeckel: hohl (Boden + Rippen) statt 12 mm Vollmaterial; liegt zum Druck auf der Aussenseite
//    cartridge Filterkassette (geschlossener Rahmen mit Traeger-Diagonalgitter und Griffasche)      jig, jig_clamp   Schneidlehre fuer das Vlies (unveraendert)
//
//  Druckpose: alle Teile liegen so, dass sie ohne Stuetzen druckbar sind (siehe README/agent.md):
//    rahmen: wie gebaut (Deckelseite oben) | einlass: Magnetflaeche auf dem Bett | auslass: Muffenmuendung auf dem Bett
//  Weitere Teile aus dem System: Dichtung Ventilator-Muffe = dichtung_ventilator_muffe_tpu.stl,
//  Dichtung 100er Magnetflaeche = dichtung_100_anschluss_tpu.stl.
// =====================================================================

/* [Export und Ansicht] */
auswahl = "assembly"; // ["assembly", "rahmen", "einlass", "auslass", "lid", "cartridge", "jig", "jig_clamp", "fuesse"]
// Einlass: "stutzen" = glatter ø100-Stutzen (20 mm lang, 2 mm Wand, Schlauch wird aufgeschoben), "magnet" = 100er Magnetflansch des Systems
einlass_typ = "stutzen"; // ["stutzen", "magnet"]

/* [Hidden] */
include <abluft_ventilator_adapter.scad>   // bringt abluft_system.scad (Basis) und die fan_*/socket_*-Parameter mit
part = "keiner";          // Ausgabe der eingebundenen Dateien aus (muss nach dem include stehen)

/* [Funkenfilter und Kassette] */
// Funkenfilter: vhbw Metallfettfilter (Bauknecht 481948048232), 452 x 160 x 3,5 mm, in 3 Streifen geschnitten und gestapelt
filter_l = 452;  filter_w = 160;  filter_t = 3.5;   // Maße des Metallfilters
filter_n = 3;                                        // Streifen, in die der Filter geschnitten wird (452/3 = 150,7; Breite 160 bleibt ungeschnitten)
filter_lagen = 1;                                    // Lagen im Stapel (1..filter_lagen_max): nur die Kassette neu drucken, wenn das geaendert wird
filter_lagen_max = 3;                                // Kammer ist fuer so viele Lagen ausgelegt (aendern erfordert neuen Rahmen)
c_wall = 2.0;  c_lip = 5.0;  cart_grid_t = 4;
strip_l = filter_l / filter_n;                       // Streifenlaenge 150,7
c_w = filter_w + 2*c_wall + 2;                       // 166: Filterbreite + Waende + 1 mm Spiel je Seite
c_h = ceil(strip_l + 2*c_wall + 1.3);                // 156: Streifenlaenge + Waende + Spiel
c_d = filter_lagen*filter_t + 0.5 + cart_grid_t;     // 8 bei 1 Lage: Stapel + Spiel + Gitter
c_d_max = filter_lagen_max*filter_t + 0.5 + cart_grid_t;   // 15: bestimmt das Kassettenfach
cart_head = 1.5;   // Luft ueber der Kassette (Spalt, durch den Luft an der Kassette vorbei kann: moeglichst klein)
cart_tab_h = 10;  cart_tab_t = 6;  cart_tab_w = 40;   // Griffasche zum Herausziehen (ragt nach oben in die Deckeltasche)

/* [Kammer] */
inner_w   = c_w + 0.6;  // Innenbreite der Kammer (Kassette + 0,3 mm Spiel je Seite: Spalt neben der Kassette moeglichst klein)
inner_h   = c_h + cart_head;  // Innenhoehe der Kammer (Kassette + kleiner Spalt oben, verbleibender Umgehungsspalt)
box_wall  = 1.6;    // Wandstaerke Rahmen (Original 4 mm; Druckzeit ist fast proportional zur Wandstaerke)
frame_t   = 12;     // Kragen (Deckelauflage) seitlich ueber die Wand hinaus
foot_h    = 10;     // optionale Fuesschen unter dem Rahmen (Hoehe in mm, 0 = ohne); eigene Teile, werden untergeklebt (am Rahmen haengend waere der Boden eine 10-mm-Bruecke)
foot_size = 24;     // Kantenlaenge je Fuss (4 Stueck, jeweils in den Ecken)
foot_inset = 6;     // Abstand der Fuesse vom Rand
collar_h  = 20;     // Hoehe des Kragens unter der Deckelauflage
box_w     = inner_w + 2*box_wall;
box_h     = inner_h + 2*box_wall;

slot_cartridge = c_d_max + 3;   // Kassette + 0,5 mm vorn + 2,5 mm Platz fuer den Deckeldamm hinter der Kassette   // Fach Kassette
slot_divider   = 2;    // Anschlagrahmen zwischen Kassette und G4
slot_g4        = 23;   // Fach G4-Vlies
filter_slot    = slot_cartridge + slot_divider + slot_g4;
grid_t         = 6;    // Stuetzgitter (Original 12: reicht fuer das Vlies)
grid_rib       = 1.6;  // Stegbreite des Gitters
grid_pitch     = 18;   // Stegabstand (senkrecht zu den Stegen)
grid_rim       = 4;    // umlaufender Rand

/* [Steckverbindung und Trichter] */
sp_in     = 10;     // Tiefe des Einlass-Zapfens im Rahmen (die letzten ledge mm sind der Kassettenanschlag)
sp_out    = 10;     // Tiefe des Auslass-Zapfens im Rahmen
sp_wall   = 2.4;     // Wandstaerke der Zapfen
cone_wall = 2.0;    // Wandstaerke der Trichter am kleinen Ende
sp_gap    = 0.25;   // Spiel je Seite zwischen Zapfen und Rahmeninnenseite
ledge     = 3;      // Dicke des Kassettenanschlags am Einlass-Zapfen
in_cone   = 50;     // axiale Laenge des Einlass-Trichters (stuetzfrei druckbar: Ecken ca. 50 Grad von der Senkrechten)
out_cone  = 35;     // axiale Laenge des Auslass-Trichters (stuetzfrei: max. ca. 50 Grad)
// Einrastverbindung Zapfen/Rahmen (keine Schrauben, keine Durchbrueche: luftdicht, danach verkleben)
snap_h  = 0.8;     // Hoehe der Rastwulst im Rahmen (Zapfen liegt sp_gap = 0,25 mm von der Wand: Eingriff = snap_h - sp_gap)
snap_l1 = 2.4;     // lange Einlaufschraege (ca. 18 Grad), Druckrichtung: stuetzfrei
snap_l2 = 0.8;     // steile Rueckseite (45 Grad): haelt, im Zapfen als Nutdach ebenfalls stuetzfrei
snap_x  = 2.0;     // Abstand der Wulst-Vorderkante vom Rahmenende
snap_c  = 0.15;    // Spiel zwischen Wulst und Nut

/* [Einlass Stutzen-Variante] */
in_pipe_id   = 100.0;  // Aussendurchmesser des glatten Stutzens (einlass_typ = "stutzen")
in_tube_len  = 20.0;   // Stutzenlaenge
in_tube_wall = 2.0;   // Stutzenwand (Innendurchmesser 96)

/* [Deckel] */
lid_t      = 12;     // Gesamtdicke (Hoehe der Auflage, Scharnier- und Verschlusshoehe)
lid_plate  = 2.4;      // Deckplatte (Aussenseite)
lid_rib    = 1.6;    // Rippen-/Wandstaerke
lid_rim_x  = 9;      // umlaufender Vollrand in x
lid_dam_t  = 1.6;
seal_d     = 3;      // Dichtschnur (EPDM-Schaum-Rundschnur) Durchmesser: 3 oder 5 mm
seal_in    = 1.2;    // Lage der Dichtung hinten (y) ab Rahmen-Aussenwand    // Dicke des Damms hinter der Kassette

/* [Befestigung GH-4001 Verschluss] */
latch_hole_x = 15;  latch_hole_z = 15;  latch_hole_dia = 2.5;  latch_hole_depth = 10;

/* [Schneidlehre] */
target_w = inner_h + 1;  mat_h = inner_w + 1;  mat_t = 3.5;  jig_wall = 3.0;   // G4 auf Kammermass +1 mm zugeschnitten (fuellt die Kammer, kein Spalt oben/seitlich)

$fn = 100;

// ---------------- abgeleitete Werte ----------------
hb   = box_h - collar_h;                       // Hoehe des Hauptkoerpers, darueber der Kragen
RL   = sp_in + filter_slot + grid_t + sp_out;  // Laenge des Rahmens
yc   = box_w / 2;   zc = box_h / 2;            // Achse des Luftkanals
fl   = flange110_t;                            // Dicke des 100er Magnetflanschs
// Zapfen
sp_ow = inner_w - 2*sp_gap;   sp_oh = inner_h - 2*sp_gap;     // Aussenmasse
sp_iw = sp_ow - 2*sp_wall;    sp_ih = sp_oh - 2*sp_wall;      // Innenmasse = Kanal des Trichters am grossen Ende
win_w = c_w - 2*(c_wall + c_lip);   win_h = c_h - 2*(c_wall + c_lip);   // Fenster der Kassette = Anschlagoeffnung
win_z0 = box_wall + c_wall + c_lip;                                      // Kassette liegt auf dem Boden

xs_in = (einlass_typ == "magnet") ? fl : in_tube_len;   // Laenge von Flansch bzw. Stutzen bis zum Trichter
total_len = xs_in + in_cone + RL + out_cone + socket_depth;
echo(str("Filterkasten: Rahmen ", RL, " x ", box_w + 2*frame_t, " x ", box_h, " mm | Gesamtlaenge montiert ca. ", total_len,
         " mm (Original 151) | Kammer innen ", inner_w, " x ", inner_h));

hinge_y = box_w + 9;     // Scharnierachse: nach aussen versetzt, damit hinten Platz fuer die Dichtschnur bleibt
hinge_z = 6;             // Achse liegt hinge_z ueber der Auflageebene (kein Ausschnitt im Rahmen noetig, Auflageflaeche bleibt eben)
lid_dam_x0 = sp_in + 0.5 + c_d_max + 0.4;   // Damm beginnt 0,4 mm hinter der Rueckseite der dicksten Kassette (Lagenzahl egal)

// ---------------- Hilfsmodule ----------------
module quader_zentriert(x, w, h, dx = 0.01) {   // duenne Scheibe im Querschnitt (Breite w in y, Hoehe h in z), Mitte auf der Achse
    translate([x, yc - w/2, zc - h/2]) cube([dx, w, h]);
}
module quader_unten(x, w, h, dx = 0.01) {       // Scheibe, Unterkante z = 0 (Kasten sitzt auf dem Boden)
    translate([x, yc - w/2, 0]) cube([dx, w, h]);
}

// Rastwulst (positiv) bzw. Nut (negativ, mit Spiel d) auf drei Seiten (links, rechts, Boden; die Decke bleibt frei, dort waere ein Wulst nur mit Stuetzen druckbar).
// xa = Beginn der langen Schraege, sg = +1 (Schraege steigt zu +x) oder -1; Profil in (x, Hoehe ueber der Rahmeninnenwand)
module snap_ring(xa, sg, d = 0) {
    pts = [[0, 0], [snap_l1, snap_h], [snap_l1 + snap_l2, 0]];
    module prof() offset(delta = d) polygon([for (p = pts) [xa + sg * p[0], p[1]]]);
    z0 = box_wall;  zl = inner_h;
    translate([0, box_wall, z0 - 0.1]) linear_extrude(height = zl + 0.1) prof();                       // linke Wand (y = box_wall)
    translate([0, box_w - box_wall, z0 - 0.1]) linear_extrude(height = zl + 0.1) mirror([0, 1]) prof();   // rechte Wand
    translate([0, box_w - box_wall + 0.1, z0]) rotate([90, 0, 0]) linear_extrude(height = inner_w + 0.2) prof();   // Boden
}

// ==========================================
// 1. RAHMEN  (x = 0 ... RL, Boden z = 0, Deckelseite oben)
// ==========================================
module rahmen() {
    grid_x = sp_in + filter_slot;
    difference() {
        union() {
            // Hauptkoerper
            cube([RL, box_w, hb]);
            // Kragen mit 45-Grad-Unterseite (stuetzfrei)
            hull() {
                translate([0, 0, hb - frame_t]) cube([RL, box_w, 0.1]);
                translate([0, -frame_t, hb]) cube([RL, box_w + 2*frame_t, collar_h]);
            }
            // Scharnier-Knuckles
            for (x0 = [0, RL - 10])
                hull() {
                    translate([x0, box_w + 5.5, box_h - 0.1]) cube([10, frame_t - 5.5, 0.1]);
                    translate([x0, hinge_y, box_h + hinge_z]) rotate([0, 90, 0]) cylinder(d = frame_t, h = 10);
                }
        }
        // Kammer durchgehend
        translate([-1, box_wall, box_wall]) cube([RL + 2, inner_w, inner_h]);
        // Deckeloeffnung ueber beiden Faechern (Kassette wird von oben eingesteckt)
        translate([sp_in, box_wall, box_h - box_wall - 1]) cube([filter_slot, inner_w, box_wall + collar_h]);
        // Scharnierbohrung (Deckel-Knuckle x = 10,5 ... 27,5 liegt ueber der Ebene, kein Ausschnitt noetig)
        translate([-1, hinge_y, box_h + hinge_z]) rotate([0, 90, 0]) cylinder(d = 4.5, h = RL + 2);
        // Verschluss-Sacklöcher (Seite -y)
        for (ix = [-1, 1]) for (iz = [-1, 1])
            translate([RL/2 + ix * latch_hole_x/2, -frame_t - 0.1, box_h - 12 + iz * latch_hole_z/2])
                rotate([-90, 0, 0]) cylinder(d = latch_hole_dia, h = latch_hole_depth + 0.1);
    }
    // Anschlagrahmen zwischen Kassette und G4 (U-Profil: unten und seitlich 5 mm, oben offen)
    difference() {
        translate([sp_in + slot_cartridge, box_wall - 0.1, box_wall - 0.1]) cube([slot_divider, inner_w + 0.2, inner_h + 0.1]);
        translate([sp_in + slot_cartridge - 0.1, box_wall + 5, box_wall + 5]) cube([slot_divider + 0.2, inner_w - 10, inner_h]);
    }
    // Rastwuelste fuer die Zapfen von Einlass und Auslass
    snap_ring(snap_x, 1);
    snap_ring(RL - snap_x, -1);
    // Stuetzgitter fuer das G4-Vlies: diagonale Stege (45 Grad, ohne Stuetzen druckbar), nur so tief wie noetig
    intersection() {
        translate([grid_x, box_wall - 0.1, box_wall - 0.1]) cube([grid_t, inner_w + 0.2, inner_h + 0.1]);
        union() {
            // Rahmen um das Gitter (haelt die Stege an den Waenden)
            difference() {
                translate([grid_x - 1, box_wall - 0.1, box_wall - 0.1]) cube([grid_t + 2, inner_w + 0.2, inner_h + 0.1]);
                translate([grid_x - 2, box_wall + grid_rim, box_wall + grid_rim]) cube([grid_t + 4, inner_w - 2*grid_rim, inner_h]);
            }
            for (k = [-10 : 10], sgn = [-1, 1])
                translate([grid_x + grid_t/2, yc, box_wall + inner_h/2 + k * grid_pitch * sqrt(2)])
                    rotate([sgn * 45, 0, 0]) cube([grid_t + 2, 3*inner_w, grid_rib], center = true);
        }
    }
}

// ==========================================
// 2. EINLASS  (lokal: Magnetflaeche bei x = 0 zeigt nach -x, Trichter, Zapfen ab x = xe)
// ==========================================
xe_in = xs_in + in_cone;
bore_in = (einlass_typ == "magnet") ? stub_bore_d : in_pipe_id - 2*in_tube_wall;   // lichte Weite am Einlass (Stutzen: 96)     // grosses Ende des Trichters
module einlass() {
    difference() {
        union() {
            if (einlass_typ == "magnet") {
                // 100er Magnetflansch des Systems (Magnetflaeche bei x = 0, Lappen in +-y)
                translate([0, yc, zc]) rotate([0, 90, 0])
                    mag_flange(fl, n_mag_110, R110, lobe110, body110_r, 90, gr110, groove_depth_mag, stub_bore_r, 0, 0, false, 0, 0, pr110);
            } else {
                translate([0, yc, zc]) rotate([0, 90, 0]) cylinder(d = in_pipe_id, h = in_tube_len + 0.1);
            }
            // Trichter aussen
            hull() {
                translate([xs_in - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(d = (einlass_typ == "magnet") ? stub_bore_d + 2*cone_wall : in_pipe_id, h = 0.01);
                translate([xe_in, yc - sp_ow/2, box_wall + sp_gap]) cube([0.01, sp_ow, sp_oh]);   // aussen = Zapfen-Aussenmass (Trichterwand = sp_wall)
            }
            // Zapfen: Rohr + Anschlagrahmen (letzte "ledge" mm)
            translate([xe_in - 0.01, yc - sp_ow/2, box_wall + sp_gap]) cube([sp_in + 0.01, sp_ow, sp_oh]);
        }
        // Kanal: Bohrung -> Trichter -> Zapfeninnenraum
        translate([-1, yc, zc]) rotate([0, 90, 0]) cylinder(d = bore_in, h = xs_in + 1.02, $fn = 240);
        hull() {
            translate([xs_in, yc, zc]) rotate([0, 90, 0]) cylinder(d = bore_in, h = 0.01, $fn = 240);
            translate([xe_in, yc - sp_iw/2, box_wall + sp_gap + sp_wall]) cube([0.01, sp_iw, sp_ih]);
        }
        translate([xe_in - 0.02, yc - sp_iw/2, box_wall + sp_gap + sp_wall]) cube([sp_in - ledge + 0.02, sp_iw, sp_ih]);
        // Fenster im Anschlagrahmen
        translate([xe_in + sp_in - ledge - 0.01, yc - win_w/2, win_z0]) cube([ledge + 0.1, win_w, win_h]);
        // Rastnut im Zapfen (Rahmen-x = lokal - xe_in)
        translate([xe_in, 0, 0]) snap_ring(snap_x, 1, snap_c);
    }
}

// ==========================================
// 3. AUSLASS  (lokal: grosses Ende x = 0, Zapfen x < 0, Trichter 0..out_cone, Muffe danach)
// ==========================================
module auslass() {
    rs_o = fan_socket_d/2 + socket_wall;
    xm = out_cone;                              // Muffenboden (Schulter)
    xt = xm + socket_depth;                      // Muffenrand
    difference() {
        union() {
            hull() {
                translate([0, yc - sp_ow/2, box_wall + sp_gap]) cube([0.01, sp_ow, sp_oh]);
                translate([xm - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(d = 2*rs_o, h = 0.01);   // Aussenkontur laeuft tangential in den Muffenzylinder (keine Stufe aussen)
            }
            translate([xm - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(r = rs_o, h = socket_depth + 0.01);
            translate([-sp_out, yc - sp_ow/2, box_wall + sp_gap]) cube([sp_out + 0.01, sp_ow, sp_oh]);
        }
        // Kanal: Zapfeninnenraum -> Trichter -> Bohrung ø fan_bore_d
        translate([-sp_out - 0.01, yc - sp_iw/2, box_wall + sp_gap + sp_wall]) cube([sp_out + 0.02, sp_iw, sp_ih]);
        hull() {
            translate([-0.01, yc - sp_iw/2, box_wall + sp_gap + sp_wall]) cube([0.01, sp_iw, sp_ih]);
            translate([xm, yc, zc]) rotate([0, 90, 0]) cylinder(d = fan_bore_d, h = 0.01);
        }
        // Muffe innen + Einfuehrfase, O-Ring-Nut, Schraubloecher (gemeinsam mit dem Ventilator-Adapter)
        // Schulter als 45-Grad-Kegel (statt ebener Stufe): glatter Uebergang ø fan_bore_d -> Muffe, ohne Bruecke druckbar
        ss = (fan_socket_d - fan_bore_d) / 2;
        translate([xm - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(d1 = fan_bore_d, d2 = fan_socket_d, h = ss + 0.01);
        translate([xm + ss - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(d = fan_socket_d, h = socket_depth - ss + 0.02);
        translate([xt - socket_chamfer, yc, zc]) rotate([0, 90, 0])
            cylinder(d1 = fan_socket_d, d2 = fan_socket_d + 2*socket_chamfer + 0.1, h = socket_chamfer + 0.1);
        translate([xt, yc, zc]) rotate([0, 90, 0]) fan_muffe_schnitte(0);
        // Rastnut im Zapfen (Rahmen-x = lokal + RL)
        translate([-RL, 0, 0]) snap_ring(RL - snap_x, -1, snap_c);
    }
}

// ==========================================
// 4. KLAPPDECKEL  (Auflageebene z = 0, Platte z = 0..lid_t, Lippe z < 0)
// ==========================================

// Dichtungsnut (Unterseite des Deckels, offen nach oben beim Druck): abgerundetes Rechteck um die Oeffnung
module seal_groove() {
    gw = seal_d * 1.3;  gd = seal_d * 0.55;  r = 6;
    x0 = lid_rim_x / 2;  x1 = RL - lid_rim_x / 2;  y0 = -frame_t / 2;  y1 = box_w + seal_in;
    module bahn() offset(r = r) offset(delta = -r) translate([x0, y0]) square([x1 - x0, y1 - y0]);   // Mittellinie der Schnur
    translate([0, 0, -1]) linear_extrude(height = gd + 1)
        difference() { offset(delta = gw/2) bahn(); offset(delta = -gw/2) bahn(); }
}
module lid() {
    lx0 = sp_in + 0.5;  lx1 = sp_in + filter_slot - 0.5;           // Lippe ueber den Faechern
    ly0 = box_wall + 0.5;  ly1 = box_w - box_wall - 0.5;
    module lippenring(h0, h1, w = lid_rib)       // Ring um die Lippe, z = h0..h1
        translate([0, 0, h0]) linear_extrude(height = h1 - h0)
            difference() {
                translate([lx0, ly0]) square([lx1 - lx0, ly1 - ly0]);
                translate([lx0 + w, ly0 + w]) square([lx1 - lx0 - 2*w, ly1 - ly0 - 2*w]);
            }
    difference() {
        union() {
            difference() {
                translate([0, -frame_t, 0]) cube([RL, box_w + frame_t + frame_t/2, lid_t]);
                // Taschen von der Innenseite (z = 0) her: Deckplatte lid_plate bleibt, Rippenraster + Lippenring bleiben stehen
                difference() {
                    translate([lid_rim_x, 0, -1]) cube([RL - 2*lid_rim_x, box_w, lid_t - lid_plate + 1]);
                    lippenring(-2, lid_t + 2);
                    for (y = [yc - 30, yc + 30]) translate([lx0, y - lid_rib/2, -2]) cube([lx1 - lx0, lid_rib, lid_t + 4]);
                }
            }
            // Lippe: Ring + zwei Querrippen (drueckt das Vlies an, schliesst die Kammer)
            lippenring(-box_wall, 0.1);
            for (y = [yc - 30, yc + 30]) translate([lx0, y - lid_rib/2, -box_wall]) cube([lx1 - lx0, lid_rib, box_wall + 0.1]);
            // Damm hinter der Kassette: sperrt den Raum ueber der Kassette (Spalt oben, Deckelhohlraum) gegen Vorbeistroemen; Unterkante 0,3 mm ueber der Kassettenoberkante
            translate([lid_dam_x0, box_wall + 0.3, -(box_wall + cart_head - 0.3)])
                cube([lid_dam_t, inner_w - 0.6, box_wall + cart_head - 0.3 + lid_t - lid_plate + 0.1]);
            // Scharnierknuckle
            hull() {
                translate([10.5, box_w, 0]) cube([17, hinge_y - box_w, lid_t]);
                translate([10.5, hinge_y, hinge_z]) rotate([0, 90, 0]) cylinder(d = frame_t, h = 17);
            }
        }
        translate([-1, hinge_y, hinge_z]) rotate([0, 90, 0]) cylinder(d = 4.5, h = RL + 2);
        // Aussparungen fuer die Rahmen-Knuckles (x = 0 ... 10 und RL-10 ... RL)
        for (x0 = [-1, RL - 10.25]) hull() {
            translate([x0, box_w + 5.5 - 0.4, -1]) cube([11.25, frame_t - 5.5 + 0.8, 1.01]);
            translate([x0, hinge_y, hinge_z]) rotate([0, 90, 0]) cylinder(d = frame_t + 0.8, h = 11.25, $fn = 60);
        }
        // Nut fuer die Dichtschnur (Rundschnur), umlaufend um die Kammeroeffnung in der Auflageflaeche des Deckels
        seal_groove();
        for (ix = [-1, 1]) translate([RL/2 + ix * latch_hole_x/2, -frame_t - 0.1, 6])
            rotate([-90, 0, 0]) cylinder(d = latch_hole_dia, h = latch_hole_depth + 0.1);
    }
}

// Fuesschen: kleines Quader mit leichter Fase unten, flach druckbar; 4 Stueck (Positionen foot_inset/foot_size)
module fuss() {
    c = min(1.5, foot_h / 4);
    hull() {
        translate([c, c, 0]) cube([foot_size - 2*c, foot_size - 2*c, 0.01]);
        translate([0, 0, c]) cube([foot_size, foot_size, foot_h - c]);
    }
}
module fuss_positionen() {
    for (fx = [foot_inset, RL - foot_inset - foot_size], fy = [foot_inset, box_w - foot_inset - foot_size])
        translate([fx, fy, -foot_h]) children();
}

// ==========================================
// 5. KASSETTE, 6. LEHRE (unveraendert)
// ==========================================
module cartridge() {
    // geschlossener Rahmen (Wand c_wall rundum), offen zum Einlegen des Vlieses (x = 0),
    // auf der Rueckseite (x = c_d) ein Rand c_lip und ein Diagonalgitter, das das Vlies traegt.
    // Druckpose: Gitterseite auf dem Bett -> Stege liegen auf, keine Bruecken.
    grid_d = cart_grid_t;
    wy0 = c_wall + c_lip;  wz0 = c_wall + c_lip;
    ww = c_w - 2*wy0;  wh = c_h - 2*wz0;
    difference() {
        cube([c_d, c_w, c_h]);
        translate([-1, c_wall, c_wall]) cube([c_d + 1 - grid_d, c_w - 2*c_wall, c_h - 2*c_wall]);   // Vliestasche
        translate([c_d - grid_d - 1, wy0, wz0]) cube([grid_d + 2, ww, wh]);                         // Fenster
    }
    // Griffasche oben: liegt in Druckpose flach auf dem Bett (x = c_d - cart_tab_t ... c_d), Fingerloch als Langloch
    difference() {
        translate([c_d - cart_tab_t, c_w/2 - cart_tab_w/2, c_h - c_wall]) cube([cart_tab_t, cart_tab_w, cart_tab_h + c_wall]);
        translate([c_d - cart_tab_t - 1, c_w/2, c_h + cart_tab_h/2]) hull() for (dy = [-9, 9])
            translate([0, dy, 0]) rotate([0, 90, 0]) cylinder(d = 5, h = cart_tab_t + 2, $fn = 40);
    }
    intersection() {
        translate([c_d - grid_d, wy0 - 0.1, wz0 - 0.1]) cube([grid_d, ww + 0.2, wh + 0.2]);
        union() for (sgn = [-1, 1]) for (k = [-20 : 20])
            translate([c_d - grid_d/2, c_w/2, c_h/2 + k * grid_pitch * sqrt(2)])
                rotate([sgn * 45, 0, 0]) cube([grid_d, 3*c_w, grid_rib], center = true);
    }
}
module jig() {
    difference() {
        union() {
            cube([target_w, mat_h + 20, jig_wall]);
            translate([-jig_wall, 0, 0]) cube([jig_wall + 0.1, mat_h + 20, jig_wall + mat_t]);
            cube([target_w, 10, jig_wall + mat_t]);
            translate([0, mat_h + 10, 0]) cube([target_w, 10, jig_wall + mat_t]);
        }
        translate([target_w - 7.5, 5, -1]) cylinder(d = 3.3, h = 20);
        translate([target_w - 7.5, mat_h + 15, -1]) cylinder(d = 3.3, h = 20);
    }
}
module jig_clamp() {
    difference() {
        cube([15, mat_h + 20, 6]);
        translate([7.5, 5, -1]) cylinder(d = 4.5, h = 20);
        translate([7.5, mat_h + 15, -1]) cylinder(d = 4.5, h = 20);
    }
}

// ---------------- Teile-Selektion (Druckposen) ----------------
if (auswahl == "rahmen") rahmen();
if (auswahl == "einlass") translate([box_h, 0, 0]) rotate([0, -90, 0]) einlass();
if (auswahl == "auslass") translate([0, 0, out_cone + socket_depth]) rotate([0, 90, 0]) auslass();
if (auswahl == "lid") translate([0, box_w + frame_t, lid_t]) rotate([180, 0, 0]) lid();
if (auswahl == "cartridge") translate([0, 0, c_d]) rotate([0, 90, 0]) cartridge();
if (auswahl == "fuesse") for (i = [0 : 3]) translate([i * (foot_size + 6), 0, 0]) fuss();
if (auswahl == "jig") jig();
if (auswahl == "jig_clamp") jig_clamp();
if (auswahl == "assembly") {
    color("steelblue") rahmen();
    if (foot_h > 0) color("dimgray") fuss_positionen() fuss();
    color("seagreen") translate([-xe_in, 0, 0]) einlass();
    color("orange") translate([RL, 0, 0]) auslass();
    color("lightgray") translate([0, 0, box_h + 10]) lid();
    color("khaki") translate([sp_in + 0.5 + (c_d_max - c_d), (box_w - c_w)/2, box_wall]) cartridge();
}

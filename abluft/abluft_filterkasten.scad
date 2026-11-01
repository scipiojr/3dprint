// =====================================================================
//  Kompakte Lasercutter-Filterbox (100er Schlauch -> Ventilator-Muffe), DRUCKOPTIMIERT UND MODULAR
//  OpenSCAD 2021.01 oder neuer.   Baut auf dem Abluft-System auf (Basis + Ventilator-Datei).
//
//  Statt eines 510-cm3-Gehaeuses mit sehr vielen Stuetzen (ca. 1,5 Tage) besteht der Kasten jetzt aus
//  drei stuetzfrei druckbaren Gehaeuseteilen, die ineinandergesteckt und mit je 4 M3-Schrauben fixiert werden:
//
//    rahmen    Filterrahmen: Kammer fuer Kassette + G4-Vlies, Stuetzgitter, Deckelkragen, Scharnier, Verschluss
//    einlass   Einlass: 100er Magnetflansch des Systems (passt auf Schlauchanschluss / Ventilator-Adapter)
//              -> Trichter -> Steckzapfen mit Kassettenanschlag
//    auslass   Auslass: Trichter -> Ventilator-Muffe (146,4 mm, O-Ring-Nut, Schraublöcher wie Ventilator-Adapter)
//    lid       Klappdeckel: hohl (Boden + Rippen) statt 12 mm Vollmaterial; liegt zum Druck auf der Aussenseite
//    cartridge Filterkassette (unveraendert)      jig, jig_clamp   Schneidlehre fuer das Vlies (unveraendert)
//
//  Druckpose: alle Teile liegen so, dass sie ohne Stuetzen druckbar sind (siehe README/agent.md):
//    rahmen: wie gebaut (Deckelseite oben) | einlass: Magnetflaeche auf dem Bett | auslass: Muffenmuendung auf dem Bett
//  Weitere Teile aus dem System: Dichtung Ventilator-Muffe = dichtung_ventilator_muffe_tpu.stl,
//  Dichtung 100er Magnetflaeche = dichtung_100_anschluss_tpu.stl.
// =====================================================================

/* [Export und Ansicht] */
auswahl = "assembly"; // ["assembly", "rahmen", "einlass", "auslass", "lid", "cartridge", "jig", "jig_clamp"]
// Einlass: "magnet" = 100er Magnetflansch des Systems, "stutzen" = glatter Rohrstutzen wie im Original
einlass_typ = "magnet"; // ["magnet", "stutzen"]

/* [Hidden] */
include <abluft_ventilator_adapter.scad>   // bringt abluft_system.scad (Basis) und die fan_*/socket_*-Parameter mit
part = "keiner";          // Ausgabe der eingebundenen Dateien aus (muss nach dem include stehen)

/* [Kammer] */
inner_w   = 168;    // Innenbreite der Kammer (Kassette 166 + Spiel)
inner_h   = 157;    // Innenhoehe der Kammer (Kassette 151 + Boden/Spiel)
box_wall  = 1.6;    // Wandstaerke Rahmen (Original 4 mm; Druckzeit ist fast proportional zur Wandstaerke)
frame_t   = 12;     // Kragen (Deckelauflage) seitlich ueber die Wand hinaus
collar_h  = 20;     // Hoehe des Kragens unter der Deckelauflage
box_w     = inner_w + 2*box_wall;
box_h     = inner_h + 2*box_wall;

slot_cartridge = 13;   // Fach Kassette
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
join_screw_d     = 3.4;    // Durchgangsloch M3 im Rahmen
join_pilot_d     = 2.5;    // Kernloch M3 (selbstschneidend) im Zapfen
join_screw_z     = [38, 118];   // Hoehen der Verbindungsschrauben (je an beiden Seitenwaenden)

/* [Einlass Stutzen-Variante] */
in_pipe_id   = 100.0;  // Aussendurchmesser des glatten Stutzens (einlass_typ = "stutzen")
in_tube_len  = 20.0;
in_tube_wall = 2.0;

/* [Kassette] */
c_w = 166.0;  c_h = 151.0;  c_d = 12.0;  c_wall = 2.0;  c_lip = 5.0;

/* [Deckel] */
lid_t      = 12;     // Gesamtdicke (Hoehe der Auflage, Scharnier- und Verschlusshoehe)
lid_plate  = 2.4;      // Deckplatte (Aussenseite)
lid_rib    = 1.6;    // Rippen-/Wandstaerke
lid_pitch  = 60;     // Rippenabstand
lid_rim_x  = 6;      // umlaufender Vollrand in x

/* [Befestigung GH-4001 Verschluss] */
latch_hole_x = 15;  latch_hole_z = 15;  latch_hole_dia = 2.5;  latch_hole_depth = 10;

/* [Schneidlehre] */
target_w = 150.6;  mat_h = 162.0;  mat_t = 3.5;  jig_wall = 3.0;

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

total_len = fl + in_cone + RL + out_cone + socket_depth;
echo(str("Filterkasten: Rahmen ", RL, " x ", box_w + 2*frame_t, " x ", box_h, " mm | Gesamtlaenge montiert ca. ", total_len,
         " mm (Original 151) | Kammer innen ", inner_w, " x ", inner_h));

// ---------------- Hilfsmodule ----------------
module quader_zentriert(x, w, h, dx = 0.01) {   // duenne Scheibe im Querschnitt (Breite w in y, Hoehe h in z), Mitte auf der Achse
    translate([x, yc - w/2, zc - h/2]) cube([dx, w, h]);
}
module quader_unten(x, w, h, dx = 0.01) {       // Scheibe, Unterkante z = 0 (Kasten sitzt auf dem Boden)
    translate([x, yc - w/2, 0]) cube([dx, w, h]);
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
                    translate([x0, box_w, box_h - 0.1]) cube([10, frame_t, 0.1]);
                    translate([x0, box_w + frame_t/2, box_h]) rotate([0, 90, 0]) cylinder(d = frame_t, h = 10);
                }
        }
        // Kammer durchgehend
        translate([-1, box_wall, box_wall]) cube([RL + 2, inner_w, inner_h]);
        // Deckeloeffnung ueber beiden Faechern (Kassette wird von oben eingesteckt)
        translate([sp_in, box_wall, box_h - box_wall - 1]) cube([filter_slot, inner_w, box_wall + collar_h]);
        // Scharnierbohrung und Aussparung fuer den Deckel-Knuckle (Deckel: x = 10,5 ... 27,5)
        translate([-1, box_w + frame_t/2, box_h]) rotate([0, 90, 0]) cylinder(d = 4.5, h = RL + 2);
        translate([10, box_w + frame_t/2, box_h]) rotate([0, 90, 0]) cylinder(d = frame_t + 0.8, h = 18, $fn = 60);
        // Verschluss-Sacklöcher (Seite -y)
        for (ix = [-1, 1]) for (iz = [-1, 1])
            translate([RL/2 + ix * latch_hole_x/2, -frame_t - 0.1, box_h - 12 + iz * latch_hole_z/2])
                rotate([-90, 0, 0]) cylinder(d = latch_hole_dia, h = latch_hole_depth + 0.1);
        // Schraubloecher fuer die Zapfen (M3), je Seite
        for (xs = [5, RL - 5]) for (z = join_screw_z)
            translate([xs, -1, z]) rotate([-90, 0, 0]) cylinder(d = join_screw_d, h = box_w + 2, $fn = 24);
    }
    // Anschlagrahmen zwischen Kassette und G4 (U-Profil: unten und seitlich 5 mm, oben offen)
    difference() {
        translate([sp_in + slot_cartridge, box_wall - 0.1, box_wall - 0.1]) cube([slot_divider, inner_w + 0.2, inner_h + 0.1]);
        translate([sp_in + slot_cartridge - 0.1, box_wall + 5, box_wall + 5]) cube([slot_divider + 0.2, inner_w - 10, inner_h]);
    }
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
xe_in = fl + in_cone;     // grosses Ende des Trichters
module einlass() {
    difference() {
        union() {
            if (einlass_typ == "magnet") {
                // 100er Magnetflansch des Systems (Magnetflaeche bei x = 0, Lappen in +-y)
                translate([0, yc, zc]) rotate([0, 90, 0])
                    mag_flange(fl, n_mag_110, R110, lobe110, body110_r, 90, gr110, groove_depth_mag, stub_bore_r, 0, 0, false, 0, 0, pr110);
            } else {
                translate([-in_tube_len, yc, zc]) rotate([0, 90, 0]) cylinder(d = in_pipe_id, h = in_tube_len + fl + 0.1);
            }
            // Trichter aussen
            hull() {
                translate([fl - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(d = stub_bore_d + 2*cone_wall, h = 0.01);
                translate([xe_in, yc - sp_ow/2, box_wall + sp_gap]) cube([0.01, sp_ow, sp_oh]);   // aussen = Zapfen-Aussenmass (Trichterwand = sp_wall)
            }
            // Zapfen: Rohr + Anschlagrahmen (letzte "ledge" mm)
            translate([xe_in - 0.01, yc - sp_ow/2, box_wall + sp_gap]) cube([sp_in + 0.01, sp_ow, sp_oh]);
        }
        // Kanal: Bohrung -> Trichter -> Zapfeninnenraum
        translate([-in_tube_len - 1, yc, zc]) rotate([0, 90, 0]) cylinder(d = stub_bore_d, h = in_tube_len + fl + 1.02, $fn = 240);
        hull() {
            translate([fl, yc, zc]) rotate([0, 90, 0]) cylinder(d = stub_bore_d, h = 0.01, $fn = 240);
            translate([xe_in, yc - sp_iw/2, box_wall + sp_gap + sp_wall]) cube([0.01, sp_iw, sp_ih]);
        }
        translate([xe_in - 0.02, yc - sp_iw/2, box_wall + sp_gap + sp_wall]) cube([sp_in - ledge + 0.02, sp_iw, sp_ih]);
        // Fenster im Anschlagrahmen
        translate([xe_in + sp_in - ledge - 0.01, yc - win_w/2, win_z0]) cube([ledge + 0.1, win_w, win_h]);
        // M3-Kernloecher im Zapfen
        for (z = join_screw_z)
            translate([xe_in + 5, -1, z]) rotate([-90, 0, 0]) cylinder(d = join_pilot_d, h = box_w + 2, $fn = 24);
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
                translate([xm - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(d = fan_bore_d + 2*cone_wall, h = 0.01);
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
        translate([xm - 0.01, yc, zc]) rotate([0, 90, 0]) cylinder(d = fan_socket_d, h = socket_depth + 0.02);
        translate([xt - socket_chamfer, yc, zc]) rotate([0, 90, 0])
            cylinder(d1 = fan_socket_d, d2 = fan_socket_d + 2*socket_chamfer + 0.1, h = socket_chamfer + 0.1);
        translate([xt, yc, zc]) rotate([0, 90, 0]) fan_muffe_schnitte(0);
        // M3-Kernloecher im Zapfen
        for (z = join_screw_z)
            translate([-5, -1, z]) rotate([-90, 0, 0]) cylinder(d = join_pilot_d, h = box_w + 2, $fn = 24);
    }
}

// ==========================================
// 4. KLAPPDECKEL  (Auflageebene z = 0, Platte z = 0..lid_t, Lippe z < 0)
// ==========================================
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
                    for (x = [lid_rim_x + lid_pitch/2 : lid_pitch : RL - lid_rim_x - 1]) translate([x - lid_rib/2, -1, -2]) cube([lid_rib, box_w + 2, lid_t + 4]);
                    for (y = [lid_pitch/2 : lid_pitch : box_w - 1]) translate([-1, y - lid_rib/2, -2]) cube([RL + 2, lid_rib, lid_t + 4]);
                    lippenring(-2, lid_t + 2);
                    for (y = [yc - 30, yc + 30]) translate([lx0, y - lid_rib/2, -2]) cube([lx1 - lx0, lid_rib, lid_t + 4]);
                }
            }
            // Lippe: Ring + zwei Querrippen (drueckt das Vlies an, schliesst die Kammer)
            lippenring(-box_wall, 0.1);
            for (y = [yc - 30, yc + 30]) translate([lx0, y - lid_rib/2, -box_wall]) cube([lx1 - lx0, lid_rib, box_wall + 0.1]);
            // Scharnierknuckle
            hull() {
                translate([10.5, box_w, 0]) cube([17, frame_t/2, lid_t]);
                translate([10.5, box_w + frame_t/2, 0]) rotate([0, 90, 0]) cylinder(d = frame_t, h = 17);
            }
        }
        translate([-1, box_w + frame_t/2, 0]) rotate([0, 90, 0]) cylinder(d = 4.5, h = RL + 2);
        // Aussparungen fuer die Rahmen-Knuckles (x = 0 ... 10 und RL-10 ... RL)
        for (x0 = [-1, RL - 10.25]) translate([x0, box_w + frame_t/2, 0]) rotate([0, 90, 0]) cylinder(d = frame_t + 0.8, h = 11.25, $fn = 60);
        for (ix = [-1, 1]) translate([RL/2 + ix * latch_hole_x/2, -frame_t - 0.1, 6])
            rotate([-90, 0, 0]) cylinder(d = latch_hole_dia, h = latch_hole_depth + 0.1);
    }
}

// ==========================================
// 5. KASSETTE, 6. LEHRE (unveraendert)
// ==========================================
module cartridge() {
    union() {
        difference() {
            cube([c_d, c_w, c_h]);
            translate([c_wall, c_wall, c_wall]) cube([c_d - 2*c_wall, c_w - 2*c_wall, c_h + 1]);
            translate([-1, c_wall + c_lip, c_wall + c_lip]) cube([c_d + 2, c_w - 2*(c_wall + c_lip), c_h]);
        }
        translate([c_d - c_wall - 0.1, c_w/2 - 1.5, c_wall]) cube([c_wall + 0.2, 3, c_h - c_wall]);
        translate([c_d - c_wall - 0.1, c_wall, c_h/2 - 1.5]) cube([c_wall + 0.2, c_w - 2*c_wall, 3]);
        translate([0, c_w/2 - 20, c_h - 2]) cube([c_d, 40, 2]);
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
if (auswahl == "cartridge") rotate([0, -90, 0]) cartridge();
if (auswahl == "jig") jig();
if (auswahl == "jig_clamp") jig_clamp();
if (auswahl == "assembly") {
    color("steelblue") rahmen();
    color("seagreen") translate([-xe_in, 0, 0]) einlass();
    color("orange") translate([RL, 0, 0]) auslass();
    color("lightgray") translate([0, 0, box_h + 10]) lid();
    color("khaki") translate([sp_in + 0.5, (box_w - c_w)/2, box_wall]) cartridge();
}

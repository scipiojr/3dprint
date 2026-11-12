/*
  Gemeinsame Parameter für den Griff-Demonstrator (pruefgriff.scad, rotor.scad)

  Alle Maße in mm. Achse ist z. Der Stecker sitzt bei z = 0 und zeigt nach +z,
  der Griff geht nach -z. Das Wasser fließt in -z-Richtung.
  ALLE WERTE SIND STARTWERTE (Schätzung), erst der Versuch an der Dusche zeigt,
  was passt. Siehe ../anleitung_demonstrator.md.

  Teil wählen:  openscad -D 'teil="rohr"' -o rohr.stl pruefgriff.scad
  Teile: rohr, spulenring, huelse, rotor, leitrad2, kappe, stift,
         montage (alles zusammen), schnitt (Montage, halb aufgeschnitten)
*/

teil = "montage";
$fa = 2;
$fs = 0.4;

// --- Wasserweg und Rohr ---
d_wasser    = 7.94;    // Bohrung des Steckers
d_kanal     = 9;       // Einlaufkanal = freier Durchmesser im Rotor
d_bohrung   = 15;      // Rotorkammer (Rotor Ø14 + 0,5 mm Spiel je Seite)
wand        = 1.0;     // gedruckte Wand zwischen Wasser und Spule
d_rohr      = d_bohrung + 2*wand;   // 17

// --- z-Lagen (Montagekoordinaten, alle nach unten gezählt) ---
z_kanal_d9_o = 8;      // Ø9-Kanal beginnt (Kegel davor)
z_kanal_d9_u = 20;     // Ø9-Kanal endet
z_schulter_u = 23;     // Kegel auf Ø15 endet
z_leit1_o    = 9;      // Leitrad 1: obere Kante
z_leit1_u    = 19;     // Leitrad 1: untere Kante
z_rotor_o    = 26;     // Rotor: obere Kante
rotor_l      = 25;     // Rotor: Länge
z_insert_o   = 52;     // Leitrad 2: obere Kante (1 mm Spiel unter dem Rotor)
z_ende       = 73;     // Rohrende (Kappe sitzt hier an)
z_kragen_o   = 53;     // Kragen (Auflage des Spulenrings) beginnt
z_gewinde_o  = 64;     // Gewinde beginnt

// --- Rotor ---
d_rotor        = 14;
d_nabe         = 3.6;
n_rot          = 4;        // Schaufeln
t_rot          = 0.9;      // Schaufeldicke
rotor_twist    = 300;      // Grad Verdrehung über die Länge (Steigung 30 mm/Umdr., Schaufelwinkel am Rand ≈ 43°)
rotor_slices   = 75;
d_stift        = 2;
spiel_stift    = 0.25;
d_stift_loch   = d_stift + spiel_stift;
stift_l        = 42;       // Stift-Länge, auf diese Länge kürzen
z_stift_o      = 15;       // obere Stiftkante

// --- Magnete 5 x 4 x 1 mm, radial gepolt, in Taschen am Rotor ---
n_mag      = 8;
mag_l      = 5;            // axial
mag_b      = 4;            // tangential
mag_dick   = 1;
mag_epoxid = 0.3;          // Epoxidschicht über dem Magneten
r_mag_boden = d_rotor/2 - mag_dick - mag_epoxid;   // 5,7

// --- Leiträder ---
n_leit      = 4;
t_leit      = 0.8;
leit1_twist = 0;           // 0 = gerade Schaufeln. Vorverdrallung erst nach Messung probieren.
d_insert    = d_bohrung - 0.2;   // Einsatz Ø14,8
wand_insert = 0.9;

// --- Spulenring, Hülse ---
spiel_ring   = 0.2;
d_ring_i     = d_rohr + 2*spiel_ring;   // 17,4
d_ring_a     = 24;
z_ring_o     = 24;
z_ring_u     = 53;
fenster_b    = 4.4;        // Spulenfenster tangential
fenster_l    = 5.4;        // axial
z_fenster_m  = 38.5;       // Mitte = Rotormitte
d_huelse_i   = d_ring_a + 0.1;
d_huelse_a   = 26.5;
d_kabel      = 3;
z_korridor   = 32.5;       // Drahtkorridor (Mitte)

// --- Gewinde Rohr/Kappe (Nockengewinde, druckbar) ---
d_kragen     = 21;
gew_e        = 0.8;        // Exzentrizität (flach genug zum Drucken: ≈ 45° Überhang)
d_gew        = d_kragen - 2*gew_e;   // 19
gew_steigung = 5;
gew_spiel    = 0.6;        // Durchmesser-Zugabe der Kappe
d_kappe      = 25;
z_kappe_u    = 75;         // Unterkante Kappe
z_boden_o    = 73;         // Oberkante Kappenboden = Rohrende

// --- Drossel (Gesamtfläche ≈ 78 mm², wie 44 Düsen im Baum) ---
drossel_variante = 1;      // 1: ein Loch Ø10, 2: vier Löcher Ø5

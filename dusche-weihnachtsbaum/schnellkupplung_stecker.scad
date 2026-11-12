/*
  Stecker für die Hansgrohe-Schnellkupplung (Quick Connect 28346000)

  Maße vom Nutzer am Original gemessen (12.11.2026), ersetzen die frühere
  Geometrie aus hansgrohe_shower_quick_connect_adapter.scad, die in der Kupplung
  nicht hielt (O-Ring-Nut war 1 mm zu flach, mehrere Längen wichen ab).
  Die Achse ist +z, z = 0 ist die Anlagefläche am Griff (dort beginnt die
  Rastnut). `ueberlapp` verlängert den Schaft nach -z in den Griff hinein,
  damit die Vereinigung mit dem Duschkopf sauber ist.

  Profil von der Anlagefläche zur Mündung (Durchmesser in mm):
    0    ..  7.2   Ø12.4          Rastnut (Schaft)
    7.2  .. 10.2   Ø16.7          Bund
    10.2 .. 10.9   Ø16.7 -> 14    Fase
    10.9 .. 18.8   Ø14            Backenbereich (7.9 lang)
    18.8 .. 20.6   Ø14.3          Ring
    20.6 .. 23.1   Ø11.3          O-Ring-Nut
    23.1 .. 27.9   Ø14.2
    27.9 .. 30.4   Ø14.2 -> 12.2  Fase zur Öffnung
  Backen: zwei Flächen im Ø14-Bereich, nur 11.8 dick, 7.2 breit, 6.4 lang,
  oben und unten bleibt je 0.75 mm Rand (Tasche axial geschlossen).

  Eigenständiges Modell mit Anleitung zur Übernahme: ../schnellkupplung-stecker/ (gleiche Maße,
  dort ist die Maßquelle; Änderungen in beiden Dateien nachziehen).

  Der Stecker wird von werkzeuge/erzeuge_modell.py an den Griff des
  Weihnachtsbaum-Duschkopfs gesetzt.
*/

water_passage_d = (5/16)*25.4;   // 7,94 mm Wasserbohrung
ueberlapp = 3;                   // mm in den Griff hinein
dach_kappe = 4.45;               // Tropfenspitze bei r = 4,45 flach gekappt: an der O-Ring-Nut (Ø 11,3) bleiben 1,2 mm Wand
dach_winkel = 35;                // Tropfenform: Bohrungsdecke steigt mit 35° (> 30°) -> ohne Stützen druckbar
// koerper = true setzt oben den Körper zum Schaft an (nur für den Einzeldruck zum Anprobieren,
// im Baum ersetzt der Griff ihn). Nach -z, von der Anlagefläche aus gemessen (Durchmesser in mm):
//   0 .. -5.4    Ø18.8 -> 20.7   (steil)
//   -5.4 .. -19  Ø20.7 -> 23     (flach)
koerper = false;
koerper_profil = [[-19, 23], [-5.4, 20.7], [0, 18.8]];
schlauch_d = 10;          // Innendurchmesser im Körper, nicht kleiner als der Duschschlauch (Schätzung, anpassen)
bohrung_rund = false;     // true: runde Bohrung statt Tropfen (für stehenden Druck)

$fa = 1;
$fs = 0.25;

st_profil = [[0, 12.4], [7.2, 12.4], [7.2, 16.7], [10.2, 16.7], [10.9, 14],
             [18.8, 14], [18.8, 14.3], [20.6, 14.3], [20.6, 11.3], [23.1, 11.3],
             [23.1, 14.2], [27.9, 14.2], [30.4, 12.2]];
st_backe_dicke = 11.8;
st_backe_breit = 7.2;
st_backe_lang  = 6.4;
st_backe_z0    = 10.9 + (7.9 - st_backe_lang)/2;

module coupler()
{
  vorn = koerper ? concat(koerper_profil, [[0, 12.4]]) : [];   // Stufe 18.8 -> 12.4 an der Anlagefläche
  alle = concat(vorn, st_profil);
  z0 = alle[0][0];
  rotate_extrude($fn = 128)
    polygon(concat([[0, z0]],
                   [for (q = alle) [q[1]/2, q[0]]],
                   [[0, st_profil[len(st_profil)-1][0]]]));
}

difference() {
    union() {
        difference() {
            coupler();
            // Backentaschen (Flächen bei y = +-5.9)
            for (s=[1,-1])
                translate([-st_backe_breit/2, s > 0 ? st_backe_dicke/2 : -st_backe_dicke/2 - 5, st_backe_z0])
                    cube([st_backe_breit, 5, st_backe_lang]);
        }
        if (!koerper) translate([0,0,-ueberlapp]) cylinder(h=ueberlapp+0.01, d=12.4);
    }
    if (koerper) {
        // weite Bohrung im Körper, 45°-Kegel auf die Steckerbohrung kurz vor der Anlagefläche
        kegel = (schlauch_d - water_passage_d)/2;
        translate([0,0,-20]) bohrung(20 - kegel + 0.02, schlauch_d);
        // Übergang als Hülle zweier dünner Scheiben (gleiche Tropfenform), also stufenlos
        hull() {
            translate([0,0,-kegel]) bohrung(0.01, schlauch_d);
            translate([0,0,-0.01]) bohrung(0.01);
        }
        translate([0,0,-0.01]) bohrung(100);
    } else
        translate([0,0,-ueberlapp-1]) bohrung(100);
}

// Wasserbohrung als Tropfen: Kreis plus Dach, dessen Flanken den Kreis tangential berühren.
// +x ist beim Drucken oben (liegender Stecker); eine runde Decke wäre für den Slicer ein
// Überhang und bekäme Stützen, die sich in der Bohrung nicht mehr entfernen lassen.
module bohrung(h, d=water_passage_d)
{
    r = d/2;
    kappe = (d > water_passage_d) ? r + 1 : dach_kappe;   // Kappe nur an der engen Bohrung (Wand an der O-Ring-Nut)
    linear_extrude(h) intersection() {
      translate([-r-1, -r-1]) square([r + 1 + kappe, 2*r + 2]);   // 1 mm breite Brücke oben
      union() {
        circle(d=d);
        if (!bohrung_rund)
        polygon([[0,0],
                 [r*cos(dach_winkel), -r*sin(dach_winkel)],
                 [r/cos(dach_winkel), 0],
                 [r*cos(dach_winkel),  r*sin(dach_winkel)]]);
      }
    }
}

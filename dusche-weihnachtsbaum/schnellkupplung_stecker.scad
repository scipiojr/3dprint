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

  Der Stecker wird von werkzeuge/erzeuge_modell.py an den Griff des
  Weihnachtsbaum-Duschkopfs gesetzt.
*/

water_passage_d = (5/16)*25.4;   // 7,94 mm Wasserbohrung
ueberlapp = 3;                   // mm in den Griff hinein
dach_winkel = 35;                // Tropfenform: Bohrungsdecke steigt mit 35° (> 30°) -> ohne Stützen druckbar

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
  rotate_extrude($fn = 128)
    polygon(concat([[0, 0]],
                   [for (q = st_profil) [q[1]/2, q[0]]],
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
        translate([0,0,-ueberlapp]) cylinder(h=ueberlapp+0.01, d=12.4);
    }
    translate([0,0,-ueberlapp-1]) bohrung(100);
}

// Wasserbohrung als Tropfen: Kreis plus Dach, dessen Flanken den Kreis tangential berühren.
// +x ist beim Drucken oben (liegender Stecker); eine runde Decke wäre für den Slicer ein
// Überhang und bekäme Stützen, die sich in der Bohrung nicht mehr entfernen lassen.
module bohrung(h)
{
    r = water_passage_d/2;
    linear_extrude(h) union() {
        circle(d=water_passage_d);
        polygon([[0,0],
                 [r*cos(dach_winkel), -r*sin(dach_winkel)],
                 [r/cos(dach_winkel), 0],
                 [r*cos(dach_winkel),  r*sin(dach_winkel)]]);
    }
}

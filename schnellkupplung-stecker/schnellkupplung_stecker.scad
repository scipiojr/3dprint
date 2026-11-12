/*
  Stecker für die Hansgrohe-Schnellkupplung (Quick Connect 28346000)

  Zum direkten Andrucken an Duschköpfe (statt des 1/2"-Gewindes) oder als
  Einzelteil zum Anprobieren. Maße vom Nutzer am Original gemessen und im
  Druck in der Kupplung erprobt (12.11.2026). Siehe README.md.

  Koordinaten (alle Module):
    Achse = +z.  z = 0 ist die Anlagefläche am Duschkopf, die Rastnut beginnt dort.
    Die Mündung zeigt nach +z (z = 30.4).  Alles darunter (z < 0) gehört zum Duschkopf.
    Backen-Flächen (abgeflacht) liegen bei y = +-5.9, die Spitze der Tropfenbohrung
    zeigt nach +x.  Für den liegenden Druck so drehen, dass +x oben ist.

  Einbinden in ein eigenes Design:
      use <schnellkupplung_stecker.scad>
      difference() {
          union() { mein_duschkopf(); stecker_aussen(ueberlapp = 3); }
          stecker_bohrung(ueberlapp = 3);
          mein_kanal();
      }
  (Außenkörper in die Vereinigung, Bohrung in die Differenz, damit der Kanal des
   Duschkopfs nicht vom Stecker wieder zugefüllt wird.)
*/

// ---------- Maße (mm) ----------
// Profil von der Anlagefläche (z = 0) zur Mündung: [z, Durchmesser]
st_profil = [[0, 12.4], [7.2, 12.4],      // Rastnut (Schaft), 7.2 lang
             [7.2, 16.7], [10.2, 16.7],   // Bund, 3 lang
             [10.9, 14],                  // Fase auf Ø14 (0.7)
             [18.8, 14],                  // Backenbereich Ø14, 7.9 lang
             [18.8, 14.3], [20.6, 14.3],  // Ring, 1.8 lang
             [20.6, 11.3], [23.1, 11.3],  // O-Ring-Nut, 2.5 lang
             [23.1, 14.2], [27.9, 14.2],  // 4.8 lang
             [30.4, 12.2]];               // Fase zur Mündung (2.5)
st_laenge = 30.4;

// Backen: zwei ebene Flächen im Ø14-Bereich (Taschen, oben und unten bleibt Rand)
st_backe_dicke = 11.8;     // Abstand der beiden Flächen
st_backe_breit = 7.2;      // Breite (x)
st_backe_lang  = 6.4;      // Länge (z)
st_backe_z0    = 10.9 + (7.9 - st_backe_lang)/2;   // Rand 0.75 oben und unten

// Bohrung
water_passage_d = (5/16)*25.4;   // 7.94, Wasserweg im Stecker
dach_winkel = 35;                // Tropfenform: Decke steigt mit 35° (> 30°), druckbar ohne Stützen
dach_kappe  = 4.45;              // Tropfenspitze bei r = 4.45 gekappt: an der O-Ring-Nut bleiben 1.2 mm Wand

// Körper zum Schaft (nur Einzelteil), von der Anlagefläche nach -z: [z, Durchmesser]
koerper_profil = [[-19, 23], [-5.4, 20.7], [0, 18.8]];
koerper_l = 19;
schlauch_d = 10;                 // Innendurchmesser im Körper, nicht kleiner als der Duschschlauch

$fa = 1;
$fs = 0.25;

// ---------- Bohrung (Tropfen) ----------
// Kreis plus Dach, dessen Flanken den Kreis tangential berühren. Eine runde Decke wäre beim
// liegenden Druck ein Überhang mit Stützen, die sich in der Bohrung nicht entfernen ließen.
module bohrung_scheibe(h, d = water_passage_d, rund = false)
{
    r = d/2;
    kappe = (d > water_passage_d) ? r + 1 : dach_kappe;   // Kappe nur an der engen Bohrung
    linear_extrude(h) intersection() {
        translate([-r-1, -r-1]) square([r + 1 + kappe, 2*r + 2]);
        union() {
            circle(d = d);
            if (!rund)
                polygon([[0,0],
                         [r*cos(dach_winkel), -r*sin(dach_winkel)],
                         [r/cos(dach_winkel), 0],
                         [r*cos(dach_winkel),  r*sin(dach_winkel)]]);
        }
    }
}

// ---------- Außenkörper des Steckers ----------
// ueberlapp: Stummel (Ø12.4) nach -z in den Duschkopf hinein, für eine saubere Vereinigung.
module stecker_aussen(ueberlapp = 3)
{
    union() {
        difference() {
            rotate_extrude($fn = 128)
                polygon(concat([[0, 0]],
                               [for (q = st_profil) [q[1]/2, q[0]]],
                               [[0, st_laenge]]));
            for (s = [1, -1])
                translate([-st_backe_breit/2,
                           s > 0 ? st_backe_dicke/2 : -st_backe_dicke/2 - 5,
                           st_backe_z0])
                    cube([st_backe_breit, 5, st_backe_lang]);
        }
        if (ueberlapp > 0)
            translate([0, 0, -ueberlapp]) cylinder(h = ueberlapp + 0.01, d = 12.4);
    }
}

// ---------- Bohrung des Steckers (zum Abziehen) ----------
// Beginnt bei z = -ueberlapp - 1 und läuft durch die Mündung.
module stecker_bohrung(ueberlapp = 3, rund = false)
{
    translate([0, 0, -ueberlapp - 1]) bohrung_scheibe(ueberlapp + 1 + st_laenge + 1, rund = rund);
}

// ---------- fertiger Stecker mit Bohrung ----------
module stecker(ueberlapp = 3, rund = false)
{
    difference() {
        stecker_aussen(ueberlapp);
        stecker_bohrung(ueberlapp, rund);
    }
}

// ---------- Einzelteil zum Anprobieren: Stecker mit Körper zum Schaft ----------
// Weite Bohrung (schlauch_d) im Körper, stufenloser Übergang auf die Steckerbohrung.
module stecker_einzel(rund = false)
{
    kegel = (schlauch_d - water_passage_d)/2;   // 45°
    difference() {
        union() {
            rotate_extrude($fn = 128)
                polygon(concat([[0, -koerper_l]],
                               [for (q = koerper_profil) [q[1]/2, q[0]]],
                               [[12.4/2, 0]],
                               [for (q = st_profil) [q[1]/2, q[0]]],
                               [[0, st_laenge]]));
        }
        for (s = [1, -1])
            translate([-st_backe_breit/2,
                       s > 0 ? st_backe_dicke/2 : -st_backe_dicke/2 - 5,
                       st_backe_z0])
                cube([st_backe_breit, 5, st_backe_lang]);
        translate([0, 0, -koerper_l - 1]) bohrung_scheibe(koerper_l + 1 - kegel + 0.02, schlauch_d, rund);
        hull() {
            translate([0, 0, -kegel]) bohrung_scheibe(0.01, schlauch_d - 0.05, rund);
            translate([0, 0, -0.01]) bohrung_scheibe(0.01, water_passage_d, rund);
        }
        translate([0, 0, -0.01]) bohrung_scheibe(st_laenge + 1, rund = rund);
    }
}

// ---------- Vorgabe beim direkten Rendern ----------
// openscad -D 'modus="einzel"' (Standard), "einzel_rund" (stehender Druck), "anbau" (mit Stummel)
modus = "einzel";
if (modus == "einzel")           stecker_einzel();
else if (modus == "einzel_rund") stecker_einzel(rund = true);
else if (modus == "anbau")       stecker();

/*
  Stecker für die Hansgrohe-Schnellkupplung (Quick Connect 28346000)

  Geometrie unverändert aus hansgrohe_shower_quick_connect_adapter.scad
  (Modul coupler() samt Schlüsselflächen und Wasserbohrung), ohne die
  1/2"-Gewindebuchse. Die Achse ist +z, z = 0 ist die Anlagefläche am Griff
  (dort beginnt die Rastnut). `ueberlapp` verlängert den Schaft nach -z in
  den Griff hinein, damit die Vereinigung mit dem Duschkopf sauber ist.

  Der Stecker wird von werkzeuge/erzeuge_modell.py an den Griff des
  Weihnachtsbaum-Duschkopfs gesetzt.
*/

water_passage_d = (5/16)*25.4;   // 7,94 mm Wasserbohrung
ueberlapp = 3;                   // mm in den Griff hinein

$fa = 1;
$fs = 0.25;

module coupler()
{
  // Schaft am Rastnut-Durchmesser
  cylinder(h=30, d=12.3);

  translate([0,0,6.5]) {                   // Ende der Rastnut
      cylinder(h=4, d=16.7);               // Bund
      translate([0,0,4])
      {
        cylinder(h=1, d1=16.7, d2=14.5);   // Fase am Bund
        cylinder(h=10, d=14.5);            // Schaft bis zur O-Ring-Nut
        translate([0,0,4.5]) cube([3.4,13,6.6], center=true);
        translate([0,0,12.5])              // nach der O-Ring-Nut (2,5 mm)
        {
            cylinder(h=6, d=14.5);
            translate([0,0,6]) cylinder(h=1.2, d1=14.5, d2=12); // Fase an der Spitze
        }
      }
  }
}

difference() {
    union() {
        difference() {
            coupler();
            // Schlüsselflächen wie im Adapter (dort bei z = 34 = 19 + 15)
            for (s=[1,-1]) translate([0,s*7,15]) cube([8.5,2.4,6.6], center=true);
        }
        translate([0,0,-ueberlapp]) cylinder(h=ueberlapp+0.01, d=12.3);
    }
    translate([0,0,-ueberlapp-1]) cylinder(h=100, d=water_passage_d);
}

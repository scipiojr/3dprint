// =====================================================================
//  Luefterhalter mit Magnetmuffe: Aufhaengung (Wandwinkel, 6 Magnete, 100er Muster) kombiniert mit der Luefterkonsole
//  Auf die flache Oberseite wird der Luefter geschraubt (Lochbild wie abluft_ventilator_konsole.scad); darunter schnappt
//  die Magnetmuffe an. Hinten liegt wie bei der Konsole eine duenne Zunge (2 mm, 25 mm lang) auf der Wand auf, die beiden
//  Winkel (Bein + 2 Rippen, Schraublochform wie Konsole) werden an die Wand geschraubt.
//  Alle Parameter und die Geometrie stehen in abluft_aufhaengung.scad (ah_*, fan_*, ah_zunge_*).
//  Druckpose: Oberseite (Luefterseite) auf dem Bett, Winkel nach oben, Taschen und Mutterntaschen oben offen, keine Stuetzen.
// =====================================================================
include <abluft_aufhaengung.scad>

part        = "wand";
ah_luefter  = true;    // Langloecher + Mutterntaschen
ah_zunge_l  = 25;      // Auflagezunge hinten (wie die Konsole)

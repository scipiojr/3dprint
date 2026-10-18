# Version 3 – Plan: abnehmbare Seitenwände an den Schmalseiten

Stand: 18.10.2026. Plan um 18:30 Uhr (Stand 1), **umgesetzt in V3, Stand 2 (18:55 Uhr)**. Sprache mit der Nutzerin: Deutsch.

## Umsetzungsstand (V3, Stand 2) und Abweichungen vom Plan

Alles Folgende steht in `biomuell_system.scad`; der ursprüngliche Plan darunter bleibt zur Nachvollziehbarkeit unverändert.

| Plan | Umgesetzt | Grund |
|---|---|---|
| Zapfen 4 mm dick, ca. 16 mm lang, mit Schulter | Zapfen 14 mm breit (`zapfen_b`), 20 mm lang (`zapfen_l`), Tasche 14 mm tief; die Stegkanten (Steg 20 mm) bilden die Schulter | einfachste Schulter ohne zusätzliches Bauteil, Führung 14 mm |
| Block unter der Plattformkante | Block als **Ohr** über die Plattenkante, bis x = ±106,7 (1,8 mm vor der Öffnung) | die Wand (x = 100,5 … 104,5) liegt fast bündig mit der Plattenkante (105); ohne Ohr bliebe 0,3 mm Material neben dem Schlitz |
| Rastzunge mit Nase | zusätzlich **Relief** (`tasche_relief = 1,2`) hinter der Zunge in der Tasche | die 1 mm hohe Nase passt nur durch den Schlitz, wenn die Zunge einfedern kann (Schlitzspiel nur 0,2 mm) |
| Eckfüße rücken nach innen | x = ±78,6 statt ±82, berechnet aus den Blöcken (`FX`) | Fußteller (32 mm) hätten die Blöcke berührt |
| Plattform ≈ 210 mm | `platte_l_wand = 210` (nur im Wandmodus), `platte_l = 206` bleibt für `"band"` | wie geplant |
| `oeffnung_l/b` fest | `oeffnung_l = 217`, `oeffnung_b = 172`, `oeffnung_fase = 16` ersetzen `oeffnung_spiel` | wie geplant; Trichterhälfte, Mittelteil, Bügel mit Eckpunktabweichung 0,0000 mm gegenüber Stand 9 |
| Stege bündig nach der Eckschräge | `wand_eck_abstand = 0`, Stege y = ±47 … ±67 | wie geplant; der Block reicht dabei bis y = ±67 (1,8 mm zur Öffnung) |
| Durchbiegung 3–4 mm bei 5 N | 3,7 mm (Stege), mit Spiel im Zapfen bis 6,6 mm | Spiel 0,2 mm je Seite über 14 mm Führung kippt die Wand oben um bis ca. 2,9 mm; die Konsole meldet beides |

Geprüft (Standardwerte): Netze dicht, Wand und Plattform durchdringen sich nicht, waagerechter Abstand zur Öffnung Block 1,8 mm / Wand mit Nase 3,0 mm, Rastzunge Dehnung ca. 2,5 % bei 0,8 mm Haltefläche, `korb_v3.3mf` gültig. **Nicht geprüft:** Einstecken und Rasten am Probedruck, Passung im Eimer, Slicer-Import.

Neu gerendert wurden Plattform, Seitenwand und Rastprobe; Trichter, Mittelteil und Bügel sind unverändert.

## Wunsch der Nutzerin

Die Schlaufen (Bänder mit Griffschlaufe) auf den **kurzen Seiten** werden ersetzt durch zwei dünne **Wände** in parametrierbarer Höhe (Standard 10 cm):

- Form eines **nach unten offenen U** (∩): zwei Seitenstege und ein Quersteg oben.
- Die Seitenstege beginnen **erst nach den abgeschrägten Ecken** der Plattform.
- Sie werden durch einen **Mechanismus in die Bodenplatte eingeclipst** und lassen sich zum Reinigen demontieren.
- Die Seiten müssen **stabiler sein als die flexiblen Griffbänder**.

## Entscheidungen der Nutzerin (18.10.2026)

1. **Trichteröffnung bleibt unverändert** (217 × 172 mm, der Trichter muss nicht neu gedruckt werden).
2. **Stege dürfen nach innen versetzt werden**, wenn das der Stabilität oder einer einfacheren Konstruktion dient (auch nur leicht).
3. **Griffe nur an den Längsseiten** sind in Ordnung. Gehoben wird allein an den beiden Bügeln.
4. **Wandhöhe 10 cm ab Plattenoberseite**, aber variabel: Man soll später einfach andere Wandhöhen drucken können.

## Geometrie der Wand

- **Höhe** `wand_h = 100` mm ab Plattenoberseite (Oberkante 156 mm über Boden, weit unter der Öffnungs-Unterkante bei 220 mm).
- **Breite:** Außenkante der Seitenstege bei y = ±(W2 − platte_fase) = ±67 mm (Anfang des geraden Stücks, direkt nach der Eckschräge). `wand_eck_abstand` (Standard 0) verschiebt beide Stege nach innen; der Quersteg wird entsprechend kürzer.
- **Stege:** Seitenstege `wand_steg_b = 20`, Quersteg `wand_quer_h = 20`, alle Kanten gerundet bzw. gefast (keine Ablagerungen).
- **Dicke** `wand_t = 4` mm. Überschlag: zwei Stege 20 × 4 mm, 100 mm hoch, geben bei 5 N an der Oberkante etwa 3–4 mm nach. Ein Griffband (1,6 × 22 mm) wäre bei gleicher Höhe rund 30-mal weicher.
- **Lage in x:** Innenfläche bei sack_b/2 + `wand_sack_spiel` (0,5 mm), Außenfläche mindestens 1,5 mm innerhalb der Trichteröffnung.
- **Druck:** flach liegend, ohne Stützen, ca. 135 × 116 mm. Die Biegelast quer zur Wand verläuft entlang der Schichten.

### Platz in Längsrichtung (Trichteröffnung bleibt fest)

Mit dem 5-mm-Mittelteil ist die Öffnung 217 × 172 mm, je Schmalseite also 8,5 mm zwischen Sack (100 mm) und Öffnung (108,5 mm):

| je Schmalseite, ab Sackmitte | x |
|---|---|
| Sack | 100 |
| Wand innen (0,5 mm Spiel zum Sack) | 100,5 |
| Wand außen (4 mm Wand) | 104,5 |
| Trichteröffnung | 108,5 |

- Zwischen Wand und Öffnung bleiben 4 mm.
- **Öffnung wird von der Plattform entkoppelt:** feste Parameter `oeffnung_l = 217` und `oeffnung_b = 172` mit genau den heutigen Werten (bisher `platte_l + 2·oeffnung_spiel`). Eine längere Plattform ändert den Trichter dann nicht. Kontrolle: neu exportierte Trichterhälfte muss mit der bisherigen STL identisch sein.
- **Plattform** wird im Wandmodus nur in Längsrichtung länger: `platte_l` 206 → ca. 210 mm, damit die Taschen für die Wandzapfen vollständig in der Plattform liegen. Breite bleibt 166 mm.

## Clip-Mechanismus: Steckzapfen mit Rastzunge, durchgehende Tasche

- Jeder Seitensteg endet unten in einem Zapfen, so dick wie die Wand (4 mm), ca. 16 mm lang (`zapfen_l`).
- Der Zapfen wird von oben in eine passende Tasche gesteckt. Die Tasche sitzt in einem Block unter der Plattformkante (ähnlich den heutigen Scharnierblöcken).
- Eine Schulter am Zapfen liegt auf der Plattenoberseite auf und legt die Höhe fest.
- Die 16 mm lange, enge Führung (`zapfen_spiel = 0.2`) nimmt das Kippmoment auf. Das macht die Wand steif, anders als ein Scharnier.
- In der Mitte des Zapfens ist eine federnde **Rastzunge** ausgeschnitten. Ihre Nase (0,8–1 mm, `rast_nase`) schnappt unter die Unterkante des Blocks.
- **Lösen:** Nase von unten mit dem Daumen eindrücken, Wand nach oben abziehen, kein Werkzeug.
- **Reinigung:** Die Tasche ist unten offen (kein Sackloch, in dem sich Schmutz oder Schimmel sammelt); der Sprühstrahl der Spülmaschine kommt durch.
- **Druck:** Plattform kopfüber, die Tasche steht dabei senkrecht – ohne Stützen.

### Alternative (nur Rückfalloption)

Das vorhandene Scharnier mit abgeflachtem Stift: Wand wie ein Band einhängen, hochklappen, mit zusätzlicher Rastnase gegen Zurückklappen sichern. Vorteil: erprobt. Nachteil: mehr Spiel, weniger steif.

## Wandhöhe austauschbar

- `wand_h` ist frei einstellbar. Zapfen, Rastzunge und Tasche sind unabhängig von der Höhe immer gleich, Wände verschiedener Höhe passen in dieselbe Plattform. Später wird nur eine neue Wand gedruckt.
- Dateiname mit Höhe, z. B. `seitenwand_h100_2x.stl`.
- Die Konsole warnt, wenn die Wand bis auf 3 mm an die Eimerkante reicht oder darüber hinaus (bei der angenommenen Absatzhöhe etwa ab `wand_h` ≈ 230 mm). Durch die Öffnung passt die Wand in jeder Höhe, weil sie innerhalb des Öffnungsumrisses liegt.
- Die Konsole meldet, wie weit die Wand oben bei 5 N nachgibt. Das Nachgeben steigt mit der dritten Potenz der Höhe (bei 150 mm ca. 3,4-mal so viel wie bei 100 mm). Für hohe Wände `wand_t` erhöhen, bis maximal 6 mm; darüber warnt die Konsole wegen des Abstands zur Öffnung.

## Auswirkungen auf andere Teile

- **Plattform:** Scharnierblöcke an den Schmalseiten entfallen, stattdessen 2 Taschenblöcke je Schmalseite bei y ≈ ±57.
  - **Eckfüße:** Sie sitzen heute bei etwa (±80, ±43) mit 32 mm Fußteller und kollidieren sehr wahrscheinlich mit den neuen Blöcken. Die Fußposition wird künftig aus allen Blöcken berechnet; die Füße rücken nach innen (nicht die Stege).
  - Das Lochraster weicht über die bestehenden Sperrzonen (`KEEP`) automatisch aus.
- **Trichter:** unverändert. Das Mittelteil (5 mm) bleibt.
- **Längsbügel:** unverändert, tragen künftig allein (4 Haken auf 4 Stiften).
- **Übersicht:** zeigt die Wände statt der Bänder.
- **Bänder Schmalseite:** bleiben über `schmalseite_typ = "band"` wählbar (Version 2).

## Neue Parameter (Customizer-Gruppe „Seitenwände“)

- Auswahl: `schmalseite_typ` = `wand` (neu) oder `band` (Version 2)
- Wand: `wand_h`, `wand_t`, `wand_steg_b`, `wand_quer_h`, `wand_eck_abstand`, `wand_sack_spiel`
- Zapfen und Raste: `zapfen_l`, `zapfen_spiel`, `rast_nase`, `rast_zunge_b`, `rast_zunge_l`
- Öffnung fest: `oeffnung_l = 217`, `oeffnung_b = 172`
- Neue Teilauswahl `teil = "seitenwand"` (2× drucken) und `teil = "rastprobe"` (kleiner Taschenblock mit kurzem Wandstück, vorab zu drucken, um Spiel und Rastkraft zu prüfen, wie die Passlehre)

## Neue Warnungen in der Konsole

- Wand berührt den Sack
- Wand liegt zu nah an der Trichteröffnung (< 1,5 mm)
- Fuß kollidiert mit einem Taschenblock
- Zunge zu kurz oder zu steif (Dehnung beim Einrasten über ca. 3 %)
- Durchbiegung der Wand über einem Grenzwert
- Wand reicht bis an die Eimerkante

## Ablauf der Umsetzung

1. Werkzeuge aufsetzen: OpenSCAD als WebAssembly-Build, Node-Wrapper (`werkzeuge/openscad_wasm.mjs`), Python-Prüfung.
2. Parameter und Wandgeometrie einbauen, `seitenwand_stueck` druckfertig ausgeben.
3. Taschenblöcke an der Plattform, Fußposition neu berechnen, Sperrzonen erweitern.
4. Rastzunge und Rastprobe.
5. Übersicht und Konsolenmeldungen ergänzen.
6. Prüfen: Netze dicht; Wand ↔ Sack; Wand ↔ Trichteröffnung; Zapfen ↔ Tasche (Spiel); Füße ↔ Blöcke; Trichterhälfte identisch zur bisherigen STL.
7. STLs, 3MF (Wand: 4 Wände, 100 % Füllung), Bilder (`werkzeuge/bilder.sh`) und Doku neu erzeugen.

## Offene Fragen

Keine offenen Rückfragen an die Nutzerin. Zu bestätigen bleibt nach dem Probedruck:

- Passung und Rastkraft des Zapfens (`zapfen_spiel`, `rast_nase`) – dafür gibt es die Rastprobe.
- Ob 100 mm Wandhöhe passen oder mehr bzw. weniger gewünscht ist.
- Weiterhin offen aus Version 2: `absatz_z` nachmessen (Griffhöhe der Längsbügel hängt davon ab).

## Umsetzungsstand (V3, Stand 3)

- `mittelteil = 0` ist jetzt der Standard. Der Trichter besteht aus zwei Hälften à 140,25 mm (Gesamtlänge 280,5 mm), die Öffnung bleibt 217 × 172 mm.
- Das Mittelteil bleibt als optionale Notlösung für schon gedruckte Hälften (`mittelteil = 5`); die zugehörigen Dateien sind weiter gültig.
- Schrauben der Trichterfugen: M3 × 16 (mit Mittelteil M3 × 20).

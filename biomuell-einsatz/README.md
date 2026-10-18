# Biomüll-Einsatz – Korb und Trichter für den Biomülleimer

Einsatz für einen Biomülleimer in einem Küchenauszug. Ein Papier-Biomüllsack steht auf einer Plattform und wird mit Griffen herausgehoben. Ein Trichter liegt rundum auf dem Absatz am oberen Eimerrand, bleibt dauerhaft im Eimer und hält den Sack in Position. Alle Teile werden aus PETG gedruckt und sind spülmaschinenfest.

![Übersicht im Eimer](bilder/uebersicht.png)

## Prinzip

- **Korb:** Eine Plattform auf vier Füßen trägt den Sack. An ihren Kanten sind zwei Bügel (Langseiten) und zwei Bänder (Schmalseiten) eingehängt. Sie laufen am Sack hoch und enden in Griffschlaufen.
- **Trichter:** Der Kragen liegt auf dem 3-mm-Absatz des Eimers. Darunter folgt eine 40 mm tiefe Schräge bis zur Öffnung, an der ein 15 mm hoher senkrechter Haltekragen hängt.
- Der Sack ragt durch die Trichteröffnung nach oben. Die Bänder laufen zwischen Sack und Trichterrand. Die Griffe liegen dort greifbar, 10 mm unter der Eimerkante.
- Zum Leeren wird der ganze Korb mit dem Sack **durch die Trichteröffnung** gehoben. Der Trichter bleibt im Eimer.
- Nichts ragt über die Eimerkante, weil der Eimer unter eine Ablage fährt.

![Schnitte durch den eingebauten Zustand](bilder/schnitt.png)

| Korb (Plattform + Bügel + Bänder) | Trichter (2 Hälften) |
|---|---|
| ![Korb](bilder/korb.png) | ![Trichter](bilder/trichter.png) |

## Dateien

| Datei | Inhalt |
|---|---|
| `biomuell_system.scad` | Hauptdatei: alle Teile, parametrisch, Customizer auf Deutsch (OpenSCAD 2021.01 oder neuer). |
| `mittelteil_v1.scad` | Mittelteil für bereits gedruckte Trichterhälften der Version 1 (Eimerlänge 278 mm). |
| `biomuell_system.3mf` | Bambu-Studio-Projekt vom ersten Druckdurchgang (Trichter Version 1), Teile mit Druckeinstellungen auf Platten verteilt. Enthält zusätzlich zwei Testobjekte. |
| `bilder/` | Vorschaubilder, erzeugt mit `werkzeuge/bilder.sh`. Sie zeigen den Endstand (Version 2 mit Mittelteil), nicht den jeweiligen Zwischenstand. |
| `archiv/` | Zwischenstände vom 16.10.2026: Python-Generator (V0) und erste SCAD-Version (V1), jeweils mit Vorschau und Kennwerten. |
| `werkzeuge/` | Skripte für die Bilder und OpenSCAD als WebAssembly (für Umgebungen ohne OpenSCAD). |
| `agent.md` | Arbeitsstand, Konzeptentscheidungen und Arbeitsweise für KI-Agenten. |

Alle Konstruktionsstände sind eingecheckt: STL, 3MF, PNG und SCAD stehen direkt in diesem Ordner, jeder Stand ist ein eigener Commit (siehe [Verlauf](#verlauf)). Neu erzeugen aus der SCAD-Datei: `teil` wählen, `stueck` setzen, F6, als STL exportieren.

**Druckdateien** (Stand = letzter Commit, der die Datei geändert hat; „rekonstruiert“ = aus dem SCAD-Stand desselben Commits neu erzeugt, weil das ausgelieferte Original nicht mehr vorlag):

| Datei | Stand | Herkunft | Inhalt |
|---|---|---|---|
| `biomuell_system.scad` | 1 | rekonstruiert | Hauptdatei, Stand 1 (Keilwand, Druckhilfe an, Eimer 278 mm, Schnapphaken) |
| `vergleich_v1_v2.png` | 1 | Original | Vergleich Version 1 (rot) und Version 2 (grün), Schnitte durch die Trichterschräge |
| `trichter_v2_haelfte_2x.stl` | 1 | rekonstruiert | Trichterhälfte mit Druckhilfe, Eimer 278 mm: 143,25 × 207,5 × 59, 2× drucken |

## Teile

| `teil` | Anzahl | Maße (mm) | Beschreibung |
|---|---|---|---|
| `plattform` | 1 | 206 × 166 × 56 | Massive 6-mm-Platte mit 9 Langlöchern, 4 runde Füße (50 mm Bodenabstand), 6 Scharnierstifte (rund, Schnapphaken) |
| `langseite` | 2 | 239,75 × 134 | Bügel mit zwei Haken und Griffschlaufe |
| `schmalseite` | 2 | 239,75 × 124 | Band mit einem Haken und Griffschlaufe |
| `trichter` | 2 | 143,25 × 207,5 × 59 (mit Druckhilfe; ohne 137,75) | Trichterhälfte, Keilwand, Laschen mit M3-Löchern an der Fuge (bis Stand 6 mit angeschnittenem oberen Loch) |
| `lehre` | 2 | Hälften | Passlehre für den Trichterkragen – zuerst drucken und im Eimer prüfen |

| Plattform | Bügel Langseite | Band Schmalseite | Trichterhälfte |
|---|---|---|---|
| ![Plattform](bilder/plattform.png) | ![Bügel](bilder/buegel_langseite.png) | ![Band](bilder/band_schmalseite.png) | ![Trichterhälfte](bilder/trichter_haelfte.png) |

**Kaufteile:** 4 Edelstahlschrauben M3 × 16 mit Muttern für die Trichterfuge (Länge siehe Konsolenausgabe). Optional 2K-Epoxid für die Fuge.

## Bedienung der SCAD-Datei

- `teil = "uebersicht"` zeigt alles im Eimer, mit Sack und Eimer als Platzhalter.
- `stueck = -1` zeigt alle Druckstücke eines Teils nebeneinander, `stueck = 0, 1, …` liefert genau ein druckfertig orientiertes Stück.
- Die Konsole (ECHO) meldet Stückzahlen, Längen, Höhen, Schrägen und Warnungen.
- Teile, die größer als das Druckbett sind (`bett_x/y`, abzüglich `bett_rand`), teilt die Datei automatisch:
  - Plattform: Schwalbenschwanz-Puzzle über die volle Höhe, geklebt.
  - Bänder/Bügel: verdickter Stoß mit Schwalbenschwanz, geklebt.
  - Trichter: immer geteilt; gerade Fugen mit Laschen und M3-Schrauben.

## Anpassen an den eigenen Eimer

Die Maße stehen im Abschnitt „Eimer – gemessen“:

| Parameter | Vorgabe | Bedeutung |
|---|---|---|
| `eimer_l`, `eimer_b` | 278, 210 | Innenmaß oberhalb des Absatzes |
| `eimer_gerade_l`, `eimer_gerade_b` | 240, 170 | gerade Wandstücke zwischen den 45°-Eckschrägen |
| `absatz` | 3 | Rücksprung der Wand je Seite am Absatz |
| `absatz_z` | 275 | Höhe des Absatzes über dem **Innenboden** – noch nicht nachgemessen |
| `absatz_bis_rand` | 15 | Absatz bis Oberkante Eimer |

Bandlänge und Griffhöhe werden aus `absatz_z` berechnet (`laenge_lang/kurz = 0`). Die Trichteröffnung ergibt sich aus der Plattform plus `oeffnung_spiel`.

## Druck

PETG, 0,4-mm-Düse, alle Teile ohne Stützen.

| Teil | Lage auf dem Bett | Wände | Füllung | Oben/Unten |
|---|---|---|---|---|
| Plattform | Oberseite unten, Füße oben | 4 | 25 % Gyroid | 5/5 |
| Bügel / Band | flach | 3 | 100 % | 5/5 |
| Trichterhälfte | Kragenoberseite unten | 4 | 100 % | 5/5 |
| Passlehre | Kragen unten | 2 | 15 % | 3/3 |

Bei den großen Flächen ggf. eine Brim verwenden. Für die Trichterhälften ist standardmäßig eine abbrechbare Druckhilfe eingeschaltet (`druckhilfe = true`), die die offene Seite beim Druck zum Ring schließt.

### Slicer-Hinweise (Anycubic Kobra S1)

- Jede Trichterhälfte auf ein eigenes Druckbett.
- Außenwand 60–80 mm/s, Wandbeschleunigung höchstens 3000.
- 240–245 °C, Lüfter 30–40 %, Überhang-Lüfter höchstens 50 %.
- Stützen aus, Brim 5–8 mm.
- Die 3MFs sind in PrusaSlicer geprüft (Teile dicht), im Anycubic Slicer Next nicht geöffnet.

## Montage

1. Passlehre in den Eimer legen und prüfen. Bei Bedarf `flansch_spiel` oder `trichter_spiel` anpassen.
2. Trichterhälften mit M3-Schrauben und Muttern verbinden und in den Eimer legen.
3. Bügel und Bänder auf die Stifte der Plattform aufschnappen und hochklappen.
4. Sack auf die Plattform stellen und den Korb durch die Trichteröffnung einsetzen.

## Verlauf

Jeder Konstruktionsstand ist ein eigener Commit mit allen erzeugten Dateien. Details je Stand stehen in [`agent.md`](agent.md) und in den Commit-Meldungen.

| Stand | 18.10.2026 | Änderung |
|---|---|---|
| 1 | 10:04 | Trichter Version 2: Keilwand (innen steilere Schräge, oben dickere Wand), abbrechbare Druckhilfe (Standard an), Eimer weiter 278 mm. Neue Trichterhälfte (STL) und Vergleich V1/V2. |

## Stand

Laufender Stand und offene Punkte stehen in [`agent.md`](agent.md).

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
| `biomuell_system.scad` | 8 | Original | Hauptdatei, Stand 8 (`eimer_l = 283`, `eimer_gerade_l = 245`) |
| `vergleich_v1_v2.png` | 1 | Original | Vergleich Version 1 (rot) und Version 2 (grün), Schnitte durch die Trichterschräge |
| `trichter_v2_haelfte_2x.stl` | 8 | Original | Trichterhälfte, Eimer 283 mm, ohne Mittelteil: 140,25 × 207,5 × 59, 2× drucken |
| `trichter_v2.3mf` | 8 | Original | Trichter ohne Druckhilfe, Eimer 283 mm, ohne Mittelteil |
| `druckhilfe_steg.stl` | 8 | Original | Druckhilfe-Steg für Eimer 283 mm |
| `trichter_v2_druckhilfe.3mf` | 8 | Original | wie zuvor, Eimer 283 mm, ohne Mittelteil |
| `plattform.stl` | 5 | Original | Plattform 206 × 166 × 56 mit abgeflachten Scharnierstiften, 1× drucken |
| `buegel_langseite_2x.stl` | 5 | Original | Bügel Langseite mit 2 Haken (Kanal), 239,75 × 134, 2× drucken |
| `band_schmalseite_2x.stl` | 5 | Original | Band Schmalseite mit 1 Haken (Kanal), 239,75 × 124, 2× drucken |
| `scharnier_flachlage.png` | 5 | Original | Scharnier in drei Stellungen: aufrecht (hält), waagerecht (löst), dazwischen |
| `korb_v2.3mf` | 6 | Original | Korb auf 5 Platten: Plattform, 2 Bügel, 2 Bänder, Druckeinstellungen je Objekt |
| `lasche_loecher.png` | 7 | Original | Schnitt durch die Laschen, je 2 volle Schraublöcher |
| `lehre_haelfte_2x.stl` | 8 | Original | Passlehre für den Trichterrand, Eimer 283 mm (140,25 × 207,5 × 10), 2× drucken |

## Teile

| `teil` | Anzahl | Maße (mm) | Beschreibung |
|---|---|---|---|
| `plattform` | 1 | 206 × 166 × 56 | Massive 6-mm-Platte mit 9 Langlöchern, 4 runde Füße (50 mm Bodenabstand), 6 abgeflachte Scharnierstifte |
| `langseite` | 2 | 239,75 × 134 | Bügel mit zwei Haken und Griffschlaufe |
| `schmalseite` | 2 | 239,75 × 124 | Band mit einem Haken und Griffschlaufe |
| `trichter` | 2 | 140,25 × 207,5 × 59 | Trichterhälfte, Keilwand, Laschen mit M3-Löchern an der Fuge |
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
| `eimer_l`, `eimer_b` | 283, 210 | Innenmaß oberhalb des Absatzes |
| `eimer_gerade_l`, `eimer_gerade_b` | 245, 170 | gerade Wandstücke zwischen den 45°-Eckschrägen |
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

Bei den großen Flächen ggf. eine Brim verwenden. Für die Trichterhälften gibt es optional eine abbrechbare Druckhilfe (`druckhilfe = true`), die die offene Seite beim Druck zum Ring schließt.

### Slicer-Hinweise (Anycubic Kobra S1)

- Jede Trichterhälfte auf ein eigenes Druckbett.
- Außenwand 60–80 mm/s, Wandbeschleunigung höchstens 3000.
- 240–245 °C, Lüfter 30–40 %, Überhang-Lüfter höchstens 50 %.
- Stützen aus, Brim 8–10 mm.
- In `trichter_v2*.3mf` hinterlegt: 4 Wände (Arachne), 40 % Gyroid, oben/unten 5 Lagen, 0,2 mm, Brim 6 mm, Außenwand 70 mm/s, Innenwand 100 mm/s, Beschleunigung 2000/3000, Naht hinten. Temperatur und Lüfter stehen nicht in der 3MF (Filamentprofil).
- `korb_v2.3mf`: Plattform 4 Wände, 25 % Gyroid, 5/5, Brim 5 mm; Bügel und Bänder 3 Wände, 100 %, 5/5, kein Brim.
- Die 3MFs sind in PrusaSlicer geprüft (Teile dicht), im Anycubic Slicer Next nicht geöffnet.

## Montage

1. Passlehre in den Eimer legen und prüfen. Bei Bedarf `flansch_spiel` oder `trichter_spiel` anpassen.
2. Trichterhälften mit M3-Schrauben und Muttern verbinden und in den Eimer legen.
3. Bügel und Bänder waagerecht nach außen liegend von oben auf die abgeflachten Stifte der Plattform setzen und hochklappen. Aufgeklappt halten die Haken fest.
4. Sack auf die Plattform stellen und den Korb durch die Trichteröffnung einsetzen.

## Verlauf

Jeder Konstruktionsstand ist ein eigener Commit mit allen erzeugten Dateien. Details je Stand stehen in [`agent.md`](agent.md) und in den Commit-Meldungen.

| Stand | 18.10.2026 | Änderung |
|---|---|---|
| 1 | 10:04 | Trichter Version 2: Keilwand (innen steilere Schräge, oben dickere Wand), abbrechbare Druckhilfe (Standard an), Eimer weiter 278 mm. Neue Trichterhälfte (STL) und Vergleich V1/V2. |
| 2 | 10:13 | `trichter_v2.3mf`: beide Hälften auf je einer Platte, Druckeinstellungen je Objekt. |
| 3 | 10:17 | `druckhilfe = false` als Standard (der Steg stünde im fertigen Trichter quer in der Öffnung). STL, 3MF und SCAD neu. |
| 4 | 10:19 | `trichter_v2_druckhilfe.3mf`: Druckhilfe als eigenes, abtrennbares Teil; `druckhilfe_steg.stl`. |
| 5 | 11:31 | Scharnier: Stift mit zwei Abflachungen (`stift_flach = 4.2`, `kanal_spiel = 0.25`, `kanal_fase = 0.6`), Haken mit Kanal, Lösefenster ±7°. Neue Plattform, Bügel und Bänder. |
| 6 | 12:32 | `korb_v2.3mf`: Plattform, 2 Bügel und 2 Bänder auf 5 Platten. |
| 7 | 16:10 | Laschenlöcher korrigiert: je Lasche 2 volle Löcher (M3 × 16), Lage aus der Laschenbreite berechnet (`loch_rand_min = 1.5`). Beide Trichter-3MFs neu. |
| 8 | 16:13 | Eimer nachgemessen: `eimer_l` 278 → 283, `eimer_gerade_l` 240 → 245. Hälften 140,25 mm lang, ohne Mittelteil. Passlehre `lehre_haelfte_2x.stl`. |

## Stand

Laufender Stand und offene Punkte stehen in [`agent.md`](agent.md).

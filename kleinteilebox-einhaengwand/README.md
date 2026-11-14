# Kleinteilebox – Sammelboxen für Eurobox und Einhängewand

Sortierboxen für Schrauben und andere Kleinteile. Jede Box passt **liegend lückenlos in eine Eurobox 60 × 40 × 8 cm** und lässt sich **an eine Einhängewand mit Stegen hängen**. Länge und Breite stellt man im festen Raster ein, Höhe und Haken sind bei allen Größen identisch, sodass jede Box an jeden Steg passt. Gedruckt wird aufrecht in PETG auf einem Anycubic (3MF für Anycubic Slicer Next liegt bei).

![Ansicht: Box grau, Tragzone rot, Stützturm blau](bilder/ansicht.png)

## Prinzip

- **Raster 40 mm.** Eine Box ist `units_w` (Breite, entlang der Wand) mal `units_l` (Tiefe, von der Wand weg) Einheiten groß, abzüglich 0,5 mm Spiel. In die Eurobox (Innenmaß am Boden 560 × 360 mm, **noch nachmessen**) passen 14 × 9 Einheiten. Haken und Etiketteneinschub sind **im Raster eingerechnet**: Der Boxkörper wird um deren Überstand kürzer, die belegte Fläche bleibt exakt `units × 40 − 0,5`.
- **Feste Höhe 70 mm** (Eurobox innen ca. 75 mm, nachmessen), kleiner als der Stegabstand von **76 mm** (Oberkante zu Oberkante), damit sich die Boxen in der Wand nicht berühren.
- **Haken über die ganze Breite**, immer gleich: Dach 4 mm dick liegt auf dem Steg, dahinter greift eine 2 mm dicke Lippe **8 mm tief** (Steglänge) hinter den Steg. Schlitz für den Steg 4,1 mm (Steg 2 mm + 2,1 mm Luft).
- **Etiketteneinschub** vorn: Rahmen oben und unten geschlossen, das Etikett wird **seitlich eingeschoben**. Höhen 6, 9, 12, 19 oder 24 mm, Breite Standard Boxbreite − 20 mm, mittig im oberen Drittel (bei hohen Etiketten weiter unten).
- **Leicht und tragfest zugleich:** dünne Wände und ein automatisch bemessener Boden, dazu ein **massiver Tragrahmen** oben, wo Haken und Box verbunden sind (siehe unten).

![Längsschnitt](bilder/schnitt.png)

## Dateien

| Datei | Inhalt |
|---|---|
| `kleinteilebox.scad` | **Quelle** (OpenSCAD 2021.01 oder neuer). Alle Parameter oben, `part` wählt das Ausgabeteil |
| `kleinteilebox_2x3.stl` / `_stuetzturm.stl` / `.3mf` | Box 79,5 × 119,5 × 70 mm, Stützturm einzeln, Druckdatei für Anycubic Slicer Next |
| `kleinteilebox_1x2.stl` / `_stuetzturm.stl` / `.3mf` | kleinste Box 39,5 × 79,5 × 70 mm, gut als **Probedruck** für den Sitz am Steg |
| `bilder/` | Ansicht und Längsschnitt (`werkzeuge/bilder.sh`) |
| `werkzeuge/export.sh` | erzeugt STL und 3MF für beliebige Größen: `werkzeuge/export.sh 4x3 3x3` |
| `werkzeuge/traglast.py` | Traglastrechnung, liest die Maße aus der SCAD-Datei |
| `werkzeuge/erzeuge_3mf.py`, `stl_werkzeug.py`, `bild_schnitt.py`, `bilder.sh` | 3MF-Bau, STL-Prüfung (wasserdicht, Volumen), Bilder |
| `agent.md` | Stand, Entscheidungen und Arbeitsweise für KI-Agenten |

Andere Größen: `werkzeuge/export.sh 4x3` (Breite × Tiefe in Einheiten). Eigene Werte mit `EXTRA="-D hook_t=3" werkzeuge/export.sh 4x4`.

## Wichtige Parameter (`kleinteilebox.scad`)

| Parameter | Standard | Bedeutung |
|---|---|---|
| `units_w`, `units_l` | 2, 3 | Größe in Rastereinheiten (Breite entlang der Wand, Tiefe von der Wand weg) |
| `H` | 70 | feste Gesamthöhe inkl. Haken |
| `wall` | 1,2 | Wandstärke der leichten Box (3 Wände à 0,4 mm) |
| `wall_band` | 2,4 | Wandstärke im Tragrahmen (6 Wände) |
| `band_h` | 20 | **Höhe des Tragrahmens von oben nach unten.** Mehr = mehr massive Schichten, die Gesamthöhe bleibt |
| `band_ring` | false | false: nur die Rückwand (Hakenseite) ist im Tragrahmen dick; true: um alle vier Wände (steifer Rand, bei 2×3 ca. 23 g mehr) |
| `floor_t` | 0 | Bodenstärke; 0 = automatisch aus Traglast und Spannweite (1,0 bis 3,2 mm je nach Größe) |
| `rail_t`, `hook_clear`, `hook_drop`, `hook_t`, `hook_top` | 2 / 2,1 / 8 / 2 / 4 | Steg- und Hakenmaße. **`rail_t` nachmessen**, `hook_t` siehe Traglast |
| `label_h`, `label_w`, `label_open_left/right` | 12, 0 (= Breite − 20), je true | Etikett: Höhe (6/9/12/19/24), Breite, seitlich offene Seiten |
| `n_laengs`, `n_quer`, `div_h` | 0, 0, 60 | gleichmäßig verteilte Trennwände (längs / quer) und deren Höhe |
| `support_rib` | false | Abstützleiste unten hinten bis zur Wandebene (Wandanlage ohne Neigung) |
| `part` | box | `box`, `tower` (Stützturm), `assembly` (beides), `modifier` (Tragzone für den Slicer) |

## Leichtbau und Tragrahmen

- **Leicht:** Wände 1,2 mm statt 1,6 mm, Boden nur so dick wie nötig. Die 2×3-Box hat **49,3 cm³ statt 55,8 cm³** beim vorherigen Entwurf (Wand 1,6, Boden 1,2, kein Rahmen), also **etwa 12 % weniger Material** (als Vollkörper ca. 63 g statt 71 g, im Slicer meist etwas weniger). Eine Füllung spielt kaum eine Rolle, weil die Wände ohnehin keinen Innenraum lassen. Das Gewicht steckt in den Wänden.
- **Massiv:** Die obersten `band_h` = 20 mm (100 Schichten bei 0,2 mm) sind der **Tragrahmen**, in dem Hakendach, Lippe und Rückwand zusammenlaufen. Dort ist die Rückwand 2,4 mm dick (45°-Übergang nach unten, druckbar ohne Stütze), und die 3MF enthält ein **Modifier-Volumen** (rot im Bild), das in diesem Höhenbereich **6 Wände und 100 % Füllung** erzwingt. Wer mehr Schichten tragend haben will, erhöht `band_h`. Die Gesamthöhe bleibt 70 mm, der Rahmen wächst nur nach unten.
- **Warum nur die Rückwand dick ist:** Die Rechnung (unten) braucht es nicht, die Last läuft über die Rückwand in den Haken. Ein Rahmen aus 2,4 mm rund um alle vier Wände (`band_ring = true`) kostet bei 2×3 rund 18 cm³ (23 g) mehr und macht die Box nicht tragfähiger, nur steifer am Rand.

## Traglast für Metallschrauben

Rechnung: `python3 werkzeuge/traglast.py` (Handrechnung mit Balken- und Plattentheorie, **keine FEM, nicht durch Versuch bestätigt**). Annahmen:

- Füllgut **lose Metallschrauben, 4,0 kg/l Schüttdichte** (typisch 3,5 bis 4,5), Box **voll bis zum Rand**.
- **Zuschlag ×1,5** für Ruck beim Einhängen und herausfallende Schrauben.
- Zulässig bei Dauerlast in PETG: **10 MPa quer zu den Schichten** (Schichthaftung ca. 20 MPa, halbiert wegen Kriechen und Streuung), **15 MPa in der Schichtebene**, 5 MPa Pressung auf dem Steg.
- Gewicht hängt **allein am Haken**. Reibung an der Wand wird nicht angesetzt.

**Was die Wand trägt:** Die Wand nimmt kein Gewicht ab, aber das **Kippmoment**. Der Schwerpunkt der Füllung liegt vor dem Haken, die Box will sich unten zur Wand drehen. Dagegen drückt die Rückwandunterkante an die Wand (ohne Leiste nach ca. 5,6° Neigung, mit `support_rib = true` sofort) und die Lippe hält oben gegen. Das entlastet den Haken nur von einem Teil, **die Horizontalkraft an der Lippe beträgt trotzdem etwa das 0,95-Fache der Gewichtskraft** (2×3, voll). Sie wirkt als Biegung an der Lippenwurzel, also **quer zu den Schichten**: Das ist die schwächste Stelle der ganzen Box.

| Größe | außen B×T×H [mm] | Boden [mm] | Inhalt [l] | voll [kg] | Lippe quer [MPa] | Boden [MPa] / Durchb. [mm] | kleinste Reserve | empf. max. Füllung [kg] | kritisch |
|---|---|---|---|---|---|---|---|---|---|
| 1x2 | 39.5 × 79.5 × 70 | 1.0 | 0.18 | 0.7 | 2.0 | 3.2 / 0.3 | **4.7×** | 0.7 | Boden (Biegung) |
| 2x3 | 79.5 × 119.5 × 70 | 1.4 | 0.58 | 2.3 | 4.8 | 5.5 / 1.5 | **2.1×** | 2.3 | Hakenlippe (Biegung quer) |
| 3x3 | 119.5 × 119.5 × 70 | 1.8 | 0.87 | 3.5 | 4.9 | 4.7 / 1.8 | **2.1×** | 3.5 | Hakenlippe (Biegung quer) |
| 4x3 | 159.5 × 119.5 × 70 | 2.2 | 1.16 | 4.6 | 4.9 | 4.6 / 1.6 | **2.1×** | 4.6 | Hakenlippe (Biegung quer) |
| 4x4 | 159.5 × 159.5 × 70 | 2.8 | 1.57 | 6.3 | 8.8 | 3.5 / 1.6 | **1.1×** | 3.6 | Hakenlippe (Biegung quer) |
| 6x4 | 239.5 × 159.5 × 70 | 3.2 | 2.36 | 9.4 | 8.8 | 4.5 / 2.0 | **1.1×** | 5.3 | Hakenlippe (Biegung quer) |

Ergebnis für die 2×3-Box: Rückwand 28-fache und Tragrahmen 56-fache Reserve, Steg-Pressung 23-fach, Seitenwände 15-fach, Boden 2,7-fach (1,5 mm Durchbiegung bei voller Box). **Die Lippe ist mit 2,1-facher Reserve das schwächste Glied.**

- **Tiefe Boxen (4 Einheiten und mehr) nicht voll füllen:** Die Kippkraft wächst mit dem Quadrat der Tiefe, die Reserve sinkt auf 1,1×. Die Tabelle nennt die empfohlene Maximalfüllung für 2-fache Reserve.
- **Lippe dicker machen hilft am meisten:** Die Spannung sinkt mit 1/Dicke². `hook_t = 3` statt 2 mm hebt 4×4 und 6×4 auf **2,6-fache Reserve** (`python3 werkzeuge/traglast.py hook_t=3 4x4`). Ob das geht, hängt vom **Abstand zwischen Steg und Wand** ab: Die Lippe sitzt dort. Bitte nachmessen, dann `hook_t` setzen. Der Haken wird dadurch 1 mm länger, der Boxkörper entsprechend kürzer.
- Der Boden wird aus der Durchbiegung bemessen (höchstens 2 mm bei voller Box, allseitig gelenkig gerechnet, also vorsichtig), nicht aus der Festigkeit.

## Drucken (Anycubic Slicer Next)

1. `kleinteilebox_2x3.3mf` öffnen. Es ist **ein Objekt mit drei Teilen**: Box, Stützturm (steht frei hinter der Box) und Tragzone (Modifier, nur Einstellungen). Die Box steht aufrecht, der Haken ist oben.
2. In der 3MF stehen: Schichthöhe 0,2 mm, 3 Wände, 5 % Gyroid, oben/unten 4 Lagen, keine Stützen, kein Brim. Tragzone: 6 Wände, 100 % Füllung, nur in den obersten 20 mm. Der Turm hat 2 Wände, 0 % Füllung. **Temperatur und Lüfter stehen im Filamentprofil**, nicht in der 3MF (im Repo sonst für PETG auf dem Kobra S1: 240–245 °C, Lüfter 30–40 %).
3. **Schichthöhe 0,2 mm beibehalten**: Der Turm endet 0,2 mm unter der Hakenlippe (`sup_gap`). Bei anderer Schichthöhe `sup_gap` gleich der Schichthöhe setzen und neu exportieren. Klebt die Lippe am Turm, `sup_gap` auf 0,3 setzen.
4. Nach dem Druck den Turm einfach wegnehmen. Er berührt die Box nirgends (4,1 mm Abstand zur Rückwand, 0,2 mm Luft unter der Lippe), es muss nichts abgebrochen werden.
5. Falls der Slicer den Modifier **nicht** übernimmt: Rechtsklick auf das Objekt, Modifier hinzufügen (Quader), über den Boxgrundriss legen (Z 48,8 bis 70,4 mm) und dort 6 Wände, 100 % Füllung einstellen.
6. Etikett von der Seite einschieben. Zu locker: `label_gap` verkleinern oder eine Seite schließen (`label_open_left/right = false`).

## Stand und offene Punkte (14.11.2026)

- **Nichts davon ist gedruckt.** Alle STL sind wasserdicht, die 3MF ist strukturell geprüft (Teile, Platzierung, Einstellungen), aber **nicht im Anycubic Slicer Next geöffnet**. Erster Schritt: die 1×2-Box als Probedruck, Sitz am Steg prüfen.
- **Nachmessen:** Innenmaße der Eurobox am Boden und Innenhöhe (`eb_x`, `eb_y`, `eb_h`), Steg-Dicke (`rail_t`), Abstand Steg–Wand (für `hook_t`).
- Annahmen der Traglast (Schüttdichte, zulässige Spannungen für PETG) sind nicht gemessen. Ein Belastungsversuch mit einer gedruckten Box zeigt, ob sie stimmen.
- Bei dauerhaft hoher Last PETG verwenden, PLA kriecht (vor allem warm) und hat eine schlechtere Schichthaftung.

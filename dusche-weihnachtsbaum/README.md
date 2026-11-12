# Weihnachtsbaum-Duschkopf mit Hansgrohe-Schnellkupplung

Der „Xmas tree shower head“ von QuiqueCrimson (MakerWorld, Profil „Decorated“) hat am Griffende einen 1/2"-Außengewindezapfen für den Duschschlauch. In dieser Version ist der Zapfen durch den Stecker der **Hansgrohe-Schnellkupplung (Quick Connect 28346000)** ersetzt, und der eckige Griff ist rund. Der Duschkopf klickt damit direkt in die Kupplung am Schlauch, ohne Zwischenadapter.

Es gibt zwei Varianten:

- **Standard:** runder Griff, Schnellkupplung.
- **Mit Geschenken:** zusätzlich vier weiße Geschenke mit roten Bändern und Schleifen unter dem Baum.

![Übersicht](bilder/uebersicht.png)

![Mit Geschenken](bilder/geschenke.png)

| Geschenke unter dem Baum (Schnitt auf halber Höhe) | Längsschnitt am Griffende |
|---|---|
| ![Draufsicht Geschenke](bilder/geschenke_draufsicht.png) | ![Schnitt](bilder/schnitt.png) |

Stecker aus `schnellkupplung_stecker.scad`:

![Stecker](bilder/stecker.png)

## Dateien

| Datei | Inhalt |
|---|---|
| `schnellkupplung_stecker.scad` | Stecker der Schnellkupplung. Geometrie 1:1 aus `hansgrohe_shower_quick_connect_adapter.scad` (Modul `coupler()`, Schlüsselflächen, Bohrung ø 7,94), ohne Gewindebuchse; 3 mm Überlappung in den Griff. |
| `werkzeuge/erzeuge_modell.py` | Baut aus der Original-3MF den runden Griff mit Stecker, optional die Geschenke, und schreibt STL und Bambu-3MF. Druckeinstellungen und die Farbbemalung der Kugeln bleiben erhalten. |
| `werkzeuge/bilder.py` | Erzeugt die Bilder in `bilder/` (außer `stecker.png`, das kommt direkt aus OpenSCAD). |

**Das Netz des Duschkopfs ist nicht eingecheckt.** Das Original steht unter der *Standard Digital File License* von MakerWorld, die das Weitergeben der Datei und abgeleiteter Dateien nicht erlaubt; das Repository ist öffentlich. Das fertige Modell entsteht lokal aus der heruntergeladenen Original-3MF:

```sh
python3 werkzeuge/erzeuge_modell.py DuchaArbolBolas.3mf ausgabe/              # Standard
python3 werkzeuge/erzeuge_modell.py DuchaArbolBolas.3mf ausgabe/ --geschenke  # mit Geschenken
python3 werkzeuge/bilder.py ausgabe/ bilder/                                  # braucht beide Varianten
```

Benötigt: OpenSCAD (getestet 2021.01), Python mit `numpy trimesh manifold3d lxml shapely` (für die Bilder zusätzlich `matplotlib`).

## Umbau

**Schnellkupplung**
- Der Gewindezapfen (ø ≈ 19,3, 15 mm) fällt weg. Der Stecker beginnt mit der Rastnut direkt an der Stirnfläche des Griffs, genau wie im Adapter über der Gewindebuchse.
- Griffachse: y = 0, z = −0,625 mm in Original-Koordinaten (Mitte des alten 20-mm-Griffs, gemessen an Außenkontur und Bohrung).

**Runder Griff**
- Statt 20 × 20 mm eckig jetzt ein Zylinder mit ø 21,25 mm von der Stirnfläche bis kurz vor den Hals (x = −97,5 … −17). Danach eine Fase auf ø 15 zum Hals, wie die Fase im Original.
- Unten ist der Griff auf Bettniveau abgeflacht, die Fläche ist 7,2 mm breit. So liegt er beim Druck auf, ohne dass sich der Rest des Modells verschiebt. Oben endet er bei z = 10,0, also unter der Oberkante des Baums.
- Die ø-21,25-Stirnfläche entspricht der ø-21-Schulter des Adapters, an der die Kupplung anliegt.
- Wasserweg: Stecker ø 7,94 → Griffbohrung ø 10 → Hals ø 10 → Duschkopf. Durchgehend geprüft (Strahl entlang der Achse).

**Geschenke** (`GESCHENKE` in `erzeuge_modell.py`)
- Vier Kartons, je zwei links und rechts vom Griff unter dem untersten Ast. Sie haben dieselbe Stärke wie der Baum (21,25 mm) und laufen über die volle Höhe durch. Größen 12–25 × 14–19 mm.
- Bänder kreuzförmig, 3,2 mm breit, über die volle Höhe. Auf jedem Deckel sitzt eine Schleife aus zwei Schlaufen und einem Knoten.
- Halt:
  - Die Schleifen reichen 1,5 mm in den vollen Fußrand des Baums (Unterseite x = −3,5, der Hohlraum beginnt erst bei x = +1,75).
  - Die inneren Kartons liegen 1 mm tief am Griffmantel an (Kontaktstreifen etwa 9 mm breit über die ganze Kartonlänge).
  - Die äußeren Kartons hängen am inneren Karton und an ihrer eigenen Schleife.
- Wasserführung: Die Geschenke berühren nur Vollmaterial. Der Abstand zur Wasserbohrung (r < 5) und zum Hohlraum im Baum ist groß. Das Skript bricht ab, wenn die Geschenke in den Baum ragen, nicht verbunden sind oder Teile überlappen.
- In der 3MF ist alles ein Objekt mit drei Bauteilen, die sich nur berühren:

  | Bauteil | Filament |
  |---|---|
  | Baum | Slot 6, grün, wie im Original |
  | Geschenke | Slot 14, auf Weiß gesetzt, PLA Basic |
  | Schleifen | Slot 5, dasselbe Rot wie die Kugeln |

**Allgemein**
- Die Farbbemalung des Originals (goldene und rote Kugeln, Slots 4 und 5) wird Dreieck für Dreieck übernommen. Verloren geht nur die Grün-Bemalung des alten eckigen Griffs.
- Das Modell ist 242,7 × 85 × 21,25 mm groß. Es passt auf 256er-Betten (X1/P1/A1), nicht auf den A1 mini. Der Duschkopf ist ein geschlossenes, einteiliges Netz.

## Druck

- Lage wie im Original: flach, Baum liegend. **Stützen nötig** (in der 3MF aktiv: Baum-Stützen, nur vom Druckbett):
  - Die Steckerachse liegt 10 mm über dem Bett, der Bund also 1,65 mm darüber.
  - Der runde Griff steigt seitlich der 7-mm-Auflage flach an.
- Die O-Ring-Nut und die Rastnut werden liegend gedruckt. Die Unterseite nach dem Entfernen der Stützen sauber nacharbeiten, sonst dichtet der O-Ring schlecht oder die Kupplung rastet schwer.
- O-Ring wie beim Adapter in die Nut zwischen den beiden ø-14,5-Abschnitten.
- Geschenk-Variante: Weiß und Rot laufen über die ganze Höhe. Damit wechselt der Drucker in jeder Lage zwischen Grün, Weiß und Rot. Das kostet Zeit und Spülmaterial (in der Größenordnung wie die bemalten Kugeln). Spülen ins Infill bzw. ins Objekt lohnt sich.

## Stand

- 09.11.2026: erste Version mit Schnellkupplung.
- 12.11.2026:
  - Griff rund (ø 21,25, unten abgeflacht).
  - Variante mit Geschenken.
  - Die Kugel-Bemalung bleibt jetzt erhalten. In der ersten Version ging sie verloren.
- Noch nicht gedruckt erprobt. Die Steckermaße sind die des vorhandenen Adapters, nur die Drucklage ist anders (liegend statt stehend).

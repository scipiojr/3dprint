# Weihnachtsbaum-Duschkopf mit Hansgrohe-Schnellkupplung

Der „Xmas tree shower head“ von QuiqueCrimson (MakerWorld, Profil „Decorated“) hat am Griffende einen 1/2"-Außengewindezapfen für den Duschschlauch. In dieser Version ist der Zapfen durch den Stecker der **Hansgrohe-Schnellkupplung (Quick Connect 28346000)** ersetzt. Der Duschkopf klickt damit direkt in die Kupplung am Schlauch, ohne Zwischenadapter.

![Übersicht](bilder/uebersicht.png)

| Stecker (aus `schnellkupplung_stecker.scad`) | Längsschnitt am Griffende |
|---|---|
| ![Stecker](bilder/stecker.png) | ![Schnitt](bilder/schnitt.png) |

## Dateien

| Datei | Inhalt |
|---|---|
| `schnellkupplung_stecker.scad` | Stecker der Schnellkupplung. Geometrie 1:1 aus `hansgrohe_shower_quick_connect_adapter.scad` (Modul `coupler()`, Schlüsselflächen, Bohrung ø 7,94), ohne Gewindebuchse; 3 mm Überlappung in den Griff. |
| `werkzeuge/erzeuge_modell.py` | Schneidet das Original am Griff ab, setzt den Stecker koaxial an und schreibt STL und Bambu-3MF (Druckeinstellungen des Originals bleiben erhalten). |
| `werkzeuge/bilder.py` | Erzeugt `bilder/uebersicht.png` und `bilder/schnitt.png`. |
| `bilder/` | Vorschaubilder; `stecker.png` direkt aus OpenSCAD. |

**Das Netz des Duschkopfs ist nicht eingecheckt.** Das Original steht unter der *Standard Digital File License* von MakerWorld, die das Weitergeben der Datei und abgeleiteter Dateien nicht erlaubt; das Repository ist öffentlich. Das fertige Modell entsteht lokal aus der heruntergeladenen Original-3MF:

```sh
python3 werkzeuge/erzeuge_modell.py DuchaArbolBolas.3mf ausgabe/
# -> ausgabe/weihnachtsbaum_dusche_quick_connect.3mf und .stl
```

Benötigt: OpenSCAD (getestet 2021.01), Python mit `numpy trimesh manifold3d lxml shapely` (für die Bilder zusätzlich `matplotlib`).

## Umbau

- Schnitt bei x = −97,5 mm (Original-Koordinaten): Dort ist der Griff voll 20 × 20 mm; das Gewinde (ø ≈ 19,3, 15 mm) samt Übergangsfase fällt weg.
- Griffachse: y = 0, z = −0,625 mm (Mitte des 20-mm-Griffs, gemessen an Außenkontur und Bohrung).
- Der Stecker beginnt an der Schnittfläche mit der Rastnut, genau wie im Adapter über der Gewindebuchse. Die Stirnfläche des Griffs (20 × 20, Ecken R ≈ 3) übernimmt die Anlage, die im Adapter die ø-21-Schulter hatte.
- Wasserweg: Stecker ø 7,94 → Griffbohrung ø 10 → Duschkopf. Durchgehend geprüft (Strahl entlang der Achse).
- Das Modell wird um 12,7 mm länger: 242,7 × 85 × 21,25 mm. Es bleibt auf 256er-Betten (X1/P1/A1), nicht auf dem A1 mini. Das Ergebnis ist ein geschlossenes, einteiliges Netz.

## Druck

- Lage wie im Original: flach, Baum liegend. Die Steckerachse liegt 10 mm über dem Bett, der Bund also 1,65 mm darüber. **Stützen nötig** (in der 3MF aktiv: Baum-Stützen, nur vom Druckbett), wie schon beim alten Gewindezapfen.
- Die O-Ring-Nut und die Rastnut werden liegend gedruckt. Die Unterseite nach dem Entfernen der Stützen sauber nacharbeiten, sonst dichtet der O-Ring schlecht oder die Kupplung rastet schwer.
- O-Ring wie beim Adapter in die Nut zwischen den beiden ø-14,5-Abschnitten.

## Stand

- 09.11.2026: erste Version. Nicht gedruckt erprobt. Die Steckermaße sind die des vorhandenen Adapters, nur die Drucklage ist anders (liegend statt stehend).

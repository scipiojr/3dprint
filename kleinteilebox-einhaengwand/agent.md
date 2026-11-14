# agent.md – Kleinteilebox (Sortierboxen für Eurobox + Einhängewand)

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit dem Nutzer: **Deutsch**. Anwenderdoku: `README.md`.

## Arbeitsweise in diesem Repository

- Projektordner: `kleinteilebox-einhaengwand/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Projektordner nicht anfassen.
- Wie in den anderen Projekten: **jede Änderung committen und nach `origin/main` pushen**, ohne Rückfrage, solange der Nutzer nichts anderes sagt. Vor dem Push `git pull --rebase origin main`.
- Commit-Messages auf Deutsch, Betreffzeile im Imperativ (≤ 72 Zeichen), darunter kurz *was* und *warum*; Trailer wie in den vorhandenen Commits (`Co-Authored-By: …`, `Claude-Session: …`).
- **Die SCAD-Datei ist die Quelle.** STL und 3MF werden eingecheckt. Nach jeder Geometrieänderung: `werkzeuge/export.sh` (erzeugt 1x2 und 2x3), `werkzeuge/bilder.sh`, `python3 -I werkzeuge/traglast.py --md` (Tabelle im README aktuell halten), dann alles mitcommitten. Andere Größen nur bei Bedarf einchecken.
- **Versionierung nur über Git:** neue Stände überschreiben die gleichnamige Datei, keine `_v2`-Kopien.
- Werkzeuge: OpenSCAD 2021.01 (alle Exporte zusammen ca. 3 s), Python mit `numpy` und `matplotlib` (`pip install --break-system-packages …`), `xvfb-run` für die Vorschau. Python-Skripte mit `python3 -I` starten. `__pycache__` nicht einchecken. OpenSCADs `--render` ignoriert `color()`, Bilder mit Farbe nur im Vorschaumodus (siehe `bilder.sh`).
- README und dieses Dokument aktuell halten, wenn sich Parameter, Teile oder Entscheidungen ändern.

## Ziel

Sammelboxen für Schrauben (Metall) und Kleinteile, die **liegend lückenlos in eine Eurobox 60 × 40 × 8 cm** passen und **an eine Einhängewand mit Stegen** gehängt werden. Länge und Breite parametrisch im festen Raster, Höhe fest, Haken immer gleich (Höhe, Tiefe, Lage). Druck: aufrecht, PETG, **Anycubic (Kobra S1) mit Anycubic Slicer Next** (Orca-basiert). Das Druckbett im Repo wird sonst mit 250 × 250 mm angesetzt (Plattenmitte 125/125).

## Dateikarte

| Datei | Inhalt |
|---|---|
| `kleinteilebox.scad` | Quelle. `part` = `box`, `modifier` (Tragzone), `support_zone` (Stützbereich/Enforcer). Koordinaten: X Breite (entlang der Wand), Y Tiefe (0 = Wandseite mit Haken), Z Höhe = Druckrichtung |
| `kleinteilebox_BxT.stl`, `.3mf` | Ausgaben, eingecheckt für 1x2 und 2x3 |
| `werkzeuge/export.sh` | `export.sh [BxT …]`: STL (box) + 3MF je Größe, STL-Prüfung |
| `werkzeuge/erzeuge_3mf.py` | 3MF im Bambu/Orca-Format (wie `biomuell-einsatz/werkzeuge/korb_3mf.py`): **ein Objekt, drei Bauteile** (Box, Tragzone als `modifier_part`, Stützbereich als `support_enforcer`), Einstellungen in `Metadata/model_settings.config`, Plattenmitte 125/125 |
| `werkzeuge/stl_werkzeug.py` | STL laden/prüfen (wasserdicht, Volumen, Körperzahl), nur numpy |
| `werkzeuge/traglast.py` | Traglastrechnung; liest die Standardwerte aus der SCAD-Datei, Parameter per `name=wert` überschreibbar |
| `werkzeuge/bild_schnitt.py`, `bilder.sh` | Längsschnitt (matplotlib) und Ansicht (OpenSCAD-Vorschau) → `bilder/` |

## Entscheidungen (mit Begründung)

- **Raster 40 mm, Spiel 0,5 mm je Box.** Haken (hinten) und Etikettenrahmen (vorn) sind im Raster eingerechnet: `L = units_l·40 − 0,5 − hook_over − front_over`. Dadurch ist die belegte Fläche immer ein Vielfaches des Rasters.
- **Hakenmaße (Nutzer):** Steglänge (Lippe hinter dem Steg) 8 mm, Stegabstand an der Wand **76 mm Oberkante zu Oberkante** (also `H = 70 ≤ 76`), Hakendach **4 mm** (der Nutzer wollte 2 mm mehr Oberkante für höhere Last), Schlitz **+1,5 mm** breiter (`hook_clear` 2,1). Haken und Lippe laufen **über die ganze Breite** (vollflächig, vom Nutzer so gewünscht).
- **Etikett (Nutzer):** feste Höhen 6/9/12/19/24 mm, Breite Standard Boxbreite − 20 mm, horizontal mittig, **im oberen Drittel**, darf bei hohen Etiketten weiter unten liegen; **oben geschlossen**, seitlich einschiebbar (offene Seiten wählbar); freie Brücke der oberen Leiste über 40 mm bekommt dünne Stützstege im Sichtfenster.
- **Leichtbau + Tragrahmen (Nutzer, 14.11.2026):** Die Schichten, die Halter und Boxrahmen verbinden und die Last tragen, sollen massiv sein, die Box selbst möglichst leicht. Umsetzung: `wall` 1,2 mm, Boden automatisch aus der Durchbiegung (`sag_max` 2 mm, Schüttdichte 4 kg/l), obere `band_h` mm (Standard 20) mit 2,4 mm Rückwand und **Modifier-Volumen** (6 Wände, 100 % Füllung). Der Nutzer wies darauf hin, dass der tragende Rahmen **bei gleicher Gesamthöhe mehr Schichten haben darf**: deshalb ist `band_h` ein eigener Parameter, der Rahmen wächst nach unten.
- **Nur die Rückwand ist im Rahmen dick (`band_ring = false`).** Gemessen: Ein 2,4-mm-Ring um alle Wände machte die Box schwerer als den alten Entwurf (56,4 statt 55,8 cm³); nur die Rückwand dick ergibt 49,3 cm³ (−12 %). Die Rechnung braucht den Ring nicht (Rückwand 28-fach, Rahmen 56-fach Reserve).
- **Wandanlage:** Die Wand nimmt nur das Kippmoment auf (Horizontalkraft an der Lippe ≈ 0,95 × Gewichtskraft bei 2×3 voll), kein Gewicht. Reibung wird nicht angesetzt. **Schwächstes Glied ist die Hakenlippe** (Biegung quer zu den Schichten): 2,1-fache Reserve bei 2×3, nur 1,1-fach bei Tiefe ≥ 4 Einheiten. Gegenmittel: `hook_t` 3 mm (2,6-fach), hängt vom Abstand Steg–Wand ab (offen, Nutzer muss messen); sonst tiefe Boxen nicht voll füllen.
- **Stützen macht der Slicer, nicht das Modell (Nutzer, 14.11.2026):** Die Hakenlippe hängt frei. Der Nutzer will **keinen selbst gebauten Stützturm** im Modell, sondern in der 3MF **einen Bereich für Stützen**. Umsetzung: `part = "support_zone"` ist ein flacher Quader (Breite W, Y −0,5 bis hook_t + 0,5, Z `zl − 1` bis `zl + 1`, `zl` = Lippenunterkante 58 mm), in der 3MF Bauteil `support_enforcer`. Objekt-Einstellung `enable_support = 1`, `support_type = normal(manual)`, `support_on_build_plate_only = 1`: Stützen entstehen nur im Enforcer-Bereich. Nicht im Slicer geprüft (offen, siehe unten).
- Etikettenrahmen unten mit 45°-Fase (druckbar ohne Stütze); Tragrahmen-Übergang ebenfalls 45°.

## Verworfene Varianten – nicht wieder vorschlagen

- **Abstützleiste unten hinten als Standard:** Nutzer: unnötig. Bleibt als Option `support_rib`, Standard aus. (Mit ihr liegt die Box sofort an der Wand an; ohne neigt sie sich ca. 5,6° bis die Rückwandkante anliegt.)
- **Stütze im Sichtfenster des Etiketts:** Der Nutzer meinte die Stütze für die **Einhängeleiste (Haken)**, nicht fürs Sichtfenster.
- **Abbruchstützen an der Hakenlippe** (Rippenkamm an der Rückwand, erst als einzelne Rippen, dann als zusammenhängender Streifen mit Sollbruchstelle): Nutzer: zu viele kleine Teile zum einzelnen Ausbrechen, riss an der Senkrechten und an der Waagerechten nicht sauber ab. Ersetzt durch den freistehenden Turm.
- **Tragrahmen als Ring um alle vier Wände als Standard:** schwerer als nötig (siehe oben). Nur als Option `band_ring`.
- **Wände 1,6 mm / Boden 1,2 mm** (erster Entwurf): durch den leichteren Aufbau ersetzt.

## Randbedingungen vom Nutzer

- Eurobox 60 × 40 × 8 cm; die **Innenmaße am Boden und die Innenhöhe sind nicht gemessen** (Annahme 560 × 360 × 75 mm, `eb_x`, `eb_y`, `eb_h`). Steg-Dicke `rail_t` = 2 mm ist ebenfalls geschätzt.
- Füllgut: **Metallschrauben**. Der Nutzer wollte, dass die Traglast gerechnet wird und die Wandanlage einen Teil der Last abträgt (Ergebnis siehe oben: sie trägt das Kippmoment).
- 3MF **für Anycubic** (Slicer Next, Orca-Format). Der Nutzer gibt gern Rückmeldung per Foto/Screenshot.

## Stand (14.11.2026) und offen

- Modell, STL (1x2, 2x3), 3MF, Doku und Rechnung sind fertig und gepusht. **Nichts ist gedruckt**, die 3MF ist **nicht im Anycubic Slicer Next geöffnet** (nur Aufbau und XML geprüft). Ob der Slicer den Modifier mit seinen Einstellungen und den Stützbereich als Enforcer übernimmt (Stützen nur dort, Typ „normal (manuell)“), ist unbestätigt; Rückfallanleitung steht im README. Falls der Nutzer berichtet, dass keine oder falsche Stützen entstehen: Screenshot anfordern, dann `support_type` oder die Enforcer-Lage (`support_zone`) anpassen.
- Nutzer soll nachmessen: Eurobox-Innenmaße und -höhe, `rail_t`, Abstand Steg–Wand (für `hook_t` 3).
- Annahmen der Traglast (Schüttdichte 4 kg/l, zulässige Spannungen PETG, Ruckfaktor 1,5) sind nicht durch Versuch bestätigt; nach dem ersten Probedruck (1×2) mit Belastungsversuch abgleichen.
- Möglich später: Haken mit Anschlagnase nach vorn gegen Abrutschen, Trennwand-Varianten, weitere Etikettenformen. Nur auf Wunsch.

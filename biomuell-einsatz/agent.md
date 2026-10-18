# agent.md – Biomüll-Einsatz

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit der Nutzerin: **Deutsch**.

## Arbeitsweise in diesem Repository

- Projektordner: `biomuell-einsatz/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner nicht anfassen.
- **Jede Änderung wird committet und sofort nach `origin/main` gepusht**, ohne Rückfrage. So hat es die Nutzerin festgelegt.
- Commit-Messages auf Deutsch, sprechend: Betreffzeile im Imperativ (≤ 72 Zeichen), darunter kurz *was* und *warum*.
- Vor dem Push `git pull --rebase origin main` (die Nutzerin committet auch selbst).
- STL-Dateien werden eingecheckt. Die SCAD-Datei ist die Quelle.
- Jeder neue Konstruktionsstand ist ein eigener Commit mit allen erzeugten Dateien im Projektordner. Der Verlauf steht in der Git-Historie.
- Bilder nach Geometrieänderungen neu erzeugen: `werkzeuge/bilder.sh` (siehe unten) und mitcommitten.
- README und dieses Dokument aktuell halten, wenn sich Parameter, Teile oder Entscheidungen ändern.

## Ziel

Für einen Biomülleimer werden 3D-Druck-Teile aus PETG entworfen:

- ein **Korb** (Plattform mit Bügeln und Bändern), mit dem ein Papier-Biomüllsack herausgehoben wird,
- ein **Trichter**, der rundum auf dem Absatz am oberen Eimerrand aufliegt.

Alles steht in **einer parametrischen OpenSCAD-Datei** (`biomuell_system.scad`). Zu große Teile teilt sie automatisch und versieht sie mit Klebe- bzw. Schraubverbindungen.

## Randbedingungen (von der Nutzerin)

- **Drucker:** Druckraum 260 × 260 × 260 mm, PETG. Alle Teile müssen in die Spülmaschine dürfen.
- **Nichts über der Eimerkante:** Der Eimer fährt unter eine Ablage. Keine Auflagen oder Griffe über dem Rand.
- **Zu große Teile** dürfen geteilt und geklebt werden, wenn die Verbindung dafür konstruiert ist.
- **Eimer:** 32 cm hoch, Ecken innen 45° abgeschrägt. Auf 30,5 cm springt die Wand je Seite um 3 mm zurück (Absatz). Maße oberhalb des Absatzes siehe Parameter. Messungenauigkeit einplanen.
- **Papiersack:** 360 hoch × 200 breit × 160 tief. Er sackt zusammen und passt deshalb trotz der Höhe.

## Gültiges Konzept

> **Der Trichter führt den Müll NICHT in den Sack. Er hält den Sack in Position.**

1. Der Sack ragt durch die Trichteröffnung nach oben. Die Öffnung umschließt Sack und Bänder; die Bänder schaffen den Abstand dazwischen.
2. Die Griffe liegen zwischen Sack und Trichter-Innenrand, unter der Eimerkante (Voreinstellung: Oberkante 5 mm über dem Absatz = 10 mm unter der Kante).
3. Der Trichter bleibt dauerhaft im Eimer. Der ganze Korb wird **durch die Trichteröffnung** gehoben.
4. Trichter: Kragen auf dem 3-mm-Absatz, darunter 40 mm Schräge bis zur Öffnung, dort ein 15 mm hoher senkrechter Haltekragen.

### Verworfene Varianten – nicht wieder vorschlagen

- Trichter mit Tülle, die in den Sack ragt, Bänder an der Eimerwand, Trichter wird vor dem Leeren herausgenommen.
- Separater „Sackring“-Einsatz, der im Trichter aufliegt und mit einer Tülle in den Sack ragt.

## Stand der Konstruktion (18.10.2026)

### Verlauf

- **Vor dem 16.10.2026 – Version 0 (Python):** Plattform 250 × 195 mit Rippen und 4-mm-Löchern, Schnapphaken-Bänder, kein Trichter. Quellen und 3MF in `archiv/2026-10-16_v0_python/`.
- **16.10.2026, 01:55 – Version 1 (SCAD):** Massive Plattform 206 × 166, Bügel, Bänder, Trichter (gleich dicke Wand), Passlehre. Eimer mit 278 × 210 mm angenommen. Quellen, damaliges Übergabedokument und 3MF in `archiv/2026-10-16_v1_scad/`; darauf beruht das erste Druckprojekt (`biomuell_system.3mf`).
  Die V1-SCAD erzeugt Maße und Volumen der damaligen STLs exakt (geprüft am 18.10.). Alte STLs werden nicht eingecheckt; bei Bedarf neu exportieren.
- **18.10.2026 – Version 2** (Entwicklungsstände, jeder ein Commit):
  - **Stand 1, 10:04 Uhr:** **Trichter neu aufgebaut (Version 2).** Anlass: Die gedruckten Hälften der Version 1 rissen nach wenigen Millimetern der Schräge ab (Spaghetti, PETG, mehrere Drucker). Ursache laut Analyse: nicht der Überhang (nur 33–38° aus der Senkrechten), sondern eine sehr schmale Auflage auf dem Bett (3,5–6 mm breit, zusammen ca. 1860 mm²), eine dünne, nach innen geneigte 2,5-mm-Wand, die an der Fuge offene U-Form, dazu die Slicer-Einstellungen aus dem ersten Projekt (Kobra S1: Außenwand 200 mm/s, Innenwand 300 mm/s, Beschleunigung 10 000, Lüfter ab 10 % Überhang auf 90 %, 230 °C).
     - **Keilwand** (`innenform = "keil"`, Standard; `"parallel"` = Wand der Version 1): Außenmaße und Außenform unverändert, innen steilere Schräge (64°/75°, Ecken 60°), Kragen-Oberseite `ring_x = 10`, `ring_y = 6` mm breit. Überhang beim Druck 26° (Schmalseite), 15° (Langseite), 30° (Ecken). Auflage auf dem Bett ca. 3470 mm² (mit Druckhilfe ca. 4302 mm²), ca. 50 % mehr Material, Griffraum an der Schmalseite oben 25 statt 31 mm. `ring_y` wurde im Lauf des Stands von 7,5 auf 6 mm gesenkt, damit an den Langseiten der Fingerraum nahe an Version 1 bleibt.
     - **Druckhilfe** (`druckhilfe = true` in diesem Stand): 4 × 5 mm Steg auf dem Bett, schließt die offene Seite zum Ring, hängt an zwei 0,5 mm dünnen Haltestegen und wird nach dem Druck abgetrennt. Die Klebefläche der Fuge bleibt frei.
     - Gedruckt war Version 2 noch nicht; sie ließ sich in PrusaSlicer ohne Fehler slicen.
  - **Stand 2, 10:13 Uhr:** **`trichter_v2.3mf`:** beide Hälften (mit Druckhilfe) auf je einer Platte, druckfertig mit der Kragenoberseite unten. Plattenraster aus dem Projekt der Nutzerin für den Kobra S1 übernommen (Spaltenabstand 314,4 mm). Einstellungen je Objekt: 4 Wände (Arachne), 40 % Gyroid, oben/unten 5 Lagen, 0,2 mm, keine Stützen, Brim 6 mm außen, Außenwand 70 mm/s, Innenwand 100 mm/s, Beschleunigung 2000/3000, Naht hinten. Temperatur und Lüfter lassen sich nicht je Objekt in der 3MF speichern (Filamentprofil: 240–245 °C, Lüfter 30–40 %, Überhang-Lüfter höchstens 50 %). In PrusaSlicer geprüft (beide Hälften dicht); im Anycubic Slicer Next nicht geöffnet.
  - **Stand 3, 10:17 Uhr:** **`druckhilfe = false` als Standard.** Der Steg war nur als Druckhilfe gedacht und stünde im zusammengebauten Trichter quer in der Öffnung. Hälfte wieder 137,75 × 207,5 × 59 mm. Ohne Steg fehlt die Versteifung der offenen U-Seite: Brim auf 8–10 mm stellen und die Enden an der Fuge beobachten. STL, 3MF und SCAD neu.
  - **Stand 4, 10:19 Uhr:** **`trichter_v2_druckhilfe.3mf`:** Der Steg ist als eigenes Teil „Druckhilfe - nach dem Druck abtrennen“ im Trichter-Objekt angelegt (2 Wände, 15 % Gitter, 2 Haltestege), `druckhilfe_steg.stl` ist das Einzelteil. Als echter Support lässt er sich nicht definieren: Der Slicer erzeugt Support nur unter Überhängen, und Support haftet absichtlich locker und würde die offene U-Seite nicht versteifen. In PrusaSlicer als getrennte, dichte Teile erkannt.
  - **Stand 5, 11:31 Uhr:** **Scharnier gegen Abfallen:** Der 6-mm-Stift in der Plattform ist an zwei Seiten senkrecht auf 4,2 mm abgeflacht (`stift_flach = 4.2`), die Haken haben statt der Schnappöffnung einen geraden Kanal von 4,7 mm (`kanal_spiel = 0.25`, Einführfase `kanal_fase = 0.6`). Aufrecht im Eimer liegt der Kanal quer zur Abflachung, der Haken ist gefangen. Nur bei waagerecht nach außen liegendem Band (±7°) lässt er sich von oben aufstecken und abziehen; im 2D-Schnitt geprüft: abnehmbar nur bei ca. 83–95° aus der Senkrechten. Alle drei Teile (Plattform, Bügel, Bänder) neu drucken, alte und neue passen nicht zusammen. `stift_flach = 0` = alter Schnapphaken.
  - **Stand 6, 12:32 Uhr:** **`korb_v2.3mf`:** 5 Platten (Plattform, Bügel Langseite A/B, Band Schmalseite A/B). Zwei Bänder nebeneinander sind breiter als das Druckbett, ineinander verschachteln geht nicht, weil die Griffschlaufen an die Beine der Bügel stoßen. Einstellungen je Objekt: Plattform 4 Wände, 25 % Gyroid, 5/5, Brim 5 mm; Bügel und Bänder 3 Wände, 100 %, 5/5, kein Brim; keine Stützen. Empfehlung: zuerst ein Band mit der Plattform drucken und die Passung des Hakens prüfen.

### Kennwerte mit Standardwerten (Konsolenausgabe)

- Druckraum nutzbar 250 × 250 (`bett_rand = 5`).
- Plattform 206 × 166, Höhe 56, 1 Stück, 9 Langlöcher.
- Bügel Langseite und Band Schmalseite: je 239,75 mm, 1 Stück, je 2× drucken. Griff-Oberkante 280 mm über Boden.
- Trichter 275,5 × 207,5 × 59: 2 Hälften à 137,75. Öffnung 212 × 172. Außenschräge 54°/69°, Ecken 52°.
- Sack in der Öffnung: 6 mm Abstand je Seite (davon 2,3 mm Band). Öffnungs-Unterkante 220 mm über Boden.
- Trichterfuge: 4 Schrauben M3 × 16 (Edelstahl) + Muttern, optional 2K-Epoxid. Bis Stand 6 saß das obere Loch jeder Lasche angeschnitten.

### Wichtige Parameter

- `absatz_z = 275`: Absatz über dem **Innenboden**. **Nur angenommen** (altes Skript: 290 Innentiefe − 15). Bandlänge und Griffhöhe hängen davon ab.
- Plattform: `platte_l/b = 206/166`, `platte_fase = 16`, `platte_t = 6` (massiv, keine Rippen – Wunsch: wenig Ablagerung, leicht zu reinigen), `bodenabstand = 50`, Langlöcher 44 × 22.
- Scharniere: `scharniere_lang = 2` (Bügel, Haken bei x = ±55), `scharniere_kurz = 1` (Band).
- Trichter: `trichter_tiefe = 40`, `oeffnung_spiel = 3`, `kragen_unten_h = 15`, `wand = 2.5`, `kragen_t = 4`, `flansch_spiel = 1.25`, `trichter_spiel = 1.0`.

- Eimer (gemessen): `eimer_l = 278`, `eimer_gerade_l = 240`, `eimer_b = 210`, `eimer_gerade_b = 170`.
- Keilwand: `innenform = "keil"`, `ring_x = 10`, `ring_y = 6`; Druckhilfe `druckhilfe = false`.
- Scharnier: `stift_flach = 4.2`, `kanal_spiel = 0.25`, `kanal_fase = 0.6`.

### Koordinaten

- Übersicht: X = Eimer-Längsachse, Y = Querachse, Z = 0 auf dem Innenboden.
- Trichter: lokal mit z = 0 auf der Absatzebene.
- Bänder: Druckkoordinaten X = Länge, Y = Breite, Z = Dicke; Z = 0 ist die Außenseite zur Eimerwand.

## Offene Punkte

1. **`absatz_z` nachmessen lassen** (Absatz über dem Innenboden), danach STLs neu exportieren.
2. Passlehre zuerst drucken; bei Bedarf `flansch_spiel` / `trichter_spiel` anpassen.
3. **Abfall auf der Trichterschräge:** rutscht zum Öffnungsrand an die Sackwand. Möglicher Hinweis: Sackrand über Haltekragen bzw. Schräge umschlagen. Mit der Nutzerin klären, nicht eigenmächtig umkonstruieren.
4. **Sack über der Kante:** 360 mm Sack ab 56 mm Höhe ragt rechnerisch über die Kante (290 mm). Die Nutzerin sagt, er sacke zusammen. Ggf. nach einem Umschlag fragen.
5. Bei kleinerem Druckbett kann eine Plattformfuge durch ein Loch laufen (funktioniert, ist dort schwächer).
6. Unten hat die Plattform Spiel zum Eimer; zentriert wird oben durch die Trichteröffnung.
7. Griffwölbung (`griff_t = 8`) zeigt zum Sack und drückt etwa 5 mm ins Papier; ggf. verkleinern.
8. Geklebte Fugen: 2K-Epoxid; Trichter bevorzugt mit Edelstahlschrauben.
9. Druckeinstellungen in der 3MF sind nicht für Version 2 aktualisiert.

## Werkzeuge

- **OpenSCAD:** Wenn kein natives OpenSCAD installierbar ist, funktioniert der WebAssembly-Build 2022.03 (`github.com/openscad/openscad-wasm/releases/download/2022.03.20/openscad.wasm` und `openscad.wasm.js`).
  - `werkzeuge/openscad_wasm.mjs <ein.scad> <aus.stl|.svg> [-D name=wert …]` führt ihn unter Node aus (`OPENSCAD_WASM_DIR` zeigt auf den Ordner mit den beiden Dateien).
  - `include <…>` geht dort nicht. Für Baugruppen die Datei verketten und einen Aufruf anhängen, mit `-D teil="keins"` (siehe `bilder.sh`).
  - Renderzeiten: Trichter ca. 3 s, Plattform und Bügel 20–30 s.
- **Bilder:** `werkzeuge/bilder.sh` rendert Baugruppen und Einzelteile, exportiert zwei Schnitte als SVG (`projection(cut=true)`) und zeichnet daraus mit `werkzeuge/bilder.py` (numpy, matplotlib) die PNGs in `bilder/`.
- **Prüfungen** (bisher ad hoc in Python mit numpy/scipy): Dichtheit und Kantenzählung der STLs, Volumen, Bounding-Box, Abstände zwischen Teilen über Oberflächenpunkte und `cKDTree`.

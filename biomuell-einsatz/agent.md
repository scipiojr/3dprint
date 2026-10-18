# agent.md – Biomüll-Einsatz

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit der Nutzerin: **Deutsch**.

## Arbeitsweise in diesem Repository

- Projektordner: `biomuell-einsatz/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner nicht anfassen.
- **Jede Änderung wird committet und sofort nach `origin/main` gepusht**, ohne Rückfrage. So hat es die Nutzerin festgelegt.
- Commit-Messages auf Deutsch, sprechend: Betreffzeile im Imperativ (≤ 72 Zeichen), darunter kurz *was* und *warum*.
- Vor dem Push `git pull --rebase origin main` (die Nutzerin committet auch selbst).
- STL-Dateien werden nicht eingecheckt (`.gitignore`). Die SCAD-Datei ist die Quelle.
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
- **18.10.2026 – Version 2:**
  - Eimer nachgemessen: `eimer_l = 283`, `eimer_gerade_l = 245` (vorher 278 / 240).
  - **Trichter-Mittelteil** (`mittelteil = 5`): je Längsseite ein Zwischenstück zwischen den Hälften. Die Hälften bleiben 137,75 mm lang, der Trichter wird 280,5 mm lang.
  - `mittelteil_v1.scad`: Mittelteil passend zu den schon gedruckten Hälften der Version 1 (Löcher an den alten Positionen).
  - **Keilwand** (`innenform = "keil"`): Außenform unverändert, innen steilere Schräge (64°/75°, Ecken 60°) und breitere Kragen-Oberseite (10/6 mm) als Bettauflage.
  - Optionale abbrechbare **Druckhilfe** für die Trichterhälften (`druckhilfe`).
  - **Scharnier:** Stift mit zwei Abflachungen (`stift_flach = 4.2`), Haken mit Kanal. Der Haken geht nur bei waagerecht nach außen liegendem Band (±7°) auf den Stift und ab. `stift_flach = 0` = alter Schnapphaken.

### Kennwerte mit Standardwerten (Konsolenausgabe)

- Druckraum nutzbar 250 × 250 (`bett_rand = 5`).
- Plattform 206 × 166, Höhe 56, 1 Stück, 9 Langlöcher.
- Bügel Langseite und Band Schmalseite: je 239,75 mm, 1 Stück, je 2× drucken. Griff-Oberkante 280 mm über Boden.
- Trichter 280,5 × 207,5 × 59: 2 Hälften à 137,75 + 2 Mittelteile à 5. Öffnung 217 × 172. Außenschräge 54°/69°, Ecken 52°.
- Sack in der Öffnung: 6 mm Abstand je Seite (davon 2,3 mm Band). Öffnungs-Unterkante 220 mm über Boden.
- Trichterfugen: je Fuge 4 Schrauben M3 × 20 (Edelstahl) + Muttern, optional 2K-Epoxid.

### Wichtige Parameter

- `absatz_z = 275`: Absatz über dem **Innenboden**. **Nur angenommen** (altes Skript: 290 Innentiefe − 15). Bandlänge und Griffhöhe hängen davon ab.
- Plattform: `platte_l/b = 206/166`, `platte_fase = 16`, `platte_t = 6` (massiv, keine Rippen – Wunsch: wenig Ablagerung, leicht zu reinigen), `bodenabstand = 50`, Langlöcher 44 × 22.
- Scharniere: `scharniere_lang = 2` (Bügel, Haken bei x = ±55), `scharniere_kurz = 1` (Band).
- Trichter: `trichter_tiefe = 40`, `oeffnung_spiel = 3`, `kragen_unten_h = 15`, `wand = 2.5`, `kragen_t = 4`, `flansch_spiel = 1.25`, `trichter_spiel = 1.0`.

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

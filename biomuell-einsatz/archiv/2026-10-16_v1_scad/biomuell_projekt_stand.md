# Biomüll-Eimer-Projekt – Übergabe an einen Agenten

Stand: 16.10.2026, 01:55. Sprache mit der Nutzerin: Deutsch.

## Ziel

Für einen Biomüll-Eimer werden 3D-Druck-Teile aus PETG entworfen:

- Ein **Korb** (Plattform mit Tragebändern bzw. Bügeln), mit dem ein Papier-Biomüllsack herausgehoben wird.
- Ein **Trichter**, der rundum auf dem Absatz am oberen Eimerrand aufliegt.

Alles wird als **eine parametrische OpenSCAD-Datei** gepflegt (`biomuell_system.scad`). Teile, die größer als der Druckraum sind, teilt die Datei automatisch und versieht sie mit Klebe- bzw. Schraubverbindungen.

## Randbedingungen (von der Nutzerin)

- **Drucker:** Druckraum 260 × 260 × 260 mm. Material PETG. Alle Teile müssen in die Spülmaschine dürfen.
- **Keine Teile über der Eimerkante:** Der Eimer fährt mit seiner Oberkante unter eine Ablage. Es darf also nichts über den Eimerrand hinausragen (keine Auflagen o. Ä.).
- **Zu große Teile:** dürfen geteilt und geklebt werden, wenn die Verbindung entsprechend konstruiert ist.
- **Eimer**
  - 32 cm hoch, Ecken innen 45° abgeschrägt (Foto vorhanden: hellgrauer Kunststoffeinsatz).
  - Auf 30,5 cm Höhe springt die Wand je Seite um 3 mm zurück. Oberhalb dieses Absatzes ist er innen 210 × 278 mm.
  - Die geraden Wandstücke zwischen den Eckschrägen sind oben 170 bzw. 240 mm lang.
  - Messungenauigkeit einplanen.
- **Papiersack:** 360 hoch × 200 breit × 160 tief. Er sackt zusammen, deshalb passt er trotz der Höhe in den Eimer.

## Gültiges Konzept (nach mehreren Korrekturen der Nutzerin)

> **Der Trichter führt den Müll NICHT in den Sack. Er hält den Sack in Position.**

1. **Der Sack ragt durch die Trichteröffnung nach oben.** Die Öffnung umschließt den Sack samt Tragebändern. Die Bänder laufen zwischen Sack und Trichter-Innenrand und schaffen ohnehin den Abstand dazwischen.
2. **Die Griffe der Bänder** sind zwischen Sack und Trichter-Innenrand greifbar und liegen unter der Eimerkante. Voreinstellung: Griff-Oberkante 5 mm über dem Absatz, also 10 mm unter der Kante.
3. **Der Trichter bleibt dauerhaft im Eimer.** Der ganze Korb (Plattform + Bänder + Sack) wird **durch die Trichteröffnung** herausgehoben.
4. **Trichter:** Ein Kragen liegt auf dem 3-mm-Absatz. Darunter folgt eine Schräge 40 mm tief bis zur Öffnung. An der Öffnung hängt ein 15 mm hoher senkrechter Haltekragen nach unten.

### Verworfene Varianten – nicht wieder vorschlagen

- **Trichter mit Tülle, die in den Sack ragt,** und Bänder an der Eimerwand, Trichter wird vor dem Leeren herausgenommen. Die Nutzerin will, dass der Trichter bleibt.
- **Separater „Sackring“-Einsatz,** der im Trichter aufliegt und mit einer Tülle in den Sack ragt. Abgelehnt, die Nutzerin hat das Konzept oben klargestellt.

## Dateien

Alle Dateien liegen in `/home/claude/work/`. Die Container-Session ist flüchtig; die Nutzerin hat die Dateien als Anhänge.

| Datei | Inhalt |
|---|---|
| `biomuell_system.scad` | **Hauptdatei**, parametrisch, Customizer-Gruppen auf Deutsch |
| `biomuell_system.zip` | SCAD + STLs mit Standardwerten + `vorschau.png` |
| `stl/plattform.stl` | 206 × 166 × 56, massiv mit 9 Langlöchern, 1× drucken |
| `stl/buegel_langseite_2x.stl` | Bügel mit 2 Haken, Länge 239,75, 2× drucken |
| `stl/band_schmalseite_2x.stl` | Einzelband, Länge 239,75, 2× drucken |
| `stl/trichter_haelfte_2x.stl` | Trichterhälfte, 137,75 × 207,5 × 59, 2× drucken; beide Hälften sind identisch (um 180° gedreht) |
| `stl/lehre_haelfte_2x.stl` | Passlehre für den Trichterkragen, 2× drucken, vorab zum Prüfen |
| `biomuell_system.3mf` | alle 9 Druckteile (5 Objekte, mehrfach benötigte als Kopien), bereits druckfertig orientiert; nebeneinander abgelegt, im Slicer auf Druckplatten verteilen |
| `biomuell_plattform.py` | **Altbestand:** Python-Generator der Nutzerin für Plattform und Bänder (Länge 244, Plattform 250 × 195). Die SCAD-Geometrie wurde daraus übernommen und dagegen geprüft. |

## Druckeinstellungen (in der 3MF je Objekt hinterlegt)

PETG, 0,4-mm-Düse. Die Einstellungen stehen in `Metadata/Slic3r_PE_model.config` (PrusaSlicer) und `Metadata/model_settings.config` (Bambu Studio/OrcaSlicer). In keinem Slicer getestet.

| Teil | Wände | Füllung | Muster | Oben/Unten | Stützen |
|---|---|---|---|---|---|
| Plattform | 4 | 25 % | Gyroid | 5/5 | aus (Stifte überbrücken den Schlitz, ca. 26 mm); Füllung liegt geschlossen in der massiven Platte |
| Bügel / Band | 3 | 100 % | geradlinig | 5/5 | aus |
| Trichterhälfte | 4 | 100 % | geradlinig | 5/5 | aus (Innenschräge ≤ 38° Überhang, Löcher in Tropfenform) |
| Passlehre | 2 | 15 % | Gitter | 3/3 | aus |

Alle Teile sind so konstruiert, dass sie ohne Stützen druckbar sind. Bei großen PETG-Flächen ggf. eine Brim (Randrahmen) verwenden.

## Aufbau der SCAD-Datei

### Auswahl im Customizer

- `teil`: `uebersicht | plattform | langseite | schmalseite | trichter | lehre`
- `stueck`:
  - `-1` = alle Stücke nebeneinander
  - `0..n-1` = ein druckfertig orientiertes Stück

### Koordinaten

- **Übersicht:** X = Eimer-Längsachse (278), Y = Querachse (210). Z = 0 auf dem Innenboden, also der Standfläche der Plattformfüße.
- **Trichter:** wird lokal mit z = 0 auf der Absatzebene modelliert.

### Wichtige Parameter (Standardwerte)

- **Druckraum:** `bett_x/y/z = 260`, `bett_rand = 5` → nutzbar 250 × 250.
- **Eimer:** `eimer_l = 278`, `eimer_b = 210`, `eimer_gerade_l = 240`, `eimer_gerade_b = 170`, `absatz = 3`, `absatz_bis_rand = 15`.
- **Absatzhöhe:** `absatz_z = 275` = Höhe des Absatzes über dem **Innenboden**.
  - **Nur angenommen, nicht bestätigt!** Begründung: Das alte Skript nahm 290 mm Innentiefe an; 290 − 15 = 275.
  - Die 32 cm sind wahrscheinlich außen gemessen.
  - Die Nutzerin soll nachmessen. Davon hängen Bandlänge und Griffhöhe ab.
- **Sack:** `sack_b = 200`, `sack_t = 160`, `sack_h = 360`. Die Sackbreite liegt in X.
- **Plattform** (Wunsch der Nutzerin: wenig Ablagerung, Schimmel leicht zu entfernen)
  - `platte_l = 206`, `platte_b = 166`, `platte_fase = 16`
  - `platte_t = 6`: massiv, oben und unten bis auf die Löcher eben und geschlossen. Keine Rippen, kein Gitter mehr.
  - `platte_kante = 1`: Fase an Plattenrand und Lochkanten
  - `bodenabstand = 50` (Fußhöhe)
  - Löcher: `loch_form = "oval" | "rund"`, `loch_l = 44`, `loch_b = 22`, `loch_steg = 9`, `loch_rand = 9`. Versetztes Raster; Löcher, die Füße, Scharnierblöcke oder Rand berühren, entfallen automatisch. Standard: 9 Langlöcher, ca. 23 % offene Fläche.
  - Füße: 4 runde Eckfüße (`fuss = 22` mit kegeligem Übergang auf `fuss_fuss = 32`), möglichst weit außen; optional `mittelfuss = true`
  - Abweichungen von der ebenen Unterseite nur, wo konstruktiv nötig: Füße und Scharnierblöcke mit Schlitz und Stift
- **Scharniere**
  - `scharniere_lang = 2` (Bügel mit Haken bei x = ±55), `scharniere_kurz = 1` (Einzelband)
  - Werte 0, 1 oder 2 möglich; Abstände `scharnier_abstand_lang = 110`, `scharnier_abstand_kurz = 80`
  - Schnapphaken um einen 6-mm-Stift (aus dem Python-Skript übernommen; Tropfenform, Öffnungswinkel aus `schnapp` berechnet)
- **Bänder**
  - `laenge_lang`, `laenge_kurz`: 0 = automatisch, sonst feste Länge
  - Automatische Länge = `absatz_z + griff_ueber_absatz − HAKEN_UNTEN_Z`
  - Griffschlaufe: Fenster 108 × 32
  - `griff_t = 8` (vorher 12; die Wölbung zeigt zum Sack und drückt etwa 5 mm ins Papier)
- **Trichter**
  - `trichter_tiefe = 40`, `oeffnung_spiel = 3` → Öffnung = Plattform + 2 × 3 = 212 × 172
  - `kragen_unten_h = 15`, `wand = 2.5`, `kragen_t = 4`
  - `flansch_spiel = 1.25` (Kragen zur Eimerwand oben), `trichter_spiel = 1.0` (Körper zur Wand unter dem Absatz)
- **Verbindungen**
  - Schwalbenschwanz: `schwalbe_*`, `fuge_spiel = 0.15`
  - Bandstoß: `stoss_l`, `stoss_t`
  - Trichterlaschen: `rippe_h = 8`, `rippe_t = 5`, `schraube_d = 3.4`

### Automatische Teilung

Getestet mit einem 200-mm-Bett.

- **Plattform:** Puzzle-Schwalbenschwänze über die volle Höhe; die Zapfen werden nicht auf die Schnittlinien der anderen Richtung gesetzt (`frei()`).
- **Bänder:** verdickter Stoß, 4 mm stark und 30 mm lang, mit Schwalbenschwanz je Bein. Die Schnitte liegen nur im Bandbereich.
- **Trichter:** gerade Fugen. Je Fuge sitzt an der Außenseite der Schräge eine Lasche mit 2 × 2 M3-Löchern in Tropfenform, begrenzt auf die Eimerkontur. Der Haltekragen und der obere Kragen sind nur stumpf gestoßen und werden geklebt.
- **Echos:** Stückzahlen, Maße und Warnungen, u. a.:
  - Griff an der Eimerkante
  - Bänder stehen im Sack
  - Trichterschräge flacher als 45°
  - Band lässt sich nicht teilen

### Druckorientierung

- Plattform: Oberseite aufs Bett, Füße nach oben. Die Lochfasen am Bett überhängen 45°.
- Trichter: Kragenoberseite aufs Bett; die Schräge steigt zur Öffnung hin an.
- Bänder: flach.

## Prüfergebnisse (Standardwerte)

- **Netze:** Alle STLs sind geschlossen; keine fehlerhaften Kanten oder Ecken, je ein zusammenhängender Körper.
- **Abgleich mit dem Altbestand:** Plattform und Bänder stimmen mit den Original-STLs bzw. dem Python-Skript überein. Volumen ±1–3 %, gleiche Bounding-Box, das Hakenprofil ist im Schnitt deckungsgleich.
- **Montiert gemessen**
  - Band zum Trichter: mindestens 3,3 mm Abstand.
  - Die Bänder liegen innerhalb der Plattformkontur, der Korb passt also durch die Öffnung.
  - Griff-Oberkante bei 280 mm, 10 mm unter der Kante (Plattenoberseite jetzt 56 mm über Boden).
- **Trichterschrägen:** Seiten 54° bzw. 69°, Ecken 52°.
- **Nebensache:** CGAL meldet bei geteilten Plattformstücken manchmal „may not be a valid 2-manifold“. Die eigene Prüfung findet keine Fehler.

## Werkzeuge (in der alten Session; in einer neuen Session neu aufsetzen)

- **Kein natives OpenSCAD:** apt, pip und npm sind gesperrt. Funktioniert hat OpenSCAD als WebAssembly-Build (Version 2022.03), geladen von `github.com/openscad/openscad-wasm/releases/download/2022.03.20/` (`openscad.wasm`, `openscad.wasm.js`).
- **Node-Wrapper** `run.mjs`: lädt `openscad.wasm.js` per `eval` mit `wasmBinary`, schreibt `/in.scad` ins virtuelle Dateisystem und ruft `callMain([in, '-o', out, ...-D])` auf.
  - `include <...>` funktioniert darin nicht, weil die Datei nicht im virtuellen Dateisystem liegt.
  - Für Baugruppen deshalb die Datei verketten und einen Aufruf anhängen, z. B. `cat biomuell_system.scad; echo 'baender_alle();'` mit `-D teil="keins"`.
- **Python-Prüfung** mit numpy und scipy:
  - Kantenzählung, Dichtheit, Volumen, Bounding-Box
  - Abstände zwischen Teilen über zufällige Punkte auf den Oberflächen und `cKDTree`
  - Vorschaubilder mit matplotlib (`Poly3DCollection`)
- Renderzeiten: Plattform ca. 25 s, Bügel ca. 20 s, Trichter ca. 10 s.

## Offene Punkte / mögliche nächste Schritte

1. **`absatz_z` bestätigen lassen:** Absatz über dem Innenboden messen. Danach STLs neu exportieren.
2. **Passlehre zuerst drucken.** Bei Bedarf `flansch_spiel` oder `trichter_spiel` anpassen.
3. **Offen: Was passiert mit Abfall, der auf der Trichterschräge landet?** Er rutscht zum Öffnungsrand an die Sackwand. Möglicher Hinweis: den Sackrand nach außen über den Haltekragen bzw. die Schräge umschlagen. Mit der Nutzerin klären, nicht eigenmächtig umkonstruieren.
4. **Offen: Wo liegt der Sack, wenn er über die Kante ragt?** Der Sack ist 360 mm hoch, steht ab 54 mm Höhe und ragt damit über die Kante (290 mm). Die Nutzerin sagt, er sacke zusammen. Gegebenenfalls nachfragen, ob ein Umschlag eingeplant ist.
5. **Teilung der massiven Plattform:** Bei kleinerem Druckbett kann eine Fuge durch ein Loch laufen (z. B. bei x = 0). Die Fuge funktioniert, ist dort aber schwächer. Gegebenenfalls Lochraster versetzen oder Schnittposition außerhalb der Löcher legen.
6. **Bodenzentrierung:** Unten lässt der Eimer der Plattform Spiel (ca. 272 × 204 innen gegenüber 206 × 166). Die Trichteröffnung zentriert Sack und Bänder oben; unten ist die Plattform frei.
7. **Griffwölbung:** Bei Bedarf `griff_t` verkleinern oder die Wölbung zur Wand drehen. Letzteres hätte im Flachdruck einen Überhang zur Folge.
8. **Geklebte Fugen:** Für die Spülmaschine 2K-Epoxid empfehlen; bei den Trichterlaschen bevorzugt Edelstahlschrauben M3 × 16 mit Muttern.

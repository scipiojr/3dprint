# agent.md – Biomüll-Einsatz

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit der Nutzerin: **Deutsch**.

## Arbeitsweise in diesem Repository

- Projektordner: `biomuell-einsatz/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner nicht anfassen.
- **Jede Änderung wird committet und sofort nach `origin/main` gepusht**, ohne Rückfrage. So hat es die Nutzerin festgelegt.
- Commit-Messages auf Deutsch, sprechend: Betreffzeile im Imperativ (≤ 72 Zeichen), darunter kurz *was* und *warum*.
- Vor dem Push `git pull --rebase origin main` (die Nutzerin committet auch selbst).
- STL-Dateien werden eingecheckt. Die SCAD-Datei ist die Quelle.
- **Versionierung nur über Git** (Festlegung der Nutzerin, 19.10.2026): Jeder neue Konstruktionsstand ist ein eigener Commit. Ein neuer Stand **überschreibt die gleichnamige Datei** des Vorstands; es werden keine neuen Dateien pro Version oder Stand angelegt.
  - Dateinamen ohne Versions- oder Standkennung (also `trichter_haelfte_2x.stl`, `korb.3mf`, nicht `…_v2…`, `…_v3…`, `…_neu…`, `…_stand5…`). Der Verlauf steht in der Git-Historie, Versionen werden mit Tags markiert (`biomuell-v2`, `biomuell-v3`, …).
  - Eigene Dateinamen nur für Teile, die es **gleichzeitig** gibt und die tatsächlich verschieden sind (z. B. Variante mit Mittelteil, Seitenwand anderer Höhe `seitenwand_h<Höhe>_2x.stl`), nicht für ältere Stände desselben Teils.
  - Ein älterer Stand wird bei Bedarf aus der Historie geholt (`git show <commit>:biomuell-einsatz/<datei>`), nicht als Kopie im Ordner gehalten. Der Ordner `archiv/` bleibt unverändert, bekommt aber nichts Neues.
  - Die Dateien wurden am 19.10.2026 umbenannt (`trichter.3mf`, `trichter_druckhilfe.3mf`, `trichter_mittelteil.3mf`, `trichter_haelfte_2x.stl`, `korb.3mf`); `korb_v2.3mf` wurde gelöscht. Die Verlaufseinträge unten nennen die Namen des jeweiligen Stands und bleiben unverändert. Ausnahme: `mittelteil_v1*` bleibt, weil es eine eigene Variante für die gedruckten Hälften der Version 1 ist.
- Bilder nach Geometrieänderungen neu erzeugen: `werkzeuge/bilder.sh` (siehe unten) und mitcommitten.
- README und dieses Dokument aktuell halten, wenn sich Parameter, Teile oder Entscheidungen ändern.

## Ziel

Für einen Biomülleimer werden 3D-Druck-Teile aus PETG entworfen:

- ein **Korb** (Plattform mit Bügeln an den Langseiten und, ab Version 3, abnehmbaren Seitenwänden an den Schmalseiten; Version 2: Bänder), mit dem ein Papier-Biomüllsack herausgehoben wird,
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
  - **Stand 8, 16:13 Uhr:** **Bügellänge gegen Druckraum prüfen.** Wunsch der Nutzerin: Sind die Griffe zu lang für den Druckraum, soll die SCAD warnen und anbieten, stattdessen den Trichter tiefer zu ziehen. Neu: `bei_zu_langem_buegel = "warnen"` (Standard) oder `"trichter_tiefer"`. Intern: `LEN_AUTO` (automatische Länge), `FEHLMASS` (um wie viel länger als `UX = bett - 2 * bett_rand`, auf 0,1 mm aufgerundet plus 0,05), `TIEFER`, `TT = trichter_tiefe + TIEFER` (wirksame Trichtertiefe, ersetzt `trichter_tiefe` in allen Trichterformeln), `GRIFF_Z` wird um `TIEFER` gesenkt. Bei `warnen`: WARNUNG mit Vorschlag samt konkreter Werte; bei `trichter_tiefer`: HINWEIS mit neuer Tiefe. Auch eine feste `laenge_lang/kurz` über `UX` warnt. Getestet: Standard (249,75 mm, keine Warnung, Geometrie unverändert), `bett_x/y = 250` mit `warnen` (Warnung, Bügel 2 Teile) und mit `trichter_tiefer` (Trichter 49,8 mm tief, Bügel 239,95 mm, 1 Teil). Nicht erledigt: Wirkung auf den Sack/Öffnungs-Unterkante bei großem Fehlmaß prüfen (Konsole meldet Öffnungs-Unterkante).
  - **Stand 7, 16:01 Uhr:** **Rastnase 1,5 mm weiter heraus.** Wunsch der Nutzerin. `rast_nase` 1,5 → 3,0 mm. Damit die Zunge nicht überdehnt (bei Zunge 19 mm wären es ca. 5,3 %): `zapfen_l` 20 → 28 mm (Zunge 27 mm, Dehnung ca. 2,6 %), `tasche_relief` 1,5 → 3,0 (Zunge muss 3,2 mm einfedern), `rast_rampe` 3 → 5 mm (flachere Auflaufschräge, geringere Steckkraft). Haltefläche nominal 2,8 mm. Die Eckfüße rücken auf x = ±76,8. Keine Warnungen, Netze dicht. Seitenwand 128 × 134 × 7 mm; Zapfenspitze liegt 28 mm unter der Plattenoberseite (frei, Füße bei x ≤ 92,8). Nicht am Druck geprüft: Rastprobe zuerst drucken; Steckkraft könnte hoch sein, dann `rast_nase` 2,0 bis 2,5.
  - **Stand 6, 15:49 Uhr:** **Plattform niedriger.** Wunsch der Nutzerin: Beine 1 cm kürzer, Platte 2 mm dünner. `bodenabstand` 50 → 40, `platte_t` 6 → 4; Plattenoberseite 44 statt 56 mm über Boden, Plattform 210 × 166 × 44. Folgen: (1) Die Hakenmitte bleibt 10 mm unter der Plattenoberseite (`stift_z = -10`, Wulst 12 mm), die Bügel werden um 12 mm länger (Griff-Oberkante bleibt am Absatz). Das hätte 251,75 mm ergeben und den Bügel wegen `bett_rand = 5` (nutzbar 250 mm) automatisch in zwei Teile geteilt. Daher `griff_ueber_absatz` 5 → 3 (Griff-Oberkante 278 statt 280 mm über Boden), Bügel 249,75 mm, ungeteilt. (2) Bügel und V2-Band (`band_schmalseite_2x.stl`) sind neu zu drucken, Seitenwände und Trichter bleiben. (3) Seitenwand-Oberkante liegt nun bei 144 mm über Boden. Alle Netze dicht. Nicht am Druck geprüft.
  - **Stand 5, 15:04 Uhr:** **Scharnier: Lösen nur bei 180° nach unten, Platte tritt 2 mm zurück.** Wunsch der Nutzerin: Zwischen Platte und Griff ist im Scharnier zu wenig Abstand, die Hakenrundung schabt an der Platte. Außerdem sollen Bügel nur bei auf 180° nach unten gedrehtem Griff ein- oder ausgehängt werden können. Umsetzung: `schlitz_zugabe = 2` (SLOT_V +2 mm, Wulst/Füße verschieben sich mit). Die Ecken der Standfläche des Hakens überstreichen Radius ca. 7,2 mm, der Schlitz ließ nur 6,45 mm: dort schabte es (bei 120 bis 165° Kollision). Stiftabflachungen jetzt oben und unten (Stift 4,2 mm hoch, 6 mm breit; ein gerader Kanal löst sich bei Abflachung und Kanalrichtung in einer Linie, das ist bei 0° und 180° der Fall; bei 0° blockiert die Innenwand des Schlitzes (nur 2,7 mm Weg, nötig ca. 8,8 mm), bei 180° wandert der Haken frei nach außen). Mit `werkzeuge/scharnier_pruefung.py` (2D, Erreichbarkeit im Verschieberaster) geprüft: abnehmbar nur bei 175 bis 185°, bei 0 bis 165° gehalten, keine Kollisionen. Der Haken (Bügel, Bänder) bleibt unverändert; nur Plattform und `korb.3mf` neu drucken. Nicht am Druck geprüft; Spiel von Haken/Stift (`kanal_spiel`) bei Bedarf anpassen.
  - **Stand 4, 10:19 Uhr:** **`trichter_v2_druckhilfe.3mf`:** Der Steg ist als eigenes Teil „Druckhilfe - nach dem Druck abtrennen“ im Trichter-Objekt angelegt (2 Wände, 15 % Gitter, 2 Haltestege), `druckhilfe_steg.stl` ist das Einzelteil. Als echter Support lässt er sich nicht definieren: Der Slicer erzeugt Support nur unter Überhängen, und Support haftet absichtlich locker und würde die offene U-Seite nicht versteifen. In PrusaSlicer als getrennte, dichte Teile erkannt.
  - **Stand 5, 11:31 Uhr:** **Scharnier gegen Abfallen:** Der 6-mm-Stift in der Plattform ist an zwei Seiten senkrecht auf 4,2 mm abgeflacht (`stift_flach = 4.2`), die Haken haben statt der Schnappöffnung einen geraden Kanal von 4,7 mm (`kanal_spiel = 0.25`, Einführfase `kanal_fase = 0.6`). Aufrecht im Eimer liegt der Kanal quer zur Abflachung, der Haken ist gefangen. Nur bei waagerecht nach außen liegendem Band (±7°) lässt er sich von oben aufstecken und abziehen; im 2D-Schnitt geprüft: abnehmbar nur bei ca. 83–95° aus der Senkrechten. Alle drei Teile (Plattform, Bügel, Bänder) neu drucken, alte und neue passen nicht zusammen. `stift_flach = 0` = alter Schnapphaken.
  - **Stand 6, 12:32 Uhr:** **`korb_v2.3mf`:** 5 Platten (Plattform, Bügel Langseite A/B, Band Schmalseite A/B). Zwei Bänder nebeneinander sind breiter als das Druckbett, ineinander verschachteln geht nicht, weil die Griffschlaufen an die Beine der Bügel stoßen. Einstellungen je Objekt: Plattform 4 Wände, 25 % Gyroid, 5/5, Brim 5 mm; Bügel und Bänder 3 Wände, 100 %, 5/5, kein Brim; keine Stützen. Empfehlung: zuerst ein Band mit der Plattform drucken und die Passung des Hakens prüfen.
  - **Stand 7, 16:10 Uhr:** **Laschenlöcher korrigiert.** Vorher hatte jede Lasche 2 volle und 2 angeschnittene Löcher: Die Lasche reicht nur bis zur Eimerkontur und ist oben am Kragen wenige Millimeter breit, das obere Loch wurde von der Außenkante angeschnitten. Jetzt werden die Lochpositionen aus der tatsächlichen Laschenbreite berechnet (`lasche_zs`, `loch_rand_min = 1.5`): je Lasche 2 volle Löcher mit mindestens 1,5 mm Material ringsum, ca. 9 mm übereinander im unteren, voll ausgebildeten Teil. Je Fuge 4 Schrauben M3 × 16 mit Mutter; beide Hälften sind gleich aufgebaut, die Löcher fluchten. Klarstellung: Die zwei kleinen Stege auf der Plattform der Projekt-3MF sind keine Messstege, sondern die beiden Hälften der Passlehre.
  - **Stand 8, 16:13 Uhr:** **Eimer nachgemessen:** `eimer_l = 283`, `eimer_gerade_l = 245` (vorher 278 / 240). Annahme: Die Eckschrägen bleiben gleich groß, deshalb wurde das gerade Stück der Langseite auf 245 mm verlängert. Der Trichter ist 280,5 × 207,5 mm (vorher 275,5 × 207,5), jede Hälfte 140,25 × 207,5 × 59 mm und passt weiter ins Druckbett. Die Öffnung (212 × 172) und damit der Korb bleiben unverändert. Außenschräge an der Schmalseite 52° statt 54°, Innenschräge 61° statt 64°, Überhang beim Druck höchstens 29° (Ecken 32°); der Griffraum wächst dort um 2,5 mm. Passlehre `lehre_haelfte_2x.stl` neu: zuerst drucken und in den Eimer legen.
  - **Stand 9, 16:19 Uhr:** **Trichter-Mittelteil** (`mittelteil = 5`): je Längsseite ein Zwischenstück, das zwischen die beiden Hälften geschraubt wird. Die Hälften sind wieder 137,75 mm lang, der Trichter wird 280,5 mm lang (Eimerlänge weiter wie gemessen eintragen), die Öffnung 217 × 172 mm. Neue Teil-Auswahl `teil = "mittelteil"`; die Passlehre wird ebenfalls um das Maß kürzer erzeugt. Schrauben M3 × 20 statt M3 × 16.
     - `mittelteil_v1.scad` (eigenständig): Mittelteil für die schon gedruckten Hälften der Version 1 (gleich dicke Wand, Eimer 278 mm, Schraublöcher an den alten Positionen; das obere Loch ist wie bei den alten Hälften angeschnitten, mit `obere_loecher = false` weglassen). Profil gegen die Fugenfläche einer hochgeladenen Hälfte geprüft: Flächenabweichung 0,000 mm².
     - `mittelteil_5mm_2x.stl` passt nur zu Hälften der Version 2 (`trichter_haelfte_mittelteilversion_2x.stl`); `mittelteil_v1_5mm_2x.stl` nur zu den alten Hälften der Version 1.

- **18.10.2026 – Version 3** (Plan: [`v3_plan.md`](v3_plan.md)):
  - **Stand 1, 18:30 Uhr:** Plan eingecheckt (`v3_plan.md`), keine Geometrie.
  - **Stand 2, 18:55 Uhr:** **Seitenwände statt Schmalseiten-Bänder umgesetzt.** Wunsch der Nutzerin: zwei dünne, steife Wände (nach unten offenes U, Höhe parametrierbar, Standard 10 cm), Seitenstege erst nach den Eckschrägen, eingeclipst und zum Reinigen abnehmbar, steifer als die Griffbänder; Trichteröffnung unverändert; Stege dürfen leicht nach innen versetzt werden; Griffe nur an den Längsbügeln.
     - **Parameter** (Gruppe „Seitenwände Schmalseiten“): `schmalseite_typ = "wand"` (oder `"band"` = Version 2), `wand_h = 100` (ab Plattenoberseite), `wand_t = 4`, `wand_steg_b = 20`, `wand_quer_h = 20`, `wand_eck_abstand = 0`, `wand_sack_spiel = 0.5`; Zapfen/Tasche: `zapfen_l = 20`, `zapfen_b = 14`, `zapfen_spiel = 0.2`, `tasche_tiefe = 14`, `tasche_wand = 2`, `tasche_relief = 1.2`; Rast: `rast_nase = 1`, `rast_zunge_b = 8`, `rast_schlitz = 1`, `rast_wurzel = 3`, `rast_rampe = 3`, `rast_flach = 1.2`, `rast_spiel_z = 0.3`. Neu: `platte_l_wand = 210`, `oeffnung_l = 217`, `oeffnung_b = 172`, `oeffnung_fase = 16` (ersetzen `oeffnung_spiel`). Neue Teile: `teil = "seitenwand"`, `"rastprobe"`.
     - **Mechanismus (Abweichungen vom Plan):** Der Zapfen ist 14 mm breit (Steg 20 mm); die Stegkanten daneben bilden die Schulter auf der Platte. Zapfen 20 mm lang, Tasche 14 mm tief (Führung). Der Taschenblock steht als Ohr über die Plattenkante (bis x = ±106,7, 1,8 mm vor der Öffnung), weil die Wand (x = 100,5 … 104,5) fast bündig mit der Plattenkante (105) liegt. Hinter der Rastzunge liegt ein Relief (1,2 mm) in der Tasche, in das die Zunge beim Einstecken einfedert, sonst wäre kein Durchstecken der 1 mm hohen Nase möglich. Die Nase rastet 0,3 mm unter der Blockunterseite ein.
     - **Plattform:** 210 × 166 im Wandmodus, Eckfüße bei x = ±78,6 statt ±82 (Block-Kollision), Lochraster weicht den Taschen über `KEEP` aus (weiter 9 Löcher).
     - **Trichteröffnung fest** (217 × 172): `LIP` und `OEFF` aus `oeffnung_*`, nicht mehr aus der Plattform. Nachgerechnet: Trichterhälfte, Mittelteil und Bügel haben gegenüber Stand 9 Eckpunktabweichung 0,0000 mm (also nichts neu drucken außer Plattform).
     - **Prüfungen** (Standardwerte): alle Netze dicht (offene Kanten 0); Wand ↔ Plattform durchdringen sich nicht (Schnittmenge leer), kleinster Abstand ca. 0,2 mm (Zapfenspiel); waagerechter Abstand zur Trichteröffnung: Taschenblock 1,8 mm, Wand samt Nase 3,0 mm, Bügel 3,3 mm; Wand innen 0,5 mm vom Sack. Rastzunge: Dehnung ca. 2,5 %, Haltefläche 0,8 mm. Wand-Durchbiegung oben bei 5 N ca. 3,7 mm (Biegung), mit Spiel im Zapfen höchstens 6,6 mm.
     - **Nicht geprüft:** Einstecken und Rasten am Probedruck, Passung im Eimer, Slicer-Import der `korb.3mf` (Netze dicht, XML gültig).

  - **Stand 4, 14:10 Uhr:** **Rastnase größer.** Kritik der Nutzerin: Die Seitenwände clipsen nicht ein, die Nasen sind zu kurz, die Wand gleitet mühelos zurück. `rast_nase` 1,0 → 1,5 mm, `tasche_relief` 1,2 → 1,5 mm (Einfederweg), `rast_wurzel` 3 → 1 mm (Zunge 19 mm lang, Dehnung beim Einrasten ca. 2,8 %, unter der 3-%-Warnschwelle). Haltefläche nominal 1,3 mm (bei 0,4 mm Spiel im Zapfen mindestens ca. 0,9 mm). Neu: `plattform.stl`, `seitenwand_h100_2x.stl`, `rastprobe.stl`, `korb_v3.3mf`. Nicht am Druck geprüft: erst Rastprobe drucken; reicht es nicht, `rast_nase` bis 1,8 erhöhen (dann `rast_wurzel` 0,5 oder `zapfen_l` größer) oder eine Hinterschneidung der Rastkante vorsehen.
  - **Stand 3, 19:54 Uhr:** **Mittelteil optional, `mittelteil = 0` als Standard.** Wunsch der Nutzerin: Die Mittelteile (Notlösung für die schon gedruckten Hälften) sollen nicht mehr Standard sein, der Trichter entsprechend größer (länger) werden. Umsetzung: Hälften 140,25 × 207,5 × 59 mm (je 2,5 mm länger als mit Mittelteil), Trichter weiter 280,5 mm (= Eimerlänge 283 − 2 × 1,25 mm Spiel), Öffnung weiter fest 217 × 172 (`oeffnung_l/b`), Schrauben M3 × 16. Neu erzeugt: `trichter_v2_haelfte_2x.stl`, `lehre_haelfte_2x.stl`, `druckhilfe_steg.stl`, `trichter_v2.3mf`, `trichter_v2_druckhilfe.3mf` (Netze dicht, Boxen wie in den Vorlagen; Druckeinstellungen aus den Vorlagen übernommen, `werkzeuge/trichter_3mf.py`). Die bisherige Passlehre (137,75 mm) heißt jetzt `lehre_haelfte_mittelteilversion_2x.stl`. Die Mittelteil-Dateien (`mittelteil_5mm_2x.stl`, `trichter_haelfte_mittelteilversion_2x.stl`, `trichter_v2_mittelteil.3mf`, `mittelteil_v1*`) bleiben gültig für Nutzer des Mittelteils. Bilder ohne Mittelteil neu erzeugt.

### Kennwerte mit Standardwerten (Konsolenausgabe)

- Druckraum nutzbar 250 × 250 (`bett_rand = 5`).
- Plattform 210 × 166 (mit Ohren 213,4), Höhe 56, 1 Stück, 9 Langlöcher, Eckfüße bei x = ±78,6, y = ±43,5.
- Bügel Langseite: 249,75 mm, 1 Stück, 2× drucken. Griff-Oberkante 278 mm über Boden. Seitenwand Schmalseite: 128 × 134 × 7 mm (`wand_h = 100`), 1 Stück, 2× drucken, Oberkante 144 mm über Boden.
- Trichter 280,5 × 207,5 × 59: 2 Hälften à 140,25 (Standard, `mittelteil = 0`; mit `mittelteil = 5`: 2 × 137,75 + 2 Mittelteile à 5). Öffnung 217 × 172. Außenschräge 54°/69°, Ecken 52°. Trichterfugen: je Fuge 4 Schrauben M3 × 16 (mit Mittelteil M3 × 20).
- Sack in der Öffnung: 8,5 mm (Längsrichtung, mit Mittelteil) / 6 mm (Querrichtung) Abstand je Seite. Öffnungs-Unterkante 220 mm über Boden.
- Trichterfugen: je Fuge 4 Schrauben M3 × 20 (Edelstahl) + Muttern, optional 2K-Epoxid.

### Wichtige Parameter

- `absatz_z = 275`: Absatz über dem **Innenboden**. **Nur angenommen** (altes Skript: 290 Innentiefe − 15). Bandlänge und Griffhöhe hängen davon ab.
- Plattform: `platte_l/b = 206/166` (206 nur bei `schmalseite_typ = "band"`, sonst `platte_l_wand = 210`), `platte_fase = 16`, `platte_t = 4` (massiv, keine Rippen – Wunsch: wenig Ablagerung, leicht zu reinigen), `bodenabstand = 40`, Langlöcher 44 × 22.
- Scharniere: `scharniere_lang = 2` (Bügel, Haken bei x = ±55), `scharniere_kurz = 1` (Band, nur bei `schmalseite_typ = "band"`).
- Seitenwand (Version 3): `schmalseite_typ = "wand"`, `wand_h = 100`, `wand_t = 4`, Zapfen/Tasche/Rast siehe Verlauf Stand V3-2.
- Trichter: `trichter_tiefe = 40`, `oeffnung_l/b = 217/172` (fest), `oeffnung_fase = 16`, `kragen_unten_h = 15`, `wand = 2.5`, `kragen_t = 4`, `flansch_spiel = 1.25`, `trichter_spiel = 1.0`.

- Eimer (gemessen): `eimer_l = 283`, `eimer_gerade_l = 245`, `eimer_b = 210`, `eimer_gerade_b = 170`.
- Keilwand: `innenform = "keil"`, `ring_x = 10`, `ring_y = 6`; Druckhilfe `druckhilfe = false`.
- Scharnier: `stift_flach = 4.2`, `kanal_spiel = 0.25`, `kanal_fase = 0.6`.
- Laschenlöcher: `loch_rand_min = 1.5`, 2 Löcher je Lasche, Lage aus der Laschenbreite.
- Mittelteil: `mittelteil = 0` (Standard, seit V3-3; 5 = Mittelteil wie in Stand 9), `teil = "mittelteil"` nur bei `mittelteil > 0`.

### Koordinaten

- Übersicht: X = Eimer-Längsachse, Y = Querachse, Z = 0 auf dem Innenboden.
- Trichter: lokal mit z = 0 auf der Absatzebene.
- Bänder: Druckkoordinaten X = Länge, Y = Breite, Z = Dicke; Z = 0 ist die Außenseite zur Eimerwand.
- Seitenwand: Druckkoordinaten X = Länge ab Zapfenspitze, Y = quer, Z = Dicke; Z = 0 ist die Innenseite (zum Sack, auf dem Bett), die Rastnase zeigt nach oben. Taschen: lokales Kantensystem von `am_rand` (y = 0 Plattenkante, innen negativ).

## Offene Punkte

1. **`absatz_z` nachmessen lassen** (Absatz über dem Innenboden), danach STLs neu exportieren.
2. Passlehre zuerst drucken; bei Bedarf `flansch_spiel` / `trichter_spiel` anpassen.
3. **Abfall auf der Trichterschräge:** rutscht zum Öffnungsrand an die Sackwand. Möglicher Hinweis: Sackrand über Haltekragen bzw. Schräge umschlagen. Mit der Nutzerin klären, nicht eigenmächtig umkonstruieren.
4. **Sack über der Kante:** 360 mm Sack ab 56 mm Höhe ragt rechnerisch über die Kante (290 mm). Die Nutzerin sagt, er sacke zusammen. Ggf. nach einem Umschlag fragen.
5. Bei kleinerem Druckbett kann eine Plattformfuge durch ein Loch laufen (funktioniert, ist dort schwächer).
6. Unten hat die Plattform Spiel zum Eimer; zentriert wird oben durch die Trichteröffnung.
7. Griffwölbung (`griff_t = 8`) zeigt zum Sack und drückt etwa 5 mm ins Papier; ggf. verkleinern.
8. Geklebte Fugen: 2K-Epoxid; Trichter bevorzugt mit Edelstahlschrauben.
9. Druckeinstellungen in den 3MFs sind nicht für Version 2 aktualisiert. `korb.3mf` ist neu erzeugt (Seitenwand 4 Wände, 100 %), in keinem Slicer geöffnet.
10. **Version 3:** Rastprobe drucken und Spiel (`zapfen_spiel`), Rastkraft (`rast_nase`) und Wackeln der Wand prüfen. Das Spiel im Zapfen erlaubt oben bis ca. 3 mm Kippen; bei Bedarf `zapfen_spiel` verkleinern (0,15) oder die Tasche tiefer machen.
11. **Version 3:** Wand liegt nur 0,5 mm vom nominellen Sack (200 mm). Ein praller Sack kann an der Wand schleifen; `wand_sack_spiel` ggf. erhöhen (Rest zur Öffnung 4 mm, Block 1,8 mm).
12. **Version 3:** Bügel tragen jetzt allein (4 Haken). Mit gefülltem Sack erproben.
13. Alte Schmalseiten-Bänder passen nur zur Plattform der Version 2 (206 mm); `schmalseite_typ = "band"` erzeugt sie wieder.

## Werkzeuge

- **OpenSCAD:** Wenn kein natives OpenSCAD installierbar ist, funktioniert der WebAssembly-Build 2022.03 (`github.com/openscad/openscad-wasm/releases/download/2022.03.20/openscad.wasm` und `openscad.wasm.js`).
  - `werkzeuge/openscad_wasm.mjs <ein.scad> <aus.stl|.svg> [-D name=wert …]` führt ihn unter Node aus (`OPENSCAD_WASM_DIR` zeigt auf den Ordner mit den beiden Dateien).
  - `include <…>` geht dort nicht. Für Baugruppen die Datei verketten und einen Aufruf anhängen, mit `-D teil="keins"` (siehe `bilder.sh`).
  - Renderzeiten: Trichter ca. 3 s, Plattform und Bügel 20–30 s.
- **STL-Prüfung:** `werkzeuge/stl_pruefung.py` (`info`: Dichtheit, Volumen, Box; `vergleich`: Eckpunktabweichung zweier STLs, z. B. neu gerendert gegen vorherigen Stand; `abstand`: kleinster Abstand zweier Teile). Mit `python3 -I` aufrufen.
- **3MF:** `werkzeuge/korb_3mf.py <plattform.stl> <buegel.stl> <seitenwand.stl> <aus.3mf>` baut `korb.3mf` (5 Platten, Einstellungen je Objekt).
- **Bilder:** `werkzeuge/bilder.sh` rendert Baugruppen und Einzelteile, exportiert zwei Schnitte als SVG (`projection(cut=true)`) und zeichnet daraus mit `werkzeuge/bilder.py` (numpy, matplotlib) die PNGs in `bilder/`.
- **Prüfungen** (bisher ad hoc in Python mit numpy/scipy): Dichtheit und Kantenzählung der STLs, Volumen, Bounding-Box, Abstände zwischen Teilen über Oberflächenpunkte und `cKDTree`.

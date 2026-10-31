# agent.md – Abluft (magnetischer Schlauchanschluss, Dachfenster)

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit der Nutzerin: **Deutsch**. Anwenderdoku: `README.md`.

## Arbeitsweise in diesem Repository

- Projektordner: `abluft/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner (`biomuell-einsatz`, `pooldach-bestway-56448`, `tuerknauf`) nicht anfassen.
- Die Nutzerin arbeitet in den anderen Projekten so: **jede Änderung committen und sofort nach `origin/main` pushen**, ohne Rückfrage. Hier genauso verfahren, solange sie nichts anderes sagt. Vor dem Push `git pull --rebase origin main`.
- Commit-Messages auf Deutsch, Betreffzeile im Imperativ (≤ 72 Zeichen), darunter kurz *was* und *warum*; Attributionszeilen wie in den vorhandenen Commits.
- **Die SCAD-Datei ist die Quelle.** STL werden eingecheckt. Nach jeder Geometrieänderung: `werkzeuge/export_alle.sh`, `python3 -I werkzeuge/pruefung.py ...` (mit den Referenzteilen, falls vorhanden) und `python3 -I werkzeuge/bilder.py`, dann alles mitcommitten.
- **Versionierung nur über Git**, wie im Projekt `biomuell-einsatz`: ein neuer Stand überschreibt die gleichnamige Datei, keine `_v2`-Kopien. Eigene Dateinamen nur für Teile, die gleichzeitig existieren (zum Beispiel `verjuengung_150_100_stutzen.stl` als Variante). Meilensteine als Tags (`abluft-v1`, …).
- README und dieses Dokument aktuell halten, wenn sich Parameter, Teile oder Entscheidungen ändern.
- Werkzeuge: OpenSCAD 2021.01 (CGAL, langsam: Gewindeteile 1–2 Minuten, alles ca. 6 Minuten auf 2 Kernen); Python mit `trimesh`, `numpy`, `manifold3d`, `matplotlib` (`pip install --break-system-packages …`). **STEP gibt es nicht**, OpenSCAD exportiert kein STEP; MakerWorld nimmt STL.

## Ziel

Ein 110-mm-Abluftschlauch (Laser-Cutter, heiße Rauchluft) soll über magnetische Kupplungen an ein **Plexiglas im Dachfenster** angeschlossen werden. Dieses Plexiglas ist 5 mm dick und hat einen runden Ausschnitt ø155 mm (für 150-mm-Schläuche) in einer Ecke, 45 mm von zwei Kanten entfernt. Wegen des Rahmens bleiben nur etwa 20 mm Rand ab der Ausschnittkante. Auch 150-mm-Schläuche sollen so angeschlossen werden. Die Teile:

1. **Durchführung** (Innenscheibe + Halteplatte): beide Außenflächen magnetisch, mit Dichtungsnuten; Verbindung der beiden Scheiben über das Rohr mit Gewinde (zugleich Luftkanal).
2. **Verjüngung 150 → 110** auf kurzer Strecke, dann Anschluss an den 110er-Magnetanschluss.
3. **Ventilator-Adapter** (28.10.2026): Muffe für einen 140-mm-Ventilatoranschluss (Innendurchmesser 146,4 mm, höchstens 36 mm tief) → Trichter → 110er-Magnetflansch. Fixierung der Muffe am Ventilator ist **noch ungelöst**: Standard 4 Schraublöcher (parametrisch), alternativ Duct Tape.
4. Später: weitere Teile aus dem MakerWorld-System (Umlenker, Größenadapter), die auf dieselben Magnetflächen passen müssen.

## Randbedingungen (von der Nutzerin)

- **Drucker:** Druckraum 260 × 260 × 260 mm, **PETG**; Dichtungen aus **TPU** (O-Ring-Vorlagen mit 4 mm Schnur). Heiße Rauchluft im Kanal.
- **Magnete:** 40 Stück 15 × 3 mm, plan eingelassen, mit Sekundenkleber, **alternierende Polung** (so sieht es das System vor). Taschen mit sehr feinen Klemmnasen sind gewünscht.
- **Referenz ist die parametrische 110er-Datei** (`Magnetic_Hose_Adapter_Parametric`): Die Nutzerin baut die weiteren Teile des Systems mit ihrer MakerWorld-Quelle. Alle neuen Flächen müssen deckungsgleich passen (Taschenmuster, Nuten, Umriss). Auch der 150er-Referenzadapter ist maßgeblich.
- **Dachfenster, Schlauch hängt innen:** Die Magnete halten nur die Kupplung an der Innenscheibe. Das **Gewinde trägt die Innenscheibe samt Last** (Zugbelastung) an der Halteplatte. Die Seitenlast soll über einen Zentrierbund ins Plexiglas gehen.
- Der Stutzen-Entwurf (fester Schlauchstutzen) war zuerst gewünscht (Schlauchschellen, ausreichende Wand, Wulste wie in der Referenz); später legte die Nutzerin fest, dass das 110er-Ende einen **Magnetflansch** hat, auf den ihr Anschluss passt. Der Stutzen blieb als Variante.
- Rohrstumpf-Variante (`end110="pipe"`): glatter Stumpf ø109 außen / ø100 innen, 36 mm, ohne Magnete, zum Überstülpen der Muffe eines 110er-KG-Rohrs; optional gewinkelt (`pipe_angle`, `pipe_bend_r`, `pipe_dir`). Der Stumpf ist ein einziges Polyeder (Ringe senkrecht zum Pfad), ohne Boolesche Operationen; die Verbindung zum Trichter liegt koplanar bei z = Trichterende. `pipe_straight` ("bend distance", Standard 0) fügt vor dem Bogen eine gerade Strecke ein; die 36 mm `pipe_len` folgen weiterhin nach dem Bogen. Der Winkel-Export (45°) liegt als eigene Datei bei; Stützen sind nötig. Nicht gedruckt getestet; ø109 ist nominal, Toleranz der Muffe ungeprüft.
- Kein Durchschrauben durch das Plexiglas, wenn es sich vermeiden lässt (nicht absolut ausgeschlossen: wäre die Rückfalllösung).
- Plattendicke „leicht dicker“ ist erlaubt; Gewindelänge soll parametrisch mitwachsen.

## Wichtige Entscheidungen

- **150er-Magnetfläche exakt wie `Magnetic_Hose_Adapter_150`:** 8 Magnete im 45°-Raster auf Teilkreisradius 91,0 mm, Tasche ø15,3 × 3,2 mm, Nut Radius 73,4–77,6 mm (Mitte 75,5 mm = Bohrungsradius + 5,5), 1,9 mm tief, Bohrung ø140. Umriss als Polygon `ref150_pts` aus dem STL (Lappenradius 101,5 mm, Taille 83,4 mm). 110er-Fläche wie die Parametric-Referenz: 6 Magnete auf R = 70,9 mm, Nut Mitte 55,5 mm, 4,2 breit, 1,3 tief, Bohrung ø100.
- **Beide Scheiben sind Plattenflächen mit Nut** (auf Wunsch der Nutzerin, nachdem sie zunächst flach waren); darum hat die Halteplatte einen **geschlossenen Steg (3,5 mm)** an der Magnetfläche und das Gewinde sitzt darunter im Hohlraum. Das Rohr endet 0,3 mm unter dem Steg (`tube_gap`).
- **Lappen der Scheiben um 22,5° gedreht** (`lobe_offset150`), damit die Ausdehnung 95,7 mm bleibt (frei 97,5 mm). Die Verjüngung ist wie die Referenz unverdreht (`lobe_offset_funnel = 0`).
- **Plexiglasnut** (Radius 80,2 mm, 2,8 mm tief, 0,6 mm neben der Ausschnittkante) lässt in der Taille nur ca. 1,1 mm Rand zum Außenumriss. Das ist bewusst knapp, damit der Umriss exakt der Referenz entspricht.
- **Gewinde:** zuerst Steigung 6 mm, dann auf Wunsch fein und kurz (4 mm, Tiefe 1,5). Rechtsgewinde über `linear_extrude` mit `twist` (negativ); die Innengewindehülse hat Radialspiel 0,35 und Flankenspiel 0,03 Steigung. Rohr und Bund stoßen **plan** an die Scheibe, damit keine fast koinzidenten Wandflächen entstehen (sie führten zu nicht-manifolden Kanten im Export).
- **Zentrierbund** im Bereich der Plexiglasdicke (ø153,4 mm), damit Seitenlast nicht über Gewindespitzen und Dichtungen läuft.
- **Sicherung:** radiale M4-Bohrungen (ø3,3) in der Halteplatte zwischen den Lappen, Nutzerin entscheidet über Einsatz. Bajonett und Storz wurden diskutiert und **nicht gebaut**: Bei Zuglast keine wesentlich höhere Festigkeit, nur bessere Handhabung; die Nutzerin blieb beim Gewinde. Eine federgelagerte Noppe wurde verworfen (Rastwinkel hängt von Plexiglasdicke und Dichtung ab, gedruckte Biegearme ermüden in PETG).

## Verworfene Varianten – nicht wieder vorschlagen

- Gewinde mit 6 mm Steigung und nur 1,6 Gängen mit flacher Plattenfläche (Nut kollidierte mit dem Gewinde).
- Nut auf der Magnetfläche der Halteplatte weglassen (Nutzerin besteht auf Nut).
- Bajonett/Storz als Ersatz fürs Gewinde (siehe oben), federgelagerte gedruckte Noppe.

## Stand der Konstruktion (27.10.2026)

### Verlauf (jeder Stand ein Commit; hier die Etappen der Entstehung)

1. Erste Fassung: Durchführung mit grobem Gewinde (6 mm), 8 mm Scheiben, Verjüngung (35 mm) mit Schlauchstutzen.
2. 110er-Ende auf Magnetflansch nach Referenz umgestellt (Stutzen blieb als Variante); Umrissabgleich mit dem beigefügten 110er-Anschluss.
3. 150er-Flächen exakt nach `Magnetic_Hose_Adapter_150` (Teilkreis 91 mm, Umriss, Nut 75,5 mm); Platten zunächst ohne Nut auf der Magnetseite.
4. Nuten auf allen Magnetflächen; Halteplatte mit Steg; Gewinde 4 mm Steigung; Scheiben 10 mm.
5. Zentrierbund; Dicken `disc_t`, `nut_t`, `adapter_t` getrennt (Standard 12/12/10); Bohrungen für Sicherungsschrauben; Gewindelänge folgt `nut_t`.

6. **28.10.2026:** `part = "adapter140"`: Ventilator-Adapter (Muffe ø146,4 × 36 mm, Schulter auf ø140, 35-mm-Trichter, 110er-Magnetflansch nach Referenz, `fan_screw_*` für radiale Schraublöcher). Vorlage war `4inchto6inchDuct_v5.stl` (Muffe 35 mm tief, ID 149,2, Trichter ca. 38 mm, Stutzen); die Maße der Nutzerin weichen ab, die Form ist ähnlich.

7. **28.10.2026:** Ventilator-Adapter mit **O-Ring-Nut in der Muffenwand** (3-mm-TPU-Schnur, 1,6 mm tief, 24 mm vom Rand, `part = "oring_fan"` liefert den Ring) und **optionaler Dichtungsnut** auf dem 110er-Magnetflansch (`fan_flange_groove`, Standard an). Die 110er-Nut ist an Verjüngung und Adapter identisch (r 53,4–57,6), ein Ring `dichtung_100_anschluss_tpu.stl` passt überall. Die Nutzerin wollte zunächst nur wissen, ob beidseitig gedichtet ist; Entscheidung: Nut in der Muffenwand (nicht Flachdichtung auf der Schulter).

### Schlauchgröße 100 (`hose_nom`) und Schraubkappe
- Nutzerin: Schlauch nominal **100 mm**; ihr 100er-Schlauchanschluss (Rahmensystem-generiert, vermessen) war zuerst mit Taschen ø10,2 auf R 61,0 vermessen; der **aktuelle** Anschluss (15×3-Magnete) hat 6 Taschen ø15,2 auf R 66,0, Nut Mitte r 50,5, Bohrung ø90, Körper r 58,4, Lappen bis r 76,5 und ist die Referenz (`R110`, `body110_r`, `lobe110` bei `hose_nom=100`). Dateinamen mit 100 für die Schlauchseite; `verjuengung_150_110_rohr*` behält 110 (KG110-Rohr).
- Schraubkappe (`abluft_schraubkappe.scad`, `include <abluft_system.scad>`): Gewindeprofil des **110er**-Anschlusses per Querschnitten vermessen (P 10,04 mm, Rechtsgewinde, konisch −0,031 mm/mm, Tabelle rt_tab), Innengewinde = Profil + `thread_clear`. Nutzerwunsch: damit der 110er-Anschluss nicht neu gedruckt werden muss.

### Fensterkanal (`abluft_fensterkanal.scad`, eigene Datei, bindet `abluft_system.scad` per `include` ein und setzt danach `part="keiner"`)
- Ein Ring-Sweep entlang der Mittellinie (Parameter s) erzeugt alle Rundteile, den Loft (Radialabbildung Kreis → abgerundetes Rechteck, Glättung smoothstep) und den Flachkanal als Polyeder ohne Boolesche Operationen. Teile sind Abschnitte [s0, s1] desselben Sweeps; Steckverbindungen entstehen durch zusätzliche Ringe mit anderem Wandversatz (Spigot außen halbe Wand, Muffe innen halbe Wand plus Spiel).
- Teileplan (`plan`, `fits`): nur so viele Teile wie nötig, Greedy in 5-mm-Schritten; Zwangsschnitte (Loftanfang, Flachkanalanfang) und Spalten nur wenn `ncol > 1` (Breite > Druckraum − Steckverbindung). Stege liegen im lokalen Rahmen (Ebenen exakt koplanar zu den Endringen); bei geraden Teilen werden lokale Koordinaten exakt statt per Matrix berechnet (sonst fast-koplanare Flächen).
- Nutzerwunsch: nur teilen, wenn nötig; Standard ohne Seitenteile; auf einfaches Drucken optimiert (stehend, wenige Teile). Beispiel der Nutzerin (Datei Window_Duct): Rundrohr 101,6 → Flachkanal 340 × 60, asymmetrisch (177/163), Stützblöcke.
- Messwert-Formel (`fk_use_messung`): Dachneigung phi = 90 − Winkel(Stab, Waagerechte); Rahmenkante bei u = a·cos(phi), w = Plattendicke + h + a·sin(phi); Kanalende = Rahmenkante + m_reach in Austrittsrichtung (Standard `m_exit_waagerecht=true`: waagerecht in Verlängerung von m_a, Knickwinkel = m_beta; sonst parallel zur Scheibe mit `m_exit_tilt`); daraus fk_L1/fk_after_total. Nutzer: Spalthöhe variabel (klein, ggf. mehrere cm), Überstand 60 mm (mehr gern, aber keine zusätzliche Druckplatte), Fenster geneigt, Stab senkrecht zur Scheibe; zwei Varianten: einteilig und zweiteilig (`fk_split`). Messdaten folgen.
- Offen: nicht gedruckt, Passung der Steckverbindungen und Falze ungeprüft; Spaltenteilung wurde nur geometrisch geprüft (`werkzeuge/pruefung_fensterkanal.py`).

### Ausströmer direkt (`abluft_ausstroemer_direkt.scad`, bindet `abluft_system.scad` per `include` ein)
- Nutzerwunsch: kein Bogen, gerader Keil vom 150er-Flansch zum Flachkanal, ohne Rundungen (außer Flansch); Unterseite des Kanals liegt auf der Rahmenkante E; Überstand ≥ 50 mm (Abtropfrand); höchstens 3 Teile nebeneinander; Stützen beim Druck erlaubt; Strömungsstege sollen Stabilität und Luftführung verbinden.
- Aufbau: Mittellinie gerade, Winkel `al` aus Iteration (E = Unterseite, Kanalmitte um m_gap/2 versetzt); Querschnitte rechteckig, Eckpunkte als Ring mit 4 Punkten (`cpt`, `sweep4`); Anfang schräg an der Flanschebene (`CUT`, `cutS`), bis `T0` konstanter Querschnitt (symmetrischer Schnitt), dann lineare Aufweitung bis `S_F0`, danach Flachkanal. Teilkoordinaten: x zum Raum, y Breite, z Achse; `Mw(s0)` rechnet in Weltkoordinaten (Flanschfläche z=0).
- Seiten: e_WL liegt bei −y = rechte Fensterseite von innen, e_WR bei +y = linke (Nutzer: breite Seite muss rechts sein); Flansch gehört zur Spalte `jf` (enthält y=0). Vorschau mit Stegen: `ausgabe="schnitt"`.
- Stege (`vane`): strahlenförmig ab `rib_s0`, parallel im Flachkanal; durchgehend durch Spigot/Muffe bis zum Stegbeginn des Folgeteils (Klebefläche); in Spalten auf den Kern der Spalte begrenzt (Falzbereiche ausgenommen). Planer (`plan`, `fits`): Teil 1 mit Flansch in Weltlage, alle anderen liegend; Schnipsel (< 25 mm Spalte) werden vermieden (`nosliver`).
- Lehren: Der Anfangsschnitt braucht konstante Höhe/Breite bis `T0`, sonst wird die Öffnung asymmetrisch und ragt über den Flansch; Wandstärke bleibt wegen der Schräge nur nahe Nenn (Querschnittsrahmen senkrecht zur Achse).
- Nutzer: Kanal muss nicht so breit werden -> `fk_W_max` 450. Lehre: Falz-Aussparung muss auch die Spigot-Hülse (s1..s1+jl) abtragen, sonst entsteht eine freiliegende Hülsenfläche (nicht wasserdicht). Stegabstand: `fk_rib_pitch` 70, `fk_rib_gap0` 35 (enge Kanäle würden mit Teer zuwachsen; Reibungsverlust der Stege nur 1-3 Pa).
- Offen: nicht gedruckt; Passung der Falze, Stützen für Teil 1 und Druckreihenfolge ungeprüft; keine Strömungssimulation (Aufweitwinkel noch groß).

### Ausmesshilfe (`abluft_ausmesshilfe.scad`)
- Eigene Datei ohne Abhängigkeit zur Hauptdatei. Platte mit Taschen (Magnete unten bündig), Speichen/Fenster, Nabe und senkrechtem 5-mm-Stift (gedruckt oder Bohrung für einen Metallstift). Parameter für Magnetart, Anzahl, Durchmesser, Teilkreis, Stiftlänge. Nutzerwunsch: Magnetart, Anzahl, Durchmesser und Stiftlänge frei wählbar, eigenes OpenSCAD.

### Geprüft (Rechenmodell, `werkzeuge/pruefung.py`)

Alle STL wasserdicht; keine Überlappung Innenscheibe/Plexiglas/Halteplatte; Gewinde frei bei ca. 50° Drehspiel (0,56 mm axial); Verjüngung und Referenzadapter (150 auf Halteplatte und unter Innenscheibe, 110 auf Flansch) ohne Überlappung; Ring- und Taschenradien stimmen mit der Referenz überein. Mit abweichenden Dicken (`disc_t = 15`, `nut_t = 18`) wurden nur die Kontrollausgaben (3,6 Gänge) geprüft, nicht der volle Export.

### Offen / nicht am Druck geprüft

- Gewindesitz, Dichtheit, Haltekraft (Magnete: Überschlag 7–10 kg Zug, Querkraft nur Reibung), Kriechen unter Zug und Wärme, Klemmnasen, Madenschrauben in PETG.
- **Polungsregel der Referenzteile** unbekannt (Kerbenmarkierung im Modell ist eine eigene Konvention).
- O-Ring-Pressung auf den Anschlussflächen: zwei Nuten à 1,9 mm gegen 4 mm Schnur ergeben nur ca. 0,2 mm Vorspannung, sobald die Flächen anliegen (110er-Flächen: 2 × 1,3 mm, also ca. 1,4 mm bzw. 35 % Pressung); bei undichtem Ring tiefere Nuten oder weichere/dickere Ringe prüfen (Referenzmaß bleibt maßgeblich).
- Ausreichende Wand an der Plexiglasnut in der Taille (ca. 1,1 mm): am Probedruck beobachten.
- **Ventilator-Adapter:** Der Muffen-O-Ring dichtet nur, wenn der Außendurchmesser des Ventilatoranschlusses zu 146,4 − 2 × 1,4 + Spiel passt (Pressung ca. 1,2 mm bei AD 146,0). Außendurchmesser des Ventilatoranschlusses messen und `fan_groove_depth`/`fan_oring_d` anpassen. Lichte Weite des Ventilatoranschlusses (`fan_bore_d = 140`) und sein Außendurchmesser sind Annahmen (die Muffe ist 146,4 mm, die Nutzerin hat nur diesen Wert genannt). Schrauben- oder Klebefixierung ungeklärt; Wandstärke 4 mm und Lochlage (12 mm vom Rand) nicht am Teil erprobt.
- Möglicher Schritt: 3MF mit Druckeinstellungen (PETG: 100 % Füllung/≥ 5 Wände für Rohrteile; TPU für Dichtungen), Gewindeprobe als kleines Probestück, Bajonettvariante als Option (`fastening`), Parametertest für abweichende Magnetzahl (nur 8/6 haben Referenzumriss).

## Hinweise zur Geometrie (für Änderungen)

- `mag_flange(...)` baut Flansche aus gestapelten `linear_extrude`-Schichten (Magnettaschen, Nut, Bohrung je nach Höhe), das ist für CGAL viel schneller als Boolesche Differenzen. Haltepunkte werden mit `qsort` sortiert.
- Gewinde: `thread_tube` (Außenprofil, Bohrung innen) und `thread_nut_ring` (Innenprofil, außen glatter Ring); beide verwenden dieselbe Profilfunktion `tf` (halbe Zahnbreite `thr_hr`, Spitze `thr_hc`).
- Maße der Referenzen (zum Nachprüfen, Werte aus den STL gemessen): 110er-Adapter: Magnetkreis 70,9 mm, Tasche ø15,2–15,4, Tiefe 3,2, Nut r 53,4–57,6 / 1,3 tief, Bohrung ø100, Stutzen ø110 außen (konisch 55,1 → 54,1 mm Radius), 5 Wulste (Radius ca. 2, Teilung 6, Höhe ca. 2,4). 150er-Adapter: Magnetkreis 91,0 mm, Tasche ø15,2–15,5, Tiefe 3,1, Nut r 73,4–77,6 / 1,9 tief, Bohrung ø140, Flanschhöhe 15, Gesamthöhe 65. O-Ring-Vorlagen: Torus ø4 mm; OD 105 bzw. 110 mm.
- Die Referenzdateien liegen nicht im Repository (MakerWorld, siehe README). Wenn sie fehlen, läuft `pruefung.py` ohne `--ref150`/`--ref110`.
- Eine Fremdgeometrie nicht blind übernehmen: Der Umriss `ref150_pts` stammt aus der Vorlage; vor Veröffentlichung Lizenz klären.

- **Lehre Ausströmer direkt:** `fk_bed` ist der *nutzbare* Raum, nicht die Nenngröße. Mit 260 füllte das Flanschteil (258,5 mm) die Platte komplett und passte praktisch nicht (Brim/Stützen/Skirt). Standard jetzt 240×240×250; Teile werden entsprechend neu geteilt (Teil 2 jetzt 236,5 × 216,4 × 114,9 mm).

- **Ersatz-Füße:** `abluft_fuss.scad` (include system, `part="keiner"`). Lehre: In OpenSCAD wird eine nach einem `include` überschriebene Variable an der Stelle der ERSTEN Zuweisung ausgewertet; deshalb dürfen überschriebene Systemvariablen (`polarity_marks`) nur Literale sein, nicht von später definierten Parametern abhängen. Export `werkzeuge/export_fuss.sh`.

- **DN110-Doppelbogen:** `abluft_dn110_winkel.scad`, Rohrbausteine (`tube_s`, `tube_b`, `rotate_extrude(angle=90)`), Frame-Konvention lokal: Fahrtrichtung +y, links = −x. CGAL-Render von Teil 2 ca. 50 s (`fn=80`). Montierte Pose und Überlappungsprüfung (0 mm³) per trimesh/manifold gegen die Druckposen geprüft.
- **DN110-Doppelbogen v2:** Flansch nicht mehr angeformt, sondern als Flanschring (Teil 3) mit Innengewinde auf Außengewinde von Teil 2 (`helix_extrude`, `thr_pts` des Systems, Gewindegrund ro − thread_depth). Beim Prüfen der Montage Druckpose → lokal: y_lokal = 2·yc − y_druck (Spiegelung um yc), nicht yc − y.
- **Arbeitsplatten-Variante:** `abluft_dn110_arbeitsplatte.scad` setzt Parameter VOR dem `include` (dp_*) und überschreibt `wk_*` danach (Werte hängen nur von dp_* ab, die vor dem include stehen). Teil 2: eine durchgehende Bohrung und 0,3/1 mm Überlappung an Bogenfugen, sonst 4-Flächen-Kanten (nicht wasserdicht).
- **Kegel/Ring flach:** `wk_kegel_l` im Doppelbogen (Bohrung ri → stub_bore_r am Rohrende); Arbeitsplatten-Variante: wk_v = (dp_ring_aufl − dp_lippe) − dp_zc − Rc. Standard-Rohrbogen statt Teil 1 ist angeboten, aber nicht gebaut (Bogenmaße fehlen).

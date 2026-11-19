# agent.md – Rhino-Gittermaske

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit dem Nutzer: **Deutsch**. Anwenderdoku: `README.md`.

## Arbeitsweise

- Projektordner `rhino-maske/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner nicht anfassen.
- Wie in den anderen Projekten: Änderungen committen und nach `origin/main` pushen; vorher `git pull --rebase origin main`. Commit-Messages auf Deutsch, Betreff im Imperativ.
- **Quelle ist `rhino_lattice_mask.py` + `modell/meshy_rhino.obj`.** Alles in `druck/` ist erzeugt und wird eingecheckt. Nach jeder Änderung neu erzeugen (Befehle im README) und alles mitcommitten. Versionen nur über Git, keine `_v2`-Dateien.
- Werkzeuge: Blender 4.x oder `pip install --break-system-packages bpy` (getestet mit bpy 5.3 unter Python 3.13). Lauf ca. 20 s.

## Festgelegte Entscheidungen (vom Nutzer)

- **Form 1:1 aus dem Meshy-Modell** – nicht glätten, nicht remeshen, nichts „verbessern“. Das Modell ist wasserdicht, deshalb kein Voxel-Remesh (`IMPORT_VOXEL = 0`).
- Einziger Eingriff in die Form: Die gerundete Halsunterseite wird waagerecht abgeschnitten (`IMPORT_ABSCHNITT_ANTEIL = 0.1326` der Modellhöhe), weil der Hals erst dort weit genug für den Kopf ist.
- Augen = die Augenwölbungen des Modells (Flächenwachstum vom Augenmittelpunkt bis zum Knick, `AUGE_KANTENWINKEL = 14°`, stabil zwischen 10° und 17°), solidifiziert mit 5 mm. Eine angepasste Kugel passte nicht (die Augen sind oval) und hätte Gittermuster auf dem Auge gezeigt.
- **Ein Erwachsenenkopf muss durch Öffnung UND Hals passen** (Nutzer). `kopf_einpassen()` schneidet die Fläche alle 5 mm bis 250 mm Höhe, sucht die beste Lage einer Kopf-Ellipse 170 × 230 mm (95. Perzentil inkl. Nase) und vergrößert die Maske, bis überall ≥ 10 mm Luft sind. Engstelle: 27 mm über der Öffnung (Halsinnentiefe). Ergebnis: Faktor 300,7 × 1,037, Maske 385 × 511 × 515 mm.
- **Balance (Nutzer):** Die Maske darf nicht nach vorne kippen; das Schnauzengewicht wird durch dickere Hinterkopfteile ausgeglichen. `ausgleich()`: Vertex-Gruppe „Hinterkopf“ (y > Kopfmitte + 20 mm, weich über 60 mm; z > 140 mm), Solidify mit Gruppe; die Tiefe hinten wird per Sekantenverfahren so gewählt, dass der Schwerpunkt 5 mm hinter der Kopfmitte liegt. Ergebnis: 5,7 mm hinten, 1077 g, Schwerpunkt y = 64,8 (Kopfmitte 60), z = 244 mm. Gegengeprüft aus den exportierten Teilen.
- Sicht geprüft (Strahlen von den Trägeraugen, ±32 mm, 85 mm vor der Kopfmitte, 140–230 mm hoch): 100 % durch eine Netzlage, Maskenaugen nicht im Blickfeld. Ein „Sichtfeld“ mit flacheren Stegen vorne will der Nutzer erst nach dem Prototyp entscheiden: **Front unverändert lassen.**
- Drucker: Anycubic Kobra 4, 260 × 260 × 260 mm, Rand 2 mm (bei 5 mm wären es 12 statt 8 Teile) → 2 × 2 × 2 = 8 Teile, max. 192 × 255 × 258 mm.

- Mini-Variante (`PRESET = "mini"` oder `-- mini`): 59,5 mm Höhe → 45 × 60 × 60 mm, Lochnetz Maschen 1,6 mm, Stege 0,8 mm, Tiefe 0,8 mm mittig (`NETZ_OFFSET = 0`), Löcher ca. 0,8 mm (Grenze für 0,4-mm-Düse), nur Lage A mit `WIRE_OFFSET_A = 0` (Ohren sind dort nur 0,6–1 mm dick), zusätzlich eine massive Figur (`VOLLKOERPER`). Ausgabe in `druck/mini/`.

- **Zweck des Netzes (vom Nutzer):** Die Maske soll massiv wirken, ist es aber nicht; der Träger sieht hinaus, man sieht nicht hinein. Deshalb `GITTER_MODUS = "lochnetz"`: kleine Löcher (groß ca. 1,6 mm, Mini ca. 0,8 mm). Das frühere offene Stabgitter (`"stabgitter"`, Waben 8 mm, zwei Lagen) passt dazu nicht und ist nur noch als Option da.

## Technik

- Lochnetz: `quadriflow_remesh` (Zielmaschen = Fläche / ZELLE² × 1,15) → Maschen mit Innenradius > STEG/2 + MIN_LOCH/2 per `inset_individual` (STEG/2, nicht „even“) einrücken und löschen → Solidify `NETZ_TIEFE` (nicht „even“, sonst Spitzen). Decimate + Dual Mesh ergab sehr ungleiche Löcher (p10 0,1 mm, p90 2,3 mm) und ist nur der Ersatzweg. Große Maske: ca. 100 000 Maschen, 1,2 Mio. Faces, Lauf ca. 4,5 min; Komplett-STL 120 MB (nicht eingecheckt, `.gitignore`), 3MF 31 MB.
- Stabgitter (alt) A: Decimate (Collapse, X-Symmetrie) auf ca. 8 mm Kantenlänge → Geometry-Nodes-Dual-Mesh → Wireframe 2,4 mm, Offset −1 (nach innen), `use_even_offset = False` (sonst Spitzen an Wabenecken).
- Gitter B: Fläche um 1,9 mm nach innen versetzt, Dreiecke ca. 10 mm, Wireframe 2,0 mm. Überlappung mit A: 0,5 mm. In dünnen Bereichen (Ohrränder, Dicke < ca. 8 mm) gibt es keine Lage B, sonst sticht sie auf der Gegenseite durch.
- `aufraeumen()` entfernt Fliegen-Vertices und kleine Inseln vor dem Wireframe; sonst entstehen nicht-manifolde Kanten.
- Teilen: `bisect_plane` je Achse, Schnittflächen mit `holes_fill`; Problemstellen werden bis zu 4× freigeschnitten und neu geschlossen. Ergebnis: 0 offene Kanten je Teil.
- Die Lagen, der Kragen und die Augen sind getrennte, sich überlappende Körper. Der Slicer vereinigt sie. Eine echte Voxel-Fusion (`FINAL_VOXEL_FUSE`) würde bei 0,35 mm ca. 40 Mio. Dreiecke ergeben.
- 3MF: einfache Core-3MF ohne Slicer-Profil. Die Teile liegen auf Plattenpositionen im Raster von Bambu/Orca (3 Spalten, Abstand Bett × 1,2).

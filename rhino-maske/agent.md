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
- Größe automatisch aus dem Kopfmaß 220 mm + 2 × 15 mm Luft + Wand → Faktor ≈ 300,7 (Modelleinheiten → mm).
- Drucker: Anycubic Kobra 4, 260 × 260 × 260 mm, Rand 5 mm → 2 × 2 × 2 = 8 Teile.

- Mini-Variante (`PRESET = "mini"` oder `-- mini`): 59,1 mm Höhe → 45 × 59 × 60 mm, Waben 2 mm, Stege 1 mm (Wunsch des Nutzers; feiner schließen sich die Löcher auf FDM, siehe Tabelle im Chat: 1,6/0,9 ist die Grenze), nur Lage A mit `WIRE_OFFSET_A = 0` (Ohren sind dort nur 0,6–1 mm dick), zusätzlich eine massive Figur (`VOLLKOERPER`). Ausgabe in `druck/mini/`.

## Technik

- Gitter A: Decimate (Collapse, X-Symmetrie) auf ca. 8 mm Kantenlänge → Geometry-Nodes-Dual-Mesh → Wireframe 2,4 mm, Offset −1 (nach innen), `use_even_offset = False` (sonst Spitzen an Wabenecken).
- Gitter B: Fläche um 1,9 mm nach innen versetzt, Dreiecke ca. 10 mm, Wireframe 2,0 mm. Überlappung mit A: 0,5 mm. In dünnen Bereichen (Ohrränder, Dicke < ca. 8 mm) gibt es keine Lage B, sonst sticht sie auf der Gegenseite durch.
- `aufraeumen()` entfernt Fliegen-Vertices und kleine Inseln vor dem Wireframe; sonst entstehen nicht-manifolde Kanten.
- Teilen: `bisect_plane` je Achse, Schnittflächen mit `holes_fill`; Problemstellen werden bis zu 4× freigeschnitten und neu geschlossen. Ergebnis: 0 offene Kanten je Teil.
- Die Lagen, der Kragen und die Augen sind getrennte, sich überlappende Körper. Der Slicer vereinigt sie. Eine echte Voxel-Fusion (`FINAL_VOXEL_FUSE`) würde bei 0,35 mm ca. 40 Mio. Dreiecke ergeben.
- 3MF: einfache Core-3MF ohne Slicer-Profil. Die Teile liegen auf Plattenpositionen im Raster von Bambu/Orca (3 Spalten, Abstand Bett × 1,2).

# agent.md – Stecker Hansgrohe-Schnellkupplung

Sprache mit dem Nutzer: **Deutsch**. Projektordner `schnellkupplung-stecker/` im Repo `scipiojr/3dprint` (Branch `main`), andere Ordner nur nach Rückfrage ändern.

- Lies zuerst `README.md`: Maßtabelle, Koordinaten, Übernahme ins eigene Design, Drucken.
- **Maße sind vom Nutzer gemessen und im Druck erprobt.** Nicht „verbessern" oder runden, ohne dass der Nutzer neu misst. Der erste Stecker aus einem Adapter-Modell hielt nicht (O-Ring-Nut zu flach).
- Nach jeder Änderung am SCAD: `python3 werkzeuge/exportiere.py` (erneuert `druck/`), `python3 werkzeuge/zeichnung.py` (erneuert `bilder/profil.png`), und mit `trimesh` prüfen, dass alle Netze geschlossen sind. Die Baumvariante `../dusche-weihnachtsbaum/schnellkupplung_stecker.scad` muss dieselben Maße haben.
- Die 3MF-Dateien sind Bambu/Orca-Format von Hand geschrieben (trimesh-3MF öffnet Anycubic Slicer Next nicht). Im Slicer nicht geprüft, im Zweifel STL nehmen.
- Commit-Messages auf Deutsch, Betreff im Imperativ (höchstens 72 Zeichen). Vor dem Push `git fetch` und auf `origin/main` aufsetzen (Klon ist flach).

# agent.md – Weihnachtsbaum-Duschkopf mit LED-Stern und Wasserturbine

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit dem Nutzer: **Deutsch**.

## Zuerst lesen

1. `README.md` in diesem Ordner: Ziel, Messwerte, Energiebilanz, Konzept, nächste Schritte.
2. `../dusche-weihnachtsbaum/README.md` und `agent.md`: Basismodell, Stecker, Koordinaten, Werkzeuge.

## Arbeitsweise

- Projektordner: `dusche-weihnachtsbaum-led/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Ordner nicht ändern. Aus `../dusche-weihnachtsbaum/` nur lesen und wiederverwenden (Stecker-SCAD, `erzeuge_modell.py`), dort nichts umbauen, ohne zu fragen.
- Commit-Messages auf Deutsch, Betreff im Imperativ (höchstens 72 Zeichen), darunter kurz was und warum. Vor dem Push `git pull --rebase origin main`.
- Versionierung nur über Git, Dateinamen ohne Versionskennung.
- **Kein Netz des Original-Duschkopfs (STL/3MF) einchecken.** Grund: MakerWorld Standard Digital File License, das Repo ist öffentlich. Eigene Teile wie Prüfgriff und Rotor dürfen als SCAD rein, STLs daraus nur, wenn der Nutzer es will.
- Werkzeuge wie im Hauptprojekt:
  - OpenSCAD.
  - Python mit `numpy trimesh manifold3d lxml shapely matplotlib`.
  - Nachrechnungen mit Skripten unter `werkzeuge/`, nicht im Kopf.
- Zahlen, die nicht gemessen sind, als **Schätzung** kennzeichnen. Im README getrennt halten: Messwerte am Modell, Händlerangaben, Überschläge.

## Vorgaben des Nutzers (verbindlich)

- **Wenige LEDs, zur Not nur der Stern.** Selbst baubar und **dicht** gehen vor Lichtmenge.
- Strom nur aus dem Wasser. Keine Batterie, kein Kabel nach außen.
- Elektronik getrennt vom Wasser, vollständig vergossen, keine Wellendichtung.
- Drucker: Anycubic + ACE (4 Filamente). Nasse Teile aus PETG.

## Stand (12.11.2026)

- Machbarkeit geprüft, siehe README. Fertige Hydrogeneratoren sind zu groß (≥ 32 mm dick, ≈ 85 mm lang). Der Baum-Hohlraum ist zu flach (≤ Ø 6 mm frei).
- Gewähltes Konzept: **axiale Ring-Turbine mit mehreren Stufen im Griff**, Magnete im Rotorring, Spulen vergossen in der Griffwand, Stift-Lagerung. Ziel 0,05–0,1 bar Druckverlust und 0,1–0,3 W (geschätzt).
- Noch keine Konstruktion.

## Offen beim Nutzer

- Ist ein Griff mit Ø 26–28 mm statt 21,25 in Ordnung?
- Welche LED-Farbe soll der Stern haben, und ist der Stern aus durchscheinendem PETG in Ordnung?
- Wie hoch sind Fließdruck und Durchfluss an seiner Dusche?

## Nächster Schritt

Prüfgriff konstruieren (`pruefgriff.scad`, `rotor.scad`), parametrisch, ohne Baum. Er bekommt ein Auslassstück mit Drossel, die etwa 78 mm² Düsenfläche nachbildet. Dazu eine Bau- und Messanleitung für den Nutzer ins README.

# agent.md – Weihnachtsbaum-Duschkopf mit LED-Stern und Wasserturbine

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit dem Nutzer: **Deutsch**.

## Zuerst lesen

1. `README.md` in diesem Ordner: Ziel, Entscheidungen, Messwerte, Energiebilanz, Konzept, nächste Schritte.
2. `bauteile.md`: Bauteil-Recherche mit Links, Preisen, Maßen und Bewertung. Neue Recherchen dort ergänzen, mit Datum.
3. `../dusche-weihnachtsbaum/README.md` und `agent.md`: Basismodell, Stecker, Koordinaten, Werkzeuge.

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
- **Neu:** LED-Wasserhahnaufsätze (etwa 24 × 24 × 35 mm) und LED-Duschköpfe haben kleine Generatoren. Weg A (Spender ausbauen) wird zuerst geprüft. Der Nutzer kauft und zerlegt.
- Weg B, falls A nicht klappt: **axiale Ring-Turbine mit mehreren Stufen im Griff**, Magnete im Rotorring, Spulen vergossen in der Griffwand, Stift-Lagerung. Ziel 0,05–0,1 bar Druckverlust und 0,1–0,3 W (geschätzt).
- Noch keine Konstruktion.

## Entscheidungen des Nutzers (12.11.2026)

- Griff darf dicker werden (Ø 26–28).
- Stern gelb. Transparente Schicht oder Öffnungen für die LEDs sind erlaubt, alternativ farbige LEDs.
- Hausdruck 4 bar. **Durchfluss gemessen:** alter Kopf 4,6 l/min, Schlauch 14,6, Baum ohne Geschenke 14,2 l/min (je ein Versuch). Rechnung läuft mit 14,2 l/min. Fließdruck offen.

## Nächster Schritt

Durchfluss ist da (12.11.2026) und eingerechnet. Prüfgriff (Weg B) baut und prüft fehlerfrei (OpenSCAD 2021.01, `werkzeuge/pruefe_pruefgriff.py`: alle Teile dicht, nur 1,1 mm³ Überschneidung Rohr/Spulenring). Es fehlen noch Fließdruck und Spender-Generatoren (Maße, Spannung, Strom). Als Nächstes: Druckverlust des Prüfgriffs bei 14,2 l/min abschätzen und den Rotor-Kanal prüfen (Ø 9 → größer?). Dann Prüfgriff konstruieren (`pruefgriff.scad`, ggf. `rotor.scad`), parametrisch, ohne Baum. Er bekommt ein Auslassstück mit Drossel, die etwa 78 mm² Düsenfläche nachbildet. Dazu eine Bau- und Messanleitung für den Nutzer ins README.

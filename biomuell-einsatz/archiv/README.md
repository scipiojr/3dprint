# Archiv – Zwischenstände

Frühere Stände des Projekts, so wie sie vom Rechner der Nutzerin übernommen wurden. Sie dienen zum Nachvollziehen und Vergleichen; weitergearbeitet wird in `../biomuell_system.scad`.

| Ordner | Stand | Inhalt |
|---|---|---|
| [`2026-10-16_v0_python`](2026-10-16_v0_python/) | vor dem 16.10., 01:55 | Python-Generator für Plattform und Bänder: Rippenplatte 250 × 195, Schnapphaken. Noch kein Trichter. |
| [`2026-10-16_v1_scad`](2026-10-16_v1_scad/) | 16.10.2026, 01:55 | Erste parametrische SCAD-Datei mit Korb, Trichter (gleich dicke Wand) und Passlehre. Eimer mit 278 mm angenommen. |
| (Hauptordner) | 18.10.2026 | Version 2: Eimer 283 mm, Mittelteil, Keilwand, Druckhilfe, abgeflachter Scharnierstift. |

## Entwicklung in Stichworten

| | V0 (Python) | V1 (SCAD, 16.10.) | V2 (aktuell, 18.10.) |
|---|---|---|---|
| Plattform | 250 × 195 × 4 mm, Rippen, 4-mm-Quadratlöcher, 7 Füße | 206 × 166 × 6 mm, massiv, 9 Langlöcher, 4 runde Füße | wie V1 |
| Plattformhöhe | 54 mm | 56 mm | 56 mm |
| Bänder | 244 mm, Griffsteg 12 mm | 239,75 mm, Griffsteg 8 mm | wie V1 |
| Scharnier | runder Stift, Schnapphaken | runder Stift, Schnapphaken | Stift mit Abflachungen, Haken mit Kanal |
| Trichter | – | 2 Hälften, gleich dicke Wand | 2 Hälften + 2 Mittelteile, Keilwand |
| Eimer (Länge innen) | 275 mm (Höhe 290) | 278 mm | 283 mm |

Die STL-Dateien der alten Stände sind nicht eingecheckt (`.gitignore`). Sie lassen sich aus den hier abgelegten Quellen neu erzeugen: V0 mit `biomuell_plattform.py`, V1 mit OpenSCAD (die Maße und Volumina der neu erzeugten V1-Teile stimmen mit den STLs von damals überein).

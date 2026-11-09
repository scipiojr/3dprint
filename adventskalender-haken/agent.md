# agent.md – Zuckerstangen-Haken für den Adventskalender

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit dem Nutzer: **Deutsch**.

## Arbeitsweise

- Projektordner: `adventskalender-haken/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner nicht anfassen.
- Commit-Messages auf Deutsch, Betreff im Imperativ (≤ 72 Zeichen), darunter kurz was und warum. Vor dem Push `git pull --rebase origin main`.
- Versionierung nur über Git, Dateinamen ohne Versionskennung.
- Eigenes Design: STL und 3MF werden eingecheckt. Nach jeder Geometrieänderung `python3 werkzeuge/erzeuge_modell.py` und `python3 werkzeuge/bilder.py` ausführen und beides committen.
- Die Ausgabe von `erzeuge_modell.py` (Maße, Volumen, Schichten mit Farbwechsel) in README-Tabellen übernehmen, wenn sich etwas ändert.

## Ziel

Magnethaken (Neodym Ø 15 × 3 mm) für einen Adventskalender: wenig Auskragung, sieht aus wie eine rot-weiße Zuckerstange. Optimiert für Zweifarbdruck mit Filamentwechsler (Bambu AMS, Anycubic ACE 2 Pro). Unsichtbare Bereiche (Wandkontakt) müssen nicht zweifarbig sein.

## Entscheidungen

- Zwei Bauformen auf Wunsch des Nutzers: **relief** (Hauptvariante, ~6 Wechselschichten, 8,6 mm tief, Band wird unter dem Bogenscheitel durchgefädelt) und **rund** (offener Haken, Bogen nach vorn, 74 Wechselschichten). Je 1, 2, 4 Magnete.
- Drei Körper je Variante: `platte`, `weiss`, `rot`. Platte und Stange sind in Z getrennt (Stange = Stange − Platte), so gibt es an der Plattenoberseite nur einen Wechsel. Die Plattenfarbe ist frei wählbar.
- relief: Streifen als schräge Bänder in Stangenkoordinaten (s, t), auf die Ebene abgebildet. Rot nur in der Fase plus 0,2 mm darunter (Z 7,4–8,6). Fädelschlitz 9 × 3 mm mit flacher Unterseite der Stange als Brücke, also ohne Stützen.
- rund: Spiralstreifen als Ringsektoren, die entlang des Pfads gedreht werden. Unterhalb PLATTE_T + 1,2 bleibt die Stange weiß.
- Netze: Booleans mit manifold3d. Damit beim Export keine nicht-mannigfaltigen Kanten entstehen:
  - Rot wird mit dem *Werkzeug* aus Weiß geschnitten, nicht mit dem roten Körper.
  - Werkzeuge ragen über die Stange hinaus.
  - Fasenstufen überlappen leicht.
  - Kugelkappen sind schief gedreht.
  - Die Streifen werden mit eigener Abtastung erzeugt.
  - Das Skript prüft `is_watertight`.
- Bilder mit eigenem Z-Puffer-Rasterer in `bilder.py`, weil die Painter-Sortierung von matplotlib zu falschen Verdeckungen führt.

## Offen

- Nicht gedruckt erprobt: Brücke über den Fädelschlitz, Passung der Magnete (Spiel 0,3 mm im Durchmesser), Haltekraft.
- Ob 3 mm Schlitz für das Band des konkreten Kalenders reichen.

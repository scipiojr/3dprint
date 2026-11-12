# Eigenbau-Demonstrator: Ring-Turbine mit Spulen-Generator

Plan vom **12.11.2026**, überarbeitet nach der ersten Konstruktion und Nachrechnung. Das ist die Umsetzung von „Weg B" aus dem [README](README.md). Alle Zahlen sind **Schätzungen**, gerechnet mit [`werkzeuge/demonstrator_rechnung.py`](werkzeuge/demonstrator_rechnung.py). Gemessen ist nur der Durchfluss an der Dusche (12.11.2026, siehe unten), am Modell selbst noch nichts.

Modelle: [`pruefgriff.scad`](pruefgriff.scad), [`rotor.scad`](rotor.scad), [`parameter.scad`](parameter.scad). Bau- und Messanleitung: [`anleitung_demonstrator.md`](anleitung_demonstrator.md).

## Ziel

Ein **Prüfgriff ohne Baum**, der an der echten Dusche zeigt:

1. Eine gedruckte Ring-Turbine mit Magneten und vergossenen Spulen läuft bei Duschdurchfluss.
2. Sie liefert genug Strom für wenige LEDs (Ziel 3, Mindestziel 2, je etwa 1 mA).
3. Der Griff ist **dicht** und der Druckverlust bleibt klein (Ziel 0,05–0,1 bar).

**Erfolgskriterien** (vorab festlegen, damit die Messung eindeutig ist):

| Kriterium | Ziel | Mindestens |
|---|---|---|
| LEDs sichtbar bei Duschdurchfluss | 3 LEDs, je ≈ 1 mA | 2 LEDs |
| Leerlaufspannung (Spitze, vor dem Gleichrichter) | ≥ 5 V | ≥ 3 V |
| Druckverlust über den Prüfgriff | ≤ 0,1 bar | ≤ 0,2 bar |
| Durchfluss mit Prüfgriff gegenüber ohne | ≥ 90 % | ≥ 75 % |
| Dichtheit | 30 min bei 4 bar trocken | 10 min |

Nicht Ziel des Demonstrators: Baum, Stern, Optik. Das kommt erst nach den Messwerten.

## Aufbau (konstruiert, siehe SCAD-Dateien)

Getrennte Teile, damit der Generator ohne Druckstopp angebaut werden kann (Spulen vorher wickeln, von außen einsetzen, Rotor von unten einsetzen):

| Teil | Wichtigste Maße (Startwerte) |
|---|---|
| Turbinenrohr mit Stecker und Leitrad 1 | außen Ø 17, Rotorkammer Ø 15, Wand zu den Spulen 1,0 mm, Länge 73 mm unter dem Stecker |
| Einlaufkanal | Ø 7,94 (Stecker) → Ø 9, 4 gerade Leitschaufeln um eine Nabe Ø 3,6 |
| Rotor | Ring Ø 14 / Ø 9, 25 mm lang, 4 Schaufeln um eine Nabe, **300° Verdrehung** (Steigung 30 mm/Umdr.), 8 Magnettaschen |
| Leitrad 2 (Einsatz) | Rohr Ø 14,8, Nabe mit Stiftloch, von unten eingeschoben |
| Spulenring | Ø 17,4 innen / Ø 24 außen, 8 Fenster 4,4 × 5,4 mm, Drahtkorridor |
| Außenhülse | Ø 24,1 innen / Ø 26,5 außen |
| Kappe | Nockengewinde (Steigung 5 mm), Drossel im Boden: Variante 1 ein Loch Ø 10, Variante 2 vier Löcher Ø 5 (je ≈ 78 mm²) |
| Stift | Edelstahl Ø 2 × 42 mm |
| Magnete | 8 × 5 × 4 × 1 mm, radial gepolt, abwechselnd N/S |

Die Modelle sind gerendert und geprüft: alle Teile sind geschlossene Körper, im Zusammenbau gibt es keine Kollision (`werkzeuge/pruefe_pruefgriff.py`). **An Wasser erprobt ist nichts.**

Die engste Stelle vor der Turbine ist die **Stecker-Bohrung Ø 7,94**. Die freie Fläche im Rotor (Ø 9 um die Nabe, abzüglich Schaufeln) beträgt etwa 45 mm². Das ist weniger als die Steckerbohrung (49 mm²). Schon ohne Energieentnahme ist deshalb ein Druckverlust von einigen hundertstel bar zu erwarten.

## Rechnung (Schätzung, neu 12.11.2026)

Die erste Rechnung war zu optimistisch. Drei Dinge begrenzen sich gegenseitig:

1. **Drehzahl** folgt aus der Steigung der Schaufeln: Leerlauf = Axialgeschwindigkeit / Steigung. Unter Last etwa die Hälfte.
2. **Spannung** folgt aus dem Feld der Magnete und der Frequenz. Ein 1 mm dicker Magnet hat ein schwaches Feld, im Mittel über die Spulentiefe etwa 65 mT (Blockformel).
3. **Kupfer:** Das Spulenfenster begrenzt Windungen und Widerstand. Die größte Leistung bei angepasster Last hängt kaum von der Windungszahl ab.

**Gemessen an der Dusche (Nutzer, 12.11.2026, Eimer und Stoppuhr, je ein Versuch):**

| Messung | Menge | Zeit | Durchfluss |
|---|---|---|---|
| bisheriger Duschkopf | 3,5 l | 46,09 s | **4,6 l/min** |
| Schlauch ohne Duschkopf | 3,15 l | 12,92 s | **14,6 l/min** |
| Weihnachtsbaum ohne Geschenke | 3,2 l | 13,48 s | **14,2 l/min** |

- Der Baum lässt fast so viel durch wie der offene Schlauch (−3 %). Das liegt im Rahmen der Messunsicherheit (je ein Versuch, Eimer, Stoppuhr). Der Schlauch und der Hahn begrenzen, nicht die 44 Düsen.
- Der alte Kopf bremst auf knapp ein Drittel. Der Baum verbraucht also etwa **dreimal so viel Wasser** wie der alte Kopf.
- Der Fließdruck ist weiter unbekannt. Aus den zwei Punkten folgt nur: Die Versorgung ist „steif". Ein Druckverlust von etwa 0,1 bar am Baum (Schätzung, siehe unten) kostet nur wenige Prozent Durchfluss.

Gerechnet wird mit **14,2 l/min als Höchstfall** (Alltagsbetrieb voraussichtlich 6–8 l/min, siehe unten). Das erhöht Drehzahl, Spannung und Leistung, aber auch die Strömungsgeschwindigkeit in Stecker und Rotor (Schätzung: 4,8 m/s in der Steckerbohrung, 5,3 m/s im Rotor, entspricht rund 0,12–0,14 bar Staudruck). Der **Druckverlust des Prüfgriffs wird dadurch vermutlich höher als das Ziel 0,1 bar**. Das muss die Messung zeigen. Hebel: Rotor-Kanal größer (Ø 9 → 10–11), steilere Leitschaufeln nur im Notfall.

Zum Vergleich der Baumdüsen (44 × Ø 1,5 mm = 78 mm², Schätzung mit Auslaufzahl 0,6–0,8): bei 14,2 l/min etwa 0,07–0,13 bar, bei den früheren 8 l/min nur 0,02–0,04 bar. Mit größeren Düsen (Nutzerwunsch, Standard **ø 2,0 mm**, Fläche 138 mm²) sinkt der Druckverlust der Düsen bei 14,2 l/min auf etwa 0,03 bar und die Strahlen werden weicher (≈ 2,5 m/s statt 4,3 m/s). Die Drossel im Prüfgriff (Kappe) folgt dem Parameter `duesen_d` in `parameter.scad` (Standard 2,0 → Ø 13,3 mm).

Ergebnisse bei **14,2 l/min** (`werkzeuge/demonstrator_rechnung.py`, Schätzung, kinematisches Modell ohne Schlupf):

| Verdrehung | Wand | Draht | Drehzahl unter Last | Windungen gesamt | Widerstand | Leerlauf-Spitzenspannung | größte Leistung |
|---|---|---|---|---|---|---|---|
| 200° | 1,0 mm | Ø 0,10 | 3610 U/min | 2190 | 44 Ω | 3,1 V | 27 mW |
| 200° | 1,0 mm | Ø 0,08 | 3610 U/min | 3220 | 101 Ω | 4,5 V | 25 mW |
| **300°** | **1,0 mm** | **Ø 0,08** | 5410 U/min | 3220 | 101 Ω | **6,7 V** | **56 mW** |
| 300° | 0,8 mm | Ø 0,08 | 5410 U/min | 3220 | 101 Ω | 7,5 V | 70 mW |

**Hinweis des Nutzers (12.11.2026): Die Strahlen aus dem Baum sind bei 14 l/min ziemlich hart, „fast schmerzhaft".** Im Alltag wird der Hahn deshalb voraussichtlich **teilweise zugedreht**, vermutlich auf 6–8 l/min. Mit größeren Düsen (ø 2,0) werden die Strahlen aber auch bei vollem Durchfluss weicher; dann ist der volle Durchfluss wieder der Normalfall. Beide Fälle bleiben im Entwurf: Ausgelegt wird auf **6–8 l/min** als sicheren Fall, 14,2 l/min ist der gute Fall (56 mW). Für die gewählte Zeile (300°, 1,0 mm, Ø 0,08) gilt (Schätzung):

| Durchfluss | Spitzenspannung | größte Leistung | Druckverlust Baumdüsen | Staudruck im Rotor |
|---|---|---|---|---|
| 4,6 l/min (wie alter Kopf) | 2,2 V | 6 mW | 0,01 bar | 0,015 bar |
| 6 l/min | 2,8 V | 10 mW | 0,01–0,02 bar | 0,025 bar |
| 8 l/min | 3,8 V | 18 mW | 0,02–0,04 bar | 0,044 bar |
| 10 l/min | 4,7 V | 28 mW | 0,04–0,06 bar | 0,07 bar |
| 14,2 l/min | 6,7 V | 56 mW | 0,07–0,13 bar | 0,14 bar |

- Bei 6–8 l/min reicht die Leistung für 3 LEDs (6–12 mW), aber knapp. Die Spannung von 2,8–3,8 V Spitze liegt an der Grenze für parallele LEDs (≈ 3 V). Ein **Spannungsverdoppler** ist dann eingeplant, nicht optional.
- Bei nur 4,6 l/min (Durchfluss des alten Kopfes) leuchten die LEDs voraussichtlich nicht ohne Verdoppler.
- Der Druckverlust im Prüfgriff ist bei diesen Durchflüssen kein Problem mehr (Staudruck unter 0,05 bar). Das Risiko durch 5 m/s gilt nur für den Höchstfall.
- Die Messung am Prüfgriff soll deshalb bei **mehreren Durchflüssen** erfolgen (voll, etwa 8 und etwa 5 l/min).

Gewählt bleiben **300°, 1,0 mm Wand, Ø 0,08 mm** (Zeile 3). Zum Vergleich: Drei gelbe LEDs mit je 1 mA brauchen etwa 6 mW, mit je 2 mA 12 mW, fünf mit je 2 mA 20 mW.

**Ergebnis:** Mit dem gemessenen Durchfluss reicht die Leistung deutlich besser (Faktor ≈ 3 über dem Bedarf von 3–5 LEDs), die Spannung für 3 LEDs in Reihe ist aber noch knapp. Offen ist vor allem der Druckverlust. Der Demonstrator soll das klären. Folgen:

- **LEDs parallel** mit je einem Vorwiderstand (etwa 3 V nötig) bleibt der sichere Start. Eine Reihenschaltung von 3 gelben LEDs braucht etwa 6,8 V (3 × 2 V plus 0,8 V Gleichrichter) und liegt bei ≈ 6,7–7,5 V Spitze genau an der Grenze, unter Last darunter.
- Wenn die Spannung zu klein ist: **Spannungsverdoppler** (2 Dioden, 2 Kondensatoren) hinter dem Generator.
- **Hebel zum Verbessern:** steilere Schaufeln (mehr Drehzahl), dünnere Wand (0,8 mm), größere Magnete (z. B. 5 × 4 × 1,5 mm), eine Eisenrückführung außen, mehr Platz für Kupfer.
- Die frühere Annahme (9 V, 340 Windungen Ø 0,1) war falsch: Die Windungen passen nicht ins Fenster, und das Feld war überschätzt.

Die Unsicherheit liegt bei einem Faktor 2 und mehr. Die Messung entscheidet.

## Bauschritte

Eine ausführliche Bau- und Messanleitung steht in [`anleitung_demonstrator.md`](anleitung_demonstrator.md).

1. **Messen an der Dusche (vor dem Druck):** Durchfluss ohne Kopf, mit Eimer und Stoppuhr: **erledigt am 12.11.2026** (siehe oben). Fließdruck, falls ein Manometer vorhanden ist: offen.
2. **Dichtheitstest zuerst:** Turbinenrohr allein drucken, Auslass verschließen, 4 bar anlegen. Erst wenn es dicht ist, weiterbauen.
3. **Rotor:** drucken, Magnete mit Polung prüfen und einkleben, mit Epoxid überziehen, auf dem Stift von Hand drehen.
4. **Spulen:** 8 Spulen wickeln (Ø 0,08 mm, etwa 400 Windungen), wechselnd gepolt in Reihe schalten, Widerstand messen (Soll etwa 100 Ω gesamt).
5. **Elektronik:** Brückengleichrichter aus 4 Schottky-Dioden, Elko, 3 LEDs parallel mit Vorwiderstand. Zuerst offen auf dem Brett testen.
6. **Messung an der Dusche:** Leerlaufspannung (AC und DC), Strom, Helligkeit, Durchfluss mit und ohne Prüfgriff, Druckverlust.
7. **Vergießen** erst nach erfolgreicher Messung.
8. **Auswerten:** Werte in dieses Dokument eintragen, Schätzungen ersetzen.

## Bauteilliste

Preise sind **Schätzungen**, wenn nicht „Geprüft" dabeisteht. Quellen und Alternativen stehen in [`bauteile.md`](bauteile.md).

| Nr. | Teil | Menge | Zweck | Preis (ca.) | Quelle / Hinweis |
|---|---|---|---|---|---|
| 1 | Neodym-Quader 5 × 4 × 1 mm, N50, vernickelt | 20 (1 Packung) | 8 am Rotor, 12 Reserve | **5,00 € + Versand** | **Geprüft 12.11.2026:** [supermagnete.de Q-05-04-01-N](https://www.supermagnete.de/quadermagnete-neodym/quadermagnet-5mm-4mm-1mm_Q-05-04-01-N), sofort lieferbar (36 480 Stück), 1–3 Arbeitstage. Max. 80 °C. Mindestbestellwert 20 € beachten, daher mit Magnetkleber oder weiteren Teilen kombinieren |
| 2 | Kupferlackdraht Ø 0,08–0,09 mm | 10–100 g | 8 Spulen, ≈ 30 m nötig | 10–16 € | [eBay Müller-Spulen](https://www.ebay.de/itm/135255257425) hatte Ø 0,07 / 0,09 / 0,12 mm auf 100 g, Ø 0,08 mm nicht bestätigt. Bei Ø 0,09 passen etwa 330 Windungen je Spule |
| 3 | Edelstahlstift Ø 2 mm × 70 mm | 2 | Achse, auf **42 mm** kürzen, 1 Reserve | 2–4 € | noch nicht recherchiert |
| 4 | Schottky-Dioden 1N5819 oder BAT54 | 8 | Brückengleichrichter, 4 Reserve (für Verdoppler weitere 2) | 1–2 € | noch nicht recherchiert. DigiKey-Suche zeigte 1N5819 ab 0,33 € pro Stück netto |
| 5 | Elko 47–100 µF, 25 V | 3 | Glättung, Verdoppler | 1–2 € | noch nicht recherchiert |
| 6 | Vorverdrahtete SMD-LED 0603, gelb | 6 | 3 im Test, 3 Reserve | etwa 15 € | [eBay maxi-ledsde](https://www.ebay.de/itm/394858486801), 2,50 €/Stk. |
| 7 | Widerstandssatz 100 Ω – 2,2 kΩ | 1 Satz | Strombegrenzung je LED | ca. 3 € | noch nicht recherchiert |
| 8 | Epoxid-Elektrovergussmasse, ca. 600 g | 1 | Spulen und Elektronik vergießen | 20–30 € | [BEKATEQ BK-250EP](https://www.ebay.de/p/8006001630) oder [Hornbach transparent](https://www.hornbach.de/p/elektrovergussmasse-giessharz-zum-verdichten-von-elektrischen-bauteilen/12723864/). Wärmefestigkeit bis 60 °C im Datenblatt prüfen |
| 9 | PETG (nass, dicht) | 1 Rolle | Gehäuse, Rotor, Leiträder, Kappe | vorhanden? | Anycubic + ACE |
| 10 | PTFE-Dichtband | 1 | Gewinde der Kappe | 1–2 € | |
| 11 | Epoxid-Kleber, 5 min | 1 | Magnete und Stift einkleben | ca. 5 € | noch nicht recherchiert |
| 12 | Multimeter, Messbecher, Stoppuhr | – | Messung | vorhanden? | optional Manometer mit G1/2-T-Stück |

Gesamtkosten grob **55–85 €**, ohne Messmittel und Filament.

**Optional als Vergleich:** ein **nackter** Mini-Generator mit Kabel (AC 2–10 V, M23×1,5 oder M26×1,5, je etwa 10–16 €), um den Eigenbau gegen ein Fertigteil zu messen. Der Fertigteil-Generator liefert laut Angeboten 10–50 mA bei 2–10 V und wäre deutlich stärker. LED-Wasserhahnaufsätze taugen dafür nur, wenn sich der Generator herausnehmen lässt: Die LED ist darin vergossen (Hinweis des Nutzers). Siehe `bauteile.md`, Abschnitt 2.

## Risiken (für den Demonstrator)

- **Spannung und Leistung:** sehr knapp, siehe Rechnung. Gegenmaßnahmen: Verdoppler, steilere Schaufeln, dünnere Wand, größere Magnete.
- **Dichtheit der Spulenwand:** 1,0 mm gedruckte Wand, 100 % Infill, mehr Wände. Erst Drucktest, dann bewickeln.
- **Magnete im Wasser:** nickelbeschichtet, nur für trockene Räume gedacht. Taschen mit Epoxid überziehen.
- **Drehrichtung und Schaufelform:** Die Verdrehung (300°) ist ein Startwert. Leitrad 1 hat gerade Schaufeln (keine Vorverdrallung). Beides am Prüfgriff ausprobieren.
- **Axiallager:** Der Rotor wird vom Wasser gegen das Leitrad 2 gedrückt. Reibung dort kann Drehzahl kosten.
- **Nebenstrom im Spalt:** Zwischen Rotor Ø 14 und Kammer Ø 15 fließt etwas Wasser am Rotor vorbei.
- **Überhänge beim Drucken:** Rotorschaufeln und Gewinde liegen bei etwa 43–45° Überhang. Gute Kühlung, notfalls Gewinde flacher.
- **Druckverlust:** nur geschätzt, der Prüfgriff misst ihn.
- **Magnet-Entmagnetisierung:** Güte N verliert oberhalb von etwa 80 °C Kraft, Duschwasser (bis 60 °C) ist unkritisch.
- **Kalk und Abrieb an der Lagerung:** Lager muss zerlegbar sein, solange nicht vergossen wird.

## Offen beim Nutzer

- Fließdruck an der Dusche (nur mit Manometer möglich; der Durchfluss ist gemessen).
- Bessere Messung des Durchflusses: mehrere Wiederholungen, gleiche Eimermenge (die Versuche haben 3,15–3,5 l).
- Entscheidung, ob parallel ein nackter Spender-Generator bestellt wird.

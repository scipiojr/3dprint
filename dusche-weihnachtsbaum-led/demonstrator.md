# Eigenbau-Demonstrator: Ring-Turbine mit Spulen-Generator

Plan vom **12.11.2026**. Das ist die Umsetzung von „Weg B" aus dem [README](README.md). Alle Zahlen sind **Schätzungen**, gerechnet mit [`werkzeuge/demonstrator_rechnung.py`](werkzeuge/demonstrator_rechnung.py). Gemessen ist noch nichts.

## Ziel

Ein **Prüfgriff ohne Baum**, der an der echten Dusche zeigt:

1. Eine gedruckte Ring-Turbine mit Magneten und vergossenen Spulen läuft bei Duschdurchfluss.
2. Sie liefert genug Strom für eine kurze LED-Kette (Ziel 5 gelbe LEDs, Fallback 3).
3. Der Griff ist **dicht** und der Druckverlust bleibt klein (Ziel 0,05–0,1 bar).

**Erfolgskriterien** (vorab festlegen, damit die Messung eindeutig ist):

| Kriterium | Ziel | Mindestens |
|---|---|---|
| LEDs sichtbar hell bei Duschdurchfluss | 5 LEDs | 3 LEDs |
| Leerlaufspannung (Spitze, nach Gleichrichter) | ≥ 12 V | ≥ 7 V |
| Druckverlust über den Prüfgriff | ≤ 0,1 bar | ≤ 0,2 bar |
| Durchfluss mit Prüfgriff gegenüber ohne | ≥ 90 % | ≥ 75 % |
| Dichtheit | 30 min bei 4 bar trocken | 10 min |

Nicht Ziel des Demonstrators: Baum, Stern, Optik. Das kommt erst nach den Messwerten.

## Aufbau

```
 Stecker │ Einlauf │ Leit │ Rotor-Ring │ Leit │ Auslass+Drossel │
         │         │      │ Magnete    │      │ (≈ 78 mm²)      │
         │         │      │ Spulen in Wand (vergossen)         │
```

Maße (Schätzung, am Modell prüfen):

| Teil | Maß |
|---|---|
| Gehäuse außen | Ø 27 mm (Rahmen des Nutzers: 26–28) |
| Länge Griffteil | 82 mm, wie das Original |
| Rotor-Ring | Ø 14 außen, Ø 9 innen (frei), etwa 25 mm lang |
| Stufen | 1 Rotor und 2 Leitrad-Hälften, später 2–3 Stufen |
| Luftspalt Rotor zu Gehäuse | 0,5 mm |
| Gedruckte Wand zwischen Wasser und Spule | ≥ 0,8 mm, dazu Epoxid |
| Magnete | 8 Stück, alternierend gepolt, in Taschen am Rotor-Außenring |
| Spulen | 8 Taschen in der Gehäusewand, je etwa 4 × 5 mm Fläche, ≈ 3 mm tief |
| Achse | Edelstahlstift Ø 2 mm, an beiden Enden in Speichennaben |
| Auslass | Drossel mit etwa 78 mm² Fläche, bildet die 44 Düsen des Baums nach |

Die engste Stelle vor der Turbine ist die **Stecker-Bohrung Ø 7,94**. Der freie Rotorquerschnitt (Ø 9) liegt darüber, ein Strömungsverlust dort ist also nicht zu erwarten.

## Rechnung (Schätzung)

Annahmen: 8 l/min, Rotor-Innendurchmesser 9 mm, Druckverlust 0,05 bar, 8 Magnete 5 × 4 × 1 mm, je 340 Windungen Ø 0,1 mm, Luftspalt inklusive Wand 1,3 mm.

| Größe | Wert |
|---|---|
| Axialgeschwindigkeit im Rotor | 2,1 m/s |
| Hydraulische Leistung bei 0,05 bar | 667 mW |
| Elektrisch bei 5 / 10 / 20 % | 33 / 67 / 133 mW |
| Drehzahl, elektrische Frequenz | ≈ 2900 U/min, ≈ 190 Hz |
| Windungen gesamt, Drahtlänge | 2720, ≈ 55 m |
| Leerlauf-Spitzenspannung | ≈ 9 V |
| Spulenwiderstand | ≈ 120 Ω |
| Last: 5 gelbe LEDs in Reihe | ≈ 10 V, 2 mA, 20 mW |

**Ergebnis:** Die Leistung reicht, die **Spannung ist knapp**: 9 V Spitze gegen 10 V LED-Kette plus Gleichrichter. Deshalb gilt:

- **Erste Wicklung für 3 LEDs in Reihe** (≈ 6 V), nicht für 5.
- Mehr Spannung ist leicht: mehr Windungen (dünnerer Draht, z. B. Ø 0,08) oder die Spulen paarweise in Reihe. Das entscheidet die Messung der Leerlaufspannung.
- Die Drehzahl hängt am Wirkungsgrad der Schaufeln und ist die größte Unsicherheit. Halbe Drehzahl heißt halbe Spannung.

Eine ausführliche Bau- und Messanleitung steht in [`anleitung_demonstrator.md`](anleitung_demonstrator.md). Dort ist auch beschrieben, wie der Generator ohne Druckstopp angebaut wird (Spulen vorher wickeln, von außen in offene Taschen setzen).

## Bauschritte

1. **Messen an der Dusche (vor dem Druck):** Durchfluss ohne Kopf, mit Eimer und Stoppuhr. Fließdruck, falls ein Manometer vorhanden ist.
2. **Modell:** `pruefgriff.scad` und `rotor.scad`, parametrisch in OpenSCAD. Stecker aus `../dusche-weihnachtsbaum/schnellkupplung_stecker.scad`.
3. **Dichtheitstest zuerst:** Gehäuse allein drucken, Auslass verschließen, 4 bar anlegen. Erst wenn es dicht ist, bewickeln.
4. **Rotor:** drucken, Magnete mit Polung prüfen (Kompass oder zweiter Magnet) und einkleben, Wuchten per Auge, auf dem Stift von Hand drehen.
5. **Spulen:** 8 Spulen wickeln, wechselnd gepolt in Reihe schalten, Widerstand messen (Soll ≈ 120 Ω), in die Taschen setzen.
6. **Elektronik:** Brückengleichrichter aus 4 Schottky-Dioden, Elko, LED-Kette mit Strombegrenzung. Zuerst offen auf dem Brett testen.
7. **Vergießen:** Spulen, Drähte und Elektronik mit Epoxid. Aushärten lassen.
8. **Messung an der Dusche:**
   - Leerlaufspannung (Wechselspannung und nach Gleichrichter) bei Voll- und Halbdurchfluss.
   - Strom und Helligkeit an 3 und 5 LEDs.
   - Durchfluss mit Prüfgriff, daraus der Druckverlust.
9. **Auswerten:** Werte in dieses Dokument eintragen und die Schätzungen oben ersetzen.

## Bauteilliste

Preise sind **Schätzungen**, wenn nicht „Geprüft" dabeisteht. Quellen und Alternativen stehen in [`bauteile.md`](bauteile.md).

| Nr. | Teil | Menge | Zweck | Preis (ca.) | Quelle / Hinweis |
|---|---|---|---|---|---|
| 1 | Neodym-Quader 5 × 4 × 1 mm, N50, vernickelt | 20 (1 Packung) | 8 am Rotor, 12 Reserve | **5,00 € + Versand** | **Geprüft 12.11.2026:** [supermagnete.de Q-05-04-01-N](https://www.supermagnete.de/quadermagnete-neodym/quadermagnet-5mm-4mm-1mm_Q-05-04-01-N), sofort lieferbar (36 480 Stück), 1–3 Arbeitstage. Max. 80 °C. Mindestbestellwert 20 € beachten, daher mit Magnetkleber oder weiteren Teilen kombinieren |
| 2 | Kupferlackdraht Ø 0,10 mm, 100 g | 1 | Spulen, ≈ 55 m nötig, Rest für Versuche | 10–16 € | [eBay Müller-Spulen](https://www.ebay.de/itm/135255257425). Alternativ Ø 0,08 mm für mehr Spannung |
| 3 | Edelstahlstift Ø 2 mm × 70 mm | 2 | Achse, 1 Reserve | 2–4 € | noch nicht recherchiert |
| 4 | Schottky-Dioden 1N5819 oder BAT54 | 8 | Brückengleichrichter, 4 Reserve | 1–2 € | noch nicht recherchiert |
| 5 | Elko 47–100 µF, 25 V | 2 | Glättung | 1 € | noch nicht recherchiert |
| 6 | Vorverdrahtete SMD-LED 0603, gelb | 6 | 5 im Stern-Test, 1 Reserve | etwa 15 € | [eBay maxi-ledsde](https://www.ebay.de/itm/394858486801), 2,50 €/Stk. |
| 7 | Widerstand für die LED-Kette (Wert nach Messung), Satz 100 Ω–2,2 kΩ | 1 Satz | Strombegrenzung | 3 € | noch nicht recherchiert |
| 8 | Epoxid-Elektrovergussmasse, 600 g | 1 | Spulen und Elektronik | 20–30 € | [BEKATEQ BK-250EP](https://www.ebay.de/p/8006001630) oder [Hornbach transparent](https://www.hornbach.de/p/elektrovergussmasse-giessharz-zum-verdichten-von-elektrischen-bauteilen/12723864/). Wärmefestigkeit bis 60 °C im Datenblatt prüfen |
| 9 | PETG (nass, dicht) | 1 Rolle | Gehäuse, Rotor, Leitschaufeln | vorhanden? | Anycubic + ACE |
| 10 | O-Ringe oder Dichtmittel für den Stecker | nach Bedarf | Anschluss zur Schnellkupplung | 2–5 € | Stecker-Maße siehe Hauptprojekt |
| 11 | Epoxid-Kleber, 5 min | 1 | Magnete, Stift | 5 € | noch nicht recherchiert |
| 12 | Messmittel: Multimeter, Messbecher, Stoppuhr | – | Messung | vorhanden? | optional Manometer mit G1/2-T-Stück |

Gesamtkosten grob **60–90 €**, ohne Messmittel und Filament.

**Optional als Vergleich:** ein **nackter** Mini-Generator mit Kabel (AC 2–10 V, M23×1,5 oder M26×1,5, je etwa 10–16 €), um den Eigenbau gegen ein Fertigteil zu messen. LED-Wasserhahnaufsätze taugen dafür nur, wenn sich der Generator herausnehmen lässt: Die LED ist darin vergossen (Hinweis des Nutzers). Siehe `bauteile.md`, Abschnitt 2.

## Risiken (für den Demonstrator)

- **Drehzahl und Spannung:** größte Unsicherheit, siehe Rechnung. Gegenmaßnahme: Wicklung nach der Messung anpassen, deshalb Spulentaschen so bauen, dass sich die Spulen tauschen lassen, solange nicht vergossen ist.
- **Dichtheit der Spulenwand:** 0,8 mm gedruckte Wand, 100 % Infill, mehr Wände. Erst Drucktest, dann bewickeln.
- **Unwucht des Rotors:** eingeklebte Magnete laufen leicht unrund. Zuerst mit der Hand auf dem Stift prüfen.
- **Magnet-Entmagnetisierung:** Güte N verliert oberhalb von etwa 80 °C Kraft, Duschwasser (bis 60 °C) ist unkritisch.
- **Kalk und Abrieb an der Lagerung:** Lager muss zerlegbar sein, solange nicht vergossen wird.
- **Druckverlust:** nur geschätzt. Der Prüfgriff misst ihn, Ziel 0,05–0,1 bar.

## Offen beim Nutzer

- Durchfluss in l/min und Fließdruck an der Dusche.
- Entscheidung, ob parallel ein Spender-Generator (LED-Aufsatz) bestellt wird.

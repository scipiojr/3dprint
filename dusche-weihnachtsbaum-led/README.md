# Weihnachtsbaum-Duschkopf mit LED-Stern und Wasserturbine

Ableger von [`../dusche-weihnachtsbaum`](../dusche-weihnachtsbaum): Der Duschkopf mit Hansgrohe-Schnellkupplung bekommt einen **leuchtenden Stern**. Den Strom liefert eine **eigene Turbine mit Generator im Griff**, also keine Batterie und kein Kabel nach außen.

**Stand: Konzept und Machbarkeit, noch nichts konstruiert oder gedruckt.** Nächster Schritt ist ein Prüfgriff (siehe unten).

## Ziel und Randbedingungen (Vorgaben des Nutzers)

- **Wenige LEDs, zur Not nur der Stern.** Der Nutzer muss es selbst bauen können, und es **muss dicht sein**. Einfachheit und Dichtheit gehen vor Lichtmenge.
- Geschenke unter dem Baum optional mit je 1–2 LEDs, aber nur, wenn die Turbine genug liefert und der Aufbau einfach bleibt.
- Die Elektronik ist nicht Teil des Wasserwegs. Alle Leiter und Bauteile sind vollständig vergossen, und keine Welle führt durch eine Wand nach außen.
- Drucker: Anycubic mit ACE (4 Filamente), Anycubic Slicer Next. Für alles, was nass wird, **PETG statt PLA**.
- Ausgangsmodell, Schnittstelle und Lizenz wie im Hauptprojekt:
  - Stecker aus `../dusche-weihnachtsbaum/schnellkupplung_stecker.scad`.
  - Baum-Netz aus der MakerWorld-Original-3MF. **Nicht einchecken**, das Original steht unter der Standard Digital File License und das Repo ist öffentlich.

## Ergebnisse der Machbarkeitsprüfung (12.11.2026)

### Fertige Hydrogeneratoren passen nicht

Alle marktüblichen Module für G1/2-Leitungen sind viel zu groß für Griff (Ø 21,25) oder Baum. Laut Händlerangaben:

| Modul | Größe | Bemerkung |
|---|---|---|
| Seeed/Beduan-Typ 5 V / 12 V | 86,5 × 49 × 32 mm, 90 g | 3,5–20 l/min bei 0,05–0,2 MPa, max. 150–220 mA |
| DFRobot SEN0229 (5 V) | Maßzeichnung nur als Bild; in derselben Größenklasse | 5 V bei 4 l/min, 0–150 mA, Anlauf 3,5 l/min |
| 3,5-W-Modul mit Magnetkupplung | Ø 85,4 × 42,5 × 81,4 mm | ein Käufer misst unter 1 W bei 3 bar |
| Seeed 3,6 V mit Akku | 84,5 × 64,5 × 81 mm, 165 g | 0,4 bar Druckverlust schon bei 3 l/min |
| Mini-Wind/Wasser-Generator 16 × 16 × 16 mm | passt, aber 0,01–0,2 mA | unbrauchbar |

- Die gekauften Module sind Strahlturbinen (eine Düse auf ein kleines Rad) und brauchen 0,5–2 bar.
- Ein Zwischenstück vor der Schnellkupplung bringt nichts: Die Kupplung hat keine elektrischen Kontakte. Der Generator muss hinter der Kupplung sitzen, also im Griff oder im Baum.

### Platz im Modell (gemessen am Original, Original-Koordinaten, Baumspitze bei +x)

- **Griff:** von x = −97,5 (Stecker-Anlage) bis −15 (Hals), also **82,5 mm lang**, außen Ø 21,25, Bohrung Ø 10. Die Achse liegt bei y = 0, z = −0,625.
- **Stecker:** Bohrung Ø 7,94. Das ist die engste Stelle vor der Turbine.
- **Baumfuß-Hohlraum:**
  - Bei x = 2 ist er 57 mm breit und 12 mm hoch. Bei x ≈ 8 teilen ihn Stege in 5 Kanäle.
  - Nach vorn wird er flacher: bei x = 18 9 mm hoch, bei x = 30 6 mm. Ab etwa x = 75 ist kein Hohlraum mehr.
  - Größter freier Kreis über die Länge: etwa Ø 6 mm. **Für eine Turbine ungeeignet.**
- **Düsen:** 44 Stück, Ø ≈ 1,5 mm, zusammen 78 mm², alle auf der Unterseite (z = −10,6). Bei 8 l/min bremsen sie nur etwa 0,015–0,04 bar, die Turbine wäre also der größte Widerstand.
- **Stern:**
  - Massiv, x ≈ 96–115, etwa 30 mm breit (y ±15,3), **5 mm dick** (z = −10,6 … −5,6).
  - Platz für LED-Taschen 0603/0805 mit etwa 2,5 mm Resthaut.
- **Kabelweg zum Stern:**
  - Der Hohlraum endet etwa 15–25 mm vor dem Stern. Bis dorthin führt ein Kabelkanal von etwa Ø 1,2 mm durch Vollmaterial.
  - Die Wand zwischen Hohlraum und Außenhaut ist mindestens etwa 2,1 mm dick (bei x = 40).

### Energiebilanz (Überschlag, nicht gemessen)

Grenze: Leistung = Druckverlust × Durchfluss × Wirkungsgrad. **Eine längere Turbine erhöht diese Grenze nicht.** Sie verbessert aber den Wirkungsgrad bei wenig Druck und bietet Platz für einen größeren Generator, der langsamer drehen kann.

| Druckverlust | Leistung im Wasser bei 8 l/min | elektrisch bei 15–25 % |
|---|---|---|
| 0,05 bar | 0,67 W | 0,10–0,17 W |
| 0,1 bar | 1,3 W | 0,20–0,33 W |
| 0,2 bar | 2,7 W | 0,40–0,67 W |

Die 15–25 % sind für einen gedruckten Eigenbau optimistisch. Erst die Messung am Prüfgriff zeigt den echten Wert.

LED-Bedarf:
- Gesamtleistung = Anzahl × Strom pro LED × LED-Spannung (Weiß ≈ 3 V, Rot/Gelb ≈ 2 V).
- Moderne LEDs sind bei 1–2 mA gut sichtbar (≈ 3–6 mW).
- **Die Anzahl ist nicht der Engpass.** Engpässe sind:
  1. Grünes PLA/PETG schluckt viel Licht, deshalb sitzen die LEDs hinter durchscheinenden Stellen.
  2. Bei wenig Wasser werden alle LEDs dunkler.
  3. Jede LED bedeutet Drähte, Kanäle, Verguss und eine mögliche Undichtigkeit.

## Konzept: Ring-Turbine und Generator im Griff

```
 Stecker │◄──────────── Griff ≈ 82 mm, Ø 26–28 ────────────►│ Hals → Baum
         │ Nabe │ Leit │ Rotor │ Leit │ Rotor │ Leit │ Rotor │ Nabe │
         │  ●───┼──────┼═══════┼──────┼═══════┼──────┼═══════┼───●  │  Edelstahlstift Ø 2
         │      Spulen (vergossen) in der Griffwand, ≥ 0,8 mm Kunststoff zum Wasser
```

- **Typ:** axiale Turbine mit mehreren Stufen nach dem Prinzip einer Kaplan-Turbine, für wenig Druck und viel Wasser. Jede Stufe nimmt nur einen Teil des Drucks. Ziel ist ein Druckverlust von 0,05–0,1 bar.
- **Rotor:**
  - Durchgehender, gedruckter Ring, etwa Ø 13 außen und 60 mm lang.
  - Innen 3–4 Stufen schraubenförmiger Schaufeln. Außen Magnete in Taschen, z. B. Neodym-Quader oder -Scheiben, wechselnd gepolt.
- **Leitschaufeln:** fest im Griffgehäuse zwischen den Rotorstufen.
- **Lagerung:**
  - Ein Edelstahlstift Ø 2 läuft durch die Rotornabe. Er wird an beiden Enden von Speichennaben gehalten, durch die das Wasser fließt.
  - Gleitlager aus PETG oder eine Messing-/Kunststoffhülse.
- **Generator:**
  - Spulen sitzen in Taschen in der Griffwand, außen über dem Rotor.
  - Sie werden komplett mit Epoxid vergossen. Zwischen Wasser und Spule bleibt eine durchgehende gedruckte Wand von mindestens 0,8 mm. **Keine Wellendurchführung, keine Dichtung.**
- **Elektronik:**
  - Schottky-Brückengleichrichter und Glättungselko, dazu Vorwiderstand oder einfache Stromquelle.
  - Die Spannung legt die Windungszahl fest. Ziel: LEDs in Reihe.
  - Alles sitzt im Verguss in der Griffwand.
- **Folge:** Der Griff wird dicker, **Ø 26–28 mm statt 21,25** (Spulen etwa 3 mm, Luftspalt, Rotor-Ring). **Der Nutzer muss das noch bestätigen.**
- **Kabel zum Stern:** Lackdraht oder Silikonlitze im eigenen Kanal. Der Kanal liegt möglichst im Vollmaterial, also außerhalb des Hohlraums, und wird nach dem Einziehen vergossen.

### LEDs

- Mindestausbau: **5 LEDs im Stern**, in Reihe (warmweiß etwa 15 V, gelb/bernstein etwa 10 V).
  - In den Stern kommen Taschen von unten. Die Oberseite bleibt geschlossen, Resthaut etwa 2,5 mm.
  - Stern aus **durchscheinendem PETG** (eigener ACE-Slot) statt Grün. Sonst kommt kaum Licht durch.
- Optional: je 1–2 LEDs pro Geschenk hinter weißen bzw. durchscheinenden Flächen.
- Kaufteile:
  - Vorverdrahtete SMD-LEDs 0603/0805 für 3 V gibt es mit Lackdraht oder Litze.
  - In die Tasche setzen und mit Epoxid vergießen.

### Mögliche Teileliste (noch nicht festgelegt)

- 6–12 Neodym-Magnete (z. B. 4 × 2 × 1 mm Quader oder Ø 3 × 2 mm Scheiben)
- Kupferlackdraht 0,08–0,12 mm
- Edelstahlstift Ø 2 mm, etwa 70 mm
- Schottky-Brückengleichrichter (z. B. SOT-23 oder 4 × BAT54), Elko 47–100 µF / 25 V, Widerstände
- 5 vorverdrahtete LEDs 0603/0805, warmweiß oder gelb
- Vergussmasse: Epoxid, wasserfest und 60 °C fest
- PETG grün, durchscheinendes PETG für den Stern

## Risiken und offene Fragen

- **Wirkungsgrad und Druckverlust nur geschätzt.** Das muss der Prüfgriff messen.
- **Dichtheit gedruckter dünner Wände:**
  - Mehr Wände und 100 % Infill an der Spulenwand.
  - Zusätzlich Epoxid darüber.
  - Drucktest vor dem Bewickeln.
- Kalk und Abrieb an Lager und Schaufeln. Die Lagerung muss zerlegbar sein.
- Ob der Rotor mit eingeklebten Magneten rund läuft. Unwucht gibt Lärm und Verschleiß.
- Warmwasser bis etwa 60 °C. PETG hält das, ist aber knapp. Epoxid entsprechend wählen.
- Die Lage des Kabelkanals zum Stern muss am Netz geplant werden.
- **Offen beim Nutzer:**
  - Ist ein dickerer Griff (Ø 26–28) in Ordnung?
  - Welche LED-Farbe soll der Stern haben?
  - Wie hoch ist der Fließdruck an seiner Dusche, und wie viele l/min fließen ohne Duschkopf?

## Nächste Schritte

1. **Prüfgriff konstruieren**, ohne Baum:
   - Hansgrohe-Stecker, dicker Griff mit Turbinenkammer, Leitschaufeln und Spulentaschen.
   - Am Ende ein kurzes Auslassstück mit Drossel, die den Baum nachbildet (etwa 78 mm² Düsenfläche).
   - Rotor als eigenes Druckteil.
   - Alles parametrisch in OpenSCAD: `pruefgriff.scad`, `rotor.scad`.
2. Nutzer druckt, bewickelt und misst an der echten Dusche:
   - Leerlaufspannung und Strom an 1 kΩ bzw. an der LED-Kette über dem Durchfluss.
   - Durchfluss mit und ohne Prüfgriff (Eimer und Stoppuhr).
3. Mit den Messwerten Windungszahl und Stufenzahl festlegen.
4. Danach in den Baum übertragen:
   - Griff aus dem Prüfgriff übernehmen, Kabelkanal und Stern-Taschen anlegen.
   - Ein Skript ähnlich `../dusche-weihnachtsbaum/werkzeuge/erzeuge_modell.py` baut das aus der Original-3MF.

## Quellen

- Patente zu Duschköpfen mit Turbine und LED: [US 7387401](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/7387401), [US 9416764](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/9416764)
- [Nuts & Volts: Zerlegter LED-Duschkopf mit Miniturbine](https://nutsvolts.com/blog/post/harvesting_power)
- [DFRobot SEN0229](https://core-electronics.com.au/water-turbine-generator-5vdc.html), [Seeed Micro Water Turbine 5 V](https://core-electronics.com.au/micro-water-turbine-hydroelectric-generator-dc-5v-with-g1-2-thread.html), [cnx-software zu 5/12-V-Mikroturbinen](https://www.cnx-software.com/2020/04/29/power-sensors-and-boards-with-water-using-5v-12v-micro-water-turbines/)
- Maße der Module: [ManoMano 12 V](https://www.manomano.co.uk/p/diy-hydroelectric-water-pump-generator-12v-222282643), [ManoMano 3,5 W](https://www.manomano.co.uk/p/miniature-micro-hydroelectric-dc-water-pipe-generator-93152586), [Electrokit 3,6 V](https://www.electrokit.com/en/micro-hydro-generator-3.6v), [Open Electronics](https://oe2.open-electronics.org/?p=53399)
- Kleine Generatoren: [Mini Wind/Water Generator 16 mm](https://littlebirdelectronics.com.au/products/wind-generator-motor-alternator-0-05-1-5v-dc-16-5x16x16mm-1pc)
- Vorverdrahtete SMD-LEDs: [eBay 0402–1206 3 V](https://www.ebay.de/itm/145816592279), [eBay 0603 Lackdraht](https://www.ebay.de/itm/394858486801)
- Studienprojekt Wasserhahn-Turbine mit Pelton-Rad und Magnetkupplung: [Eco Illuminator](https://www.scribd.com/document/249914432/Report)

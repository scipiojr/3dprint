# Bauteil-Recherche

Stand der Recherche: **12.11.2026**. Preise sind Momentaufnahmen von Händler- oder Marktplatzseiten und schwanken stark, Marktplatzangebote verschwinden oft. Maße stammen aus Händlerangaben, wenn nicht anders vermerkt. **Selbst nachgemessen ist noch nichts.**

Bewertung: ✅ passt / geeignet · ⚠️ mit Einschränkung · ❌ passt nicht

## 1. Fertige Hydrogeneratoren (G1/2-Inline-Module)

Alle sind für den Griff (heute Ø 21,25, künftig etwa Ø 26–28) und für den Baum-Hohlraum (≤ 12 mm hoch) **zu groß**. Außerdem sind es Strahlturbinen, die 0,5–2 bar Druckverlust brauchen.

| Modul | Preis | Maße / Gewicht | Leistung / Daten | Bewertung | Quelle |
|---|---|---|---|---|---|
| DFRobot SEN0229, 5 V geregelt | A$ 13,71–18,85, US$ 17–20, ¥ 1.830, 11,04 € netto | Maßzeichnung nur als Bild; vermutlich wie unten (≈ 85 × 50 × 32) | 5 V bei 4 l/min, 0–150 mA; 2,5 V bei 3,5 l/min; 2,5–20 l/min bei 0,05–0,2 MPa; 0–80 °C | ❌ zu groß | [Core Electronics](https://core-electronics.com.au/water-turbine-generator-5vdc.html), [Little Bird](https://littlebirdelectronics.com.au/products/water-turbine-generator-5vdc), [RobotShop](https://robotshop.com/products/5vdc-water-turbine-generator), [robot-domestici](https://website.robot-domestici.it/product/25677-water-turbine-generator-5vdc) |
| Seeed Micro Water Turbine 5 V / 12 V (G1/2) | Seeed US$ 6,90 (2020), 12 V: £ 8,99, A$ 21,20 | 90 g; Maße nur als Bild | 5 V: 5 V ab 10 l/min, 3–5 V bei 4 l/min; max. 150 mA; Anlauf 0,05 MPa; Spulenwiderstand 10,5 Ω | ❌ | [Core Electronics 5 V](https://core-electronics.com.au/micro-water-turbine-hydroelectric-generator-dc-5v-with-g1-2-thread.html), [Cool Components 12 V](https://coolcomponents.co.uk/collections/all/products/micro-water-turbine-hydroelectric-generator-dc-12v-with-g1-2-thread), [cnx-software](https://www.cnx-software.com/2020/04/29/power-sensors-and-boards-with-water-using-5v-12v-micro-water-turbines/) |
| No-name 5/12/80 V (Beduan, F50 u. a.) | etwa 20–35 € | **86,5 × 49 × 32 mm**, 90 g | 12 V ungeregelt, max. 220 mA Ladestrom | ❌ | [ManoMano 12 V](https://www.manomano.co.uk/p/diy-hydroelectric-water-pump-generator-12v-222282643), [Walmart DB-268](https://www.walmart.com/ip/12424808195) |
| DB-268 (G1/2, 5 V / 12 V / AC) | – | Stutzen 12 mm innen / 20 mm außen, Gewinde 15,5 mm | ≤ 1 W; 3 V bei 3,5 l/min | ❌ | [Walmart](https://www.walmart.com/ip/12424808195) |
| 3,5-W-Modul mit Magnetkupplung | etwa 19–37 $ | **Ø 85,4 × 42,5 × 81,4 mm** | 9,8–18,5 V leer, 128–260 mA an 100 Ω | ❌; ein Käufer misst unter 1 W bei 3 bar | [ManoMano](https://www.manomano.co.uk/p/miniature-micro-hydroelectric-dc-water-pipe-generator-93152586), [Desertcart (Bewertung)](https://www.desertcart.sn/products/15099416-small-portable-micro-hydro-generator-water-charger-hydroelectric-power-3) |
| Mini-Hydrogenerator 9,8–15 V | – | 81 × 58 mm (Ø ohne Anschlüsse), 125 g | 128–260 mA, 1,5–20 l/min | ❌ | [Open Electronics](https://oe2.open-electronics.org/?p=53399) |
| Seeed 3,6 V mit Akku | – | 84,5 × 64,5 × 81 mm, 165 g | **Druckverlust 0,4 bar schon bei 3 l/min**; 700 mA dauernd | ❌, aber wichtiger Vergleichswert für den Druckverlust | [Electrokit](https://www.electrokit.com/en/micro-hydro-generator-3.6v) |
| Mini-Wind/Wasser-Generator | – | 16,5 × 16 × 16 mm | 0,05–1,5 V, **0,01–0,2 mA** | ❌ viel zu schwach | [Little Bird](https://littlebirdelectronics.com.au/products/wind-generator-motor-alternator-0-05-1-5v-dc-16-5x16x16mm-1pc) |

## 2. Geräte mit eingebautem Mikrogenerator (Spender zum Ausschlachten)

**Neuer, wichtigster Fund.** Diese Massenartikel haben deutlich kleinere Generatoren als die Module oben. Den Generator ausbauen, vermessen und in den Griff setzen könnte einfacher und zuverlässiger sein als ein Eigenbau.

| Gerät | Preis | Maße / Gewicht | Daten | Bewertung | Quelle |
|---|---|---|---|---|---|
| LED-Wasserhahnaufsatz mit Temperaturfarbe (viele No-name-Varianten) | etwa 11–17 $ (eBay), Bundles teurer | **33 × 24 × 24 mm, 21 g** bzw. **1,4 × 0,95 × 0,95 in ≈ 36 × 24 × 24 mm** | ohne Batterie, Mini-Turbine; RGB-LED, Temperaturfühler; **≈ 1,5 l/min** | ✅ **Favorit als Spender.** Passt in einen Griff mit Ø 26–28. Ausgelegt nur für Wasserhahn-Durchfluss, siehe Hinweis unten | [ManoMano SNQ](https://www.manomano.co.uk/p/led-light-faucet-nozzle-for-sinklaundry-water-tap-with-temperature-sensor-and-aerator-91773921), [VXB](https://vxb.com/products/lit-water-powered-led-faucet-light-with-temperatur), [eBay-Übersicht](https://www.ebay.com/p/1939299152) |
| Synergy 21 LED RGB Aerator (deutsche Marke, EAN 4038816078872) | Preis nicht ermittelt | 100 g | „batteriefrei, eingebauter Mini-Generator“, 3 Farben nach Temperatur | ✅ in DE erhältlich, Maße unbekannt | [ALLNET-Shop](https://shop-en.allnet.de/Synergy-21-LED-Consumer-RGB-Aerator-Faucet/157595) |
| Goodio 2100, leuchtender Perlator | – | 65 × 39 × 39 mm, 85 g | 0,1–0,4 MPa, **100–200 kg/h (≈ 1,7–3,3 l/min)** | ⚠️ größer | [goodio.be](https://goodio.be/en/product/2100-leuchtender-perlator-mit-farbwechsel) |
| LED-Duschkopf mit Farbwechsel (No-name, Lidl Livarno, Schütte, EISL …) | No-name etwa 10–15 $, Schütte Galaxis 54,99 €, EISL DIGI, Livarno | ganzer Kopf; Generator im Inneren unbekannt groß | **für vollen Duschdurchfluss ausgelegt**, 3–7 LEDs, laut Lidl „kleiner Turbogenerator“ | ✅ **zweiter Spender-Kandidat.** Turbine passt zum Durchfluss, Größe nach dem Zerlegen messen | [Lidl Livarno](https://www.lidl.de/p/livarno-led-handbrause/p100411402), [eBay 7 Farben](https://www.ebay.de/itm/127318586954), [Schütte Galaxis](https://www.ebay.de/p/24064746036), [Nuts & Volts Zerlegung](https://nutsvolts.com/blog/post/harvesting_power) |
| Duschthermometer mit Anzeige (Brannan 18/100 u. ä.) | etwa 10 $ (2017), 18,95 € | **81 × 80,6 × 30 mm**, 75 g, Mutter 1/2″ | Hydrogenerator, LCD 20 × 34 mm, IP65 | ⚠️ als Ganzes zu groß, Generator innen eventuell klein | [Brannan-Datenblatt](https://www.brannan.co.uk/wp-content/uploads/2025/10/Shower-thermometer-digital-18_100-Brannan-product-data-sheet.pdf), [cnx-software](https://cnx-software.com/?p=52163) |
| **Lowenergie Dusch-Timer mit Durchflussmesser** (Hinweis des Nutzers, Amazon B0CY2STKVG) | Amazon-Preis nicht abrufbar; Desertcart AED 118 | nicht ermittelt | selbstversorgt, misst Durchfluss und Temperatur, Display, Farblicht | ⚠️ Beleg, dass Durchflussmessung und Anzeige mit Turbinenstrom gehen. Ein Käufer schreibt, das Gerät brauche eine Mindest-Fallhöhe und passe nicht zu den meisten Duschen, also wohl spürbarer Druckverlust | [Amazon](https://www.amazon.de/dp/B0CY2STKVG) (nicht abrufbar), [Desertcart](https://www.desertcart.ae/products/646751784-shower-timer-with-flow-meter-water-and-energy-saving-coach), [Bewertungen](https://www.desertcart.nl/products/616528552) |

**Hinweis zum Durchfluss bei Wasserhahn-Spendern:** Sie sind für etwa 1,5–3 l/min gebaut, die Dusche braucht etwa 8 l/min. Ganz eingebaut würde der Aufsatz drosseln. Ausweg: Nur ein **Teilstrom** läuft durch den Spender-Generator (Bypass im Griff), der Rest strömt frei daran vorbei. Das muss der Prüfgriff zeigen.

**Einschränkung (Hinweis des Nutzers, 12.11.2026):** In den LED-Wasserhahnaufsätzen ist nur **eine LED** eingebaut, und sie ist **vergossen**. Ob sich der Generator unbeschädigt lösen und an die Spulendrähte kommen lässt, ist **ungeprüft** und eher unwahrscheinlich. Die Bewertung „Favorit als Spender" in der Tabelle oben gilt deshalb nur unter Vorbehalt. Bevorzugt werden **nackte Generatoren mit Kabel** (Gewinde M23×1,5 oder M26×1,5, AC 2–10 V), siehe unten. Aufsätze nur kaufen, wenn die Angebotsfotos oder eine Zerlegung zeigen, dass sich der Generator herausnehmen lässt.

**Fund des Nutzers (12.11.2026): YWBL-WH „Wasserfließender Generator AC2-10V M23x1,5" (Amazon.de, derzeit nicht verfügbar).** Mini-Generator mit **seitlichem Einlass**, ABS, Anschlusskabel mit kleinem Steckverbinder, Ausgangsspannung proportional zum Wasserdruck. Der Händler nennt ihn für Bad und Duscharmaturen. Das ist dieselbe Bauart wie in den LED-Wasserhahnaufsätzen oben. ✅ **Passender Spender, Wunschkandidat für Weg A.**

Maße aus der Zeichnung des Angebots (Screenshot des Nutzers, Händlerangabe, **nicht nachgemessen**): Gewinde M23×1,5; Kopf Ø 23 × 7 mm mit Bund 2,5 mm; Länge ab Bund 24,5 mm; unterer Körper Ø 19,8 mm, davon 14,9 mm Länge. Gesamtlänge also grob 34 mm.

Daten gleicher Bauart bei anderen Anbietern (der Name „YWBL" ist nicht nötig, das Teil ist ein No-name-Standard): AC 2–10 V, 10–50 mA, M23×1,5, Varianten mit seitlichem oder unterem Einlass.
- eBay „Hydro Generator Kit … AC2V-10V 10-50MA M23x1.5": [Angebot](https://www.ebay.com/itm/387291653493)
- Fruugo, **Bottom Inlet**, 15,95 € plus 16,49 € Versand: [Angebot](https://www.fruugo.ie/micro-hydro-generator-kit-electric-water-hydroelectric-power-for-smart-bathroom-ac210v-1050ma-m23x15-bottom-inlet/p-343269084-752194920)
- DEWIN, **M26×1,5**, seitlicher Einlass, AC 2–10 V, 10–50 mA, ABS, Lebensdauer über 3000 h: [Amazon.co.uk](https://www.amazon.co.uk/DEWIN-Generator-M26x1-5-10%E2%80%9150MA-AC2%E2%80%9110V/dp/B0D4Z8RBMN). Anderes Gewinde, also vor dem Kauf Maße prüfen.
- Mdxtog, AC 2–7,5 V, 5–60 mA, 2–10 l/min, 12-mm-Steckanschluss: [Amazon.com](https://www.amazon.com/Generator-2-7-5V-Hydroelectric-Connect-Faucets/dp/B0G2L8TNVR). Anderer Anschluss, größerer Körper.

**Verfügbarkeit geprüft am 12.11.2026 (Browser):** Amazon.de M23×1,5 (YWBL-WH, Bodeneinlass) und Amazon.de M26×1,5 (Eujgoov, seitlicher Einlass, Maße 43 × 31 × 12 mm laut Angebot) sind beide „Derzeit nicht verfügbar". eBay.de findet unter „hydro generator AC2-10V M23x1.5" keine exakten Treffer. Die Angebote bei eBay.com und Fruugo stehen weiter unter „Funde" oben, Lagerbestand dort **nicht bestätigt**.

Offene Punkte (Schätzung, zu messen): Der Generator ist für Wasserhahn-Durchfluss gebaut. Bei etwa 8 l/min drosselt er stark, daher Teilstrom (Bypass) im Griff. Kopf Ø 23 mm braucht einen Griff mit mindestens Ø 26–27 mm außen, der untere Körper Ø 19,8 mm ist unkritisch. Es ist **Wechselspannung** (Gleichrichter nötig), 10–50 mA bei 2–10 V sind laut Angebot der Bereich über den Druck.

## 3. LEDs

| Teil | Preis | Maße / Daten | Bewertung | Quelle |
|---|---|---|---|---|
| 0603-SMD-LED vorverdrahtet, **Kupferlackdraht, als wasserdicht angeboten**, auch gelb / warmweiß | **2,50 €/Stk.** | 20 mA max., 120° | ✅ für den Stern. Trotzdem vergießen | [eBay maxi-ledsde](https://www.ebay.de/itm/394858486801) |
| 0402/0603/0805/1206, 3 V, 30 cm Draht, u. a. gelb und warmweiß | – | 3 V, 120° | ✅ | [eBay Molesmell](https://www.ebay.de/itm/145816592279) |
| 0402 warmweiß, 3 V, 30 cm | 5,54 €/Stk. (30 Stück) | – | ✅ | [eBay](https://www.ebay.de/itm/396107754758) |
| 0603, 12 V mit eingebautem Widerstand, 15 cm | etwa 15 $ (20 Stück) | 9–18 V, 20 mA | ⚠️ einzeln parallel an 12–15 V ohne eigene Vorwiderstände | [eBay Lighthouse LEDs](https://www.ebay.de/itm/163045577950) |
| 0603, 3 V, 25 Stück mit Harz überzogen, 10 cm Litze | – | etwa 2800–3000 K, Widerstände für 3–16 V liegen bei | ✅ | [Desertcart Bowerful](https://www.desertcart.com.cy/products/129296751-25pcs-pre-soldered-micro-litz-wired-leads-pink-smd-led) |
| IP67-LED-Draht WS2812 in Epoxid | – | adressierbar, braucht Controller | ❌ für den Stern übertrieben | [Pimoroni](https://shop.pimoroni.com/en-eu/products/5m-flexible-rgb-led-wire-50-rgb-leds-aka-neopixel-ws2812-sk6812) |

Farbe: Der Stern ist gelb. Entweder **gelbe LEDs** hinter gelbem, durchscheinendem PETG oder warmweiße LEDs hinter Öffnungen bzw. einer transparenten Schicht (siehe README).

## 4. Magnete (für einen eigenen Generator)

Neodym verliert oberhalb von etwa 80 °C (Güte N) dauerhaft Kraft. Duschwasser mit bis zu 60 °C ist unkritisch. Mit Abstand sicherer sind die „H“-Güten.

| Teil | Preis | Daten | Quelle |
|---|---|---|---|
| Würfel 4 mm, N42, vernickelt | 0,26 €/Stk. ab 80, 0,23 € ab 160 | etwa 500 g Haftkraft | [supermagnete W-04-N](https://www.supermagnete.fr/eng/shop_form.php?id=W-04-N) |
| Quader 5 × 4 × 1 mm, N50 | – | etwa 350 g, 0,15 g | [supermagnete Q-05-04-01-N](https://www.supermagnete.se/eng/block-magnets-neodymium/block-magnet-5mm-4mm-1mm_Q-05-04-01-N) |
| Quader 6 × 4 × 2 mm, **44H, hitzebeständig** | – | etwa 640 g | [supermagnete Q-06-04-02-HN](https://www.supermagnete.es/eng/block-magnets-neodymium/block-magnet-6mm-4mm-2mm_Q-06-04-02-HN) |
| Scheiben Ø 3 × 2 / Ø 4 × 2 mm, N45 | ab 6,60 € je Packung | 236 g / 372 g | [eBay Magnet-Kauf](https://www.ebay.de/itm/182835892727) |
| Quader von 2 × 2 × 1 bis 6 × 6 × 4 mm, N52 | Preis je Packung, je nach Menge | große Auswahl | [eBay HKIT](https://www.ebay.de/itm/306192649826) |

## 5. Spulendraht

| Teil | Preis | Daten | Quelle |
|---|---|---|---|
| Block CUL100, Ø 0,10 mm, 1144 m | CHF 9,06 | PUR-Lack, bis 155 °C, lötbar | [RS](https://st1-chen.rs-online.com/web/p/copper-wire/3377088) |
| Kupferlackdraht Ø 0,1 mm, 10 m | – | 38 AWG, 3,5 g | [digitec Purecrea](https://www.digitec.ch/de/s1/product/purecrea-kupferlackdraht-kupferdraht-d01mm-10m-elektronikkabel-stecker-38686914) |
| Kupferlackdraht Ø 0,04–1,3 mm, Meterware | ab 1,49 € | Durchmesser wählbar | [eBay](https://www.ebay.de/itm/335687034350) |
| Spulendraht CUL 0,10 mm, 100 g | etwa 10–16 € | – | [eBay Müller-Spulen](https://www.ebay.de/itm/135255257425) |

## 6. Vergussmasse

| Teil | Preis | Daten | Quelle |
|---|---|---|---|
| BEKATEQ BK-250EP 2K-Epoxid-Elektrovergussmasse, farblos | 29,90 € / 600 g | bis 1000 V geprüft | [eBay](https://www.ebay.de/p/8006001630), [Datenblatt](https://www.bekateq.de/datenblatt/BK-250EP_2K_Vergussmasse_Elektronik_TDB.pdf) |
| Elektrovergussmasse transparent (Hornbach) | 19,99 € | transparent | [Hornbach](https://www.hornbach.de/p/elektrovergussmasse-giessharz-zum-verdichten-von-elektrischen-bauteilen/12723864/) |
| Epoxid-Gießharz Elektroverguss 600 g, transparent | 21,90 € | – | [eBay otto-beschichtungsshop](https://www.ebay.de/p/1965021139) |
| MG Chemicals 832C, transparent, 375 ml | 47,17 € | Profi-Ware | [RS](https://de.rs-online.com/web/p/vergussmasse/9184986) |

Wärmefestigkeit für Warmwasser (bis 60 °C) im Datenblatt prüfen. Kleine Mengen (25–50-ml-Doppelkartusche) reichen für das Projekt.

## 7. Sonstiges (noch nicht recherchiert)

- Edelstahlstift Ø 2 mm × etwa 70 mm (Achse)
- Schottky-Dioden (z. B. BAT54, 1N5819) bzw. Brückengleichrichter, Elko 47–100 µF / 25 V, Widerstände
- PETG transparent bzw. gelb transluzent für den Stern
- Messmittel: Multimeter, Messbecher und Stoppuhr für den Durchfluss, optional Manometer mit G1/2-T-Stück

## Empfohlene Erstbestellung zum Ausprobieren

1. **1–2 LED-Wasserhahnaufsätze** (etwa 10–15 € pro Stück): zerlegen, Generator vermessen (Durchmesser, Länge, Spannung, Strom).
2. **1 billiger LED-Duschkopf** (etwa 10–15 €): Generator für vollen Duschdurchfluss zerlegen und vermessen.
3. **5–10 vorverdrahtete 0603-LEDs gelb** (etwa 2,50 € pro Stück).
4. **Kleine Packung Elektrovergussmasse** (etwa 20 €).

Mit den Maßen der Spender-Generatoren entscheiden wir, ob der Prüfgriff einen Spender-Generator aufnimmt oder ob wir selbst bauen (Magnete, Draht, Achse).

# Pooldach für Bestway 56448 – Vorlagen Version 3

Satteldach für den ovalen Frame-Pool Bestway Power Steel 56448 (488 × 305 × 107 cm) aus HT-Rohren DN 50. Zwei Hubs (Knotenpunkte) sitzen in den Mittelpunkten der Poolrundungen und sind über den First verbunden. Von jedem Hub laufen fünf Gratstangen zu Randhaltern, die auf das obere Rahmenrohr geclipst werden.

## Dateien

| Datei | Inhalt |
|---|---|
| `pool_hub_v3.scad` | Hub mit fünf schwenkbaren Nasen (Stangenaufnahmen) und festem First-Zapfen. Print-in-place, 2 Stück. |
| `pool_randhalter_v3.scad` | Randhalter: Rohr-Clip, Gelenkgabel mit Stangenzapfen, Steckachse und Riegel. 10 Stück. |
| `export_randhalter_teile_v3.bat` | Exportiert die vier Randhalter-Teile als getrennte STL-Dateien (Windows). |
| `pooldach_rechner.html` | Rechner für Zuschnitt, Hub-Peilungen, Plane und Einkaufszettel. |
| `montageplan.png` | Lage von Hubs, Clips und Stangen in der Draufsicht (Stangenlängen: Rechner verwenden). |
| `bilder/` | Vorschaubilder von Hub, Gabel, Neigegelenk und Steckachse. |

Beide Vorlagen sind parametrisch und für den Customizer von OpenSCAD 2021.01 ausgelegt.

## Vorgehen

1. Am Pool messen (Pfostenmitte zu Pfostenmitte, Höhe Rahmenrohr): Länge der Geraden, Breite, Gesamtlänge.
2. Werte im Rechner eintragen, Firsthöhe wählen. Der Rechner liefert Zuschnitt, Plane, Einkaufszettel und die Werte für den Hub.
3. In `pool_hub_v3.scad` die Peilungen, den Kragenradius und ggf. die Beschriftung aus dem Rechner übernehmen.
4. Randhalter-Teile exportieren: im Customizer `teil` 1 bis 4 einzeln wählen oder die Batch-Datei starten.
5. Drucken, Gelenke nach dem Druck einmal vollständig durchbewegen.
6. Montage nach Montageplan.

## Druck

- Alle Teile werden flach liegend gedruckt, ohne Stützmaterial.
- Hub: ca. 245 × 245 mm, auf dem Bett um 45° gedreht (`druck_drehung`). Passt auf ein 260 × 260 mm-Bett.
- Material: PETG oder ASA (UV-beständig). PLA wird in der Sonne weich.
- Neigegelenk Bauart `scheibe`: Der Stangenkopf haftet nach dem Druck leicht an; mit etwas Kraft lösen. Geht es zu schwer, `scheibe_spalt` auf 0,6–0,7 mm erhöhen.
- Im Slicer die STL-Dateien als getrennte Objekte laden (Abfrage „mehrteiliges Objekt?“ mit Nein beantworten).

## Montage

- Clips sitzen 7 cm neben den Pfosten (Übergangsstücke freihalten), Seiten gemäß Montageplan: 2a auf der Geraden, 2b auf der Schräge zur Spitze hin, 2c neben der Spitze (an beiden Enden punktsymmetrisch).
- Steckachse bei geöffnetem Clip von innen durch Flansch und Gabel stecken, Riegel seitlich einschieben, bis er einrastet. Schraubversion: M8 × 30 DIN 912 mit Stoppmutter, nach dem Ausrichten mit ca. 4–5 Nm anziehen.
- Clip-Arm zur Stange hin drehen. Clips 2b und 2c mit Kabelbinder oder Abstandshülse gegen Verrutschen sichern.
- Rohre auf den Zapfen mit Schraube M5 durch die Querbohrung sichern (Windsog).
- First mit Alu-Innenrohr 40 × 2 verstärken. Das Dach ist nicht für Schneelast ausgelegt.

## Parameter `pool_hub_v3.scad`

**Kranz-Zapfen (Dachstangen)**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `kranz_zapfen_d` | `44.3` | 32 … 60 | Zapfendurchmesser [mm]; 44,3 = Innenmaß HT-Rohr DN 50, 50 = Muffe |
| `kranz_zapfen_laenge` | `40` | 25 … 80 | Zapfenlänge [mm] |
| `kranz_kragen_radius` | `88` | 80 … 200 | Kragenradius (Abstand Hubmitte bis Zapfenkragen) [mm]; größer = größerer Hub |

**First-Zapfen**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `first_zapfen_d` | `44.3` | 32 … 60 | Zapfendurchmesser [mm] |
| `first_zapfen_laenge` | `40` | 25 … 80 | Zapfenlänge [mm] |
| `first_kragen_radius` | `62` | 50 … 150 | Kragenradius (Abstand Hubmitte bis Zapfenkragen) [mm] |

**Peilungen**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `kranz_peilungen` | `[95.4, 49.1, 4.0, -49.1, -95.4]` |  | Peilungen (Richtung jeder Dachstange ab Hubmitte) [°]; 0 = Poolspitze, ±90 = quer; Werte aus dem Pooldach-Rechner |
| `first_peilung` | `180` |  | Peilung des Firsts [°]; 180 = zum zweiten Hub |

**Gelenke**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `gelenk_radius` | `62` | 50 … 110 | Gelenkradius (Abstand Hubmitte bis Gelenkachse) [mm] |
| `zunge_b` | `20` | 16 … 30 | Breite der Zunge (beweglicher Teil der Nase) [mm] |
| `wange_t` | `6` | 4 … 10 | Wangendicke (feste Wand neben der Zunge) [mm] |
| `kegel_r` | `10` | 6 … 14 | Radius der Lagerkegel (halten die Zunge in den Wangen) [mm] |
| `kegel_h` | `5` | 3 … 7 | Höhe der Lagerkegel [mm] |
| `gelenk_spiel` | `0.48` | 0.3 … 0.7 | Gelenkspiel (Luftspalt zwischen beweglichen Teilen) [mm]; bei klemmendem Gelenk erhöhen |

**Gestaltung**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `fase` | `1.5` | 0 … 3 | Fase (abgeschrägte Kante) am Hub-Körper [mm]; 0 = scharfkantig |
| `zungen_fase` | `1.0` | 0 … 2 | Fase an den Zungen [mm] |
| `taschen_tiefe` | `1.5` | 0 … 3 | Taschentiefe (flache Vertiefung auf den Keilen) [mm]; 0 = keine Taschen |
| `taschen_rand` | `3.5` | 2 … 8 | Taschenrand (Abstand zu Außenkante und Wangen) [mm] |
| `taschen_ecke` | `2` | 0 … 6 | Eckenradius der Taschen [mm] |
| `mitte_d` | `40` | 0 … 60 | Durchmesser des Mittellochs [mm]; 0 = kein Loch |
| `rundung_r` | `3` | 0 … 8 | Eckenradius der senkrechten Außenkanten [mm]; 0 = eckig |
| `kehle_r` | `3` | 0 … 6 | Hohlkehle (Innenrundung) zwischen Zunge und Kragen [mm]; wird auf den freien Platz begrenzt |
| `rillen_tiefe` | `0.6` | 0 … 1.2 | Tiefe der Zierrillen [mm]; nur aktiv ohne Taschen bzw. ohne Beschriftung |
| `beschriftung_tiefe` | `0.6` | 0 … 1.2 | Gravurtiefe der Beschriftung [mm]; 0 = keine Beschriftung |
| `kranz_texte` | `["2a", "2b", "2c", "2b", "2a"]` |  | Beschriftung der Zungen, Reihenfolge wie die Peilungen |
| `first_text` | `"56448"` |  | Beschriftung des First-Arms |
| `schrift_h` | `7` | 4 … 10 | Schrifthöhe [mm] |

**Zapfensicherung**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `sicherung_d` | `5.5` | 0 … 8 | Querbohrung für Sicherungsschraube durch Rohr und Zapfen [mm]; 0 = keine |
| `zapfen_druckfase` | `true` | false / true | Druckfase (45°-Abflachung unten am Zapfen, druckbar ohne Stützen) |

**Druck**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `druck_drehung` | `45` | 0 … 90 | Drehung auf dem Druckbett [°]; bei 45° passt der Hub auf 260 × 260 mm |

**Ansicht**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `vorschau_neigung` | `0` | -10 … 70 | Zungen in der Vorschau geneigt darstellen [°]; zum Export 0 |

## Parameter `pool_randhalter_v3.scad`

**Ausgabe**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `teil` | `0` | 0:alles / 1:Clip / 2:Gabel mit Stange / 3:Steckachse / 4:Riegel | Auszugebendes Teil; zum Export jedes Teil einzeln wählen |
| `gabel_versatz` | `[125, -10]` |  | Lage der Gabel neben dem Clip bei „alles“ [mm] |
| `achse_versatz` | `[70, -75]` |  | Lage von Steckachse und Riegel bei „alles“ [mm] |
| `vorschau_montage` | `false` | false / true | Montagevorschau (Teile zusammengebaut, nicht zum Export) |
| `vorschau_gier` | `12` | -60 … 60 | Gierwinkel (Drehung der Gabel um die Armachse) in der Montagevorschau [°] |

**Testdrucke**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `nur_passring` | `false` | false / true | Nur Passring (5 mm hoher Clip-Ring zum Testen des Sitzes am Rohr) |
| `nur_passbolzen` | `false` | false / true | Nur Passbolzen (5 mm Zapfenscheibe zum Testen des Sitzes in der Muffe) |

**Rohr-Clip**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `rohr_d` | `49.5` | 34 … 70 | Außendurchmesser des Poolrohrs [mm] |
| `klemm_untermass` | `2.0` | 0 … 4 | Klemm-Untermaß (Clip-Innendurchmesser kleiner als Rohr) [mm]; größer = fester |
| `wandstaerke` | `8.25` | 7 … 12 | Wandstärke des Clip-Rings [mm] |

**Stangen-Zapfen**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `zapfen_d` | `50` | 32 … 60 | Zapfendurchmesser [mm]; 50 = Muffe HT DN 50 |
| `zapfen_laenge` | `55` | 30 … 80 | Zapfenlänge [mm] |
| `sicherung_d` | `5.5` | 0 … 8 | Querbohrung für Sicherungsschraube durch Muffe und Zapfen [mm]; 0 = keine |

**Drehgelenk (Clip – Gabel)**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `drehgelenk` | `true` | false / true | Drehgelenk (Gabel dreht um die Armachse); aus = Stange direkt am Clip |
| `verbindung` | `"steckachse"` | steckachse / schraube | Verbindung Clip – Gabel: gedruckte Steckachse oder Schraube M8 |
| `flansch_abstand` | `12.5` | 10 … 25 | Flanschabstand (Anlagefläche der Gabel über dem Clip-Ring) [mm] |
| `flansch_halbbreite` | `20` | 16 … 25 | Halbe Breite von Flansch und Gabel [mm] |
| `sockel_t` | `20` | 16 … 26 | Sockeldicke der Gabel [mm] |
| `fase` | `1.2` | 0 … 2 | Fase (abgeschrägte Kante) an Flansch und Gabel [mm] |

**Steckachse**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `achse_d` | `12` | 10 … 16 | Schaftdurchmesser [mm] |
| `achse_kopf_d` | `20` | 16 … 26 | Kopfdurchmesser [mm] |
| `achse_kopf_h` | `6` | 4 … 8 | Kopfhöhe [mm] |
| `achse_spiel` | `0.3` | 0.2 … 0.6 | Spiel (Luftspalt) in den Bohrungen [mm] |
| `achse_spalt` | `0.5` | 0.3 … 1.5 | Spalt zwischen Flansch und Gabel [mm] |
| `nut_tiefe` | `2` | 1.5 … 3 | Tiefe der Nut für den Sicherungsriegel [mm] |
| `riegel_t` | `3` | 2.5 … 4 | Riegeldicke [mm] |
| `nut_lage` | `6` | 4 … 10 | Lage der Nut ab Anlagefläche der Gabel [mm] |

**Schraubversion**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `scheibe_t` | `1.6` | 0 … 3 | Dicke der Unterlegscheibe [mm] |
| `schraube_d` | `8` | 6 … 10 | Schraubendurchmesser [mm]; M8 = 8 |
| `kopf_d` | `13` | 10 … 17 | Kopfdurchmesser der Zylinderschraube [mm]; M8 = 13 |
| `kopf_h` | `8` | 5 … 10 | Kopfhöhe der Zylinderschraube [mm]; M8 = 8 |
| `mutter_sw` | `13` | 10 … 17 | Schlüsselweite der Mutter [mm]; M8 = 13 |
| `mutter_h` | `8` | 5 … 10 | Höhe der Sicherungsmutter [mm]; M8 = 8 |
| `mutter_abstand` | `4` | 3 … 8 | Lage der Mutter ab Anlagefläche der Gabel [mm] |

**Gestaltung**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `taschen_tiefe` | `1.5` | 0 … 3 | Taschentiefe (flache Vertiefung auf der Gabel) [mm]; 0 = keine |
| `taschen_rand` | `3` | 2 … 6 | Taschenrand (Abstand zu Außenkante und Gelenk) [mm] |
| `taschen_ecke` | `2` | 0 … 5 | Eckenradius der Tasche [mm] |
| `rundung_r` | `2` | 0 … 4 | Eckenradius der senkrechten Außenkanten an Flansch und Gabel [mm]; 0 = eckig |

**Neigegelenk (Stange)**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `neigegelenk` | `"scheibe"` | scheibe / knoechel | Bauart: scheibe (bewährt, nach dem Druck mit etwas Kraft lösen) oder knoechel (drei Kegelknöchel, ungetestet) |
| `scheibe_spalt` | `0.48` | 0.3 … 1.0 | Nur scheibe: Spalt über und unter dem Stangenkopf [mm]; größer = leichter zu lösen |
| `ng_r` | `12` | 9 … 15 | Nur knoechel: Knöchelradius [mm] |
| `ng_hk` | `8` | 4 … 10 | Nur knoechel: Kegelhöhe zwischen den Knöcheln [mm] |
| `ng_hals` | `8.4` | 6 … 10 | Nur knoechel: halbe Halsbreite (Ansatz an den Knöcheln) [mm]; kleiner = größerer Schwenkbereich |

**Spiel und Druckstellung**

| Parameter | Vorgabe | Bereich | Bedeutung |
|---|---|---|---|
| `spiel` | `0.4` | 0.25 … 0.6 | Spiel (Luftspalt) in Clip-Scharnier und Verschluss [mm] |
| `gelenk_spiel` | `0.48` | 0.3 … 0.7 | Spiel im Neigegelenk [mm] |
| `zahn_hoehe` | `1.3` | 0.8 … 2.0 | Höhe des Rastzahns im Verschluss [mm]; größer = rastet fester |
| `druck_offen` | `46` | 30 … 60 | Öffnungswinkel des Clips in Druckstellung [°] |
| `stangen_winkel` | `132.8` | 45 … 135 | Winkel der Stange in Druckstellung [°] |

## Hinweise und Grenzen

- Die Vorgaben der Peilungen gelten für Pfostenmitten 263 × 280 cm und 466 cm Gesamtlänge (aus Anleitung und Skizze abgeleitet). Vor dem Druck des Hubs nachmessen und mit dem Rechner neu berechnen.
- Firsthöhe bis etwa 1 m. Darüber kommen sich benachbarte Nasen am Hub zu nahe (der Rechner warnt ab 38° Stangenneigung).
- Die Hohlkehle am Kragen wird durch den Schwenkbereich der Wangen auf etwa 1 mm begrenzt. Größer nur mit größerem `kranz_kragen_radius`, dann passt der Hub nicht mehr auf ein 260-mm-Bett.
- Neigegelenk Bauart `knoechel` ist konstruiert und am Modell geprüft, aber noch nicht gedruckt.
- Die Beschriftung nutzt die mit OpenSCAD ausgelieferte Schrift „Liberation Sans Bold“.

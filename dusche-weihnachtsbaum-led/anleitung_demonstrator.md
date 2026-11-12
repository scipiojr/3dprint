# Anleitung: Griff-Demonstrator bauen

Stand **12.11.2026**. Gehört zu [`demonstrator.md`](demonstrator.md) (Plan, Rechnung, Bauteilliste). Alle Maße sind **Schätzungen** und werden am fertigen Modell geprüft.

> **Wichtig:** Die Druckmodelle (`pruefgriff.scad`, `rotor.scad`) gibt es noch nicht. Diese Anleitung legt den Aufbau fest, nach dem sie konstruiert werden. Schritte 1–3 und 5 (Messen, Wickeln, Elektronik) können Sie schon vorbereiten.

## 1. Wie kommt der Generator in den Griff, ohne den Druck zu unterbrechen?

Gar nicht „in" den Druck. Der Griff wird **aus getrennten Teilen** gebaut, und der Generator wird nachträglich **von außen** angebaut. Drei Regeln:

1. **Das Wasserrohr ist ein eigenes, geschlossenes Teil.** Es trägt Stecker, Einlauf-Leitrad und eine dünne Wand (0,8–1,0 mm) zu den Spulen. Es wird in einem Stück gedruckt, ohne Einlegeteile, und als Erstes auf Dichtheit geprüft.
2. **Die Spulen werden vorher gewickelt und von außen eingesetzt.** Sie liegen in offenen Taschen eines **Spulenrings**, der nach dem Druck über das Rohr geschoben wird. Es muss nichts im Druck eingebettet werden.
3. **Rotor, zweites Leitrad und Drossel kommen von der Auslassseite.** Eine Schraubkappe hält sie. Der Rotor lässt sich jederzeit herausnehmen.

So bleibt auch alles **tauschbar**, bis Sie die Messwerte haben: Spulen mit einem Tropfen Sekundenkleber einkleben, messen, erst danach vergießen.

```
 Stecker  Einlauf+            Rotor mit Magneten          Leitrad 2   Kappe + Drossel
 ───┐     Leitrad 1 ┌─────────────────────────────┐      ┌───┐       ┌──────┐
    │  ┌───┬────────┤ ●  ●  ●  ●  ●  ●  ●  ●      ├──────┤   ├───────┤ ░░░░ │→ Wasser
    │  │   │  Pin Ø2 ══════════════════════════════   Pin   │   │       │ ░░░░ │
 ───┘  └───┴────────┤                             ├──────┴───┘       └──────┘
         Turbinenrohr (Wand 0,8–1,0 mm, dicht)
                    ╔═══ Spulenring, 8 Taschen von außen offen ═══╗  ← aufgeschoben
                    ╚═════════ Außenhülse ═══════════════════════╝  ← darüber
```

## 2. Druckteile

Material **PETG** (nicht PLA), 0,2 mm Schicht, Düse 0,4 mm.

| Nr. | Teil | Wasserführend | Druckhinweis (Schätzung) |
|---|---|---|---|
| A | **Turbinenrohr** mit Stecker und Einlauf-Leitrad 1 | ja | Stehend drucken, Stecker unten. 4–5 Wände, 100 % Infill. Innen Ø 15, außen Ø 16,6–17. Gewinde am Auslass. |
| B | **Spulenring** | nein | Innen Ø ≈ Rohr + 0,2 mm Spiel. 8 radiale Taschen, je 4 × 5 mm, ≈ 3 mm tief, offen nach außen. Nut für die Drähte, ein Loch für das Kabel nach außen. |
| C | **Außenhülse** | nein | Schiebt über den Spulenring und hält den Verguss. Wand ≈ 1,2 mm. Außen-Ø ≈ 26. |
| D | **Rotor** | ja | Ring Ø 14 außen, Ø 9 innen frei, ≈ 25 mm lang, innen schraubenförmige Schaufeln. 8 Magnettaschen außen, ≈ 1,3 mm tief. Wenn möglich mit dem Ring stehend drucken. |
| E | **Leitrad 2** (Einsatz) | ja | Wird von der Auslassseite eingeschoben, Nabe mit Loch Ø 2 für den Stift. |
| F | **Auslasskappe** | ja | Schraubt auf das Rohr. Nimmt die Drossel auf. |
| G | **Drossel-Scheiben** (2 Varianten) | ja | Variante 1: ein Loch Ø 10 (≈ 78 mm²). Variante 2: 44 Löcher Ø 1,5 mm wie im Baum. Erst Variante 1. |

Die **Magnete im Rotor liegen im Wasser.** Nickelbeschichtete Neodym-Magnete sind nur für trockene Räume gedacht. Deshalb: Taschen nach dem Einkleben mit einer dünnen Schicht Epoxid (etwa 0,3 mm) **überziehen**, bis kein Metall mehr frei liegt.

## 3. Schritt für Schritt

### 3.1 Vorarbeit (Dusche messen)
Durchfluss und Fließdruck wie im Chat beschrieben (Eimer und Stoppuhr, optional Manometer). Werte in `demonstrator.md` eintragen.

### 3.2 Dichtheit zuerst (Teil A)
1. Turbinenrohr drucken. Auslass mit Kappe ohne Drossel **verschließen** (Stopfen oder Kappe mit Dichtband).
2. An die Dusche anschließen, Wasser aufdrehen, **30 Minuten** bei vollem Druck beobachten. Papiertuch unterlegen.
3. Nur wenn es trocken bleibt, weiterbauen. Sonst: mehr Wände, Wandstärke erhöhen, Temperatur/Fluss anpassen, neu drucken.

### 3.3 Spulen wickeln (vor dem Anbau)
Das ist der Schritt, der **nicht im Druck** stattfindet.
1. **Wickelkern:** ein kleiner Spulenkörper (4 × 5 mm Kern, Flansche 1 mm) aus PETG, alternativ ein dünner Stift mit Kern 4 × 5 mm, den man später herauszieht.
2. **Wickeln:** 8 Spulen, je **etwa 340 Windungen** Kupferlackdraht Ø 0,1 mm. Kern in Akkuschrauber oder Bohrmaschine einspannen, **langsam** drehen, Draht mit zwei Fingern bremsen. 0,1 mm reißt leicht. Windungen laut Zählung mitzählen (Strichliste oder Handy-Zähler). Alle Spulen **in gleicher Richtung** wickeln.
3. Spule mit einem Tropfen Sekundenkleber fixieren, Anfang und Ende je ≈ 4 cm Draht stehen lassen.
4. Pro Spule **Widerstand messen.** Soll ≈ 15 Ω (gesamt etwa 120 Ω bei 8 Spulen, Schätzung). Starke Abweichung heißt Windungsfehler oder Bruch.

### 3.4 Rotor bauen (Teil D)
1. Magnetpolung festlegen: **abwechselnd N und S nach außen.** Mit einem Kompass oder einem zweiten Magneten prüfen, nicht raten. Jede Tasche mit Filzstift mit „N" oder „S" markieren.
2. Magnete mit Epoxid-Kleber einkleben, auf die Polung achten, aushärten lassen.
3. Magnetflächen mit dünner Epoxidschicht überziehen (siehe oben), wieder aushärten.
4. Rotor auf den Edelstahlstift Ø 2 stecken: Er muss **leicht und ohne Schleifen** drehen. Wenn er schleift, Tasche oder Stift nacharbeiten.

### 3.5 Zusammenbau
1. Stift in die Nabe von Leitrad 1 stecken (Teil A).
2. Rotor aufstecken, Leitrad 2 (E) von der Auslassseite einschieben, bis der Stift in der Nabe sitzt.
3. Kappe (F) mit Drossel (G) aufschrauben. Gewinde mit Dichtband abdichten, sonst verfälscht Leckwasser die Messung.
4. **Trockentest:** Rohr senkrecht, durch das Rohr blasen. Der Rotor muss mitlaufen.

### 3.6 Spulenring und Verschaltung
1. Spulenring (B) über das Rohr schieben, über der Magnetposition des Rotors ausrichten.
2. Spulen von außen in die 8 Taschen setzen. **Nur mit einem Tropfen Sekundenkleber**, nicht vergießen.
3. **Reihenschaltung mit wechselnder Polung.** Alle Spulen sind gleich gewickelt, daher abwechselnd Ende mit Ende und Anfang mit Anfang verbinden:
   ```
   A ─ Anfang1…Ende1 ─ Ende2…Anfang2 ─ Anfang3…Ende3 ─ Ende4…Anfang4 ─
       Anfang5…Ende5 ─ Ende6…Anfang6 ─ Anfang7…Ende7 ─ Ende8…Anfang8 ─ B
   ```
4. Lack an den Drahtenden abschaben oder mit 380 °C Lötkolben abbrennen, verzinnen, verlöten. Mit dem Multimeter den **Gesamtwiderstand** prüfen (≈ 120 Ω).
5. Zwei dünne Silikonlitzen (≈ 30 cm) an A und B löten, durch das Loch im Ring nach außen führen. Außenhülse (C) aufschieben.

### 3.7 Elektronik (offen auf dem Brett)
```
 A ──┬──►|──┬── + ──┬──── 100 Ω…1 kΩ ── LED ── LED ── LED ──┐
     │      │       │                                       │
     └──|◄──┼───────┤  Elko 47–100 µF                       │
 B ──┬──►|──┘       │                                       │
     └──|◄──────────┴───────────────────────────────────────┘ −
```
Vier 1N5819 als Brücke, Elko parallel zur Last, LED-Kette mit Vorwiderstand. **Erst 3 LEDs** (≈ 6 V), später 5.

### 3.8 Messen
1. Dusche aufdrehen (Vollstrom): **Leerlaufspannung** (AC) an A–B messen, dann nach dem Gleichrichter (DC).
2. Das Gleiche bei halbem Durchfluss.
3. **Strom** an der LED-Kette (Multimeter in Reihe, mA-Bereich).
4. Helligkeit der LEDs beurteilen.
5. **Durchfluss mit und ohne Griff** mit Eimer und Stoppuhr. Daraus der Druckverlust, genauer mit Manometer vor dem Griff.
6. Werte in `demonstrator.md` eintragen. Auswertung dann mit [`werkzeuge/demonstrator_rechnung.py`](werkzeuge/demonstrator_rechnung.py).

### 3.9 Vergießen (erst nach erfolgreicher Messung)
1. Wenn die Spannung passt: Spulen, Lötstellen und Kabelaustritt mit Epoxid vergießen. Außenhülse als Form.
2. Aushärten lassen (Herstellerangabe beachten, Wärmefestigkeit bis 60 °C im Datenblatt prüfen).
3. Erneut messen, ob sich nichts verschoben hat.

## 4. Wenn die Spannung nicht reicht

Der Plan geht von etwa 9 V Spitze aus (Schätzung). Typische Ursachen und Gegenmaßnahmen:

| Beobachtung | Mögliche Ursache | Gegenmaßnahme |
|---|---|---|
| Rotor dreht kaum | Schaufeln zu flach, Reibung am Stift | Schaufelwinkel ändern, Stift polieren |
| Rotor dreht, Spannung zu klein | zu wenig Windungen, zu großer Abstand zu den Magneten | mehr Windungen (Ø 0,08 mm), Wand des Rohrs dünner (0,8 mm) |
| Spannung gut, LEDs dunkel | Vorwiderstand zu groß, falsche Polung der LEDs | Widerstand kleiner, Polung prüfen |
| Durchfluss bricht ein | Turbine drosselt zu stark | Rotor-Innendurchmesser größer, Leitrad aufweiten |
| Wasser tritt am Gewinde aus | Kappe undicht | Dichtband, O-Ring |

## 5. Was daraus für den späteren Baum folgt

Im Baum ist der Griff **ein** Druck mit dem Rest. Dort gilt dieselbe Idee: Spulen vorher wickeln, in **von außen offene Taschen** im Griff einsetzen und mit einer dünnen Hülse oder Epoxid verschließen. Rotor und Leitrad kommen vom Auslass- oder Einlassende her. Das wird erst nach den Messungen am Demonstrator konstruiert.

## 6. Zusätzliches Material zur Bauteilliste

Zusätzlich zu `demonstrator.md`:

| Teil | Zweck |
|---|---|
| Lötkolben, Lötzinn, dünne Silikonlitze (30 cm) | Verschaltung und Kabel |
| Lochrasterplatte oder Steckbrett | Elektronik |
| Sekundenkleber | Spulen vorläufig fixieren |
| PTFE-Dichtband | Gewinde der Kappe |
| Akkuschrauber oder Bohrmaschine, kleine Klemmung | Spulen wickeln |
| Feines Schleifpapier (240–400) | Lack von den Drahtenden |
| Kompass oder Ersatzmagnet | Magnetpolung prüfen |

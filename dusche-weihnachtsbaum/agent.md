# agent.md – Weihnachtsbaum-Duschkopf mit Schnellkupplung

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit dem Nutzer: **Deutsch**.

## Arbeitsweise

- Projektordner: `dusche-weihnachtsbaum/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner nicht anfassen.
- Commit-Messages auf Deutsch, Betreff im Imperativ (≤ 72 Zeichen), darunter kurz was und warum. Vor dem Push `git pull --rebase origin main`.
- Versionierung nur über Git, Dateinamen ohne Versionskennung.
- **Kein Netz des Duschkopfs (STL/3MF) einchecken:** Das Original (QuiqueCrimson, MakerWorld) steht unter der Standard Digital File License, das Repo ist öffentlich. Eingecheckt werden nur SCAD, Skripte und Bilder; das Modell erzeugt `werkzeuge/erzeuge_modell.py` aus der Original-3MF.
- Nach Geometrieänderungen beide Varianten erzeugen (mit und ohne `--geschenke`) und Bilder neu erzeugen (`werkzeuge/bilder.py <ausgabe> bilder`, `stecker.png` mit `xvfb-run openscad --render -o bilder/stecker.png --imgsize=900,600 --camera=0,0,12,60,0,30,90 --colorscheme=Tomorrow --viewall --autocenter schnellkupplung_stecker.scad`).

## Ziel

Der 1/2"-Gewindezapfen des Weihnachtsbaum-Duschkopfs wird durch den Stecker der Hansgrohe-Schnellkupplung 28346000 ersetzt. Vorlage für den Stecker ist der vorhandene Adapter `hansgrohe_shower_quick_connect_adapter.scad` des Nutzers (Gewindebuchse + Stecker).

## Entscheidungen

- Drucker: **Anycubic mit ACE (4 Filamente)**, Anycubic Slicer Next (Orca-basiert). Die 3MF hat Bambu/Orca-Format (Bauteile in model_settings.config, Bemalung als paint_color), aber kein project_settings.config. Die Bambu-Profile des Originals passen nicht.
- Filamente: 1 Grün, 2 Rot, 3 Gold, 4 Weiß. Die Bemalung im Original nutzt die Bambu-Slots 4 (Gold), 5 (Rot) und 6 (Grün). `umnummerieren()` schreibt die paint_color-Bäume um. Kontrolle mit Zählung der Zustände: 2 → 27934, 3 → 50640 Teil-Dreiecke.
- Schnitt bei x = −97,5 (Original-Netzkoordinaten), Achse y = 0, z = −0,625. Ergebnis wird um den Ursprung zentriert (Verschiebung x + 6,35).
- Steckergeometrie nach Messwerten des Nutzers (12.11.2026), Profil im Kopf von `schnellkupplung_stecker.scad`. Die frühere Geometrie aus dem Adapter hielt in der Kupplung nicht (O-Ring-Nut 1 mm zu flach).
- Griff rund: ø 21,25, bis an den Hals (x = −15), **ohne Fase** zum Baum (Wunsch des Nutzers). Stirnkante am Stecker 1 mm gefast (`FASE_GRIFF`). Unten bei z = −10,625 abgeflacht (7,2 mm). Die Bohrung ø 10 ist um 0,37° gegen die Originalbohrung verdreht, damit keine Ecken zusammenfallen.
- Geschenke:
  - Je Seite **ein quadratischer** Karton 26 × 26, Baum-Material, angebunden an Fußrand und Griffmantel.
  - Oberseite folgt der Wölbung des Baumfußes (`woelbung()`: Strahlen von oben bei x = −2). Kanten gefast (`FASE_OBEN`, `FASE_ECKE`, `FASE_BETT`). Das linke Geschenk ist das gespiegelte rechte.
  - Zwischen Geschenk und Hals bleibt ein Spalt von etwa 2–3 mm (Hals schmaler als Griff). Bisher nicht beanstandet.
  - **Farbe nur aufgebracht**, wie die übrige Deko: Die oberste Haut von 0,8 mm (`haut_oben`) wird je nach 2D-Fläche zum Bauteil Weiß oder Rot. Keine frei stehenden Schleifen (der Nutzer fand sie instabil), keine Farbe über die volle Höhe (zu viele Farbwechsel).
  - Volumenlose Splitter entfernt `saeubern()`.
- Innenraum (4. Runde): Der Slicer wollte in der Bohrung und in der Kammer Stützen setzen. Bohrung = Tropfen (`bohrung_dach()`, 40° im Griff; im SCAD `dach_winkel` 35° im Stecker), von x = −94,5 bis 9. Kammer des Originals unverändert (29 Pfosten ø 1,5, alle bis ins Dach, max. Abstand 4,8 mm); stattdessen `kammer_blocker()` als Bauteil mit `subtype="support_blocker"` in der 3MF (nicht in den STLs; bei Zentrierung ausgenommen, in `bilder.py` ausgeblendet). Analyse: lagenweise Überhangprüfung (Schicht für Schicht, Versatz 0,2/tan 30°). Wurde nicht im echten Anycubic Slicer geprüft.
- Düsen in Geschenken (5. Runde, Nutzerwunsch): `geschenk_hohlraum()`/`geschenk_blocker()`, Parameter `WAND_G, DACH_G, DUESEN_X/Y, PFOSTEN_X/Y, KANAL_X`. Geprüft: Düsen durchgängig, Kanal frei. Geschenke sind jetzt wasserführend (frühere Vorgabe „nicht Teil des Wassersystems“ ersetzt). Durchflussrechnung im README.
- Stecker neu vermessen (ed41b63): O-Ring-Nut Ø 11,3 → Tropfen im SCAD bei `dach_kappe` = 4,45 gekappt (Wand 1,2 mm). `Stuetzen-Blocker Bohrung` (Ø 7,6 im Stecker, 9,6 im Griff) in der 3MF.
- Düsen (12.11.2026): `--duesen-d=` (Standard 2,0 mm) bohrt die 44 Baum-Düsen auf (`baum_duesen()`, `duesen_aufbohren()`), setzt die Geschenk-Düsen (`DUESE_D`), Pfosten bleiben `PFOSTEN_D` = 1,5. Mit der Original-3MF geprüft: 44 Düsen, bei ø 2,0 sind 36 voll aufgebohrt, 8 durch Platz begrenzt (`duesen_freiraum()`), Teile dicht. Bilder (`bilder.py`) noch nicht neu erzeugt. Die Teile der Geschenk-Variante sind einzeln nicht dicht (Farbaufteilung), das war schon vorher so.
- Bemalung (paint_color) wird über `face_id` von manifold3d auf die Dreiecke des Ergebnisses übertragen.

## Offen

- Der Nutzer sollte bestätigen, dass Anycubic Slicer Next den Blocker aus der 3MF übernimmt (sonst manuell setzen, Maße im README) und dass in der Kammer keine Stützen mehr erscheinen. Falls doch Stützen erscheinen, Screenshot anfordern: dann Pfostenraster/Decke gezielt ändern.
- Brücke unter dem Hals (x = −8,5 … 3, z = −10,6 … −8) und der schwebende Stecker brauchen weiterhin (außen liegende) Stützen; Hals nach unten bis zum Bett füllen wäre möglich, wurde nicht gemacht.

- Nicht geprüft, ob Anycubic Slicer Next Bauteil-Filamente und Bemalung aus der 3MF übernimmt. Andernfalls im Slicer zuweisen bzw. die STLs nutzen.

- Nicht gedruckt erprobt. Liegender Druck von O-Ring- und Rastnut könnte nacharbeiten erfordern; Alternative wäre ein separat stehend gedruckter Stecker zum Einkleben.

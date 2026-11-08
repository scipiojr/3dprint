# agent.md – Weihnachtsbaum-Duschkopf mit Schnellkupplung

Arbeitsanweisung und Projektstand für KI-Agenten. Sprache mit dem Nutzer: **Deutsch**.

## Arbeitsweise

- Projektordner: `dusche-weihnachtsbaum/` im Repository `scipiojr/3dprint` (Branch `main`). Andere Unterordner nicht anfassen.
- Commit-Messages auf Deutsch, Betreff im Imperativ (≤ 72 Zeichen), darunter kurz was und warum. Vor dem Push `git pull --rebase origin main`.
- Versionierung nur über Git, Dateinamen ohne Versionskennung.
- **Kein Netz des Duschkopfs (STL/3MF) einchecken:** Das Original (QuiqueCrimson, MakerWorld) steht unter der Standard Digital File License, das Repo ist öffentlich. Eingecheckt werden nur SCAD, Skripte und Bilder; das Modell erzeugt `werkzeuge/erzeuge_modell.py` aus der Original-3MF.
- Nach Geometrieänderungen Bilder neu erzeugen (`werkzeuge/bilder.py` für Übersicht und Schnitt, `stecker.png` mit `xvfb-run openscad --render -o bilder/stecker.png --imgsize=900,600 --camera=0,0,12,60,0,30,90 --colorscheme=Tomorrow --viewall --autocenter schnellkupplung_stecker.scad`).

## Ziel

Der 1/2"-Gewindezapfen des Weihnachtsbaum-Duschkopfs wird durch den Stecker der Hansgrohe-Schnellkupplung 28346000 ersetzt. Vorlage für den Stecker ist der vorhandene Adapter `hansgrohe_shower_quick_connect_adapter.scad` des Nutzers (Gewindebuchse + Stecker).

## Entscheidungen

- Steckergeometrie unverändert aus dem Adapter übernommen, inklusive Schlüsselflächen (stören nicht, liegen beim Druck senkrecht).
- Schnitt bei x = −97,5 (Original-Netzkoordinaten), Achse y = 0, z = −0,625. Ergebnis wird um den Ursprung zentriert (Verschiebung x + 6,35), Bauteil-Position in der 3MF bleibt 128/128.
- In der 3MF: Netz ersetzt, Titel ergänzt, Fotos/Vorschaubilder des Originals entfernt, Druckeinstellungen (Stützen an) unverändert.

## Offen

- Nicht gedruckt erprobt. Liegender Druck von O-Ring- und Rastnut könnte nacharbeiten erfordern; Alternative wäre ein separat stehend gedruckter Stecker zum Einkleben.

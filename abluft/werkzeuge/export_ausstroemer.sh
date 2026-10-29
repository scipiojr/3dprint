#!/usr/bin/env bash
# Erzeugt alle Druckteile des Ausstroemer direkts (abluft_ausstroemer_direkt.scad) als STL.
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_ausstroemer.sh [zielordner] [-D name=wert ...]
#   Beispiele:  werkzeuge/export_ausstroemer.sh ausstroemer_direkt
#               werkzeuge/export_ausstroemer.sh test -D fk_angle=45 -D fk_WL=120 -D 'fk_bed=[220,220,250]'
# Die Anzahl der Teile haengt von Parametern und Druckraum (fk_bed) ab und wird aus der Ausgabe "info" gelesen.
# Dateien: ausstroemer_teil_1.stl ... und ausstroemer_alle.3mf (alle Teile, je ein Objekt, im Abstand einer Druckplatte).
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-ausstroemer_direkt}"; [[ $# -gt 0 ]] && shift
EXTRA=("$@")
SCAD=abluft_ausstroemer_direkt.scad
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$ZIEL"
openscad -o "$TMP/info.stl" -D 'ausgabe="info"' "${EXTRA[@]}" "$SCAD" >"$TMP/info.log" 2>&1 || true
grep -E "ECHO: \"(Querschnitt|WARNUNG|FEHLER|Teil |Anzahl)" "$TMP/info.log" | sed 's/^ECHO: //'
N=$(sed -n 's/.*Anzahl Teile: \([0-9]*\);.*/\1/p' "$TMP/info.log")
[[ -n "$N" ]] || { echo "Teileplan konnte nicht gelesen werden"; cat "$TMP/info.log"; exit 1; }
export_teil() {
  local k="$1" f="ausstroemer_teil_$1.stl"
  openscad -o "$TMP/$f" -D 'ausgabe="teil"' -D "teil_nr=$k" "${EXTRA[@]}" "$SCAD" >"$TMP/$f.log" 2>&1 || { cat "$TMP/$f.log"; exit 1; }
  grep -q "Simple:        no" "$TMP/$f.log" && echo "WARNUNG: $f nicht 'Simple' (siehe Log)"
  python3 - "$TMP/$f" "$ZIEL/$f" <<'PY' || cp "$TMP/$f" "$ZIEL/$f"
import sys, trimesh
trimesh.load(sys.argv[1]).export(sys.argv[2])
PY
  echo "ok: $ZIEL/$f"
}
n=0
for k in $(seq 1 "$N"); do
  export_teil "$k" &
  n=$((n+1)); (( n % 2 == 0 )) && wait
done
wait

# Eine 3MF mit allen Teilen (je Teil ein eigenes Objekt, im Abstand einer Druckplatte nebeneinander, Druckausrichtung)
python3 - "$ZIEL" <<'PY' || echo "WARNUNG: 3MF konnte nicht erzeugt werden (python3 mit trimesh noetig)"
import glob, re, sys, trimesh
ziel = sys.argv[1]
dateien = sorted(glob.glob(f"{ziel}/ausstroemer_teil_*.stl"), key=lambda f: int(re.search(r"_(\d+)\.stl", f).group(1)))
sc = trimesh.Scene()
x = 0.0
for i, f in enumerate(dateien, 1):
    m = trimesh.load(f)
    m.apply_translation([x - m.bounds[0][0], -m.bounds[0][1], -m.bounds[0][2]])
    sc.add_geometry(m, node_name=f"Teil_{i}", geom_name=f"Teil_{i}")
    x += 300.0          # naechste Platte (Druckraum 260 + Abstand)
sc.export(f"{ziel}/ausstroemer_alle.3mf")
print(f"ok: {ziel}/ausstroemer_alle.3mf ({len(dateien)} Objekte)")
PY

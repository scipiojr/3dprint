#!/usr/bin/env bash
# Erzeugt alle Druckteile des Fensterkanals (abluft_fensterkanal.scad) als STL.
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_fensterkanal.sh [zielordner] [-D name=wert ...]
#   Beispiele:  werkzeuge/export_fensterkanal.sh fensterkanal
#               werkzeuge/export_fensterkanal.sh test -D fk_angle=45 -D fk_WL=120 -D 'fk_bed=[220,220,250]'
# Die Anzahl der Teile haengt von Parametern und Druckraum (fk_bed) ab und wird aus der Ausgabe "info" gelesen.
# Dateien: fensterkanal_teil_1.stl ... (Reihenfolge = Strecke vom 150er-Flansch zum Auslass).
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-fensterkanal}"; [[ $# -gt 0 ]] && shift
EXTRA=("$@")
SCAD=abluft_fensterkanal.scad
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$ZIEL"
openscad -o "$TMP/info.stl" -D 'ausgabe="info"' "${EXTRA[@]}" "$SCAD" >"$TMP/info.log" 2>&1 || true
grep -E "ECHO: \"(Querschnitt|WARNUNG|FEHLER|Teil |Anzahl)" "$TMP/info.log" | sed 's/^ECHO: //'
N=$(sed -n 's/.*Anzahl Teile: \([0-9]*\);.*/\1/p' "$TMP/info.log")
[[ -n "$N" ]] || { echo "Teileplan konnte nicht gelesen werden"; cat "$TMP/info.log"; exit 1; }
export_teil() {
  local k="$1" f="fensterkanal_teil_$1.stl"
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

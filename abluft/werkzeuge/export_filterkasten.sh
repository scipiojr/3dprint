#!/usr/bin/env bash
# Exportiert alle Teile des Filterkastens (abluft_filterkasten.scad) in Druckpose nach ./filterkasten/
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_filterkasten.sh [zielordner] [-D name=wert ...]
# Dauer mit OpenSCAD 2021.01: Einlass ca. 1,5 min, Rest je unter 30 s.
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-filterkasten}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
TEILE=(
  "filterkasten_rahmen.stl|rahmen"
  "filterkasten_einlass_stutzen.stl|einlass|einlass_typ=\"stutzen\""
  "filterkasten_einlass_magnet.stl|einlass|einlass_typ=\"magnet\""
  "filterkasten_auslass_ventilator.stl|auslass"
  "filterkasten_deckel.stl|lid"
  "filterkasten_kassette.stl|cartridge|filter_lagen=1"
  "filterkasten_kassette_2lagen.stl|cartridge|filter_lagen=2"
  "filterkasten_kassette_3lagen.stl|cartridge|filter_lagen=3"
  "filterkasten_lehre.stl|jig"
  "filterkasten_lehre_klemmleiste.stl|jig_clamp"
)
export_eins() {
  local datei="$1" teil="$2" extra="$3"; shift 3
  local ex=(); [[ -n "$extra" ]] && ex=(-D "$extra")
  openscad -o "$ZIEL/$datei" -D "auswahl=\"$teil\"" "${ex[@]}" "$@" abluft_filterkasten.scad 2>&1 | grep -E "ERROR|WARNING" || true
  python3 - "$ZIEL/$datei" <<'PY' || true
import sys, trimesh
m = trimesh.load(sys.argv[1]); m.export(sys.argv[1])   # Binaer-STL
print("ok:", sys.argv[1], "wasserdicht:", m.is_watertight, "Masse:", [round(float(x), 1) for x in m.extents])
PY
}
n=0
for e in "${TEILE[@]}"; do
  IFS='|' read -r datei teil extra <<<"$e"
  export_eins "$datei" "$teil" "$extra" "$@" &
  n=$((n+1)); (( n % 2 == 0 )) && wait
done
wait

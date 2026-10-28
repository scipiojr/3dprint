#!/usr/bin/env bash
# Erzeugt alle druckbaren STL-Dateien des Abluft-Systems aus abluft_system.scad.
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_alle.sh [zielordner]
# Voraussetzung: openscad (2021.01 oder neuer). Mit Python + trimesh werden die STL als
# Binaer-STL gespeichert (ca. 5x kleiner); ohne trimesh bleibt das ASCII-STL von OpenSCAD.
# Dauer mit OpenSCAD 2021.01 (CGAL): ca. 6-8 Minuten fuer alles (Gewindeteile je 1-2 Minuten).
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-.}"
SCAD=abluft_system.scad
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Datei | part | zusaetzliche -D Argumente
TEILE=(
  "durchfuehrung_innen.stl|inner|"
  "durchfuehrung_aussen.stl|nut|"
  "verjuengung_150_110_magnet.stl|funnel|end110=\"magnet\""
  "verjuengung_150_110_stutzen.stl|funnel|end110=\"stub\""
  "adapter_ventilator_140_110.stl|adapter140|"
  "dichtung_ventilator_muffe_tpu.stl|oring_fan|"
  "dichtung_150_plexiglas_tpu.stl|oring150_plexi|"
  "dichtung_150_anschluss_tpu.stl|oring150_face|"
  "dichtung_110_anschluss_tpu.stl|oring110|"
)

export_eins() {
  local datei="$1" teil="$2" extra="$3"
  local args=(-D "part=\"$teil\"")
  [[ -n "$extra" ]] && args+=(-D "$extra")
  openscad -o "$TMP/$datei" "${args[@]}" "$SCAD" >"$TMP/$datei.log" 2>&1 || { cat "$TMP/$datei.log"; exit 1; }
  grep -q "Simple:        yes" "$TMP/$datei.log" || { echo "WARNUNG: $datei nicht 'Simple' (siehe Log)"; cat "$TMP/$datei.log"; }
  python3 - "$TMP/$datei" "$ZIEL/$datei" <<'PY' || cp "$TMP/$datei" "$ZIEL/$datei"
import sys, trimesh
m = trimesh.load(sys.argv[1]); m.export(sys.argv[2])
PY
  echo "ok: $datei"
}

mkdir -p "$ZIEL"
# zwei Teile gleichzeitig (Rechner mit 2+ Kernen); mehr parallele Jobs brauchen viel RAM
n=0
for eintrag in "${TEILE[@]}"; do
  IFS='|' read -r datei teil extra <<<"$eintrag"
  export_eins "$datei" "$teil" "$extra" &
  n=$((n+1)); (( n % 2 == 0 )) && wait
done
wait

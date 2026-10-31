#!/usr/bin/env bash
# Erzeugt alle druckbaren STL-Dateien des Abluft-Systems aus den Teile-Dateien (abluft_durchfuehrung/verjuengung/ventilator_adapter.scad; Basis: abluft_system.scad).
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_alle.sh [zielordner]
# Voraussetzung: openscad (2021.01 oder neuer). Mit Python + trimesh werden die STL als
# Binaer-STL gespeichert (ca. 5x kleiner); ohne trimesh bleibt das ASCII-STL von OpenSCAD.
# Dauer mit OpenSCAD 2021.01 (CGAL): ca. 6-8 Minuten fuer alles (Gewindeteile je 1-2 Minuten).
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-.}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Datei | scad-Datei | part | zusaetzliche -D Argumente (durch Leerzeichen getrennt, keine Leerzeichen in den Werten)
TEILE=(
  "durchfuehrung_innen.stl|abluft_durchfuehrung.scad|inner|"
  "durchfuehrung_aussen.stl|abluft_durchfuehrung.scad|nut|"
  "verjuengung_150_100_magnet.stl|abluft_verjuengung.scad|funnel|end110=\"magnet\""
  "verjuengung_150_100_stutzen.stl|abluft_verjuengung.scad|funnel|end110=\"stub\""
  "verjuengung_150_110_rohr.stl|abluft_verjuengung.scad|funnel|end110=\"pipe\""
  "verjuengung_150_110_rohr_45grad.stl|abluft_verjuengung.scad|funnel|end110=\"pipe\" pipe_angle=45"
  "adapter_ventilator_140_100.stl|abluft_ventilator_adapter.scad|adapter140|"
  "dichtung_ventilator_muffe_tpu.stl|abluft_ventilator_adapter.scad|oring_fan|"
  "dichtung_150_plexiglas_tpu.stl|abluft_durchfuehrung.scad|oring150_plexi|"
  "dichtung_150_anschluss_tpu.stl|abluft_verjuengung.scad|oring150_face|"
  "dichtung_100_anschluss_tpu.stl|abluft_ventilator_adapter.scad|oring110|"
  "magnetring_150.stl|abluft_magnetring.scad|ring150|"
  "magnetring_100.stl|abluft_magnetring.scad|ring100|"
)

export_eins() {
  local datei="$1" SCAD="$2" teil="$3" extra="$4"
  local args=(-D "part=\"$teil\"")
  for e in $extra; do args+=(-D "$e"); done
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
  IFS='|' read -r datei scad teil extra <<<"$eintrag"
  export_eins "$datei" "$scad" "$teil" "$extra" &
  n=$((n+1)); (( n % 2 == 0 )) && wait
done
wait

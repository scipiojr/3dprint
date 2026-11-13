#!/usr/bin/env bash
# Luefterhalter (Aufhaengung mit Luefter-Lochbild und Auflagezunge) -> luefterhalter/luefterhalter.stl
# Aufruf: werkzeuge/export_luefterhalter.sh [ordner] [-D name=wert ...]   (Beispiel: -D fan_dy=-10 -D ah_zunge_l=30)
set -euo pipefail
cd "$(dirname "$0")/.."
out="luefterhalter"
if [[ $# -gt 0 && "$1" != -D ]]; then out="$1"; shift; fi
mkdir -p "$out"
args=(); while [[ $# -gt 0 ]]; do args+=("$1" "$2"); shift 2; done
openscad -o "$out/luefterhalter.stl" "${args[@]}" abluft_luefterhalter.scad 2>&1 | grep -E "ECHO|WARN|ERROR|Simple" || true
python3 -I werkzeuge/pruefung_luefterhalter.py "$out/luefterhalter.stl"

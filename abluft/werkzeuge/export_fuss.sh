#!/usr/bin/env bash
# Erzeugt die Ersatz-Fuesse (abluft_fuss.scad) als STL: fuesse/fuss_6er.stl und fuesse/fuss_8er.stl
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_fuss.sh [zielordner] [-D name=wert ...]
#   Beispiel mit Kerbe und 1 mm Zugabe:   werkzeuge/export_fuss.sh fuesse -D fuss_kerbe=true -D fuss_zugabe=1
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-fuesse}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
for f in 6er 8er; do
  openscad -o "$ZIEL/fuss_$f.stl" -D "fuss=\"$f\"" "$@" abluft_fuss.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
  echo "ok: $ZIEL/fuss_$f.stl"
done

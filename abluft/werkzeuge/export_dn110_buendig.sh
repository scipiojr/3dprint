#!/usr/bin/env bash
# Erzeugt die Teile der buendigen Ausfuehrung des Arbeitsplatten-Durchlasses (abluft_dn110_durchlass_buendig.scad) nach dn110_arbeitsplatte_buendig/
#   ring, halteflansch, deckel, rohr_2 (Rohr 1 und Winkeladapter wie in dn110_arbeitsplatte/). Dauer ca. 5 Minuten.
# Aufruf (aus abluft/):   werkzeuge/export_dn110_buendig.sh [zielordner] [-D name=wert ...]
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-dn110_arbeitsplatte_buendig}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
n=1
for name in ring halteflansch deckel rohr_2; do
  openscad -o "$ZIEL/dn110_buendig_$name.stl" -D "v2_teil=$n" "$@" abluft_dn110_durchlass_buendig.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
  echo "ok: $ZIEL/dn110_buendig_$name.stl"; n=$((n+1))
done

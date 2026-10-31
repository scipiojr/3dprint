#!/usr/bin/env bash
# Erzeugt die Druckteile des DN110-Doppelbogens fuer die Arbeitsplatte (abluft_dn110_arbeitsplatte.scad): dn110_arbeitsplatte/dn110_arbeitsplatte_teil_1.stl, _2.stl
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_dn110_arbeitsplatte.sh [zielordner] [-D name=wert ...]
#   Beispiel:  werkzeuge/export_dn110_arbeitsplatte.sh dn110_arbeitsplatte -D wk_r=80 -D wk_links=false
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-dn110_arbeitsplatte}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
for k in 1 2 3; do
  openscad -o "$ZIEL/dn110_arbeitsplatte_teil_$k.stl" -D 'ausgabe="teil"' -D "teil_nr=$k" "$@" abluft_dn110_arbeitsplatte.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
  echo "ok: $ZIEL/dn110_arbeitsplatte_teil_$k.stl"
done

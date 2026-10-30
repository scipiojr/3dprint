#!/usr/bin/env bash
# Erzeugt die Druckteile des DN110-Doppelbogens (abluft_dn110_winkel.scad): dn110_winkel/dn110_winkel_teil_1.stl, _2.stl
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_dn110_winkel.sh [zielordner] [-D name=wert ...]
#   Beispiel:  werkzeuge/export_dn110_winkel.sh dn110_winkel -D wk_r=80 -D wk_links=false
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-dn110_winkel}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
for k in 1 2; do
  openscad -o "$ZIEL/dn110_winkel_teil_$k.stl" -D 'ausgabe="teil"' -D "teil_nr=$k" "$@" abluft_dn110_winkel.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
  echo "ok: $ZIEL/dn110_winkel_teil_$k.stl"
done

#!/usr/bin/env bash
# Erzeugt den Winkeladapter fuer den Arbeitsplatten-Durchlass (abluft_dn110_winkeladapter.scad): dn110_arbeitsplatte/dn110_winkeladapter.stl (ca. 1 Minute)
# Aufruf (aus abluft/):   werkzeuge/export_dn110_winkeladapter.sh [zielordner] [-D name=wert ...]
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-dn110_arbeitsplatte}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
openscad -o "$ZIEL/dn110_winkeladapter.stl" "$@" abluft_dn110_winkeladapter.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
echo "ok: $ZIEL/dn110_winkeladapter.stl"

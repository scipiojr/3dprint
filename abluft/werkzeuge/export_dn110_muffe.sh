#!/usr/bin/env bash
# Erzeugt den DN110-Muffenanschluss (abluft_dn110_muffe.scad): dn110_muffe_magnet_100.stl
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_dn110_muffe.sh [zielordner] [-D name=wert ...]
#   Beispiel:  werkzeuge/export_dn110_muffe.sh . -D mf_len=45
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-.}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
openscad -o "$TMP/t.stl" -D 'ausgabe="druck"' "$@" abluft_dn110_muffe.scad >"$TMP/log" 2>&1 || { cat "$TMP/log"; exit 1; }
grep -E "WARNING|ERROR" "$TMP/log" || true
grep -q "Simple:        yes" "$TMP/log" || { echo "WARNUNG: nicht 'Simple'"; cat "$TMP/log"; }
python3 - "$TMP/t.stl" "$ZIEL/dn110_muffe_magnet_100.stl" <<'PY' || cp "$TMP/t.stl" "$ZIEL/dn110_muffe_magnet_100.stl"
import sys, trimesh
m = trimesh.load(sys.argv[1]); m.export(sys.argv[2])
PY
echo "ok: $ZIEL/dn110_muffe_magnet_100.stl"

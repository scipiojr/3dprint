#!/usr/bin/env bash
# Erzeugt die Ausmesshilfen (abluft_ausmesshilfe.scad) fuer die 150er- und 110er-Kupplung.
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_ausmesshilfe.sh [zielordner] [-D name=wert ...]
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-.}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
for p in 150 110; do
  openscad -o "$ZIEL/ausmesshilfe_$p.stl" -D "preset=\"$p\"" "$@" abluft_ausmesshilfe.scad 2>&1 | grep -E "ECHO|WARN|ERROR" || true
  python3 - "$ZIEL/ausmesshilfe_$p.stl" <<'PY' || true
import sys, trimesh
trimesh.load(sys.argv[1]).export(sys.argv[1])
PY
done

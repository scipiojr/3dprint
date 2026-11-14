#!/usr/bin/env bash
# Erzeugt STL, 3MF und Vorschaubilder für eine oder mehrere Boxgrößen.
#   werkzeuge/export.sh            Standard: 1x2 und 2x3
#   werkzeuge/export.sh 4x3 3x3    beliebige Größen (Breite x Tiefe in Rastereinheiten)
# Ergebnis im Projektordner: kleinteilebox_BxT.stl und kleinteilebox_BxT.3mf (Box + Tragzone + Stützbereich)
# Alle weiteren Parameter stehen in kleinteilebox.scad; eigene Werte mit EXTRA="-D hook_t=3" übergeben.
set -euo pipefail
cd "$(dirname "$0")/.."
GROESSEN=("$@")
[ ${#GROESSEN[@]} -eq 0 ] && GROESSEN=(1x2 2x3)
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for g in "${GROESSEN[@]}"; do
  w="${g%x*}"; l="${g#*x}"
  n="kleinteilebox_${g}"
  for teil in box modifier support_zone; do
    # shellcheck disable=SC2086
    openscad -o "$TMP/$teil.stl" -D "units_w=$w" -D "units_l=$l" -D "part=\"$teil\"" ${EXTRA:-} kleinteilebox.scad 2>"$TMP/$teil.log" \
      || { cat "$TMP/$teil.log"; exit 1; }
  done
  cp "$TMP/box.stl"   "$n.stl"
  python3 -I werkzeuge/erzeuge_3mf.py "$TMP/box.stl" "$TMP/modifier.stl" "$TMP/support_zone.stl" "$n.3mf" "Kleinteilebox $g"
  python3 -I werkzeuge/stl_werkzeug.py "$n.stl"
  grep -h "ECHO" "$TMP/box.log" | sed 's/ECHO: //' | tr -d '"' | grep -E "^(Box außen|Boden|Tragrahmen)" || true
done

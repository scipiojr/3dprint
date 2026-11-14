#!/usr/bin/env bash
# Erzeugt bilder/schnitt.png (matplotlib, aus den STL) und bilder/ansicht.png (OpenSCAD-Vorschau, Tragzone rot
# durchsichtig, Stützturm blau). Braucht openscad, xvfb-run, python3 mit numpy und matplotlib.
# Standardgröße 2x3 (die eingecheckten STL). Andere Größe: werkzeuge/bilder.sh 4 3  (dafür vorher export.sh 4x3)
set -euo pipefail
cd "$(dirname "$0")/.."
W="${1:-2}"; L="${2:-3}"
python3 -I werkzeuge/bild_schnitt.py "kleinteilebox_${W}x${L}.stl" "kleinteilebox_${W}x${L}_stuetzturm.stl" bilder/schnitt.png
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/ansicht.scad" <<EOS
use <$PWD/kleinteilebox.scad>
color("lightgray") box();
color("tomato", 0.35) modifier_volume();
color("steelblue") hook_support_tower();
EOS
xvfb-run -a openscad -o bilder/ansicht.png --imgsize=1300,900 --camera=0,0,0,62,0,215,420 --autocenter --viewall \
  -D "units_w=$W" -D "units_l=$L" "$TMP/ansicht.scad" 2>/dev/null
echo "Bilder: bilder/schnitt.png bilder/ansicht.png"

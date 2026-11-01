#!/usr/bin/env bash
# Grobe Druckzeit-/Materialschaetzung mit Slic3r 1.3 (apt install slic3r) und Python.
# Aufruf:  werkzeuge/druckzeit.sh teil.stl [support]      (STL in Druckpose, Z nach oben)
# Annahmen: 0,4er Duese, 0,28 mm Schicht, 3 Umrisse, 15 % Fuellung, 4 Deckel-/Bodenschichten, Umrisse 40-60 mm/s, +15 % Beschleunigung.
# Nur zum VERGLEICH von Varianten (absolute Zeiten hängen von Drucker/Slicer ab). "support" schaltet Stuetzen ein (bei grossen Teilen sehr langsam).
set -euo pipefail
f="$1"; sup=""; [[ "${2:-}" == support ]] && sup="--support-material --support-material-threshold 50"
T=$(mktemp -d); out="$T/out.gcode"
slic3r --layer-height 0.28 --first-layer-height 0.28 --perimeters 3 --fill-density 15% --top-solid-layers 4 --bottom-solid-layers 4 \
  --nozzle-diameter 0.4 --filament-diameter 1.75 --perimeter-speed 60 --external-perimeter-speed 40 --infill-speed 80 --solid-infill-speed 60 \
  --support-material-speed 60 --small-perimeter-speed 40 --gap-fill-speed 40 --travel-speed 150 --bridge-speed 30 --skirts 0 \
  --cooling --slowdown-below-layer-time 5 --fan-below-layer-time 10 $sup -o "$out" "$f" > "$T/log.txt" 2>&1
python3 - "$out" "$f" "$T/log.txt" "${2:-ohne Stuetzen}" <<'PY'
import sys, re
t = 0; x = y = 0; fr = 1800
for l in open(sys.argv[1]):
    if not l.startswith('G1'): continue
    m = dict((k, float(v)) for k, v in re.findall(r'([XYZEF])(-?[\d.]+)', l))
    fr = m.get('F', fr); nx, ny = m.get('X', x), m.get('Y', y)
    t += ((nx - x)**2 + (ny - y)**2)**0.5 / (fr / 60) * 1.15; x, y = nx, ny
fil = [l for l in open(sys.argv[3]) if 'Filament required' in l]
print(f"{sys.argv[2].split('/')[-1]:36s} {sys.argv[4]:14s} ~{t/3600:5.1f} h  {fil[0].strip().split('(')[-1].rstrip(')') if fil else ''}")
PY
rm -rf "$T"

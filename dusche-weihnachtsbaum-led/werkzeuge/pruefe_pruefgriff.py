"""Prüft die STL-Dateien des Prüfgriffs: Netz geschlossen, Maße, Kollisionen.

Aufruf (aus dem Projektordner):
  for t in rohr spulenring huelse rotor_montage leitrad2 kappe stift; do
    openscad -q -D "teil=\"$t\"" -o /tmp/stl/$t.stl pruefgriff.scad; done
  python3 -I werkzeuge/pruefe_pruefgriff.py /tmp/stl
"""
import sys, itertools
import numpy as np
import trimesh

d = sys.argv[1] if len(sys.argv) > 1 else "/tmp/stl"
namen = ["rohr", "spulenring", "huelse", "rotor_montage", "leitrad2", "kappe", "stift"]
m = {}
print(f"{'Teil':14s} {'dicht':6s} {'Volumen mm³':>12s}  Ausdehnung x y z (mm)")
for n in namen:
    t = trimesh.load(f"{d}/{n}.stl")
    m[n] = t
    ext = t.bounds[1] - t.bounds[0]
    print(f"{n:14s} {str(t.is_watertight):6s} {t.volume:12.0f}  {ext[0]:.1f} {ext[1]:.1f} {ext[2]:.1f}  z {t.bounds[0][2]:.1f}..{t.bounds[1][2]:.1f}")

print("\nKollisionen (Überschneidungsvolumen in mm³, soll ≈ 0 sein):")
bad = 0
for a, b in itertools.combinations(namen, 2):
    ta, tb = m[a], m[b]
    if not (np.all(ta.bounds[0] < tb.bounds[1]) and np.all(tb.bounds[0] < ta.bounds[1])):
        continue
    try:
        i = trimesh.boolean.intersection([ta, tb], engine="manifold")
        v = i.volume if len(i.faces) else 0.0
    except Exception as e:
        v = float("nan")
    flag = "" if v < 2.0 else "  <-- PRÜFEN"   # < 2 mm³: 0,01 mm Überlappung am Kragen, gewollt
    if v >= 2.0 or v != v: bad += 1
    print(f"  {a:14s} x {b:14s} {v:8.2f}{flag}")
print("\nErgebnis:", "OK" if bad == 0 else f"{bad} Auffälligkeit(en)")

#!/usr/bin/env python3
"""Prueft den Filterkasten (abluft_filterkasten.scad) in der MONTIERTEN Pose:
  - alle Teile wasserdicht, paarweise Ueberlappung (soll ~0 mm3 sein),
  - Scharnier: Deckel um die Achse schwenken (30/60/80 Grad, soll nicht kollidieren),
  - Gesamtmasse.
Aufruf (aus abluft/):  python3 -I werkzeuge/pruefung_filterkasten.py [-D name=wert ...]
Braucht openscad, trimesh, numpy, manifold3d. Dauer ca. 3 Minuten (Einlass ist langsam)."""
import itertools, subprocess, sys, tempfile
from pathlib import Path
import numpy as np
import trimesh
import manifold3d as mf

ORDNER = Path(__file__).resolve().parent.parent
extra = sys.argv[1:]
POSEN = {
    "rahmen": "rahmen()",
    "einlass": "translate([-xe_in, 0, 0]) einlass()",
    "auslass": "translate([RL, 0, 0]) auslass()",
    "deckel": "translate([0, 0, box_h]) lid()",
    "kassette": "translate([sp_in + 0.5, (box_w - c_w) / 2, box_wall]) cartridge()",
}
M = lambda m: mf.Manifold(mf.Mesh(vert_properties=np.array(m.vertices, dtype=np.float32), tri_verts=np.array(m.faces, dtype=np.uint32)))

tmp = Path(tempfile.mkdtemp())
meshes = {}
for name, ausdruck in POSEN.items():
    scad = ORDNER / f"_pose_{name}.scad"          # im abluft-Ordner, damit include <...> gefunden wird
    scad.write_text(f'include <abluft_filterkasten.scad>\nauswahl = "keiner";\n{ausdruck};\n')
    stl = tmp / f"{name}.stl"
    try:
        subprocess.run(["openscad", "-o", str(stl), *sum((["-D", e] for e in extra), []), str(scad)], check=True, capture_output=True)
    finally:
        scad.unlink()
    meshes[name] = trimesh.load(stl)
    print(f"{name:9s} wasserdicht: {meshes[name].is_watertight}")
mf_ = {n: M(m) for n, m in meshes.items()}
fehler = 0
for a, b in itertools.combinations(meshes, 2):
    v = (mf_[a] ^ mf_[b]).volume()
    if abs(v) > 0.5:
        print(f"UEBERLAPPUNG {a}/{b}: {v:.1f} mm3"); fehler += 1
b = np.vstack([m.bounds for m in meshes.values()])
print("Gesamtmasse montiert [mm]:", (b.max(0) - b.min(0)).round(1))
# Scharnier: Achse y = box_w + frame_t/2, z = box_h; Deckel klappt zur -y-Seite hoch
txt = (ORDNER / "abluft_filterkasten.scad").read_text()
import re
def par(n):
    m = re.search(rf"^{n}\s*=\s*([-0-9.]+)\s*;", txt, re.M); return float(m.group(1))
inner_w, inner_h, wand, rand = par("inner_w"), par("inner_h"), par("box_wall"), par("frame_t")
box_w, box_h = inner_w + 2 * wand, inner_h + 2 * wand
for w in (30, 60, 80):   # ab ca. 85 Grad streift die Deckelkante an der Rahmen-Scharnierkante (9 mm3 bei 90)
    T = trimesh.transformations.rotation_matrix(np.radians(-w), [1, 0, 0], [0, box_w + rand / 2, box_h])
    d = meshes["deckel"].copy(); d.apply_transform(T)
    v = (mf_["rahmen"] ^ M(d)).volume()
    print(f"Scharnier {w:3d} Grad: Kollision {v:.1f} mm3"); fehler += abs(v) > 0.5
print("ERGEBNIS:", "OK" if not fehler else f"{fehler} Befund(e)")

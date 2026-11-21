#!/usr/bin/env python3
"""Vorschaubild des DN110-T-Stuecks: Schnitte und Ansichten (Aufruf: python3 -I werkzeuge/bild_dn110_tstueck.py [stl] [png])."""
import sys, numpy as np, trimesh
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.path import Path
from matplotlib.patches import PathPatch
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

stl = sys.argv[1] if len(sys.argv) > 1 else "dn110_tstueck/dn110_tstueck.stl"
png = sys.argv[2] if len(sys.argv) > 2 else "bilder/dn110_tstueck.png"
m = trimesh.load(stl)

def loops(origin, normal, axes):
    s = m.section(plane_origin=origin, plane_normal=normal)
    return [np.asarray(e)[:, axes] for e in s.discrete] if s is not None else []

def flaeche(a, origin, normal, axes):
    verts, codes = [], []
    ls = loops(origin, normal, axes)
    # Schachtelung bestimmen: Schleifen mit ungerader Tiefe (Loecher) gegenlaeufig, damit die Fuellung stimmt
    def area(p): return 0.5 * np.sum(p[:, 0] * np.roll(p[:, 1], -1) - np.roll(p[:, 0], -1) * p[:, 1])
    for i, p in enumerate(ls):
        tiefe = sum(Path(q).contains_point(p[0]) for j, q in enumerate(ls) if j != i)
        if (area(p) > 0) == (tiefe % 2 == 1): p = p[::-1]
        verts += [*p, p[0]]; codes += [Path.MOVETO] + [Path.LINETO] * (len(p) - 1) + [Path.CLOSEPOLY]
    a.add_patch(PathPatch(Path(verts, codes), fc="#b8c4d4", ec="#223", lw=0.8))

fig = plt.figure(figsize=(18, 7.4))
zb = (m.bounds[0][2] + m.bounds[1][2]) / 2
# (1) Raumansicht
a0 = fig.add_subplot(1, 4, 1, projection="3d")
tri = m.triangles
nrm = m.face_normals
light = np.array([0.4, -0.5, 0.75]); light /= np.linalg.norm(light)
sh = 0.35 + 0.65 * np.clip(nrm @ light, 0, 1)
col = np.stack([0.55 * sh + 0.1, 0.65 * sh + 0.1, 0.8 * sh + 0.1, np.ones_like(sh)], axis=1)
a0.add_collection3d(Poly3DCollection(tri, facecolors=col, edgecolors="none", antialiaseds=False))
a0.set_xlim(-80, 80); a0.set_ylim(-80, 80); a0.set_zlim(0, 160); a0.set_box_aspect((1, 1, 1))
a0.view_init(elev=20, azim=62); a0.set_axis_off(); a0.set_title("Druckpose (Z oben)", fontsize=10)
# (2) Schnitt x = 0 (Rohrachse + Abgang): y nach rechts, z nach oben
a1 = fig.add_subplot(1, 4, 2)
flaeche(a1, [0, 0, 0], [1, 0, 0], [1, 2]); a1.set_aspect("equal"); a1.set_xlim(-65, 95); a1.set_ylim(-3, m.bounds[1][2] + 3)
a1.set_title("Schnitt x = 0: Muffen, Anschlagringe, Abgang\n(Nuten mit Dach 45°)", fontsize=10); a1.set_xlabel("y [mm]"); a1.set_ylabel("z [mm]")
# (3) Schnitt durch die Abgangsachse z = zb (Draufsicht)
a2 = fig.add_subplot(1, 4, 3)
flaeche(a2, [0, 0, zb], [0, 0, 1], [0, 1]); a2.set_aspect("equal"); a2.set_xlim(-72, 72); a2.set_ylim(-65, 92)
a2.set_title(f"Schnitt z = {zb:.1f} mm (Abgangsachse)", fontsize=10); a2.set_xlabel("x [mm]"); a2.set_ylabel("y [mm]")
# (4) Ansicht von der Magnetflaeche: Schnitt knapp hinter der Flaeche (Taschen/Nut) in der Ebene y = yf - 1
yf = m.bounds[1][1]
a3 = fig.add_subplot(1, 4, 4)
flaeche(a3, [0, yf - 1.0, 0], [0, 1, 0], [0, 2]); a3.set_aspect("equal"); a3.set_xlim(-75, 75); a3.set_ylim(0, m.bounds[1][2] + 3)
a3.set_title("Schnitt y = Magnetflaeche - 1 mm\nMagnettaschen, Nut", fontsize=10); a3.set_xlabel("x [mm]"); a3.set_ylabel("z [mm]")
plt.tight_layout(); plt.savefig(png, dpi=80)
print("Bild:", png)

#!/usr/bin/env python3
"""Vorschaubild des Luefterhalters: Schnitte durch luefterhalter/luefterhalter.stl (Aufruf: python3 -I werkzeuge/bild_luefterhalter.py [stl] [png])."""
import sys, numpy as np, trimesh
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.path import Path
from matplotlib.patches import PathPatch

stl = sys.argv[1] if len(sys.argv) > 1 else "luefterhalter/luefterhalter.stl"
png = sys.argv[2] if len(sys.argv) > 2 else "bilder/luefterhalter.png"
m = trimesh.load(stl)

def schnitt(origin, normal, axes):
    s = m.section(plane_origin=origin, plane_normal=normal)
    return [np.asarray(e)[:, axes] for e in s.discrete] if s is not None else []

def flaeche(a, z):
    """Schnitt in der Ebene z als gefuellte Flaeche mit Loechern (even-odd)."""
    loops = schnitt([0, 0, z], [0, 0, 1], [0, 1])
    verts, codes = [], []
    for p in loops:
        verts += [*p, p[0]]; codes += [Path.MOVETO] + [Path.LINETO] * (len(p) - 1) + [Path.CLOSEPOLY]
    a.add_patch(PathPatch(Path(verts, codes), fc="#b8c4d4", ec="#223", lw=0.8))

fig, ax = plt.subplots(1, 3, figsize=(17, 6.2), gridspec_kw={"width_ratios": [1.2, 1.2, 1]})
# (1) Schnitt knapp unter der Oberseite (Luefterseite): Platte, Zunge, Langloecher, Beinquerschnitte
# (2) Schnitt auf der Magnetseite: Magnettaschen, Mutterntaschen
for a, z, t in ((ax[0], 1.0, "Schnitt z = 1 mm unter der Lüfterseite\nZunge (2 mm), Platte, Langlöcher"),
                (ax[1], 6.5, "Schnitt z = 6,5 mm\nMagnettaschen, Mutterntaschen")):
    flaeche(a, z)
    a.set_aspect("equal"); a.set_xlim(-108, 108); a.set_ylim(-34, 160)
    a.axhline(0, color="#c33", lw=1.2, ls="--"); a.text(-104, 3, "Wand (Vorderkante der Wandplatte)", color="#c33", fontsize=8)
    a.set_title(t, fontsize=10); a.set_xlabel("x (Reihenrichtung) [mm]"); a.set_ylabel("y (von der Wand weg) [mm]")
# (3) Seitenschnitt durch die Langlochmitte x = 33 (Langloch + Mutternasche) und durch x = 0
for x0, c in ((33, "#1a6"), (0, "#a61")):
    for p in schnitt([x0, 0, 0], [1, 0, 0], [1, 2]):
        ax[2].plot(p[:, 0], p[:, 1], color=c, lw=1.2, label=f"x = {x0} mm")
ax[2].invert_yaxis(); ax[2].set_aspect(3); ax[2].set_xlim(-34, 160)
ax[2].set_title("Seitenschnitte (z nach unten = zur Magnetseite / zum Winkel)\nz = 0: Lüfterseite", fontsize=10)
h, l = ax[2].get_legend_handles_labels(); ax[2].legend(dict(zip(l, h)).values(), dict(zip(l, h)).keys(), fontsize=8)
ax[2].set_xlabel("y [mm]"); ax[2].set_ylabel("z [mm]")
plt.tight_layout(); plt.savefig(png, dpi=85)
print("Bild:", png)

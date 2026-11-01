#!/usr/bin/env python3
"""Zeichnet den Filterkasten: Laengsschnitt, Draufsicht-Schnitt und Querschnitt durch die Kammer (montierte Pose).
Aufruf: python3 -I werkzeuge/bild_filterkasten.py <ordner mit rahmen/einlass/auslass/lid/cart.stl> <ausgabe.png>
(die STL in montierter Pose erzeugt werkzeuge/pruefung_filterkasten.py bzw. die Wrapper dort)."""
import sys
from pathlib import Path
import numpy as np, trimesh
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MPoly

d = Path(sys.argv[1]); out = sys.argv[2]
farbe = {"einlass": "#4c9f70", "rahmen": "#3b6ea5", "auslass": "#e08a2c", "lid": "#9aa3ad", "cart": "#d9c26a"}
ms = {k: trimesh.load(d / f"{k}.stl") for k in farbe}
b = np.vstack([m.bounds for m in ms.values()]); lo, hi = b.min(0), b.max(0)
mid = (lo + hi) / 2

def schnitt(ax, normal, origin, ix, iy, titel, xl, yl):
    for k, m in ms.items():
        s = m.section(plane_origin=origin, plane_normal=normal)
        if s is None: continue
        p2, T = s.to_2D()
        # 2D-Koordinaten auf Weltachsen abbilden
        for poly in p2.polygons_full:
            xy = np.array(poly.exterior.coords); w = (np.c_[xy, np.zeros(len(xy)), np.ones(len(xy))] @ T.T)[:, :3]
            ax.add_patch(MPoly(np.c_[w[:, ix], w[:, iy]], closed=True, fc=farbe[k], ec="k", lw=0.4))
            for h in poly.interiors:
                hx = np.array(h.coords); wh = (np.c_[hx, np.zeros(len(hx)), np.ones(len(hx))] @ T.T)[:, :3]
                ax.add_patch(MPoly(np.c_[wh[:, ix], wh[:, iy]], closed=True, fc="white", ec="k", lw=0.4))
    ax.set_xlim(lo[ix] - 8, hi[ix] + 8); ax.set_ylim(lo[iy] - 8, hi[iy] + 8); ax.set_aspect("equal")
    ax.set_title(titel, fontsize=10); ax.set_xlabel(xl); ax.set_ylabel(yl); ax.grid(alpha=0.25)

yc = (lo[1] + hi[1]) / 2 - 3   # Kastenachse (ohne Kragen/Scharnier)
fig, axs = plt.subplots(3, 1, figsize=(11, 15))
schnitt(axs[0], [0, 1, 0], [0, yc, 0], 0, 2, "Laengsschnitt (Luftstrom von links nach rechts)", "x [mm]", "z [mm]")
schnitt(axs[1], [0, 0, 1], [0, 0, 60], 0, 1, "Schnitt in Hoehe z = 60 mm (Draufsicht)", "x [mm]", "y [mm]")
x_q = ms["rahmen"].bounds[0][0] + 10 + 13 / 2     # durch das Kassettenfach
schnitt(axs[2], [1, 0, 0], [x_q, 0, 0], 1, 2, "Querschnitt durch das Kassettenfach (Blick in Stroemungsrichtung)", "y [mm]", "z [mm]")
from matplotlib.lines import Line2D
fig.legend([Line2D([0], [0], color=c, lw=8) for c in farbe.values()], ["Einlass", "Rahmen", "Auslass", "Deckel", "Kassette"], loc="upper right", ncol=5)
fig.suptitle("Filterkasten – montiert (Deckel in Schliesslage)", fontsize=13)
fig.tight_layout(rect=[0, 0, 1, 0.97]); fig.savefig(out, dpi=110)

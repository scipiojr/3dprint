#!/usr/bin/env python3
"""Vorschaubilder für das README.

Aufruf: python3 bilder.py <modell.stl> <zielordner>
Benötigt numpy, trimesh, shapely, matplotlib.
"""
import sys
from pathlib import Path

import numpy as np
import trimesh
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9})
GRUEN, STECKER = np.array([0.18, 0.55, 0.30]), np.array([0.85, 0.55, 0.15])
X_STECKER = -97.5 + 6.35  # Anlagefläche des Steckers im zentrierten Modell
ACHSE_Z = -0.625


def schattiert(m, ax, licht=(-0.4, -0.6, 0.9)):
    tri = m.triangles
    n = m.face_normals
    l = np.array(licht) / np.linalg.norm(licht)
    h = 0.35 + 0.65 * np.clip(n @ l, 0, 1)
    farbe = np.where((tri[:, :, 0].max(axis=1) < X_STECKER + 0.01)[:, None], STECKER, GRUEN)
    pc = Poly3DCollection(tri, facecolors=np.clip(farbe * h[:, None], 0, 1), linewidths=0)
    ax.add_collection3d(pc)


def ansicht(m, datei, elev, azim, grenzen, groesse):
    fig = plt.figure(figsize=groesse, dpi=130)
    ax = fig.add_subplot(projection="3d", computed_zorder=False)
    schattiert(m, ax)
    lo, hi = grenzen
    ax.set_xlim(lo[0], hi[0]); ax.set_ylim(lo[1], hi[1]); ax.set_zlim(lo[2], hi[2])
    ax.set_box_aspect(hi - lo)
    ax.view_init(elev, azim)
    ax.set_axis_off()
    fig.subplots_adjust(0, 0, 1, 1)
    fig.savefig(datei, transparent=False, facecolor="white")
    plt.close(fig)


def schnitt(m, datei):
    s = m.section(plane_origin=[0, 0, ACHSE_Z], plane_normal=[0, 0, 1])
    p, T = s.to_2D()
    fig, ax = plt.subplots(figsize=(7, 3), dpi=130)
    for pl in p.polygons_full:
        pts = trimesh.transform_points(np.c_[np.asarray(pl.exterior.coords), np.zeros(len(pl.exterior.coords))], T)
        ax.fill(pts[:, 0], pts[:, 1], color="#cfe3d4", ec="#2e8c4d", lw=0.8)
        for h in pl.interiors:
            q = trimesh.transform_points(np.c_[np.asarray(h.coords), np.zeros(len(h.coords))], T)
            ax.fill(q[:, 0], q[:, 1], color="white", ec="#2e8c4d", lw=0.8)
    ax.axvline(X_STECKER, color=STECKER, ls="--", lw=1)
    ax.text(X_STECKER + 1, 11, "Anlagefläche\n(Schnitt am Griff)", color="#a0601a", va="top")
    ax.text(-119, -12.5, "Rastnut ø12,3 · Bund ø16,7 · O-Ring-Nut · Bohrung ø7,94", fontsize=8)
    ax.set_xlim(-123, -60); ax.set_ylim(-14, 13)
    ax.set_aspect("equal"); ax.set_xlabel("mm"); ax.set_title("Längsschnitt durch die Steckerachse (Draufsicht)")
    fig.tight_layout()
    fig.savefig(datei)
    plt.close(fig)


if __name__ == "__main__":
    m = trimesh.load(sys.argv[1])
    out = Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
    ansicht(m, out / "uebersicht.png", 35, -60, m.bounds, (8, 5))
    schnitt(m, out / "schnitt.png")

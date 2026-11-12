#!/usr/bin/env python3
"""Vorschaubilder für das README aus den von erzeuge_modell.py geschriebenen STLs.

Aufruf: python3 bilder.py <ausgabe_ordner> <zielordner>
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
FARBE = {"baum": (0.16, 0.52, 0.28), "stecker": (0.85, 0.55, 0.15),
         "geschenke": (0.96, 0.96, 0.94), "schleifen": (0.82, 0.15, 0.15)}
X_STECKER = -97.5 + 6.35   # Anlagefläche des Steckers im zentrierten Modell
ACHSE_Z = -0.625
NAME = "weihnachtsbaum_dusche_quick_connect"


def teile(ordner, geschenke):
    if not geschenke:
        return [("baum", trimesh.load(ordner / f"{NAME}.stl"))]
    return [(t, trimesh.load(ordner / f"{NAME}_geschenke_{t}.stl")) for t in ("baum", "geschenke", "schleifen")]


def flaechen(name, m, licht):
    tri, n = m.triangles, m.face_normals
    l = np.array(licht) / np.linalg.norm(licht)
    h = 0.35 + 0.65 * np.clip(n @ l, 0, 1)
    farbe = np.tile(FARBE[name], (len(tri), 1))
    if name == "baum":
        farbe[tri[:, :, 0].max(axis=1) < X_STECKER + 0.01] = FARBE["stecker"]
    return tri, np.clip(farbe * h[:, None], 0, 1)


def ansicht(tl, datei, elev, azim, grenzen, groesse, licht=(-0.4, -0.6, 0.9)):
    fig = plt.figure(figsize=groesse, dpi=130)
    ax = fig.add_subplot(projection="3d", computed_zorder=False)
    e, az = np.radians(elev), np.radians(azim)
    blick = np.array([np.cos(e) * np.cos(az), np.cos(e) * np.sin(az), np.sin(e)])  # zur Kamera
    tl = [(n, m.submesh([np.nonzero(m.face_normals @ blick > 0)[0]], append=True)) for n, m in tl]
    tri, fc = zip(*(flaechen(n, m, licht) for n, m in tl))
    ax.add_collection3d(Poly3DCollection(np.concatenate(tri), facecolors=np.concatenate(fc), linewidths=0))
    lo, hi = grenzen
    ax.set_xlim(lo[0], hi[0]); ax.set_ylim(lo[1], hi[1]); ax.set_zlim(lo[2], hi[2])
    ax.set_box_aspect(hi - lo)
    ax.view_init(elev, azim)
    ax.set_axis_off()
    ax.set_proj_type("ortho")
    fig.patch.set_facecolor("#e9edf2"); ax.set_facecolor("#e9edf2")
    fig.subplots_adjust(0, 0, 1, 1)
    fig.savefig(datei, facecolor="#e9edf2")
    plt.close(fig)


def draufsicht(tl, datei, xlim, titel):
    """Schnitt bei halber Stärke, von oben, farbig je Teil."""
    fig, ax = plt.subplots(figsize=(7, 4.6), dpi=130)
    for name, m in tl:
        s = m.section(plane_origin=[0, 0, 0], plane_normal=[0, 0, 1])
        if s is None:
            continue
        p, T = s.to_2D()
        for pl in p.polygons_full:
            def xy(c):
                c = np.asarray(c)
                return trimesh.transform_points(np.c_[c, np.zeros(len(c))], T)[:, :2]
            e = xy(pl.exterior.coords)
            ax.fill(e[:, 0], e[:, 1], color=FARBE[name], ec="#333", lw=0.5)
            for h in pl.interiors:
                q = xy(h.coords)
                ax.fill(q[:, 0], q[:, 1], color="white", ec="#333", lw=0.5)
    ax.set_xlim(*xlim); ax.set_ylim(-45, 45); ax.set_aspect("equal")
    ax.set_facecolor("#e9edf2"); ax.set_xlabel("mm"); ax.set_title(titel)
    fig.tight_layout(); fig.savefig(datei); plt.close(fig)


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
    ax.axvline(X_STECKER, color=FARBE["stecker"], ls="--", lw=1)
    ax.text(X_STECKER + 1, 12.5, "Anlagefläche", color="#a0601a", va="top")
    ax.text(-119, -13.5, "Rastnut ø12,3 · Bund ø16,7 · O-Ring-Nut · Bohrung ø7,94 → Griff ø21,25 / Bohrung ø10", fontsize=8)
    ax.set_xlim(-123, -55); ax.set_ylim(-15, 14)
    ax.set_aspect("equal"); ax.set_xlabel("mm"); ax.set_title("Längsschnitt durch die Steckerachse (Draufsicht)")
    fig.tight_layout()
    fig.savefig(datei)
    plt.close(fig)


if __name__ == "__main__":
    ordner, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    einfach, mit = teile(ordner, False), teile(ordner, True)
    alles = np.array([[-122, -43, -11], [122, 43, 11]])
    ansicht(einfach, out / "uebersicht.png", 35, -60, alles, (8, 5))
    ansicht(mit, out / "geschenke.png", 55, -70, alles, (9, 4.6), licht=(-0.3, -0.5, 1))
    nah = [(n, m.slice_plane([30, 0, 0], [-1, 0, 0])) for n, m in mit]
    nah = [(n, m.slice_plane([-35, 0, 0], [1, 0, 0])) for n, m in nah]
    ansicht(nah, out / "geschenke_draufsicht.png", 90, -90,
            np.array([[-35, -43, -11], [30, 43, 11]]), (6.5, 8), licht=(0.2, -0.3, 1))
    schnitt(einfach[0][1], out / "schnitt.png")

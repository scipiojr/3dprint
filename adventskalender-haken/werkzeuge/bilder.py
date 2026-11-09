#!/usr/bin/env python3
"""Vorschaubilder aus den erzeugten STL-Dateien (matplotlib, ohne OpenGL).

  bilder/haken_<bauform>_<magnete>.png   je vier Ansichten
  bilder/uebersicht.png                  alle Varianten schräg von vorn
  bilder/schnitt_relief.png              Schnitt durch den Fädelschlitz

Aufruf aus dem Projektordner: python3 werkzeuge/bilder.py
"""
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import trimesh

HIER = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BILDER = os.path.join(HIER, "bilder")
WEISS, ROT = np.array([0.97, 0.96, 0.93]), np.array([0.82, 0.07, 0.10])
GRUEN = np.array([0.15, 0.48, 0.26])   # Plattenfarbe in den Bildern (frei wählbar)
VARIANTEN = [(b, m) for b in ("relief", "rund") for m in ("1_magnet", "2_magnete", "4_magnete")]


def lade(name):
    teile = []
    for farbe, f in ((GRUEN, "platte"), (WEISS, "weiss"), (ROT, "rot")):
        m = trimesh.load(os.path.join(HIER, f"{name}_{f}.stl"))
        m.vertices = m.vertices[:, [0, 2, 1]]   # Y (oben) -> Plot-Z
        m.faces = m.faces[:, ::-1]
        teile.append((m, farbe))
    return teile


def raster(teile, el, az, px=4.0, rand=6):
    """Kleiner Software-Renderer mit Z-Puffer (orthografisch), liefert ein RGB-Bild."""
    e, a = np.radians(el), np.radians(az)
    blick = np.array([np.cos(e) * np.cos(a), np.cos(e) * np.sin(a), np.sin(e)])   # zur Kamera
    rechts = np.array([-np.sin(a), np.cos(a), 0.0])
    oben = np.cross(blick, rechts)
    licht = blick + 0.5 * oben - 0.35 * rechts
    licht /= np.linalg.norm(licht)

    tris = np.vstack([m.triangles for m, _ in teile])
    nrm = np.vstack([m.face_normals for m, _ in teile])
    farbe = np.vstack([np.tile(c, (len(m.faces), 1)) for m, c in teile])
    sicht = nrm @ blick > 1e-6
    tris, nrm, farbe = tris[sicht], nrm[sicht], farbe[sicht]
    hell = 0.30 + 0.70 * np.clip(nrm @ licht, 0, 1)
    farbe = np.clip(farbe * hell[:, None], 0, 1)

    u, v, d = tris @ rechts, tris @ oben, tris @ blick
    u0, v1 = u.min() - rand, v.max() + rand
    X, Y = (u - u0) * px, (v1 - v) * px
    W, H = int(np.ceil((u.max() + rand - u0) * px)), int(np.ceil((v1 - v.min() + rand) * px))
    zbuf = np.full((H, W), -np.inf)
    bild = np.ones((H, W, 3))
    for i in range(len(tris)):
        x, y, z = X[i], Y[i], d[i]
        xa, xb = max(int(np.floor(x.min())), 0), min(int(np.ceil(x.max())), W - 1)
        ya, yb = max(int(np.floor(y.min())), 0), min(int(np.ceil(y.max())), H - 1)
        if xb < xa or yb < ya:
            continue
        gx, gy = np.meshgrid(np.arange(xa, xb + 1) + 0.5, np.arange(ya, yb + 1) + 0.5)
        den = (y[1] - y[2]) * (x[0] - x[2]) + (x[2] - x[1]) * (y[0] - y[2])
        if abs(den) < 1e-12:
            continue
        l0 = ((y[1] - y[2]) * (gx - x[2]) + (x[2] - x[1]) * (gy - y[2])) / den
        l1 = ((y[2] - y[0]) * (gx - x[2]) + (x[0] - x[2]) * (gy - y[2])) / den
        l2 = 1 - l0 - l1
        innen = (l0 >= -1e-6) & (l1 >= -1e-6) & (l2 >= -1e-6)
        zz = l0 * z[0] + l1 * z[1] + l2 * z[2]
        sub = zbuf[ya:yb + 1, xa:xb + 1]
        neu = innen & (zz > sub)
        sub[neu] = zz[neu]
        bild[ya:yb + 1, xa:xb + 1][neu] = farbe[i]
    return bild


def zeichne(ax, teile, el, az, titel=None):
    ax.imshow(raster(teile, el, az))
    ax.set_axis_off()
    if titel:
        ax.set_title(titel, fontsize=11)


def einzelbild(name):
    teile = lade(name)
    fig = plt.figure(figsize=(16, 6.5))
    for i, (el, az, t) in enumerate([(20, 120, "schräg"), (0, 90, "vorn"), (0, 0, "seitlich"),
                                     (-35, -120, "Rückseite (Magnettaschen)")]):
        zeichne(fig.add_subplot(1, 4, i + 1), teile, el, az, t)
    fig.suptitle(name, fontsize=13)
    fig.savefig(os.path.join(BILDER, f"{name}.png"), dpi=90, bbox_inches="tight")
    plt.close(fig)


def uebersicht():
    fig = plt.figure(figsize=(15, 11))
    for i, (b, m) in enumerate(VARIANTEN):
        name = f"haken_{b}_{m}"
        zeichne(fig.add_subplot(2, 3, i + 1), lade(name), 22, 115,
                f"{b}, {m.replace('_', ' ')}")
    fig.savefig(os.path.join(BILDER, "uebersicht.png"), dpi=85, bbox_inches="tight")
    plt.close(fig)


def schnitt_relief():
    """Längsschnitt bei x = 0 durch Scheitel und Fädelschlitz (2 Magnete)."""
    fig, ax = plt.subplots(figsize=(5, 9))
    for f, c in (("platte", GRUEN), ("weiss", WEISS * 0.85), ("rot", ROT)):
        m = trimesh.load(os.path.join(HIER, f"haken_relief_2_magnete_{f}.stl"))
        sec = m.section(plane_origin=(0, 0, 0), plane_normal=(1, 0, 0))
        if sec is None:
            continue
        for poly in sec.discrete:
            ax.fill(poly[:, 2], poly[:, 1], color=c, edgecolor="k", linewidth=0.6)
    ax.axvline(0, color="0.4", lw=2)
    ax.text(-0.6, 8, "Wand", rotation=90, ha="right", va="center", color="0.4")
    ax.annotate("Fädelschlitz:\nBand hier unter\nder Stange durch", xy=(3.2, 52), xytext=(9, 40),
                arrowprops=dict(arrowstyle="->"), fontsize=9)
    ax.annotate("Magnettaschen\n(von hinten)", xy=(1.5, 36), xytext=(9, 22),
                arrowprops=dict(arrowstyle="->"), fontsize=9)
    ax.set_aspect("equal"); ax.set_xlim(-2, 16); ax.set_ylim(-1, 63)
    ax.set_xlabel("Abstand von der Wand [mm]"); ax.set_ylabel("Höhe [mm]")
    ax.set_title("Schnitt x = 0 (relief, 2 Magnete)")
    fig.savefig(os.path.join(BILDER, "schnitt_relief.png"), dpi=100, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    os.makedirs(BILDER, exist_ok=True)
    for b, m in VARIANTEN:
        einzelbild(f"haken_{b}_{m}")
    uebersicht()
    schnitt_relief()

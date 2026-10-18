#!/usr/bin/env python3
"""Vorschaubilder für das README aus den STL/SVG-Dateien, die bilder.sh erzeugt.

Aufruf: python3 bilder.py <arbeitsordner> <zielordner>
Benötigt numpy und matplotlib.
"""
import re
import sys
from pathlib import Path

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import PathPatch
from matplotlib.path import Path as MPath
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

W = Path(sys.argv[1])
OUT = Path(sys.argv[2])
OUT.mkdir(parents=True, exist_ok=True)

FARBE = {
    "plattform": "#3f8f6b",
    "baender": "#c98a4b",
    "trichter": "#4a78a8",
    "mittelteil": "#e08a2c",
    "eimer": "#9aa0a8",
    "sack": "#d9c7a3",
}
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9})


def stl(name):
    """ASCII- oder Binär-STL -> (n, 3, 3)."""
    p = W / name
    data = p.read_bytes()
    if data[:5] == b"solid" and b"facet" in data[:300]:
        v = re.findall(rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)", data)
        return np.array(v, dtype=float).reshape(-1, 3, 3)
    n = int(np.frombuffer(data[80:84], "<u4")[0])
    rec = np.frombuffer(data[84:84 + n * 50], dtype=np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")]))
    return rec["v"].astype(float)


def schattiert(tri, farbe, licht=(-0.4, -0.7, 0.9), alpha=1.0):
    n = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    n /= np.linalg.norm(n, axis=1, keepdims=True) + 1e-12
    l = np.array(licht, float)
    l /= np.linalg.norm(l)
    k = 0.35 + 0.65 * np.clip(n @ l, 0, 1)
    base = np.array(matplotlib.colors.to_rgb(farbe))
    fc = np.clip(base[None, :] * k[:, None] + 0.08 * (1 - k[:, None]), 0, 1)
    return np.c_[fc, np.full(len(fc), alpha)]


def ansicht(teile, datei, elev=24, azim=-58, titel=None, groesse=(7, 5.2), zoom=1.0):
    fig = plt.figure(figsize=groesse, dpi=150)
    ax = fig.add_subplot(111, projection="3d")
    # alle Teile in EINE Sammlung, damit die Tiefensortierung über alle Teile gilt
    tris = np.concatenate([t for t, _, _ in teile])
    fcs = np.concatenate([schattiert(t, f, alpha=a) for t, f, a in teile])
    ax.add_collection3d(Poly3DCollection(tris, facecolors=fcs, edgecolors="none", linewidths=0))
    p = tris.reshape(-1, 3)
    lo, hi = p.min(0), p.max(0)
    mid, span = (lo + hi) / 2, (hi - lo).max() / 2 / zoom
    ax.set_xlim(mid[0] - span, mid[0] + span)
    ax.set_ylim(mid[1] - span, mid[1] + span)
    ax.set_zlim(mid[2] - span, mid[2] + span)
    ax.set_box_aspect((1, 1, 1))
    ax.view_init(elev=elev, azim=azim)
    ax.set_axis_off()
    if titel:
        ax.set_title(titel, fontsize=11)
    fig.subplots_adjust(0, 0, 1, 1)
    fig.savefig(OUT / datei, bbox_inches="tight", pad_inches=0.05, facecolor="white")
    plt.close(fig)
    print("Bild", datei)


def kanten(tri, farbe="#6b7079"):
    """Nur Umriss: Dreiecke als sehr helle Fläche (für den Eimer)."""
    return (tri, farbe, 0.10)


# ---------------------------------------------------------------- SVG-Schnitte
def svg_pfade(name):
    txt = (W / name).read_text()
    polys = []
    for d in re.findall(r'd="([^"]+)"', txt, re.S):
        for teil in re.split(r"z", d):
            pts = re.findall(r"(-?[\d.]+),(-?[\d.]+)", teil)
            if len(pts) >= 3:
                polys.append(np.array(pts, float))
    return polys


def schnitt_zeichnen(ax, praefix, umrechnen):
    reihenfolge = ["sack", "eimer", "plattform", "baender", "trichter"]
    for k in reihenfolge:
        polys = svg_pfade(f"{praefix}_{k}.svg")
        if not polys:
            continue
        verts, codes = [], []
        for p in polys:
            q = umrechnen(p)
            verts += list(q) + [q[0]]
            codes += [MPath.MOVETO] + [MPath.LINETO] * (len(q) - 1) + [MPath.CLOSEPOLY]
        pfad = MPath(np.array(verts), codes)
        if k == "sack":
            patch = PathPatch(pfad, facecolor=FARBE[k], alpha=0.45, edgecolor="#a8946c", lw=0.6, ls="--")
        else:
            patch = PathPatch(pfad, facecolor=FARBE[k], edgecolor="#222", lw=0.4)
        ax.add_patch(patch)
    ax.set_aspect("equal")
    ax.autoscale_view()


def schnittbild():
    fig, axs = plt.subplots(1, 2, figsize=(11, 6.2), dpi=150, gridspec_kw={"width_ratios": [283, 216]})
    # Längsschnitt y = 0: SVG liefert (x, z)
    schnitt_zeichnen(axs[0], "sy", lambda p: p)
    axs[0].set_title("Längsschnitt (Mitte)")
    # Querschnitt x = 55 durch ein Bügelbein: SVG liefert (-z, -y)
    schnitt_zeichnen(axs[1], "sx", lambda p: np.c_[-p[:, 1], -p[:, 0]])
    axs[1].set_title("Querschnitt (durch ein Bügelbein)")
    for ax in axs:
        ax.set_xlabel("mm")
        ax.grid(alpha=0.25, lw=0.5)
    axs[0].set_ylabel("Höhe über Innenboden [mm]")
    from matplotlib.patches import Patch
    leg = [Patch(fc=FARBE["trichter"], ec="#222", label="Trichter"),
           Patch(fc=FARBE["plattform"], ec="#222", label="Plattform"),
           Patch(fc=FARBE["baender"], ec="#222", label="Bänder / Bügel"),
           Patch(fc=FARBE["sack"], alpha=0.45, ec="#a8946c", ls="--", label="Papiersack (Platzhalter)"),
           Patch(fc=FARBE["eimer"], ec="#222", label="Eimerwand")]
    fig.legend(handles=leg, loc="lower center", ncol=5, frameon=False)
    fig.tight_layout(rect=(0, 0.06, 1, 1))
    fig.savefig(OUT / "schnitt.png", facecolor="white")
    plt.close(fig)
    print("Bild schnitt.png")


# ---------------------------------------------------------------- Bilder
eimer = stl("asm_eimer.stl")
pl = stl("asm_plattform.stl")
ba = stl("asm_baender.stl")
tr = stl("asm_trichter.stl")
mt = stl("asm_mittelteil.stl")

ansicht([kanten(eimer), (pl, FARBE["plattform"], 1), (ba, FARBE["baender"], 1),
         (tr, FARBE["trichter"], 1), (mt, FARBE["mittelteil"], 1)],
        "uebersicht.png", elev=28, azim=-55, zoom=1.15)
ansicht([(pl, FARBE["plattform"], 1), (ba, FARBE["baender"], 1)],
        "korb.png", elev=22, azim=-55, zoom=1.15)
ansicht([(tr, FARBE["trichter"], 1), (mt, FARBE["mittelteil"], 1)],
        "trichter.png", elev=38, azim=-60, zoom=1.0)
ansicht([(stl("plattform.stl"), FARBE["plattform"], 1)], "plattform.png", elev=55, azim=-60, zoom=1.1)
ansicht([(stl("langseite.stl"), FARBE["baender"], 1)], "buegel_langseite.png", elev=60, azim=-80, zoom=1.0)
ansicht([(stl("schmalseite.stl"), FARBE["baender"], 1)], "band_schmalseite.png", elev=60, azim=-80, zoom=1.0)
ansicht([(stl("trichter0.stl"), FARBE["trichter"], 1)], "trichter_haelfte.png", elev=40, azim=-50, zoom=1.1)
schnittbild()

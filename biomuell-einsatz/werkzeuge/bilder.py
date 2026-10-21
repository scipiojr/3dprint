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
    "waende": "#d9772b",
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
    if not (W / name).exists():      # leere Baugruppe (z. B. keine Bänder bei schmalseite_typ = wand)
        return []
    txt = (W / name).read_text()
    polys = []
    for d in re.findall(r'd="([^"]+)"', txt, re.S):
        for teil in re.split(r"z", d):
            pts = re.findall(r"(-?[\d.]+),(-?[\d.]+)", teil)
            if len(pts) >= 3:
                polys.append(np.array(pts, float))
    return polys


def schnitt_zeichnen(ax, praefix, umrechnen):
    reihenfolge = ["sack", "eimer", "plattform", "baender", "waende", "trichter"]
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
           Patch(fc=FARBE["baender"], ec="#222", label="Bügel"),
           Patch(fc=FARBE["waende"], ec="#222", label="Seitenwände"),
           Patch(fc=FARBE["sack"], alpha=0.45, ec="#a8946c", ls="--", label="Papiersack (Platzhalter)"),
           Patch(fc=FARBE["eimer"], ec="#222", label="Eimerwand")]
    fig.legend(handles=leg, loc="lower center", ncol=6, frameon=False)
    fig.tight_layout(rect=(0, 0.06, 1, 1))
    fig.savefig(OUT / "schnitt.png", facecolor="white")
    plt.close(fig)
    print("Bild schnitt.png")


# ---------------------------------------------------------------- Bilder
eimer = stl("asm_eimer.stl")
pl = stl("asm_plattform.stl")
ba = stl("asm_baender.stl")
wa = stl("asm_waende.stl")
tr = stl("asm_trichter.stl")
mt = stl("asm_mittelteil.stl") if (W / "asm_mittelteil.stl").exists() else np.zeros((0, 3, 3))   # nur mit mittelteil > 0

ansicht([kanten(eimer), (pl, FARBE["plattform"], 1), (ba, FARBE["baender"], 1), (wa, FARBE["waende"], 1),
         (tr, FARBE["trichter"], 1)] + ([(mt, FARBE["mittelteil"], 1)] if len(mt) else []),
        "uebersicht.png", elev=28, azim=-55, zoom=1.15)
ansicht([(pl, FARBE["plattform"], 1), (ba, FARBE["baender"], 1), (wa, FARBE["waende"], 1)],
        "korb.png", elev=22, azim=-55, zoom=1.15)
ansicht([(tr, FARBE["trichter"], 1)] + ([(mt, FARBE["mittelteil"], 1)] if len(mt) else []),
        "trichter.png", elev=38, azim=-60, zoom=1.0)
ansicht([(stl("plattform.stl"), FARBE["plattform"], 1)], "plattform.png", elev=55, azim=-60, zoom=1.1)
ansicht([(stl("langseite.stl"), FARBE["baender"], 1)], "buegel_langseite.png", elev=60, azim=-80, zoom=1.0)
ansicht([(stl("schmalseite.stl"), FARBE["baender"], 1)], "band_schmalseite.png", elev=60, azim=-80, zoom=1.0)
ansicht([(stl("seitenwand.stl"), FARBE["waende"], 1)], "seitenwand.png", elev=55, azim=-70, zoom=1.0)
ansicht([(stl("rastprobe.stl"), FARBE["waende"], 1)], "rastprobe.png", elev=40, azim=-60, zoom=1.0)
ansicht([(stl("trichter0.stl"), FARBE["trichter"], 1)], "trichter_haelfte.png", elev=40, azim=-50, zoom=1.1)
schnittbild()


def wandschnitt():
    """Schnitt durch einen Seitensteg: links ganze Wand, rechts Zapfen in der Tasche mit Rastnase."""
    fig, axs = plt.subplots(1, 2, figsize=(11, 6), dpi=150, gridspec_kw={"width_ratios": [1, 1]})
    for ax, (x0, x1, z0, z1) in zip(axs, [(85, 115, 30, 165), (92, 112, 30, 62)]):
        for k in ["plattform", "waende"]:
            polys = svg_pfade(f"sw_{k}.svg")
            verts, codes = [], []
            for p in polys:
                verts += list(p) + [p[0]]
                codes += [MPath.MOVETO] + [MPath.LINETO] * (len(p) - 1) + [MPath.CLOSEPOLY]
            if verts:
                ax.add_patch(PathPatch(MPath(np.array(verts), codes), facecolor=FARBE[k], edgecolor="#222", lw=0.5))
        ax.axvline(100, color="#a8946c", ls="--", lw=1)
        ax.text(99.7, z1 - (z1 - z0) * 0.04, "Sack", ha="right", va="top", color="#a8946c", fontsize=8)
        ax.set_xlim(x0, x1)
        ax.set_ylim(z0, z1)
        ax.set_aspect("equal")
        ax.grid(alpha=0.25, lw=0.5)
        ax.set_xlabel("x ab Mitte [mm]")
    axs[0].set_ylabel("Höhe über Innenboden [mm]")
    axs[0].set_title("Seitenwand im Schnitt (durch einen Steg)")
    axs[1].set_title("Zapfen in der Tasche, Rastnase unter dem Block")
    fig.tight_layout()
    fig.savefig(OUT / "schnitt_wand.png", facecolor="white")
    plt.close(fig)
    print("Bild schnitt_wand.png")


wandschnitt()


def magnetschnitt():
    """Schnitt durch die Magnettaschen (x = einsatz_x, Option griff_einsatz/trichter_einsatz = magnet):
    Griffsteg des Bügels und Trichterschräge mit je einer geschlossenen Tasche hinter 0,6 mm Haut.
    Die Beschriftungen gelten für die Standardwerte (absatz_z = 275, Magnet 15 x 3)."""
    fig, ax = plt.subplots(figsize=(11, 6.4), dpi=150)
    umr = lambda p: np.c_[-p[:, 1], -p[:, 0]]          # SVG (-z, -y) -> (y, z)

    def zeichne(name, farbe, **kw):
        polys = svg_pfade(name)
        verts, codes = [], []
        for p in polys:
            q = umr(p)
            verts += list(q) + [q[0]]
            codes += [MPath.MOVETO] + [MPath.LINETO] * (len(q) - 1) + [MPath.CLOSEPOLY]
        if verts:
            ax.add_patch(PathPatch(MPath(np.array(verts), codes), facecolor=farbe, **kw))

    zeichne("sx_sack.svg", FARBE["sack"], alpha=0.45, edgecolor="#a8946c", lw=0.6, ls="--")
    zeichne("sx_eimer.svg", FARBE["eimer"], edgecolor="#222", lw=0.4)
    zeichne("sm_plattform.svg", FARBE["plattform"], edgecolor="#222", lw=0.4)
    zeichne("sm_baender.svg", FARBE["baender"], edgecolor="#222", lw=0.5)
    zeichne("sm_trichter.svg", FARBE["trichter"], edgecolor="#222", lw=0.5)
    ax.set_xlim(62, 132)
    ax.set_ylim(212, 292)
    ax.set_aspect("equal")
    ax.grid(alpha=0.25, lw=0.5)
    ax.set_xlabel("y ab Mitte [mm] (Langseite rechts)")
    ax.set_ylabel("Höhe über Innenboden [mm]")
    ax.set_title("Magnettaschen im Schnitt (x = 50): Griffsteg (links) und Trichterschräge (rechts)")
    pfeil = dict(arrowstyle="-", color="#333", lw=0.8)
    ax.annotate("Tasche im Griff: Magnet 15 x 3,\n0,6 mm Haut zur Außenseite", xy=(80.5, 270), xytext=(63, 284),
                fontsize=8, arrowprops=pfeil)
    ax.annotate("Tasche im Trichter, senkrecht zur Schräge,\nauf kegeliger Aufdickung (hier 1,5 mm),\n0,6 mm Haut zum Griff hin", xy=(96, 270),
                xytext=(107, 262), fontsize=8, arrowprops=pfeil)
    # Abstand Griff-Außenseite (hängend) bis Kontaktfläche der Aufdickung (Standardwerte, Neigung 75,05 Grad)
    z_m = 262
    y_kontakt = 93.36 + (z_m - 268) * np.tan(np.radians(90 - 75.05))
    ax.annotate("", xy=(y_kontakt, z_m), xytext=(82.7, z_m), arrowprops=dict(arrowstyle="<->", color="#b00020", lw=1))
    ax.text((82.7 + y_kontakt) / 2, z_m - 1.5, "ca. 11 mm", color="#b00020", fontsize=8, ha="center", va="top")
    ax.text(63, 238, "Der Bügel wird zum\nTrichter hin angelehnt\n(Band flexibel); die\nMagnete halten ihn dort.", fontsize=8, color="#b00020")
    ax.text(80.2, 291, "Sack", ha="right", va="top", color="#a8946c", fontsize=8)
    fig.tight_layout()
    fig.savefig(OUT / "schnitt_magnet.png", facecolor="white")
    plt.close(fig)
    print("Bild schnitt_magnet.png")


if (W / "sm_trichter.svg").exists():
    magnetschnitt()

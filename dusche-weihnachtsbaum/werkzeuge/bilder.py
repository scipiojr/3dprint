#!/usr/bin/env python3
"""Vorschaubilder für das README aus den von erzeuge_modell.py geschriebenen 3MFs.

Gezeigt werden die Druckfarben: Filament je Bauteil plus die Bemalung (paint_color)
je Dreieck, vereinfacht auf die flächenmäßig überwiegende Farbe.

Aufruf: python3 bilder.py <ausgabe_ordner> <zielordner>
Benötigt numpy, trimesh, shapely, matplotlib.
"""
import sys
from pathlib import Path

import re
import zipfile

import numpy as np
import trimesh
from lxml import etree
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9})
# Filamente wie in erzeuge_modell.py: 1 Grün, 2 Rot, 3 Gold, 4 Weiß
FILAMENT = {1: (0.16, 0.52, 0.28), 2: (0.82, 0.15, 0.15), 3: (0.93, 0.74, 0.18), 4: (0.96, 0.96, 0.94)}
NS = {"m": "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"}
X_STECKER = -97.5 + 6.35   # Anlagefläche des Steckers im zentrierten Modell
ACHSE_Z = -0.625
NAME = "weihnachtsbaum_dusche_quick_connect"


def ueberwiegend(code):
    """Flächenmäßig überwiegender Zustand eines paint_color-Baums (0 = unbemalt)."""
    nib = [int(c, 16) for c in reversed(code)]
    anteil, i = {}, 0

    def knoten(gewicht):
        nonlocal i
        c = nib[i]; i += 1
        if c & 3:
            for _ in range((c & 3) + 1):
                knoten(gewicht / ((c & 3) + 1))
            return
        if (c & 12) == 12:
            z = nib[i] + 3; i += 1
        else:
            z = c >> 2
        anteil[z] = anteil.get(z, 0) + gewicht

    knoten(1.0)
    return max(anteil, key=anteil.get)


def teile(ordner, geschenke):
    """-> Liste (Name, Trimesh, Farbe je Dreieck) aus der 3MF."""
    datei = ordner / (f"{NAME}_geschenke.3mf" if geschenke else f"{NAME}.3mf")
    z = zipfile.ZipFile(datei)
    filament = {int(i): int(f) for i, f in re.findall(
        r'<part id="(\d+)".*?key="extruder" value="(\d+)"', z.read("Metadata/model_settings.config").decode(), re.S)}
    # Stützen-Blocker/-Verstärker sind keine Druckteile -> nicht zeichnen
    ms = z.read("Metadata/model_settings.config").decode()
    kein_teil = {int(i) for i, a in re.findall(r'<part id="(\d+)" subtype="(\w+)"', ms)
                 if a in ("support_blocker", "support_enforcer", "negative_part", "modifier_part")}
    t = etree.fromstring(z.read("3D/Objects/object_1.model"))
    out = []
    for o in t.iterfind(".//m:object", NS):
        if int(o.get("id")) in kein_teil:
            continue
        v = np.array([[float(e.get(k)) for k in "xyz"] for e in o.iterfind(".//m:vertex", NS)])
        tri = list(o.iterfind(".//m:triangle", NS))
        f = np.array([[int(e.get(k)) for k in ("v1", "v2", "v3")] for e in tri])
        grund = filament[int(o.get("id"))]
        farbe = np.array([FILAMENT[(ueberwiegend(e.get("paint_color")) if e.get("paint_color") else 0) or grund]
                          for e in tri])
        out.append((o.get("id"), trimesh.Trimesh(v, f, process=False), farbe))
    return out


def flaechen(m, farbe, licht):
    l = np.array(licht) / np.linalg.norm(licht)
    h = 0.35 + 0.65 * np.clip(m.face_normals @ l, 0, 1)
    return m.triangles, np.clip(farbe * h[:, None], 0, 1)


def ansicht(tl, datei, elev, azim, grenzen, groesse, licht=(-0.4, -0.6, 0.9)):
    fig = plt.figure(figsize=groesse, dpi=130)
    ax = fig.add_subplot(projection="3d", computed_zorder=False)
    e, az = np.radians(elev), np.radians(azim)
    blick = np.array([np.cos(e) * np.cos(az), np.cos(e) * np.sin(az), np.sin(e)])  # zur Kamera
    sichtbar = [(m, c, np.nonzero(m.face_normals @ blick > 0)[0]) for _, m, c in tl]
    tl = [(m.submesh([i], append=True), c[i]) for m, c, i in sichtbar]
    tri, fc = zip(*(flaechen(m, c, licht) for m, c in tl))
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
    ax.axvline(X_STECKER, color="#a0601a", ls="--", lw=1)
    ax.text(X_STECKER + 1, 12.5, "Anlagefläche", color="#a0601a", va="top")
    ax.text(-119, -13.5, "Rastnut ø12,3 · Bund ø16,7 · O-Ring-Nut · Bohrung ø7,94 → Griff ø21,25 / Bohrung ø10", fontsize=8)
    ax.set_xlim(-123, -55); ax.set_ylim(-15, 14)
    ax.set_aspect("equal"); ax.set_xlabel("mm"); ax.set_title("Längsschnitt durch die Steckerachse (Draufsicht)")
    fig.tight_layout()
    fig.savefig(datei)
    plt.close(fig)


def innenraum(ordner, datei):
    """Schnitte durch Bohrung (Tropfenform) und Kammer mit dem Stützen-Blocker aus der 3MF."""
    z = zipfile.ZipFile(ordner / f"{NAME}.3mf")
    ms = z.read("Metadata/model_settings.config").decode()
    bid = int(re.search(r'<part id="(\d+)" subtype="support_blocker"', ms).group(1))
    t = etree.fromstring(z.read("3D/Objects/object_1.model"))
    o = [e for e in t.iterfind(".//m:object", NS) if int(e.get("id")) == bid][0]
    bl = trimesh.Trimesh(np.array([[float(e.get(k)) for k in "xyz"] for e in o.iterfind(".//m:vertex", NS)]),
                         np.array([[int(e.get(k)) for k in ("v1", "v2", "v3")] for e in o.iterfind(".//m:triangle", NS)]),
                         process=False)
    m = trimesh.load(str(ordner / f"{NAME}.stl"))
    fig = plt.figure(figsize=(11, 6.2), dpi=130)
    gs = fig.add_gridspec(2, 3, height_ratios=[1, 1.15])
    for k, (x, t_) in enumerate([(-110, "Stecker (x = -110)"), (-50, "Griff (x = -50)"), (4, "Hals/Fuß (x = 4)")]):
        ax = fig.add_subplot(gs[0, k])
        for e in m.section(plane_origin=[x, 0, 0], plane_normal=[1, 0, 0]).discrete:
            ax.plot(e[:, 1], e[:, 2], "k", lw=0.8)
        ax.axhline(-10.625, color="r", lw=0.6)
        ax.set_aspect("equal"); ax.set_title(t_ + " – Bohrung als Tropfen", fontsize=8); ax.tick_params(labelsize=6)
    ax = fig.add_subplot(gs[1, :])
    for e in m.section(plane_origin=[0, 0, 0], plane_normal=[0, 1, 0]).discrete:
        ax.plot(e[:, 0], e[:, 2], "k", lw=0.7)
    sb = bl.section(plane_origin=[0, 0, 0], plane_normal=[0, 1, 0])
    for e in sb.discrete:
        ax.fill(e[:, 0], e[:, 2], color="tab:blue", alpha=0.25, lw=0)
        ax.plot(e[:, 0], e[:, 2], color="tab:blue", lw=0.6)
    ax.set_aspect("equal"); ax.set_xlim(-30, 125)
    ax.set_title("Längsschnitt y = 0: blau = Stützen-Blocker in der Kammer (Pfosten Ø 1,5 mm stehen unverändert)", fontsize=8)
    ax.tick_params(labelsize=6)
    fig.tight_layout(); fig.savefig(datei); plt.close(fig)


if __name__ == "__main__":
    ordner, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    innenraum(ordner, out / "innenraum.png")
    einfach, mit = teile(ordner, False), teile(ordner, True)
    alles = np.array([[-122, -43, -11], [122, 43, 11]])
    ansicht(einfach, out / "uebersicht.png", 35, -60, alles, (8, 5))
    ansicht(mit, out / "geschenke.png", 55, -70, alles, (9, 4.6), licht=(-0.3, -0.5, 1))
    def ausschnitt(n, m, c, x0, x1):
        i = np.nonzero((m.triangles_center[:, 0] > x0) & (m.triangles_center[:, 0] < x1))[0]
        return n, m.submesh([i], append=True), c[i]
    nah = [ausschnitt(n, m, c, -35, 30) for n, m, c in mit]
    ansicht(nah, out / "geschenke_draufsicht.png", 90, -90,
            np.array([[-35, -43, -11], [30, 43, 11]]), (6.5, 8), licht=(0.2, -0.3, 1))
    schnitt(einfach[0][1], out / "schnitt.png")

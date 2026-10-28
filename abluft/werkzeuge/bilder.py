#!/usr/bin/env python3
"""Erzeugt die Vorschaubilder in bilder/ aus den STL-Dateien.
Aufruf (aus dem Ordner abluft/):  python3 -I werkzeuge/bilder.py
Pakete: trimesh, numpy, matplotlib. Maße (Dicken, Loch) werden aus abluft_system.scad gelesen."""
import re
from pathlib import Path
import numpy as np
import trimesh
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

tf = trimesh.transformations
O = Path(__file__).resolve().parent.parent
text = (O / "abluft_system.scad").read_text()
wert = lambda n: float(re.search(rf"^{n}\s*=\s*([-0-9.]+)\s*;", text, re.M).group(1))
disc_t, nut_t, plate_t, hole_r = wert("disc_t"), wert("nut_t"), wert("plate_t"), wert("hole_d") / 2
lade = lambda n: trimesh.load(O / n)
innen, aussen = lade("durchfuehrung_innen.stl"), lade("durchfuehrung_aussen.stl")
magnet, stutzen = lade("verjuengung_150_110_magnet.stl"), lade("verjuengung_150_110_stutzen.stl")
o150p, o150a = lade("dichtung_150_plexiglas_tpu.stl"), lade("dichtung_150_anschluss_tpu.stl")
ventilator = lade("adapter_ventilator_140_110.stl")

def kontur(ax, m, farbe, lw=0.7, y=0.0):
    s = m.section(plane_origin=[0, y, 0], plane_normal=[0, 1, 0])
    for e in s.discrete:
        ax.plot(e[:, 0], e[:, 2], color=farbe, lw=lw)

# --- Schnitt durch den Aufbau (Ebene y=0), Innenseite unten (Raum), Aussenseite oben (Dach) ---
z_aussen = disc_t + plate_t + nut_t
a = aussen.copy(); a.apply_transform(tf.concatenate_matrices(tf.translation_matrix([0, 0, z_aussen]), tf.rotation_matrix(np.pi, [1, 0, 0]), tf.rotation_matrix(np.radians(97), [0, 0, 1])))
v = magnet.copy(); v.apply_transform(tf.translation_matrix([0, 0, z_aussen]))
i = innen.copy()
fig, ax = plt.subplots(figsize=(15, 8))
for sgn in (1, -1):
    ax.add_patch(Rectangle((sgn * hole_r if sgn > 0 else -hole_r - 40, disc_t), 40, plate_t, color="#9ecae1", alpha=.6, lw=0))
kontur(ax, i, "#08519c"); kontur(ax, a, "#e6550d"); kontur(ax, v, "#31a354")
ax.set_aspect("equal"); ax.set_xlim(-125, 125); ax.grid(alpha=.3)
ax.set_title("Schnitt durch den Aufbau: Innenscheibe (blau) – Plexiglas (hellblau) – Halteplatte (orange) – Verjüngung (grün)")
ax.set_xlabel("mm"); ax.set_ylabel("mm (Magnetfläche der Innenscheibe bei 0)")
fig.tight_layout(); fig.savefig(O / "bilder" / "schnitt_aufbau.png", dpi=80); plt.close(fig)

# --- Draufsicht auf die Magnetflächen und Dichtungsnuten ---
fig, axs = plt.subplots(1, 3, figsize=(24, 8))
for ax, (m, z, titel) in zip(axs, [(innen, 1.0, "Innenscheibe, Magnetfläche (z = 1)"),
                                  (aussen, 1.0, "Halteplatte, Magnetfläche (z = 1)"),
                                  (magnet, 1.0, "Verjüngung, 150er-Magnetfläche (z = 1)")]):
    s = m.section(plane_origin=[0, 0, z], plane_normal=[0, 0, 1])
    for e in s.discrete:
        ax.plot(e[:, 0], e[:, 1], "k", lw=0.8)
    ax.set_aspect("equal"); ax.grid(alpha=.3); ax.set_title(titel)
fig.tight_layout(); fig.savefig(O / "bilder" / "magnetflaechen.png", dpi=55); plt.close(fig)

# --- Verjuengung im Schnitt (beide Varianten) ---
fig, axs = plt.subplots(1, 2, figsize=(18, 9))
for ax, (m, t) in zip(axs, [(magnet, "Verjüngung mit 110er-Magnetflansch"), (stutzen, "Variante mit festem Stutzen")]):
    kontur(ax, m, "k", 0.8); ax.set_aspect("equal"); ax.grid(alpha=.3); ax.set_title(t)
fig.tight_layout(); fig.savefig(O / "bilder" / "verjuengung.png", dpi=55); plt.close(fig)
# --- Ventilator-Adapter im Schnitt ---
fig, ax = plt.subplots(figsize=(12, 9))
kontur(ax, ventilator, "k", 0.8); ax.set_aspect("equal"); ax.grid(alpha=.3)
ax.set_title("Ventilator-Adapter 140 → 110: Magnetflansch unten, Muffe (ø146,4) oben")
fig.tight_layout(); fig.savefig(O / "bilder" / "adapter_ventilator.png", dpi=60); plt.close(fig)
print("Bilder geschrieben")

#!/usr/bin/env python3
"""Zeichnet den Längsschnitt (Mitte der Box) aus den STL-Dateien: bilder/schnitt.png

Aufruf: bild_schnitt.py [kleinteilebox_2x3.stl] [kleinteilebox_2x3_stuetzturm.stl] [aus.png]
Tragzone (Modifier-Bereich) rot hinterlegt, Stützturm blau, Wandsteg schematisch gestrichelt.
Braucht numpy und matplotlib.
"""
import sys
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from matplotlib.collections import LineCollection  # noqa: E402

sys.path.insert(0, str(Path(__file__).resolve().parent))
from stl_werkzeug import lade  # noqa: E402
from traglast import parameter  # noqa: E402


def schnitt(tri, x0):
    """Schnittsegmente (y, z) der Dreiecke mit der Ebene x = x0."""
    seg = []
    d = tri[:, :, 0] - x0
    for t, dd in zip(tri, d):
        pts = []
        for i in range(3):
            j = (i + 1) % 3
            if (dd[i] > 0) != (dd[j] > 0):
                f = dd[i] / (dd[i] - dd[j])
                p = t[i] + f * (t[j] - t[i])
                pts.append((p[1], p[2]))
        if len(pts) == 2:
            seg.append(pts)
    return seg


def main():
    wurzel = Path(__file__).resolve().parent.parent
    box = Path(sys.argv[1]) if len(sys.argv) > 1 else wurzel / 'kleinteilebox_2x3.stl'
    turm = Path(sys.argv[2]) if len(sys.argv) > 2 else wurzel / 'kleinteilebox_2x3_stuetzturm.stl'
    aus = Path(sys.argv[3]) if len(sys.argv) > 3 else wurzel / 'bilder' / 'schnitt.png'
    p = parameter()
    tb, tt = lade(box), lade(turm)
    x0 = (tb[:, :, 0].min() + tb[:, :, 0].max()) / 2 + 0.3
    H = p['H']
    hook_over = p['hook_t'] + p['rail_t'] + p['hook_clear']
    zb = H - p['band_h']
    ymax = tb[:, :, 1].max()

    fig, ax = plt.subplots(figsize=(15, 6.2), dpi=110)
    ax.axhspan(zb, H + 0.4, color='tomato', alpha=0.13, lw=0)
    ax.add_collection(LineCollection(schnitt(tb, x0), colors='#222222', linewidths=1.8))
    ax.add_collection(LineCollection(schnitt(tt, x0), colors='#2c6fb7', linewidths=1.4))
    # Wandsteg schematisch (Höhe unbekannt, nur die obersten 12 mm)
    zr = H - p['hook_top']
    ax.add_patch(plt.Rectangle((p['hook_t'], zr - 12), p['rail_t'], 12, fill=False, ls='--', ec='#777777', lw=1.2))
    ax.annotate('Wandsteg (Lage schematisch)', (p['hook_t'] + p['rail_t'] / 2, zr - 12), xytext=(-20, zr - 22),
                fontsize=9, color='#555555', ha='center', arrowprops=dict(arrowstyle='-', color='#777777'))
    ax.text(ymax / 2, H - 4.5, f"Tragzone: {p['band_h']:.0f} mm = {p['band_h'] / 0.2:.0f} Schichten, Modifier 100 % Füllung, 6 Wände",
            ha='center', va='center', color='#b03a2e', fontsize=11, fontweight='bold')
    ax.text(ymax * 0.62, zb - 20, f"leichter Bereich: Wand {p['wall']:.1f} mm (3 Wände), Füllung 5 % (praktisch ohne Wirkung)",
            ha='center', va='center', color='#333333', fontsize=10)
    ax.annotate('Hakenlippe', (p['hook_t'] / 2, H - p['hook_top'] - p['hook_drop'] / 2), xytext=(12, H - 34),
                fontsize=9, arrowprops=dict(arrowstyle='->'))
    ax.annotate('Stützturm (nach Druck weg)', (-6, 30), xytext=(-48, 18), fontsize=9, color='#2c6fb7',
                arrowprops=dict(arrowstyle='->', color='#2c6fb7'))
    ax.annotate('Etiketten-\neinschub', (ymax - 1, H - 15), xytext=(ymax - 8, H - 33), fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->'))
    ax.annotate('Boden (automatisch\naus Traglast)', (ymax / 2, 0.6), xytext=(ymax / 2, 14), fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->'))
    ax.set_xlim(-60, ymax + 12)
    ax.set_ylim(-4, H + 6)
    ax.set_aspect('equal')
    ax.set_xlabel('Tiefe von der Wand [mm]  (links Wandseite mit Haken, rechts Vorderseite)')
    ax.set_ylabel('Höhe [mm]')
    ax.set_title(f'Kleinteilebox {Path(box).stem.split("_")[-1]}: Längsschnitt durch die Mitte', fontsize=12)
    ax.grid(alpha=0.25)
    aus.parent.mkdir(exist_ok=True)
    fig.tight_layout()
    fig.savefig(aus)
    print('geschrieben:', aus)


if __name__ == '__main__':
    main()

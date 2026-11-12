#!/usr/bin/env python3
"""Maßzeichnung (Längsschnitt-Profil) des Steckers -> bilder/profil.png. Benötigt matplotlib."""
import os, sys
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt

HIER = os.path.dirname(os.path.abspath(__file__))
koerper = [(-19, 23), (-5.4, 20.7), (0, 18.8)]
st = [(0, 12.4), (7.2, 12.4), (7.2, 16.7), (10.2, 16.7), (10.9, 14), (18.8, 14), (18.8, 14.3), (20.6, 14.3),
      (20.6, 11.3), (23.1, 11.3), (23.1, 14.2), (27.9, 14.2), (30.4, 12.2)]
pts = koerper + [(0, 12.4)] + st
fig, ax = plt.subplots(figsize=(11, 4.6))
x = [p[0] for p in pts]; r = [p[1] / 2 for p in pts]
ax.plot(x, r, 'k-', lw=1.6); ax.plot(x, [-v for v in r], 'k-', lw=1.6)
ax.plot([x[0], x[0]], [r[0], -r[0]], 'k-', lw=1.6); ax.plot([x[-1], x[-1]], [r[-1], -r[-1]], 'k-', lw=1.6)
ax.axhline(0, color='gray', ls='-.', lw=0.8)
ax.fill_between([-19, 0], [-5, -5], [5, 5], color='#cde', alpha=.7)
ax.fill_between([0, 30.4], [-3.97, -3.97], [3.97, 3.97], color='#cde', alpha=.7)
ax.axvline(0, color='#a0601a', ls='--', lw=1)
ax.text(0.3, -15.5, 'z = 0 Anlagefläche', color='#a0601a', fontsize=9)
# (z0, z1, Durchmesser, Text, Höhe der Beschriftung, oben=1 / unten=-1)
for (z0, z1, d, t, h, sg) in [(-19, -5.4, 23, 'Ø23 → 20,7 auf 13,6', 14.5, 1), (-5.4, 0, 20.7, 'Ø20,7 → 18,8 auf 5,4', -12.5, -1),
                              (0, 7.2, 12.4, 'Rastnut Ø12,4 · 7,2', 12.0, 1), (7.2, 10.2, 16.7, 'Bund Ø16,7 · 3', 14.5, 1),
                              (10.9, 18.8, 14, 'Backen Ø14 · 7,9\nTaschen 11,8 dick,\n7,2 breit, 6,4 lang', -9.5, -1),
                              (18.8, 20.6, 14.3, 'Ring Ø14,3 · 1,8', 12.0, 1), (20.6, 23.1, 11.3, 'O-Ring-Nut\nØ11,3 · 2,5', -10.5, -1),
                              (23.1, 27.9, 14.2, 'Ø14,2 · 4,8', 14.5, 1), (27.9, 30.4, 12.2, 'Fase auf Ø12,2\nauf 2,5', -10.5, -1)]:
    zm = (z0 + z1) / 2
    ax.annotate(t, (zm, sg * (d / 2 + 0.2)), (zm - (3.5 if 'Backen' in t else 0), h), ha='center', va='bottom' if sg > 0 else 'top',
                fontsize=7.5, arrowprops=dict(arrowstyle='-', color='gray', lw=0.6))
ax.text(-9, 0, 'Ø10 (Schlauch)', ha='center', va='center', fontsize=8)
ax.text(15, 0, 'Bohrung Ø7,94', ha='center', va='center', fontsize=8)
ax.set_aspect('equal'); ax.set_xlim(-21, 33); ax.set_ylim(-17, 18.5)
ax.set_xlabel('mm entlang der Achse (z)'); ax.set_yticks([])
ax.set_title('Schnellkupplungs-Stecker, Längsschnitt (Körper z < 0 nur beim Einzelteil)')
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HIER, '..', 'bilder', 'profil.png')
os.makedirs(os.path.dirname(out), exist_ok=True); fig.savefig(out, dpi=140, bbox_inches='tight')

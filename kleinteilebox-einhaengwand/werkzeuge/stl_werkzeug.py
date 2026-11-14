#!/usr/bin/env python3
"""STL laden und prüfen (nur numpy). Auch als Skript: stl_werkzeug.py datei.stl [...]

Prüft: Dreiecke, Bounding-Box, Volumen (mm³), wasserdicht (jede Kante genau einmal je Richtung),
Zahl der getrennten Körper. Gibt für PETG (1,27 g/cm³) das Vollkörpergewicht an (ohne Slicer-Füllung,
nur Obergrenze).
"""
import re
import sys

import numpy as np


def lade(pfad):
    """Liefert Dreiecke als Array (n, 3, 3). ASCII- und Binär-STL."""
    daten = open(pfad, 'rb').read()
    if daten[:5].lower() == b'solid' and b'vertex' in daten[:2000]:
        v = np.array(re.findall(rb'vertex\s+(\S+)\s+(\S+)\s+(\S+)', daten), dtype=float)
        return v.reshape(-1, 3, 3)
    n = int(np.frombuffer(daten, dtype='<u4', count=1, offset=80)[0])
    typ = np.dtype([('n', '<f4', 3), ('v', '<f4', (3, 3)), ('a', '<u2')])
    return np.frombuffer(daten, dtype=typ, count=n, offset=84)['v'].astype(float)


def indiziert(tri, nachkomma=4):
    """Gemeinsame Eckpunktliste und Indexdreiecke, entartete Dreiecke entfernt."""
    v = np.round(tri.reshape(-1, 3), nachkomma)
    u, inv = np.unique(v, axis=0, return_inverse=True)
    t = inv.reshape(-1, 3)
    t = t[(t[:, 0] != t[:, 1]) & (t[:, 1] != t[:, 2]) & (t[:, 0] != t[:, 2])]
    return u, t


def volumen(v, t):
    a, b, c = v[t[:, 0]], v[t[:, 1]], v[t[:, 2]]
    return float(np.einsum('ij,ij->i', a, np.cross(b, c)).sum() / 6)


def wasserdicht(t):
    kanten = np.concatenate([t[:, [0, 1]], t[:, [1, 2]], t[:, [2, 0]]])
    gerichtet = {}
    for a, b in map(tuple, kanten):
        gerichtet[(a, b)] = gerichtet.get((a, b), 0) + 1
    fehler = sum(1 for (a, b), n in gerichtet.items() if n != 1 or gerichtet.get((b, a), 0) != 1)
    return fehler == 0, fehler


def koerper(t):
    """Zahl zusammenhängender Körper (Union-Find über gemeinsame Eckpunkte)."""
    eltern = {}

    def f(x):
        while eltern.setdefault(x, x) != x:
            eltern[x] = eltern[eltern[x]]
            x = eltern[x]
        return x
    for a, b, c in t:
        eltern[f(a)] = f(b)
        eltern[f(b)] = f(c)
    return len({f(x) for x in set(t.ravel().tolist())})


def pruefe(pfad):
    tri = lade(pfad)
    v, t = indiziert(tri)
    dicht, fehler = wasserdicht(t)
    lo, hi = v.min(0), v.max(0)
    vol = volumen(v, t)
    return dict(pfad=str(pfad), dreiecke=len(t), von=lo, bis=hi, maß=hi - lo, volumen=vol,
                dicht=dicht, kantenfehler=fehler, koerper=koerper(t), gramm_voll=vol / 1000 * 1.27)


if __name__ == '__main__':
    for p in sys.argv[1:]:
        r = pruefe(p)
        print(f"{p}: {r['dreiecke']} Dreiecke, Maß {r['maß'][0]:.1f} x {r['maß'][1]:.1f} x {r['maß'][2]:.1f} mm, "
              f"Volumen {r['volumen'] / 1000:.2f} cm³ (PETG-Vollkörper max. {r['gramm_voll']:.0f} g), "
              f"{r['koerper']} Körper, {'wasserdicht' if r['dicht'] else 'NICHT dicht (' + str(r['kantenfehler']) + ' Kanten)'}")

#!/usr/bin/env python3
"""Prüfungen für die STL-Dateien des Biomüll-Einsatzes (numpy + scipy).

  stl_pruefung.py info  a.stl [b.stl ...]     Dreiecke, Volumen, Bounding-Box, Dichtheit, Körper
  stl_pruefung.py vergleich a.stl b.stl       Volumen und größte Abweichung der Eckpunkte (beide Richtungen)
  stl_pruefung.py abstand a.stl b.stl         kleinster Abstand der Oberflächen zweier Teile (Zufallspunkte)
"""
import sys
import numpy as np
from scipy.spatial import cKDTree


def lade(pfad):
    """ASCII- oder Binär-STL -> (n, 3, 3)-Array"""
    roh = open(pfad, 'rb').read()
    if roh[:5].lower() == b'solid' and b'facet' in roh[:400]:
        v = []
        for zeile in roh.decode('latin-1').splitlines():
            z = zeile.split()
            if len(z) == 4 and z[0] == 'vertex':
                v.append([float(z[1]), float(z[2]), float(z[3])])
        return np.array(v).reshape(-1, 3, 3)
    n = int(np.frombuffer(roh[80:84], dtype='<u4')[0])
    dt = np.dtype([('n', '<f4', 3), ('v', '<f4', (3, 3)), ('a', '<u2')])
    return np.frombuffer(roh[84:84 + 50 * n], dtype=dt)['v'].astype(float)


def volumen(t):
    return float(np.einsum('ij,ij->i', t[:, 0], np.cross(t[:, 1], t[:, 2])).sum() / 6)


def dichtheit(t, nd=4):
    """Kanten je zweimal (entgegengesetzt) -> dicht. Liefert (offene Kanten, falsch orientierte, Körper)"""
    idx = {}
    tri = []
    for d in t:
        tri.append([idx.setdefault(tuple(np.round(p, nd)), len(idx)) for p in d])
    tri = np.array(tri)
    kanten = {}
    for a, b, c in tri:
        for u, w in ((a, b), (b, c), (c, a)):
            kanten[(u, w)] = kanten.get((u, w), 0) + 1
    offen = sum(1 for (u, w), n in kanten.items() if kanten.get((w, u), 0) != n)
    doppelt = sum(1 for n in kanten.values() if n > 1)
    # zusammenhängende Körper (Union-Find über Eckpunkte)
    eltern = list(range(len(idx)))

    def finde(x):
        while eltern[x] != x:
            eltern[x] = eltern[eltern[x]]
            x = eltern[x]
        return x
    for a, b, c in tri:
        eltern[finde(a)] = finde(b)
        eltern[finde(b)] = finde(c)
    koerper = len({finde(x) for x in set(tri.ravel())})
    return offen, doppelt, koerper


def oberflaechenpunkte(t, n=60000, seed=1):
    rng = np.random.default_rng(seed)
    fl = np.linalg.norm(np.cross(t[:, 1] - t[:, 0], t[:, 2] - t[:, 0]), axis=1) / 2
    i = rng.choice(len(t), n, p=fl / fl.sum())
    r1, r2 = rng.random(n), rng.random(n)
    w = np.sqrt(r1)
    return (1 - w)[:, None] * t[i, 0] + (w * (1 - r2))[:, None] * t[i, 1] + (w * r2)[:, None] * t[i, 2]


def info(pfad):
    t = lade(pfad)
    p = t.reshape(-1, 3)
    offen, doppelt, k = dichtheit(t)
    print(f"{pfad}: {len(t)} Dreiecke, Volumen {volumen(t):.0f} mm³, "
          f"Box {np.round(p.min(0), 2)} … {np.round(p.max(0), 2)} (Maße {np.round(p.max(0) - p.min(0), 2)}), "
          f"offene Kanten {offen}, mehrfache Kanten {doppelt}, Körper {k}")


def vergleich(a, b):
    ta, tb = lade(a), lade(b)
    pa, pb = oberflaechenpunkte(ta), oberflaechenpunkte(tb)
    da = cKDTree(pb).query(pa)[0]
    db = cKDTree(pa).query(pb)[0]
    va = np.unique(np.round(ta.reshape(-1, 3), 4), axis=0)
    vb = np.unique(np.round(tb.reshape(-1, 3), 4), axis=0)
    dva = cKDTree(vb).query(va)[0]
    dvb = cKDTree(va).query(vb)[0]
    print(f"Volumen {volumen(ta):.2f} / {volumen(tb):.2f} mm³, Eckpunkte {len(va)} / {len(vb)}, "
          f"größte Eckpunktabweichung {max(dva.max(), dvb.max()):.4f} mm; "
          f"Oberflächenpunkte (nur grob, Abtastung): {max(da.max(), db.max()):.2f} mm")


def abstand(a, b):
    pa, pb = oberflaechenpunkte(lade(a), 150000), oberflaechenpunkte(lade(b), 150000)
    d, i = cKDTree(pb).query(pa)
    k = d.argmin()
    print(f"kleinster Abstand {d[k]:.3f} mm bei {np.round(pa[k], 1)} / {np.round(pb[i[k]], 1)}")


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    if sys.argv[1] == 'info':
        for f in sys.argv[2:]:
            info(f)
    elif sys.argv[1] == 'vergleich':
        vergleich(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == 'abstand':
        abstand(sys.argv[2], sys.argv[3])

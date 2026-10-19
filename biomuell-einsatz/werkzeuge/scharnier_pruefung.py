#!/usr/bin/env python3
"""2D-Prüfung des Scharniers (Bügel/Band <-> Plattform): bei welchen Drehwinkeln lässt sich der Haken vom Stift abnehmen?

Aufruf: scharnier_pruefung.py [flach=horizontal|vertikal] [zugabe=0] [schritt=10] [stift_flach=4.2] [kanal_spiel=0.25]

Koordinaten (Schnitt senkrecht zur Stiftachse): s = waagerecht nach außen (zur Eimerwand), z = nach oben.
Winkel alpha = Stellung des Bügels aus der Senkrechten: 0 = aufrecht, 90 = waagerecht nach außen, 180 = senkrecht nach unten.
Hakenprofil wie haken2d() in biomuell_system.scad (u = Bandrichtung, v = Banddicke, v < 0 zeigt bei aufrechtem Bügel nach außen).
Der Haken wird gegenüber dem Stift verschoben (Raster); er gilt als abnehmbar, wenn er ohne Kollision mit Stift und Plattform
(Innenwand des Schlitzes, Plattform + Wulst) mehr als 20 mm vom Stift wegkommt. Die Plattform steht nur bei s < -(R_OUT + 0,7 + zugabe).
"""
import sys
from collections import deque

import numpy as np
import shapely
from shapely import affinity
from shapely.geometry import Point, Polygon, box
from shapely.ops import unary_union

P = dict(flach="horizontal", zugabe=0.0, schritt=10.0, stift_flach=4.2, kanal_spiel=0.25, stift_d=6.0, haken_spiel=0.35,
         haken_wand=2.4, tropfen=0.6, kanal_fase=0.6, hals_t=2.0, platte_t=6.0, stift_z=-10.0, boss_unten=-16.0,
         raster=0.2, weg=20.0)
for a in sys.argv[1:]:
    k, v = a.split("=")
    P[k] = v if k == "flach" else float(v)

R_IN = P["stift_d"] / 2 + P["haken_spiel"]
R_OUT = R_IN + P["haken_wand"]
KB = P["stift_flach"] + 2 * P["kanal_spiel"]
SQ2 = 2 ** 0.5


def kreis(r):
    return Point(0, 0).buffer(r, 64)


def haken_profil():
    aussen = unary_union([kreis(R_OUT), Polygon([(0, 0), (0.01, 0), (0, R_OUT * SQ2)]).union(Point(0, R_OUT * SQ2).buffer(0.01)),
                          box(-0.75 * R_OUT, -R_OUT, 0.75 * R_OUT, -R_OUT + 0.01)]).convex_hull
    aussen = aussen.intersection(box(-2 * R_OUT, -2 * R_OUT, 2 * R_OUT, R_OUT))
    innen = unary_union([kreis(R_IN), Point(0, R_IN * SQ2).buffer(0.01)]).convex_hull
    innen = innen.intersection(box(-2 * R_OUT, -2 * R_OUT, 2 * R_OUT, R_IN + P["tropfen"]))
    kanal = box(-KB / 2, -2 * R_OUT, KB / 2, 0)
    fase = Polygon([(-KB / 2 - P["kanal_fase"] - 1, -R_OUT - 1), (KB / 2 + P["kanal_fase"] + 1, -R_OUT - 1),
                    (KB / 2, -R_OUT + P["kanal_fase"]), (-KB / 2, -R_OUT + P["kanal_fase"])])
    haken = aussen.difference(innen).difference(kanal).difference(fase)
    # Band: ab dem Kanalrand in Bandrichtung, an der Außenseite (v = -R_OUT ... -R_OUT + hals_t)
    band = box(KB / 2 + P["kanal_fase"], -R_OUT, 70, -R_OUT + P["hals_t"])
    return unary_union([haken, band])


def stift():
    kr = kreis(P["stift_d"] / 2)
    f = P["stift_flach"] / 2
    if P["flach"] == "horizontal":      # Abflachungen oben/unten: Stift 4,2 hoch, 6 breit
        return kr.intersection(box(-10, -f, 10, f))
    return kr.intersection(box(-f, -10, f, 10))   # Abflachungen seitlich (bisher): 4,2 breit, 6 hoch


def platte():
    s_wand = -(R_OUT + 0.7 + P["zugabe"])
    z0 = P["boss_unten"] - P["stift_z"]
    z1 = -P["stift_z"]
    return box(s_wand - 60, z0, s_wand, z1)


def drehen(geo, alpha_grad):
    a = np.radians(alpha_grad)
    s, c = np.sin(a), np.cos(a)

    def f(xy):
        u, v = xy[:, 0], xy[:, 1]
        return np.column_stack([u * s - v * c, u * c + v * s])
    return shapely.transform(geo, f)


def abnehmbar(alpha, mit_band=True):
    h = drehen(haken_profil() if mit_band else haken_profil(), alpha).buffer(-0.02)
    hindernis = unary_union([stift(), platte()])
    r = P["raster"]
    n = int(P["weg"] / r)
    gitter = {}

    def frei(i, j):
        if (i, j) not in gitter:
            gitter[(i, j)] = not shapely.intersects(affinity.translate(h, i * r, j * r), hindernis)
        return gitter[(i, j)]
    if not frei(0, 0):
        return None
    seen = {(0, 0)}
    q = deque([(0, 0)])
    while q:
        i, j = q.popleft()
        if (i * i + j * j) * r * r >= P["weg"] ** 2:
            return True
        for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            k = (i + di, j + dj)
            if k not in seen and abs(k[0]) <= n and abs(k[1]) <= n:
                seen.add(k)
                if frei(*k):
                    q.append(k)
    return False


if __name__ == "__main__":
    print(f"Abflachungen {P['flach']}, Stift {P['stift_flach']}, Kanal {KB:.2f}, Schlitz-Zugabe {P['zugabe']}")
    st = P["schritt"]
    ok = []
    for a in np.arange(-180, 180 + 0.1, st):
        res = abnehmbar(a)
        ok.append((a, res))
        print(f"  alpha {a:6.1f}°: {'ABNEHMBAR' if res else ('Kollision im Ausgang' if res is None else 'gehalten')}")
    print("abnehmbar bei:", [a for a, r in ok if r])

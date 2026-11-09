#!/usr/bin/env python3
"""
Zuckerstangen-Haken mit Magneten (Ø15 x 3 mm) für Adventskalender
=================================================================
Zwei Bauformen, je mit 1, 2 oder 4 Magneten:

  relief  Flache Zuckerstange als Relief auf der Platte, rote Streifen nur in den
          obersten Schichten eingelegt (~6 Farbwechsel). Ca. 9 mm tief. Das Band
          wird unter dem Bogenscheitel durch einen Schlitz gefädelt.
  rund    Runde Stange, Bogen steht nach vorn ab -> offener Haken. Spiralstreifen
          rundum, ~70 Farbwechsel. Ca. 21 mm tief.

Je Variante entstehen drei passgenaue, geschlossene Körper plus eine 3MF:
  haken_<bauform>_<magnete>_platte.stl  Basisplatte (Farbe frei wählbar, z. B. grün oder weiß)
  haken_<bauform>_<magnete>_weiss.stl   weiße Grundfarbe der Stange
  haken_<bauform>_<magnete>_rot.stl     rote Streifen
  haken_<bauform>_<magnete>.3mf         alle drei (Slicer: „ein Objekt mit mehreren Teilen“)
Platte und Stange überlappen nicht in Z: Unter der Plattenoberseite gibt es nur die
Plattenfarbe, darüber nur Stangenfarben -> ein einziger Wechsel an der Plattenoberseite.

Koordinaten: X = Breite, Y = nach oben (an der Wand), Z = aus der Wand heraus.
Rückseite der Platte liegt bei Z = 0 -> so aufs Druckbett legen.

Aufruf:  python3 werkzeuge/erzeuge_modell.py [--bauform relief rund]
                                            [--magnete 1 2 4] [-o ORDNER]
Benötigt: numpy trimesh manifold3d shapely
"""
import argparse
import os

import manifold3d as mf
import numpy as np
import trimesh
from shapely.geometry import LineString, Polygon, box
from shapely.geometry.polygon import orient
from shapely.ops import unary_union

SCHICHT = 0.2   # Bezugsschichthöhe für Angaben/Prüfungen (mm)

# ------------------------- gemeinsame Parameter (mm) -------------------------
GEMEINSAM = dict(
    PLATTE_T=4.6,        # Dicke der Basisplatte
    ECK_R=5.0,           # Eckenradius
    FASE=1.0,            # Fase an der Vorderkante der Platte

    MAG_D=15.0,          # Magnetdurchmesser
    MAG_H=3.0,           # Magnethöhe
    MAG_SPIEL_D=0.3,     # Spiel im Durchmesser (Presspassung ~0.15, mit Kleber 0.3)
    MAG_SPIEL_H=0.2,     # Magnet sitzt 0.2 mm vertieft -> Platte liegt sauber an
)

# ------------------------- Bauform „relief“ ----------------------------------
RELIEF = dict(
    STANGE_B=7.0,        # Breite der Stange (in der Wandebene)
    STANGE_HOCH=4.0,     # Höhe der Stange über der Platte
    STANGE_FASE=1.0,     # 45°-Fase an der Oberkante (wird mit gestreift)
    BOGEN_R=7.0,         # Bogenradius (Mittellinie)
    SPITZE_L=8.0,        # gerades Stück nach dem Bogen (zeigt nach unten)
    STANGE_Y0=6.0,       # unteres Ende (Mittellinie)

    ROT_TIEFE=0.2,       # rote Streifen reichen so tief unter die Fase
    STREIFEN_PERIODE=11.0,  # Abstand der Streifen entlang der Stange
    STREIFEN_ANTEIL=0.45,   # Anteil rot
    STREIFEN_SCHRAEG=0.75,  # Schräge (Versatz entlang der Stange je mm quer)

    SCHLITZ_B=9.0,       # Breite des Fädelschlitzes unter dem Scheitel (X)
    SCHLITZ_LUFT=3.0,    # Schlitz über/unter der Stange (Y), zum Einfädeln
    SCHLITZ_TIEFE=3.0,   # lichte Höhe unter der Stange (Z)
)
# STANGE_Y1 = Beginn des Bogens; Scheitel (Mittellinie) bei Y1 + BOGEN_R
RELIEF_VARIANTEN = {
    1: dict(PLATTE_B=24.0, PLATTE_H=42.0, MAG_POS=[(0.0, 15.0)], STANGE_Y1=25.0),
    2: dict(PLATTE_B=28.0, PLATTE_H=62.0, MAG_POS=[(0.0, 13.0), (0.0, 36.0)], STANGE_Y1=45.0),
    4: dict(PLATTE_B=40.0, PLATTE_H=62.0,
            MAG_POS=[(-9.5, 13.0), (9.5, 13.0), (-9.5, 36.0), (9.5, 36.0)], STANGE_Y1=45.0),
}

# ------------------------- Bauform „rund“ ------------------------------------
RUND = dict(
    STANGE_D=6.0,        # Durchmesser der Zuckerstange
    EINBETT=1.0,         # wie tief die Stange in die Platte eingelassen ist
    STANGE_Y0=6.0,       # unteres Ende der Stange
    BOGEN_R=5.5,         # Bogenradius (Mittellinie) -> lichte Weite = 2*R - D
    SPITZE_L=6.0,        # gerades Stück nach dem Bogen (zeigt nach unten)

    STREIFEN_N=3,        # Anzahl roter Streifen
    STREIFEN_ANTEIL=0.42,
    STEIGUNG=30.0,       # mm Stangenlänge pro Umdrehung der Spirale
    STREIFEN_TIEFE=1.2,  # Wandstärke der roten Streifen
    ROT_AB=1.2,          # unterhalb PLATTE_T + ROT_AB bleibt die Stange weiß
                         # (Flanke zur Platte, kaum sichtbar -> spart Farbwechsel)
    SEG_UMFANG=72,
    SEG_PFAD=0.5,
)
RUND_VARIANTEN = {
    1: dict(PLATTE_B=22.0, PLATTE_H=46.0, MAG_POS=[(0.0, 20.0)], STANGE_Y1=36.0),
    2: dict(PLATTE_B=28.0, PLATTE_H=62.0, MAG_POS=[(0.0, 16.0), (0.0, 43.0)], STANGE_Y1=50.0),
    4: dict(PLATTE_B=40.0, PLATTE_H=62.0,
            MAG_POS=[(-9.5, 16.0), (9.5, 16.0), (-9.5, 43.0), (9.5, 43.0)], STANGE_Y1=50.0),
}

MAGNET_NAME = {1: "1_magnet", 2: "2_magnete", 4: "4_magnete"}


# ============================ Hilfsfunktionen =================================
def zu_mf(m):
    return mf.Manifold(mf.Mesh(vert_properties=np.asarray(m.vertices, np.float32),
                               tri_verts=np.asarray(m.faces, np.uint32)))


def zu_tm(man):
    mesh = man.to_mesh()
    idx = np.arange(len(mesh.vert_properties))
    if len(mesh.merge_from_vert):
        idx[np.asarray(mesh.merge_from_vert)] = np.asarray(mesh.merge_to_vert)
    return trimesh.Trimesh(np.asarray(mesh.vert_properties)[:, :3], idx[np.asarray(mesh.tri_verts)])


def querschnitt(geom):
    """shapely (Multi)Polygon -> manifold CrossSection."""
    polys = getattr(geom, "geoms", [geom])
    ringe = []
    for p in polys:
        p = orient(p, 1.0)
        ringe.append(np.asarray(p.exterior.coords)[:-1])
        ringe += [np.asarray(i.coords)[:-1] for i in p.interiors]
    return mf.CrossSection(ringe, mf.FillRule.EvenOdd)


def prisma(cs, z0, z1):
    return cs.extrude(z1 - z0).translate((0, 0, z0))


def mit_fase(cs, z0, z1, fase, schritt=0.1):
    """Extrusion von z0 bis z1, oben 45°-Fase in Stufen (feiner als die Schichthöhe).
    Die Stufen überlappen leicht, damit keine deckungsgleichen Flächen entstehen."""
    n = max(1, int(round(fase / schritt)))
    teile = [prisma(cs, z0, z1 - fase)]
    for k in range(n):
        zu = z1 - fase + k * fase / n
        teile.append(prisma(cs.offset(-(k + 0.5) * fase / n, mf.JoinType.Round, circular_segments=48),
                            zu - 0.013, zu + fase / n))
    return mf.Manifold.batch_boolean(teile, mf.OpType.Add)


def platte(p):
    """Abgerundete Platte mit exakter 45°-Fase vorn (konvexe Hülle)."""
    B, H, er, T, fa = p["PLATTE_B"], p["PLATTE_H"], p["ECK_R"], p["PLATTE_T"], p["FASE"]
    rr = querschnitt(box(-B / 2 + er, er, B / 2 - er, H - er).buffer(er, quad_segs=16))
    return mf.Manifold.batch_hull([prisma(rr, 0, T - fa), prisma(rr.offset(-fa, mf.JoinType.Round, circular_segments=64), T - 0.001, T)])


def magnet_taschen(p):
    d, h = p["MAG_D"] + p["MAG_SPIEL_D"], p["MAG_H"] + p["MAG_SPIEL_H"]
    t = [mf.Manifold.cylinder(h + 1, d / 2, d / 2, 96).translate((x, y, -1)) for x, y in p["MAG_POS"]]
    return mf.Manifold.batch_boolean(t, mf.OpType.Add)


def pruefe_magnete(p, min_wand=2.0):
    rt = (p["MAG_D"] + p["MAG_SPIEL_D"]) / 2
    B, H = p["PLATTE_B"], p["PLATTE_H"]
    for i, (x, y) in enumerate(p["MAG_POS"]):
        rand = min(B / 2 - abs(x), y, H - y) - rt
        assert rand >= min_wand, f"Randwand {rand:.2f} mm bei Magnet {i}"
        for x2, y2 in p["MAG_POS"][i + 1:]:
            steg = np.hypot(x - x2, y - y2) - 2 * rt
            assert steg >= min_wand, f"Steg {steg:.2f} mm zwischen Magneten"
    assert p["PLATTE_T"] - p["MAG_H"] - p["MAG_SPIEL_H"] >= 1.0, "Vorderwand über Magnet < 1 mm"


def mischschichten(*koerper):
    """Anzahl Schichten (SCHICHT mm), in denen mehr als ein Körper vorkommt."""
    zmax = max(k.bounds[1, 2] for k in koerper)
    n = 0
    for z in np.arange(SCHICHT / 2, zmax, SCHICHT):
        da = sum(1 for k in koerper if k.bounds[0, 2] < z + SCHICHT / 2 - 1e-4 and k.bounds[1, 2] > z - SCHICHT / 2 + 1e-4)
        n += da > 1
    return n


# ============================ Bauform „relief“ ================================
def relief_mittellinie(p):
    """Mittellinie in der Wandebene (XY), Bogenscheitel bei x = 0."""
    R, y0, y1, L = p["BOGEN_R"], p["STANGE_Y0"], p["STANGE_Y1"], p["SPITZE_L"]
    xs = R
    pts = [(xs, y) for y in np.linspace(y0, y1, 60, endpoint=False)]
    pts += [(xs - R + R * np.cos(a), y1 + R * np.sin(a))
            for a in np.linspace(0, np.pi, 90, endpoint=False)]
    pts += [(xs - 2 * R, y) for y in np.linspace(y1, y1 - L, 20)]
    return np.array(pts)


def relief_streifen(p, linie):
    """Schräge Streifen in Stangenkoordinaten (s entlang, t quer), auf XY abgebildet."""
    seg = np.diff(linie, axis=0)
    s = np.concatenate([[0], np.cumsum(np.linalg.norm(seg, axis=1))])
    tang = np.vstack([seg, seg[-1:]])
    tang /= np.linalg.norm(tang, axis=1)[:, None]
    # an beiden Enden gerade verlängern (runde Kappen)
    ext = p["STANGE_B"]
    s_ext = np.concatenate([[-ext], s, [s[-1] + ext]])
    l_ext = np.vstack([linie[0] - tang[0] * ext, linie, linie[-1] + tang[-1] * ext])
    t_ext = np.vstack([tang[0], tang, tang[-1]])

    def punkt(si, ti):
        x = np.interp(si, s_ext, l_ext[:, 0]); y = np.interp(si, s_ext, l_ext[:, 1])
        tx = np.interp(si, s_ext, t_ext[:, 0]); ty = np.interp(si, s_ext, t_ext[:, 1])
        n = np.hypot(tx, ty)
        return x - ty / n * ti, y + tx / n * ti     # linke Normale

    tm = p["STANGE_B"] / 2 + 0.5
    P, w, k = p["STREIFEN_PERIODE"], p["STREIFEN_PERIODE"] * p["STREIFEN_ANTEIL"], p["STREIFEN_SCHRAEG"]
    tt = np.linspace(-tm, tm, 24)
    baender = []
    for s0 in np.arange(-ext - 2 * P, s[-1] + ext + P, P):
        a = [punkt(s0 + k * t, t) for t in tt]
        ss = np.linspace(s0 + k * tm, s0 + w + k * tm, 12)
        b = [punkt(si, tm) for si in ss]
        c = [punkt(s0 + w + k * t, t) for t in tt[::-1]]
        ss = np.linspace(s0 + w - k * tm, s0 - k * tm, 12)
        d = [punkt(si, -tm) for si in ss]
        poly = Polygon(a + b + c + d).buffer(0)
        if not poly.is_empty:
            baender.append(poly)
    return unary_union(baender)


def erzeuge_relief(n_mag):
    p = dict(GEMEINSAM); p.update(RELIEF); p.update(RELIEF_VARIANTEN[n_mag])
    pruefe_magnete(p)
    T, top = p["PLATTE_T"], p["PLATTE_T"] + p["STANGE_HOCH"]
    W, R = p["STANGE_B"], p["BOGEN_R"]

    linie = relief_mittellinie(p)
    stange2d = LineString(linie).buffer(W / 2, quad_segs=24)
    stange = mit_fase(querschnitt(stange2d), T - 0.4, top, p["STANGE_FASE"])

    # Fädelschlitz unter dem Scheitel
    ya = p["STANGE_Y1"] + R
    sb, sl = p["SCHLITZ_B"], p["SCHLITZ_LUFT"]
    schlitz2d = box(-sb / 2 + 1.5, ya - W / 2 - sl + 1.5, sb / 2 - 1.5, ya + W / 2 + sl - 1.5).buffer(1.5, quad_segs=8)
    schlitz = prisma(querschnitt(schlitz2d), T - p["SCHLITZ_TIEFE"], T + 0.02)   # nicht koplanar mit Plattenoberseite
    ober = ya + W / 2 + sl
    assert ober <= p["PLATTE_H"] - 2.0, "Schlitz zu nah am oberen Rand"
    unter = ya - W / 2 - sl
    for x, y in p["MAG_POS"]:   # Schlitz und Magnettaschen überlappen in Z -> in Y trennen
        if abs(x) - (p["MAG_D"] + p["MAG_SPIEL_D"]) / 2 < sb / 2 + 1.5:
            assert unter - (y + (p["MAG_D"] + p["MAG_SPIEL_D"]) / 2) >= 1.5, "Schlitz trifft Magnettasche"

    rot2d = relief_streifen(p, linie)   # ragt seitlich über die Stange hinaus -> keine fast deckungsgleichen Flächen
    z_rot = top - p["STANGE_FASE"] - p["ROT_TIEFE"]
    rot_werkzeug = prisma(querschnitt(rot2d), z_rot, top + 1)
    rot = stange ^ rot_werkzeug

    # Weiß mit dem Werkzeug schneiden, nicht mit dem roten Körper (keine gemeinsamen Außenflächen)
    basis = platte(p)
    weiss = stange - basis - schlitz - rot_werkzeug
    platte_k = basis - schlitz - magnet_taschen(p)
    return p, zu_tm(platte_k), zu_tm(weiss), zu_tm(rot)


# ============================ Bauform „rund“ ==================================
def rund_pfad(p):
    zc, R, step = p["zc"], p["BOGEN_R"], p["SEG_PFAD"]
    y0, y1 = p["STANGE_Y0"], p["STANGE_Y1"]
    pts, tans = [], []
    for y in np.linspace(y0, y1, max(2, int((y1 - y0) / step)), endpoint=False):
        pts.append((0, y, zc)); tans.append((0, 1, 0))
    for a in np.linspace(0, np.pi, max(8, int(np.pi * R / step)), endpoint=False):
        pts.append((0, y1 + R * np.sin(a), zc + R - R * np.cos(a)))
        tans.append((0, np.cos(a), np.sin(a)))
    for y in np.linspace(y1, y1 - p["SPITZE_L"], max(2, int(p["SPITZE_L"] / step)) + 1):
        pts.append((0, y, zc + 2 * R)); tans.append((0, -1, 0))
    pts, tans = np.array(pts, float), np.array(tans, float)
    s = np.concatenate([[0], np.cumsum(np.linalg.norm(np.diff(pts, axis=0), axis=1))])
    return pts, tans, s


def sweep(profil_fn, pts, tans, s):
    """Profil (rho, theta) entlang des Pfads ziehen. Ebener Pfad -> Binormale = X."""
    b = np.array([1.0, 0, 0])
    rings = []
    for q, t, si in zip(pts, tans, s):
        nrm = np.cross(b, t)
        rt = profil_fn(si)
        rings.append(q + np.outer(rt[:, 0] * np.cos(rt[:, 1]), nrm)
                     + np.outer(rt[:, 0] * np.sin(rt[:, 1]), b))
    rings = np.array(rings)
    K, M = rings.shape[:2]
    V = rings.reshape(-1, 3)
    F = []
    for k in range(K - 1):
        for m in range(M):
            a, c = k * M + m, k * M + (m + 1) % M
            F += [[a, c, c + M], [a, c + M, a + M]]
    for k, flip in ((0, True), (K - 1, False)):
        ci = len(V)
        V = np.vstack([V, rings[k].mean(axis=0)])
        for m in range(M):
            a, c = k * M + m, k * M + (m + 1) % M
            F.append([ci, c, a] if flip else [ci, a, c])
    mesh = trimesh.Trimesh(V, np.array(F), process=True)
    if mesh.volume < 0:
        mesh.invert()
    return zu_mf(mesh)


def erzeuge_rund(n_mag):
    p = dict(GEMEINSAM); p.update(RUND); p.update(RUND_VARIANTEN[n_mag])
    pruefe_magnete(p)
    r = p["STANGE_D"] / 2
    p["zc"] = p["PLATTE_T"] + r - p["EINBETT"]
    assert p["STANGE_Y1"] + p["BOGEN_R"] + r <= p["PLATTE_H"], "Bogen ragt über die Platte"
    pts, tans, s = rund_pfad(p)

    th = np.linspace(0, 2 * np.pi, p["SEG_UMFANG"], endpoint=False)
    kreis = np.column_stack([np.full_like(th, r), th])
    stange = sweep(lambda _: kreis, pts, tans, s)
    for q in (pts[0], pts[-1]):
        kugel = trimesh.creation.icosphere(subdivisions=4, radius=r)   # schief gedreht: keine Eckpunkte
        kugel.apply_transform(trimesh.transformations.euler_matrix(0.31, 0.47, 0.23))  # auf der Stangenkante
        stange = stange + zu_mf(kugel.apply_translation(q))

    N = p["STREIFEN_N"]
    breite = 2 * np.pi * p["STREIFEN_ANTEIL"] / N
    n = max(6, int(p["SEG_UMFANG"] * p["STREIFEN_ANTEIL"] / N) + 2)
    ra, ri = r + 0.5, r - p["STREIFEN_TIEFE"]

    def band(i):
        def f(si):
            st = 2 * np.pi * i / N + 2 * np.pi * si / p["STEIGUNG"] + 0.0137
            t = np.linspace(st, st + breite, n)
            return np.vstack([np.column_stack([np.full(n, ra), t]),
                              np.column_stack([np.full(n, ri), t[::-1]])])
        return f
    # eigene Abtastung für die Streifen, damit ihre Kanten nicht auf Stangen-Eckpunkten liegen
    ps, ts, ss = rund_pfad(dict(p, SEG_PFAD=p["SEG_PFAD"] * 0.93))
    streifen = mf.Manifold.batch_boolean([sweep(band(i), ps, ts, ss) for i in range(N)], mf.OpType.Add)

    basis = platte(p)
    z_rot = p["PLATTE_T"] + p["ROT_AB"] + 0.003
    sichtbar = mf.Manifold.cube((200, 200, 100)).translate((-100, -50, z_rot))
    rot_werkzeug = streifen ^ sichtbar
    rot = stange ^ rot_werkzeug
    weiss = stange - basis - rot_werkzeug
    platte_k = basis - magnet_taschen(p)
    return p, zu_tm(platte_k), zu_tm(weiss), zu_tm(rot)


# ============================ Ausgabe =========================================
FARBEN = {"platte": [30, 110, 60, 255], "weiss": [245, 245, 240, 255], "rot": [200, 20, 30, 255]}


def schreibe(bauform, n_mag, ausgabe):
    p, platte_k, weiss, rot = (erzeuge_relief if bauform == "relief" else erzeuge_rund)(n_mag)
    teile = {"platte": platte_k, "weiss": weiss, "rot": rot}
    for k, m in teile.items():
        assert m.is_watertight and m.is_volume, f"Netz {k} nicht geschlossen"
    name = f"haken_{bauform}_{MAGNET_NAME[n_mag]}"
    os.makedirs(ausgabe, exist_ok=True)
    pfx = os.path.join(ausgabe, name)
    sc = trimesh.Scene()
    for k, m in teile.items():
        m.export(f"{pfx}_{k}.stl")
        m.visual.face_colors = FARBEN[k]
        sc.add_geometry(m, node_name=k, geom_name=k)
    sc.export(pfx + ".3mf")

    g = trimesh.util.concatenate(list(teile.values()))
    ext = g.bounds[1] - g.bounds[0]
    print(f"{name:26s} {ext[0]:5.1f} x {ext[1]:5.1f} x {ext[2]:5.1f} mm  "
          f"Platte {platte_k.volume / 1000:5.2f}  weiß {weiss.volume / 1000:4.2f}  rot {rot.volume / 1000:4.2f} cm³  "
          f"Schichten mit Farbwechsel (0,2 mm): {mischschichten(platte_k, weiss, rot)}")
    return name, teile


if __name__ == "__main__":
    hier = os.path.dirname(os.path.abspath(__file__))
    ap = argparse.ArgumentParser(description="Zuckerstangen-Haken erzeugen")
    ap.add_argument("--bauform", nargs="+", default=["relief", "rund"], choices=["relief", "rund"])
    ap.add_argument("--magnete", nargs="+", type=int, default=[1, 2, 4], choices=[1, 2, 4])
    ap.add_argument("-o", "--ausgabe", default=os.path.dirname(hier))
    a = ap.parse_args()
    for bf in a.bauform:
        for nm in a.magnete:
            schreibe(bf, nm, a.ausgabe)

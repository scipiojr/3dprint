#!/usr/bin/env python3
"""
Biomuell-Plattform mit abnehmbaren Tragebaendern (PETG) - parametrischer STL-Generator.

Erzeugt (Plattformen druckfertig orientiert, Fuesse nach oben):
  plattform_6baender.stl - 2 Scharniere je Langseite, 1 je Schmalseite
                           -> buegel.stl 2x (Langseiten) + band.stl 2x (Schmalseiten)
  plattform_4baender.stl - 1 Scharnier je Seite -> band.stl 4x
  band.stl   - Tragband mit Schnapphaken (umgreift den Stift = echtes Scharnier) und
               Griffschlaufe (Fenster 108 mm fuer eine 10 cm breite Hand, Griffsteg
               12 mm dick und oben gewoelbt)
  buegel.stl - zwei Baender mit gemeinsamer Griffschlaufe: zwei Haken, ein Griff

Mit Argumenten nur einzelne Dateien erzeugen, z. B.:
  python3 biomuell_plattform.py plattform_4baender.stl band.stl

Einhaengen: Haken von oben-innen ueber den Stift druecken, bis er einschnappt.
Aushaengen: Band nach unten schieben und den Haken vom Stift abziehen.
Unter Zug liegt der Stift im geschlossenen Hakenbogen - die Oeffnung zeigt
immer von der Zugrichtung weg, egal wie weit das Band gekippt wird.

Keine externen CAD-Bibliotheken noetig (nur Python 3 + Standardbibliothek).
Alle Masse in mm. Parameter anpassen und Skript erneut ausfuehren.
"""
import math
import struct

# ----------------------------------------------------------------------------
# PARAMETER
# ----------------------------------------------------------------------------
# Eimer (Innenmasse): 205 x 275, Hoehe 290, Ecken 45 Grad abgeschraegt
PLATE_L = 250.0      # Laenge (X)  -> 12.5 mm Luft je Schmalseite, passt auf 260er Bett
PLATE_W = 195.0      # Breite (Y)  ->  5 mm Luft je Langseite
CHAMFER = 16.0       # Schenkellaenge der 45-Grad-Eckschraege
PLATE_T = 4.0        # Plattenstaerke
FOOT_H = 50.0        # Abstand Plattenunterseite -> Eimerboden
RIB_H = 8.0          # Hoehe der Rippen/des Randes unter der Platte
RIB_W = 2.4
RIM_W = 3.0
HOLE = 4.0           # Abflussloecher (quadratisch)
HOLE_PITCH = 8.0

FOOT_SIZE = 22.0
FOOT_FLARE = 30.0
FOOT_FLARE_H = 6.0

# Varianten: Scharnier-Aufnahmen (Kante, Position entlang der Kante) und Fuesse
VARIANTS = {
    "plattform_6baender.stl": dict(
        straps=[('+y', -55.0), ('+y', 55.0), ('-y', -55.0), ('-y', 55.0), ('+x', 0.0), ('-x', 0.0)],
        feet=[(-101, -73), (101, -73), (-101, 73), (101, 73), (0, -73), (0, 73), (0, 0)]),
    "plattform_4baender.stl": dict(
        straps=[('+y', 0.0), ('-y', 0.0), ('+x', 0.0), ('-x', 0.0)],
        feet=[(-101, -73), (101, -73), (-101, 73), (101, 73), (0, -58), (0, 58), (0, 0)]),
}

# Scharnier
PIN_D = 6.0          # Stiftdurchmesser
PIN_Z = -10.0        # Stiftmitte unter Plattenoberseite
HOOK_W = 24.0        # Hakenbreite
HOOK_CLR = 0.35      # radiales Spiel Haken <-> Stift
HOOK_WALL = 2.4      # Wandstaerke des Hakenbogens
SNAP = 0.5           # Uebermass der Schnapp-Oeffnung gegenueber dem Stift (gesamt)
TEAR_TOP = 0.6       # Tropfenform: Dach der Hakenbohrung liegt so viel ueber dem Kreis
# Hakenoeffnung: von 0 Grad (nach innen) bis GAP_TO (wird aus SNAP berechnet, ~100 Grad)
SLOT_CLR = 1.0       # seitliches Spiel Haken <-> Aussparung
EDGE_OFS = 0.3       # Band liegt 0.3 mm innerhalb der Plattenkante
FASE = 2.0           # Fase an der Umlenkkante (45 Grad)
FASE_SIDE = 1.5      # Fase an den seitlichen Kanten der Aussparung
BOSS_BOT = -16.0

# Band
BAND_W = 22.0
BAND_T = 1.6         # flexibel
NECK_T = 2.0         # verstaerkter Hals oberhalb des Hakens
NECK_L = 20.0
BAND_R = 0.8         # Kantenrundung oben (Band)
BAND_C = 0.4         # Fase unten (druckbar ohne Stuetzen)
# len = Hakenunterkante bis Schlaufenoberkante (Schlaufe ca. 8 mm unter dem Eimerrand)
# legs = Y-Positionen der Haken (muessen zu den Aufnahmen der Platte passen)
BANDS = {
    "band.stl":   dict(len=244.0, legs=(0.0,), side_w=8.0),          # Einzelband
    "buegel.stl": dict(len=244.0, legs=(-55.0, 55.0), side_w=12.0),  # 2 Beine, 1 Griff
}
# Griffschlaufe (Fenster fuer eine 10 cm breite Hand)
WIN_W = 108.0        # lichte Breite
WIN_H = 32.0         # lichte Hoehe
FRAME_W = 8.0        # Breite Seitenstege / unterer Steg
FRAME_T = 4.0        # Staerke Rahmen
FRAME_R = 2.0        # Kantenrundung Rahmen
FRAME_C = 0.6
GRIP_H = 20.0        # Griffsteg: Hoehe (in Zugrichtung)
GRIP_T = 12.0        # Griffsteg: Dicke, oben gewoelbt
GUSSET_L = 45.0      # Uebergang Band -> Schlaufe
LOOP_W = WIN_W + 2 * FRAME_W
LOOP_H = FRAME_W + WIN_H + GRIP_H

PIN_R = PIN_D / 2
R_IN = PIN_R + HOOK_CLR
R_OUT = R_IN + HOOK_WALL
PIN_V = EDGE_OFS + R_OUT                   # Stiftmitte, Abstand von der Plattenkante
GAP_FROM = 0.0


def _gap_to():
    """Winkel des zweiten Oeffnungsrandes, so dass die Oeffnung PIN_D - SNAP weit ist."""
    tip = (0.0, R_IN + TEAR_TOP)          # innere Kante der Hakenspitze (dx, dz)
    lo, hi = 60.0, 170.0
    for _ in range(60):
        a = 0.5 * (lo + hi)
        p = (R_IN * math.sin(math.radians(a)), R_IN * math.cos(math.radians(a)))
        if math.dist(p, tip) < PIN_D - SNAP:
            lo = a
        else:
            hi = a
    return 0.5 * (lo + hi)


GAP_TO = _gap_to()
SLOT_U = HOOK_W / 2 + SLOT_CLR             # halbe Breite der Aussparung
SLOT_V = PIN_V + R_OUT + 0.7               # Tiefe der Aussparung
CHEEK = 6.0                                # Wangenbreite neben der Aussparung


# ----------------------------------------------------------------------------
# Mesher: nicht gleichmaessiges Rechteckraster, Zellen am konvexen Umriss
# beschnitten, Belegung je Zelle und Schicht -> geschlossenes Dreiecksnetz.
# ----------------------------------------------------------------------------
def clip_poly(poly, a, b, c):
    out = []
    n = len(poly)
    for i in range(n):
        p, q = poly[i], poly[(i + 1) % n]
        fp = a * p[0] + b * p[1] + c
        fq = a * q[0] + b * q[1] + c
        if fp >= 0:
            out.append(p)
        if (fp >= 0) != (fq >= 0):
            t = fp / (fp - fq)
            out.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
    return out


def poly_area_centroid(poly):
    a = cx = cy = 0.0
    n = len(poly)
    for i in range(n):
        x0, y0 = poly[i]
        x1, y1 = poly[(i + 1) % n]
        cr = x0 * y1 - x1 * y0
        a += cr
        cx += (x0 + x1) * cr
        cy += (y0 + y1) * cr
    a *= 0.5
    if abs(a) < 1e-9:
        return 0.0, None
    return a, (cx / (6 * a), cy / (6 * a))


def rnd(v):
    return round(v, 4)


def frange(a, b, step):
    out, k = [], 0
    while a + k * step <= b + 1e-9:
        out.append(a + k * step)
        k += 1
    return out


def mesh_grid(xs, ys, zs, outline_halfplanes, occ_col):
    """occ_col(x, y, [z-Mitten]) -> Liste bool"""
    xs = sorted(set(rnd(x) for x in xs))
    ys = sorted(set(rnd(y) for y in ys))
    zs = sorted(set(rnd(z) for z in zs))
    nx, ny, nl = len(xs) - 1, len(ys) - 1, len(zs) - 1
    zc = [0.5 * (zs[k] + zs[k + 1]) for k in range(nl)]
    cells = {}
    for i in range(nx):
        for j in range(ny):
            x0, x1, y0, y1 = xs[i], xs[i + 1], ys[j], ys[j + 1]
            poly = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
            for (a, b, c) in outline_halfplanes:
                poly = clip_poly(poly, a, b, c)
                if len(poly) < 3:
                    break
            if len(poly) < 3:
                continue
            pr = []
            for p in poly:
                p = (rnd(p[0]), rnd(p[1]))
                if not pr or pr[-1] != p:
                    pr.append(p)
            if len(pr) > 1 and pr[0] == pr[-1]:
                pr.pop()
            if len(pr) < 3:
                continue
            area, cen = poly_area_centroid(pr)
            if area < 1e-6:
                continue
            o = occ_col(cen[0], cen[1], zc)
            if any(o):
                cells[(i, j)] = (pr, o)

    tris = []
    colz = {}          # (x, y) -> Menge der z-Werte, an denen Ecken auf dieser Senkrechten liegen

    def addz(p, z):
        colz.setdefault(p, set()).add(z)

    def solid(i, j, k):
        c = cells.get((i, j))
        return c is not None and c[1][k]

    walls = []
    for (i, j), (poly, o) in cells.items():
        for k in range(nl + 1):
            below = o[k - 1] if k > 0 else False
            above = o[k] if k < nl else False
            if below == above:
                continue
            z = zs[k]
            for p in poly:
                addz(p, z)
            pts = [(p[0], p[1], z) for p in poly]
            if below:
                for m in range(1, len(pts) - 1):
                    tris.append((pts[0], pts[m], pts[m + 1]))
            else:
                for m in range(1, len(pts) - 1):
                    tris.append((pts[0], pts[m + 1], pts[m]))
        n = len(poly)
        for e in range(n):
            p, q = poly[e], poly[(e + 1) % n]
            nb = None
            if p[0] == q[0]:
                if p[0] == xs[i + 1]:
                    nb = (i + 1, j)
                elif p[0] == xs[i]:
                    nb = (i - 1, j)
            elif p[1] == q[1]:
                if p[1] == ys[j + 1]:
                    nb = (i, j + 1)
                elif p[1] == ys[j]:
                    nb = (i, j - 1)
            k = 0
            while k < nl:   # zusammenhaengende Wandstuecke zu einem Streifen zusammenfassen
                if o[k] and not (nb is not None and solid(nb[0], nb[1], k)):
                    k0 = k
                    while k < nl and o[k] and not (nb is not None and solid(nb[0], nb[1], k)):
                        k += 1
                    walls.append((p, q, zs[k0], zs[k]))
                    addz(p, zs[k0]); addz(p, zs[k]); addz(q, zs[k0]); addz(q, zs[k])
                else:
                    k += 1
    srt = {key: sorted(v) for key, v in colz.items()}
    import bisect
    for p, q, z0, z1 in walls:
        def col(pt):
            zl = srt[pt]
            a = bisect.bisect_left(zl, z0)
            b = bisect.bisect_right(zl, z1)
            return [(pt[0], pt[1], z) for z in zl[a:b]]
        L, R = col(p), col(q)       # beide von z0 aufsteigend bis z1
        # Reissverschluss-Triangulierung zwischen linker (p) und rechter (q) Kante
        a = b = 0
        while a < len(L) - 1 or b < len(R) - 1:
            if b < len(R) - 1 and (a == len(L) - 1 or R[b + 1][2] <= L[a + 1][2]):
                tris.append((L[a], R[b], R[b + 1]))
                b += 1
            else:
                tris.append((L[a], R[b], L[a + 1]))
                a += 1
    return tris


def check_mesh(tris, name):
    edges = {}
    for t in tris:
        for a, b in ((t[0], t[1]), (t[1], t[2]), (t[2], t[0])):
            edges[(a, b)] = edges.get((a, b), 0) + 1
    bad = sum(1 for (a, b), cnt in edges.items() if cnt != 1 or edges.get((b, a), 0) != 1)
    vol = 0.0
    for a, b, c in tris:
        vol += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0])
                + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6.0
    xs = [p[0] for t in tris for p in t]
    ys = [p[1] for t in tris for p in t]
    zs = [p[2] for t in tris for p in t]
    print(f"{name}: {len(tris)} Dreiecke, fehlerhafte Kanten: {bad}, Volumen {vol / 1000:.1f} cm3, "
          f"Masse {max(xs) - min(xs):.1f} x {max(ys) - min(ys):.1f} x {max(zs) - min(zs):.1f} mm")
    return bad


def write_stl(path, tris):
    with open(path, "wb") as f:
        f.write(b"biomuell plattform".ljust(80, b" "))
        f.write(struct.pack("<I", len(tris)))
        for a, b, c in tris:
            ux, uy, uz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
            vx, vy, vz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
            nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
            ln = math.sqrt(nx * nx + ny * ny + nz * nz) or 1.0
            f.write(struct.pack("<12fH", nx / ln, ny / ln, nz / ln, *a, *b, *c, 0))


def transform(tris, fn):
    return [tuple(fn(p) for p in t) for t in tris]


# ----------------------------------------------------------------------------
# PLATTFORM  (Koordinaten: Mitte = 0, Plattenoberseite z = 0, Fuesse nach -z)
# ----------------------------------------------------------------------------
def build_plate(STRAPS, FEET):
    L2, W2, c = PLATE_L / 2, PLATE_W / 2, CHAMFER
    outline = [(-L2 + c, -W2), (L2 - c, -W2), (L2, -W2 + c), (L2, W2 - c),
               (L2 - c, W2), (-L2 + c, W2), (-L2, W2 - c), (-L2, -W2 + c)]
    hp = []
    for i in range(len(outline)):
        (x0, y0), (x1, y1) = outline[i], outline[(i + 1) % len(outline)]
        dx, dy = x1 - x0, y1 - y0
        ln = math.hypot(dx, dy)
        a, b = -dy / ln, dx / ln
        hp.append((a, b, -(a * x0 + b * y0)))

    def edge_dist(x, y):
        return min(a * x + b * y + cc for (a, b, cc) in hp)

    zT, zB = 0.0, -PLATE_T
    zR = zB - RIB_H
    zF = zB - FOOT_H

    boxes = [(-L2, L2, -W2, W2, zB, zT)]
    for gx in (-64.0, 0.0, 64.0):
        boxes.append((gx - RIB_W / 2, gx + RIB_W / 2, -W2, W2, zR, zB))
    for gy in (-32.0, 32.0):
        boxes.append((-L2, L2, gy - RIB_W / 2, gy + RIB_W / 2, zR, zB))
    keep = []
    for fx, fy in FEET:
        s, f = FOOT_SIZE / 2, FOOT_FLARE / 2
        boxes.append((fx - s, fx + s, fy - s, fy + s, zF, zB))
        boxes.append((fx - f, fx + f, fy - f, fy + f, zB - FOOT_FLARE_H, zB))
        keep.append((fx - f - 2, fx + f + 2, fy - f - 2, fy + f + 2))

    def to_local(edge, pos, x, y):
        if edge == '+y':
            return x - pos, W2 - y
        if edge == '-y':
            return pos - x, y + W2
        if edge == '+x':
            return pos - y, L2 - x
        return y - pos, x + L2

    def local_rect(edge, pos, u0, u1, v0, v1):
        if edge == '+y':
            return (pos + u0, pos + u1, W2 - v1, W2 - v0)
        if edge == '-y':
            return (pos - u1, pos - u0, -W2 + v0, -W2 + v1)
        if edge == '+x':
            return (L2 - v1, L2 - v0, pos - u1, pos - u0)
        return (-L2 + v0, -L2 + v1, pos + u0, pos + u1)

    boss_u = SLOT_U + CHEEK
    boss_v = SLOT_V + 5.0
    for edge, pos in STRAPS:
        r = local_rect(edge, pos, -boss_u, boss_u, 0, boss_v)
        boxes.append((r[0], r[1], r[2], r[3], BOSS_BOT, zB))
        r = local_rect(edge, pos, -boss_u - 6, boss_u + 6, -1, boss_v + 4)
        keep.append(r)

    holes = set()
    h2 = HOLE / 2
    n = int(L2 // HOLE_PITCH) + 2
    for ix in range(-n, n):
        for iy in range(-n, n):
            cx, cy = HOLE_PITCH / 2 + ix * HOLE_PITCH, HOLE_PITCH / 2 + iy * HOLE_PITCH
            corners = [(cx + sx * h2, cy + sy * h2) for sx in (-1, 1) for sy in (-1, 1)]
            if min(edge_dist(px, py) for px, py in corners) < RIM_W + 3.0:
                continue
            if any(k[0] < cx + h2 and cx - h2 < k[1] and k[2] < cy + h2 and cy - h2 < k[3] for k in keep):
                continue
            holes.add((ix, iy))

    def strap_state(u, v, z):
        """None = keine Aenderung, 'cut' = entfernen, 'pin' = Stift (immer Material)"""
        au = abs(u)
        # Stift
        if au <= SLOT_U + 1.0 and (v - PIN_V) ** 2 + (z - PIN_Z) ** 2 <= PIN_R ** 2:
            return 'pin'
        # Aussparung (durchgehend)
        if au < SLOT_U and v < SLOT_V:
            return 'cut'
        # Fase Umlenkkante (innere Oberkante der Aussparung)
        if au < SLOT_U + FASE_SIDE and SLOT_V <= v < SLOT_V + FASE and v - SLOT_V < z + FASE:
            return 'cut'
        # Fasen an den Seitenkanten
        if SLOT_U <= au < SLOT_U + FASE_SIDE and v < SLOT_V + FASE and au - SLOT_U < z + FASE_SIDE:
            return 'cut'
        return None

    def occ_col(x, y, zcs):
        ed = edge_dist(x, y)
        bxy = [b for b in boxes if b[0] <= x <= b[1] and b[2] <= y <= b[3]]
        locs = []
        for edge, pos in STRAPS:
            u, v = to_local(edge, pos, x, y)
            if abs(u) < SLOT_U + 10 and v < SLOT_V + 10:
                locs.append((u, v))
        hole = False
        ix, iy = math.floor(x / HOLE_PITCH), math.floor(y / HOLE_PITCH)
        if (ix, iy) in holes:
            cx, cy = HOLE_PITCH / 2 + ix * HOLE_PITCH, HOLE_PITCH / 2 + iy * HOLE_PITCH
            hole = abs(x - cx) < h2 and abs(y - cy) < h2
        out = []
        for z in zcs:
            s = any(b[4] <= z <= b[5] for b in bxy)
            if not s and zR <= z <= zB and ed <= RIM_W:
                s = True
            if s and hole and zB <= z <= zT:
                s = False
            for (u, v) in locs:
                st = strap_state(u, v, z)
                if st == 'pin':
                    s = True
                    break
                if st == 'cut':
                    s = False
            out.append(s)
        return out

    xs, ys = {-L2, L2}, {-W2, W2}
    zs = {zT, zB, zR, zF, zB - FOOT_FLARE_H, BOSS_BOT}
    for b in boxes:
        xs |= {b[0], b[1]}
        ys |= {b[2], b[3]}
    for (ix, iy) in holes:
        cx, cy = HOLE_PITCH / 2 + ix * HOLE_PITCH, HOLE_PITCH / 2 + iy * HOLE_PITCH
        xs |= {cx - h2, cx + h2}
        ys |= {cy - h2, cy + h2}
    xs |= {-L2 + RIM_W, L2 - RIM_W}
    ys |= {-W2 + RIM_W, W2 - RIM_W}
    for k in frange(0, c + RIM_W * 2 + 1, 0.75):
        xs |= {L2 - k, -L2 + k}
        ys |= {W2 - k, -W2 + k}
    # feine Rasterlinien fuer Stift, Aussparung und Fasen
    us = {-SLOT_U, SLOT_U, -SLOT_U - 1.0, SLOT_U + 1.0}
    for s in (-1, 1):
        us |= {s * t for t in frange(SLOT_U, SLOT_U + FASE_SIDE, 0.25)}
    vs = {SLOT_V} | set(frange(PIN_V - PIN_R, PIN_V + PIN_R, 0.2)) | set(frange(SLOT_V, SLOT_V + FASE, 0.25))
    for edge, pos in STRAPS:
        for u in us:
            r = local_rect(edge, pos, u, u, 0, 0)
            if edge in ('+y', '-y'):
                xs.add(r[0])
            else:
                ys.add(r[2])
        for v in vs:
            r = local_rect(edge, pos, 0, 0, v, v)
            if edge in ('+y', '-y'):
                ys.add(r[2])
            else:
                xs.add(r[0])
    zs |= set(frange(PIN_Z - PIN_R, PIN_Z + PIN_R, 0.2))
    zs |= set(frange(-max(FASE, FASE_SIDE), 0, 0.25))
    xs = [x for x in xs if -L2 <= x <= L2]
    ys = [y for y in ys if -W2 <= y <= W2]
    tris = mesh_grid(xs, ys, zs, hp, occ_col)
    print(f"Abflussloecher: {len(holes)}")
    return tris



# ----------------------------------------------------------------------------
# BAND  (Druckkoordinaten: X = Laenge, Y = Breite, Z = Dicke; Z=0 Aussenseite)
# Alles ausser dem Haken ist ein "Hoehenfeld": je (x, y) ein Bereich zb..zt.
# Kanten oben gerundet, unten leicht gefast (stuetzenfrei druckbar).
# ----------------------------------------------------------------------------
def sdf_box(x, y, x0, x1, y0, y1):
    qx = max(x0 - x, x - x1)
    qy = max(y0 - y, y - y1)
    return math.hypot(max(qx, 0.0), max(qy, 0.0)) + min(max(qx, qy), 0.0)


def sdf_rrect(x, y, x0, x1, y0, y1, r):
    return sdf_box(x, y, x0 + r, x1 - r, y0 + r, y1 - r) - r


def sdf_convex(x, y, poly):
    """Konvexes Polygon (CCW); innen exakt, aussen Naeherung."""
    d = -1e9
    n = len(poly)
    for i in range(n):
        (x0, y0), (x1, y1) = poly[i], poly[(i + 1) % n]
        ex, ey = x1 - x0, y1 - y0
        ln = math.hypot(ex, ey)
        d = max(d, ((x - x0) * ey - (y - y0) * ex) / ln)
    return d


def roundcap(d, T, r):
    """Oberkante bei Abstand d vom Rand: Viertelkreis mit Radius r, dann T."""
    if d >= r:
        return T
    return T - r + math.sqrt(max(0.0, r * r - (r - d) ** 2))


def build_band(Lb, legs=(0.0,), side_w=FRAME_W):
    """legs: Y-Positionen der Haken. (0,) = Einzelband, (-55, 55) = Buegel mit zwei Beinen."""
    Xc = Zc = R_OUT                      # Hakenmitte
    lx0 = Lb - LOOP_H                    # Unterkante Schlaufe
    win_x0 = lx0 + FRAME_W
    win_x1 = win_x0 + WIN_H
    xg = 0.5 * (win_x1 + Lb)             # Mitte Griffsteg
    hg = GRIP_H / 2
    gx0 = lx0 - GUSSET_L
    hb, hk = BAND_W / 2, HOOK_W / 2
    neck_end = Xc + NECK_L
    lw2 = WIN_W / 2 + side_w
    single = len(legs) == 1
    ramp0 = lx0 - 15.0                   # Buegel: Beine werden zur Schlaufe hin dicker
    assert gx0 > neck_end + 5, "Band zu kurz fuer Schlaufe"
    assert single or all(abs(L) + hb <= lw2 + 1e-6 for L in legs), "Beine breiter als Schlaufe"

    def ccw(poly):
        a, _ = poly_area_centroid(poly)
        return poly if a > 0 else poly[::-1]

    widens, fillets = [], []
    for L in legs:
        widens.append(ccw([(Xc - 2, L - hk), (Xc, L - hk), (Xc + 4, L - hb),
                           (Xc + 4, L + hb), (Xc, L + hk), (Xc - 2, L + hk)]))
        if not single:
            s = -1 if L > 0 else 1                       # Richtung zur Mitte
            yi = L + s * hb
            fillets.append(ccw([(lx0 - 12, yi), (lx0 + 1, yi), (lx0 + 1, yi + s * 12)]))
    gusset = ccw([(gx0, -hb), (lx0 + FRAME_W, -(lw2 - 12)), (lx0 + FRAME_W, lw2 - 12), (gx0, hb)])
    leg_end = gx0 + 1 if single else lx0 + 1

    def band_T(x):
        if x <= neck_end:
            return NECK_T
        if x <= neck_end + 3:
            return NECK_T - (NECK_T - BAND_T) * (x - neck_end) / 3
        if not single and x > ramp0:
            return BAND_T + (FRAME_T - BAND_T) * min(1.0, (x - ramp0) / (lx0 - ramp0))
        return BAND_T

    def heightfield(x, y):
        zb, zt = 1e9, -1e9
        for L in legs:                                   # Hals + Band (je Bein)
            d = -sdf_box(x, y, Xc - 2, leg_end, L - hb, L + hb)
            if d > 0:
                T = band_T(x)
                r = min(FRAME_R if T > 2.5 else BAND_R, T / 2)
                zt = max(zt, roundcap(d, T, r))
                zb = min(zb, max(0.0, BAND_C - d))
        for poly in widens:                              # Verbreiterung zum Haken
            d = -sdf_convex(x, y, poly)
            if d > 0:
                zt = max(zt, roundcap(d, NECK_T, BAND_R))
                zb = min(zb, max(0.0, BAND_C - d))
        for poly in fillets:                             # Hohlkehlen Bein -> Schlaufe
            d = -sdf_convex(x, y, poly)
            if d > 0:
                zt = max(zt, roundcap(d, FRAME_T, min(FRAME_R, FRAME_T / 2)))
                zb = min(zb, max(0.0, FRAME_C - d))
        if single:                                       # Zwickel
            d = -sdf_convex(x, y, gusset)
            if d > 0:
                t = min(1.0, max(0.0, (x - gx0) / (lx0 - gx0)))
                T = BAND_T + t * (FRAME_T - BAND_T)
                c = BAND_C + t * (FRAME_C - BAND_C)
                zt = max(zt, roundcap(d, T, min(FRAME_R, T / 2)))
                zb = min(zb, max(0.0, c - d))
        d_out = -sdf_rrect(x, y, lx0, Lb, -lw2, lw2, 12.0)   # Rahmen der Griffschlaufe
        if d_out > 0:
            d = min(d_out, sdf_rrect(x, y, win_x0, win_x1, -WIN_W / 2, WIN_W / 2, 10.0))
            if d > 0:
                zt = max(zt, roundcap(d, FRAME_T, FRAME_R))
                zb = min(zb, max(0.0, FRAME_C - d))
            dx = abs(x - xg)                             # Griffsteg: dick, oben gewoelbt
            if dx < hg:
                top = 3.0 + (GRIP_T - 3.0) * math.sqrt(1 - (dx / hg) ** 2)
                top = min(top, roundcap(d_out, GRIP_T, 3.0))
                bot = max(0.0, dx - (hg - 3.0), FRAME_C - d_out)
                if top > bot:
                    zt = max(zt, top)
                    zb = min(zb, bot)
        return zb, zt

    def hook(x, y, z):
        if not any(abs(y - L) <= hk for L in legs):
            return False
        dx, dz = x - Xc, z - Zc
        d2 = dx * dx + dz * dz
        # Tropfenform (45-Grad-Dach, oben abgeflacht): beim Druck ohne Ueberhang.
        # Die Oberseite liegt im Gebrauch innen und ist nicht belastet - getragen wird unten.
        r2 = math.sqrt(2)
        outer = d2 <= R_OUT ** 2 or (R_OUT / r2 <= dz <= R_OUT and abs(dx) + dz <= R_OUT * r2)
        inner = d2 < R_IN ** 2 or (R_IN / r2 <= dz < R_IN + TEAR_TOP and abs(dx) + dz < R_IN * r2)
        if not outer or inner:
            return False
        th = math.degrees(math.atan2(dx, dz))    # 0 = nach innen, 90 = nach oben
        return not (GAP_FROM < th < GAP_TO)

    def occ_col(x, y, zcs):
        zb, zt = heightfield(x, y)
        near_hook = x <= 2 * R_OUT + 0.5
        return [(zb <= z <= zt) or (near_hook and hook(x, y, z)) for z in zcs]

    xs = {0, Xc, Xc - 2, neck_end, neck_end + 3, leg_end, Lb}
    xs |= set(frange(0, 2 * R_OUT + 0.4, 0.2))
    xs |= set(frange(Xc - 2, Xc + 4, 0.25))
    xs |= set(frange(neck_end, neck_end + 3, 0.5))
    xs |= set(frange((gx0 - 1) if single else (ramp0 - 1), Lb, 0.5))
    ys = {-lw2, lw2}
    for L in legs:
        ys |= {L - hk, L + hk, L - hb, L + hb}
        for s in (-1, 1):
            ys |= {L + s * v for v in frange(hb - BAND_R - 0.1, hb, 0.1)}
            ys |= {L + s * v for v in frange(hb, hk, 0.25)}
    ys |= set(frange(-lw2, lw2, 0.5))
    zs = set(frange(0, max(2 * R_OUT, GRIP_T), 0.2))
    zs |= {BAND_T, NECK_T, FRAME_T, GRIP_T, 2 * R_OUT, BAND_C, FRAME_C}
    return mesh_grid(list(xs), list(ys), list(zs), [], occ_col)


if __name__ == "__main__":
    import sys
    only = sys.argv[1:]
    for name, var in VARIANTS.items():
        if only and name not in only:
            continue
        plate = build_plate(var["straps"], var["feet"])
        plate = transform(plate, lambda p: (rnd(p[0]), rnd(-p[1]), rnd(-p[2])))   # Fuesse nach oben
        check_mesh(plate, name)
        write_stl(name, plate)
    for name, spec in BANDS.items():
        if only and name not in only:
            continue
        Lb = spec["len"]
        band = build_band(Lb, spec["legs"], spec["side_w"])
        band = transform(band, lambda p: (rnd(p[0] - Lb / 2), rnd(p[1]), rnd(p[2])))
        check_mesh(band, name)
        write_stl(name, band)

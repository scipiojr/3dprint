"""VfB-Bühl-Clicker: Teile um einen Cherry-MX-kompatiblen Schalter. Einheiten: mm."""
import sys, os, math
import numpy as np, cv2
from PIL import Image
from shapely.geometry import Polygon, MultiPolygon, Point, box
from shapely.ops import unary_union
from shapely import affinity
import manifold3d as m3
import trimesh

IMG, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)

# ------------------------------------------------------------------ Parameter
D_OUT    = 40.0   # Außendurchmesser Becher
WALL     = 2.0    # Wand Becher
R_OUT    = D_OUT / 2
R_BORE   = R_OUT - WALL            # 18.0
CLR      = 0.2                     # Luft Kolben <-> Bohrung (radial)
R_CAP    = R_BORE - CLR            # 17.8 -> Logo Ø35.6
D_LOGO   = 2 * R_CAP
FLOOR    = 1.6
T_PLATE  = 2.0    # Dicke Logoplatte
INLAY    = 0.6
CHAMF    = 0.5
H_RED    = 1.0
R_RED    = 0.6
H_WHITE  = 0.6
R_WHITE  = 0.45
T_CARR   = 1.2    # Deckscheibe Kappe
SKIRT_W  = 1.6
SKIRT_L  = 4.5    # Führung des Kolbens (= POST_L, damit die Kappe mit Logoseite oben ohne Stützen druckt)
POST_L   = 4.5
POST_D   = 5.3
CROSS_L, CROSS_W1, CROSS_W2, CROSS_DEPTH = 4.15, 1.30, 1.40, 4.3
SW_HOLE  = 14.1
PLATE_T  = 1.5
PIN_CLR  = 0.4
SW_BELOW = 8.3    # Plattenoberkante -> Pin-Unterkante
SW_HOUS  = 6.6    # Gehäuse-Oberkante über Platte
TRAVEL   = 4.0
R_INS    = R_BORE - 0.1            # Einsatz
INS_WALL = 2.4
RIB_W, RIB_R0, RIB_R1 = 2.0, R_CAP - 0.9, R_BORE + 0.4
GRV_W, GRV_R1 = 2.4, R_BORE + 0.6
LUG_R, LUG_HOLE, LUG_T, LUG_Y = 5.5, 2.6, 3.5, R_OUT + 3.5
CLIP_ANGLES = (0.0, 180.0)   # Weltwinkel der Clips (0° = +x, 90° = Logo oben); nur so passt die Platte in einer Lage
R_NOSE, NOSE_L, ARM_W, NOSE_H = 11.0, 2.0, 1.4, 0.9    # Nasenmitte (Radius), Nasenlänge, Armbreite, Nasenhöhe
ARM_R0, SLOT_W = 3.6, 0.6                              # Arm beginnt bei r=5, Schlitzbreite
BARB, BARB_Z0, BARB_Z1 = 0.4, 0.4, 0.9                 # Widerhaken: Überstand, Unterkante, Oberkante (über Deckfläche)
POCKET_D, POCKET_CLR = 1.0, 0.15                       # Tiefe der Tasche in der Logoplatten-Unterseite, Spiel
SEG = 240

PLATE_TOP = FLOOR + PIN_CLR + SW_BELOW             # 11.3
CAP_UNDER_REST = PLATE_TOP + SW_HOUS + POST_L      # Deckunterkante in Ruhe
GRV_Z0 = CAP_UNDER_REST - TRAVEL - SKIRT_L - 0.4          # Nut beginnt knapp unter der Rippe bei Anschlag
H_CUP = CAP_UNDER_REST - TRAVEL + T_CARR + T_PLATE - 0.3   # Kappe bündig+0.5 bei Anschlag

# ------------------------------------------------------------------ Logo -> Polygone
a = np.array(Image.open(IMG)).astype(np.float32) / 255.0
a = a[:, :900]
al = a[..., 3]
red_s = al * np.clip(a[..., 0] - a[..., 1], 0, 1)
wht_s = al * a[..., 1]
ys, xs = np.where(al > 0.5)
x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
S = D_LOGO / (x1 - x0)
SY = D_LOGO / (y1 - y0)
A_E = B_E = D_LOGO / 2
UP = 4

def vectorize(score):
    big = cv2.resize(score, None, fx=UP, fy=UP, interpolation=cv2.INTER_CUBIC)
    big = cv2.GaussianBlur(big, (0, 0), 1.2)
    mask = (big > 0.5).astype(np.uint8)
    cnts, hier = cv2.findContours(mask, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_NONE)
    polys = []
    if hier is None:
        return MultiPolygon()
    hier = hier[0]
    def ring(c):
        p = c[:, 0, :].astype(np.float64)
        p = (p + 0.5) / UP
        return np.c_[(p[:, 0] - cx) * S, -(p[:, 1] - cy) * SY]
    for i, c in enumerate(cnts):
        if hier[i][3] != -1 or len(c) < 8:
            continue
        holes, j = [], hier[i][2]
        while j != -1:
            if len(cnts[j]) >= 8:
                holes.append(ring(cnts[j]))
            j = hier[j][0]
        p = Polygon(ring(c), holes).buffer(0)
        if p.area > 0.05:
            polys.append(p)
    g = unary_union(polys).simplify(0.012, preserve_topology=True).buffer(0)
    return g

def ellipse(a_, b_, n=SEG * 2):
    t = np.linspace(0, 2 * np.pi, n, endpoint=False)
    return Polygon(np.c_[a_ * np.cos(t), b_ * np.sin(t)])

disc = ellipse(A_E, B_E)
red = vectorize(red_s).intersection(disc)
white = vectorize(wht_s).intersection(disc)
red = red.difference(white).buffer(0)
print(f"Maßstab {S:.4f} mm/px, Ellipse {2*A_E:.2f} x {2*B_E:.2f} mm, "
      f"rot {red.area:.1f} mm², weiß {white.area:.1f} mm²")

# ------------------------------------------------------------------ Helfer
def xs_of(geom):
    rings = []
    geoms = [geom] if isinstance(geom, Polygon) else list(getattr(geom, "geoms", []))
    for g in geoms:
        if g.is_empty or not isinstance(g, Polygon):
            continue
        rings.append(np.asarray(g.exterior.coords)[:-1])
        for h in g.interiors:
            rings.append(np.asarray(h.coords)[:-1])
    return m3.CrossSection(rings, m3.FillRule.EvenOdd)

def ext(geom, h, z=0.0):
    if geom.is_empty:
        return m3.Manifold()
    return m3.Manifold.extrude(xs_of(geom), h).translate((0, 0, z))

def cyl(r, h, z=0.0, r2=None):
    return m3.Manifold.cylinder(h, r, r if r2 is None else r2, SEG).translate((0, 0, z))

def union(parts):
    out = m3.Manifold()
    for p in parts:
        out = out + p
    return out

def rounded(geom, h, r, z=0.0, steps=14):
    """Extrusion mit verrundeter Oberkante (Radius r), als feine Schichten."""
    r = min(r, h)
    parts = [ext(geom, h - r, z)] if h - r > 1e-6 else []
    zp = h - r
    for k in range(1, steps + 1):
        th = k / steps * math.pi / 2
        zt = h - r + r * math.sin(th)
        g = geom.buffer(-r * (1 - math.cos(th)), join_style=1, quad_segs=6)
        if not g.is_empty:
            parts.append(ext(g, zt - zp + (1e-4 if k < steps else 0), z + zp - (1e-4 if zp > 0 else 0)))
        zp = zt
    return union(parts)

def to_trimesh(man, color=None):
    me = man.to_mesh()
    t = trimesh.Trimesh(np.asarray(me.vert_properties)[:, :3], np.asarray(me.tri_verts), process=False)
    if color is not None:
        t.visual.face_colors = color
    return t

BLACK, RED, WHITE, GREY = [25, 25, 25, 255], [225, 20, 20, 255], [245, 245, 245, 255], [70, 70, 70, 255]
report = []
SIMP = float(os.environ.get("SIMP", "0.004"))
def save(man, name, color):
    man = man.simplify(SIMP)
    t = to_trimesh(man, color)
    t.export(os.path.join(OUT, name + ".stl"))
    bb = t.bounds
    report.append((name, t.is_watertight, t.is_winding_consistent, t.volume, bb[1] - bb[0], len(t.faces)))
    return t

# ------------------------------------------------------------------ Logoplatten
def hull_env(a_, b_, t, c):
    t_ = np.linspace(0, 2 * np.pi, SEG * 2, endpoint=False)
    def ring(aa, bb, z):
        return np.c_[aa * np.cos(t_), bb * np.sin(t_), np.full_like(t_, z)]
    pts = np.vstack([ring(a_, b_, 0), ring(a_, b_, t - c), ring(a_ - c, b_ - c, t)])
    return m3.Manifold.hull_points(pts)

env = hull_env(A_E, B_E, T_PLATE, CHAMF)
def clip_uv(phi):
    p = math.radians(phi)
    return np.array([math.cos(p), math.sin(p)]), np.array([-math.sin(p), math.cos(p)])
def rect_uv(phi, u0, u1, v0, v1):
    """Rechteck im Clip-Rahmen (Ursprung = Nasenmitte, u = radial nach außen, v = tangential) in Weltkoordinaten (x, y)."""
    u, v = clip_uv(phi); c = u * R_NOSE
    return Polygon([tuple(c + u * a + v * b) for a, b in ((u0, v0), (u1, v0), (u1, v1), (u0, v1))])
def pocket_for(phi):
    main = ext(rect_uv(phi, -NOSE_L / 2 - POCKET_CLR - 0.05, NOSE_L / 2 + POCKET_CLR + 0.05, -ARM_W / 2 - POCKET_CLR, ARM_W / 2 + POCKET_CLR), POCKET_D + 0.1, -0.1)
    under = ext(rect_uv(phi, -NOSE_L / 2 - POCKET_CLR - 0.05, NOSE_L / 2 + POCKET_CLR + 0.05, ARM_W / 2, ARM_W / 2 + BARB + POCKET_CLR), POCKET_D - (BARB_Z0 - 0.05), BARB_Z0 - 0.05)
    return main + under
PEG_D, PEG_CLR = 2.0, 0.05
dowels = union([cyl(PEG_D / 2 + PEG_CLR, POCKET_D + 0.1, -0.1).translate((sx * R_NOSE, 0, 0)) for sx in (-1, 1)])   # Sacklöcher von unten

# Variante A: bündige Farbeinlagen
zi = T_PLATE - INLAY
A_red = ext(red, INLAY + 0.1, zi) ^ env
A_white = ext(white, INLAY + 0.1, zi) ^ env
A_black = env - ext(red.union(white), INLAY + 0.2, zi) - dowels

# Variante B: erhaben + verrundet. Rot = VFB (+ Sockel unter "Bühl"), Weiß sitzt obenauf.
inner = ellipse(A_E - CHAMF - 0.05, B_E - CHAMF - 0.05)
def opened(g, d=0.04):
    # schmale Engstellen/Berührpunkte (zwei Flächen berühren sich nur an einer Kante) auflösen
    return g.buffer(-d, join_style=2, mitre_limit=5).buffer(d, join_style=2, mitre_limit=5).buffer(0)
red_c, white_c = opened(red.intersection(inner)), opened(white.intersection(inner))
B_black = env - dowels
B_red_vfb = rounded(red_c, H_RED, R_RED, T_PLATE)                         # V F B
B_white_full = rounded(white_c.buffer(0.08, join_style=2, mitre_limit=5), H_RED + H_WHITE, R_WHITE, T_PLATE)         # "Bühl", durchgehend vom Plattenrand
combined = B_red_vfb + B_white_full
SPLIT = T_PLATE + H_RED                                                    # Farbwechsel Rot -> Weiß
B_red = combined ^ m3.Manifold.cube((60, 60, SPLIT - T_PLATE + 1.0), False).translate((-30, -30, T_PLATE - 1.0))
B_white = combined ^ m3.Manifold.cube((60, 60, 10), False).translate((-30, -30, SPLIT))

# ------------------------------------------------------------------ Kappe (Kolben)
# lokal: z=0 Klebefläche zur Logoplatte, +z Richtung Schalter. Rippe bei -y (wird im Zusammenbau +y).
carrier = cyl(R_CAP, T_CARR + SKIRT_L) - cyl(R_CAP - SKIRT_W, SKIRT_L + 1, T_CARR)
rib = m3.Manifold.cube((RIB_W, RIB_R1 - RIB_R0, SKIRT_L), False).translate((-RIB_W / 2, -RIB_R1, T_CARR))
post = cyl(POST_D / 2, POST_L, T_CARR) + cyl(3.9, 1.4, T_CARR, r2=POST_D / 2)
cross = (m3.Manifold.cube((CROSS_L, CROSS_W1, CROSS_DEPTH + 1), True) +
         m3.Manifold.cube((CROSS_W2, CROSS_L, CROSS_DEPTH + 1), True)
         ).translate((0, 0, T_CARR + POST_L - CROSS_DEPTH / 2 + 0.5))
carrier = carrier + rib + post - cross
# Stützrippen unter der Deckscheibe (Kappe druckt mit der Logoseite oben): keine Brücke über Ø32
carrier = carrier + union([m3.Manifold.cube((5.0, 1.0, SKIRT_L), False).translate((11.6, -0.5, T_CARR)).rotate((0, 0, 22.5 + 45 * k)) for k in range(8)])
# Fase an der Skirt-Unterkante
carrier = carrier ^ (cyl(R_CAP + 1, T_CARR + SKIRT_L - 0.5) + cyl(R_CAP + 1, 0.5, T_CARR + SKIRT_L - 0.5, r2=R_CAP - 0.5))

# Clips: Biegearm in der Deckscheibe (Schlitze), Nase mit Widerhaken ragt Richtung Logoplatte (lokal -z), bleibt unter deren Oberkante
def to_local_xy(g):
    return affinity.scale(g, 1, -1, origin=(0, 0))        # Kappe lokal ist gegenüber der Welt um die x-Achse gedreht
def lp(c, u, v, a, b, zup):
    """Punkt im Clip-Rahmen (a längs, b quer, zup über der Deckfläche) -> Kappen-Lokalkoordinaten."""
    w = c + u * a + v * b
    return (w[0], -w[1], -zup)
noses = [cyl(PEG_D / 2, NOSE_H + 0.15, -NOSE_H).translate((sx * R_NOSE, 0, 0)) for sx in (-1, 1)]   # starre Zapfen
carrier = carrier + union(noses)
carrier_print = carrier.rotate((180, 0, 0)).translate((0, 0, T_CARR + SKIRT_L))   # Drucklage: Logoseite oben, Skirt/Zapfen unten auf dem Bett

# ------------------------------------------------------------------ Einsatz (Schalterplatte)
# lokal: z=0 Plattenoberseite (liegt beim Druck auf dem Bett), +z Richtung Becherboden
L_INS = PLATE_TOP - FLOOR
insert = cyl(R_INS, L_INS) - cyl(R_INS - INS_WALL, L_INS, PLATE_T)
insert = insert - m3.Manifold.cube((SW_HOLE, SW_HOLE, 10), True)
insert = insert ^ (cyl(R_INS, L_INS - 0.4, 0.4) + cyl(R_INS - 0.4, 0.4, 0, r2=R_INS))

# ------------------------------------------------------------------ Becher mit Öse
cup = cyl(R_OUT, H_CUP) - cyl(R_BORE, H_CUP, FLOOR)
cup = cup - cyl(R_BORE + 0.6, 0.61, H_CUP - 0.6, r2=R_BORE)            # Einführschräge
groove = m3.Manifold.cube((GRV_W, GRV_R1 - (R_BORE - 0.5), H_CUP - GRV_Z0 + 1), False
                          ).translate((-GRV_W / 2, R_BORE - 0.5, GRV_Z0))
cup = cup - groove

# ------------------------------------------------------------------ Fußball-Muster (Zylinder bleibt Zylinder)
import shapely
N_COL = 12                                   # Felder pro Reihe (muss durch 3 teilbar sein)
A_ARC = 2 * math.pi * R_OUT / N_COL          # Breite eines Sechsecks (Bogenlänge)
RH = A_ARC / math.sqrt(3)                    # Umkreisradius Sechseck
ZA = 5.1                                     # Mitte untere Reihe
ROW_DZ = 1.5 * RH
GW, GD, PD = 0.8, 0.5, 0.6                   # Nahtbreite, Nahttiefe, Tiefe Fünfeck-Einlage
R_PENT = 5.95

def hexagon(cx, cz):
    return Polygon([(cx + RH * math.cos(math.radians(90 + 60 * m)), cz + RH * math.sin(math.radians(90 + 60 * m))) for m in range(6)])
def pentagon(cx, cz):
    return Polygon([(cx + R_PENT * math.cos(math.radians(90 + 72 * m)), cz + R_PENT * math.sin(math.radians(90 + 72 * m))) for m in range(5)])

cells = {}
for row in (0, 1):
    for k in range(-N_COL, 2 * N_COL):
        cells[(k, row)] = ((k + 0.5 * row) * A_ARC, ZA + row * ROW_DZ, (k - row) % 3 == 0)
pents_all = unary_union([pentagon(sc, zc) for (sc, zc, ip) in cells.values() if ip])

def wrap_geom(g):
    g = shapely.segmentize(g, 0.4)
    return shapely.transform(g, lambda c: np.c_[R_OUT * np.sin(c[:, 0] / R_OUT), c[:, 1]])

def shell_cut(poly_local, r_in, r_out, theta_c):
    if poly_local.is_empty:
        return m3.Manifold()
    prism = ext(wrap_geom(poly_local), 40, -40).rotate((90, 0, 0))
    shell = cyl(r_out, 60, -20) - cyl(r_in, 60, -20)
    return (prism ^ shell).rotate((0, 0, theta_c - 90))

groove_parts, pocket_parts, inlay_parts = [], [], []
for (k, row), (sc, zc, ip) in cells.items():
    if not (0 <= k < N_COL):
        continue
    theta_c = 270 + math.degrees(sc / R_OUT)
    tile = pentagon(sc, zc) if ip else hexagon(sc, zc).difference(pents_all)
    tile = affinity.translate(tile, -sc, 0)
    ring = tile.boundary.buffer(GW / 2, 8)
    groove_parts.append(shell_cut(ring, R_OUT - GD, R_OUT + 1, theta_c))
    if ip:
        inner = tile.buffer(-GW / 2 - 0.05)
        pocket_parts.append(shell_cut(inner, R_OUT - PD, R_OUT + 1, theta_c))
        inlay_parts.append(shell_cut(inner, R_OUT - PD, R_OUT, theta_c))
cup = cup - union(groove_parts) - union(pocket_parts)
inlays = union(inlay_parts) ^ cyl(R_OUT, H_CUP)
print(f"Fußball-Muster: {N_COL} Felder je Reihe, {len(inlay_parts)} Fünfecke, Sechseck {A_ARC:.1f} mm breit")
lug2d = unary_union([Point(0, -LUG_Y).buffer(LUG_R, 64), box(-LUG_R, -LUG_Y, LUG_R, -(R_OUT - 1.4))])
lug2d = lug2d.buffer(1.2, 32).buffer(-1.2, 32).difference(Point(0, -LUG_Y).buffer(LUG_HOLE, 48))
lug2d = affinity.rotate(lug2d, 210, origin=(0, 0))   # 6 Uhr -> 11 Uhr
lug = ext(lug2d, LUG_T)
lug = lug - cyl(R_BORE, LUG_T + 2, FLOOR - 0.0)                         # Bohrung freihalten
cup = cup + lug
cup = cup ^ (cyl(R_OUT + 30, H_CUP))                                    # nichts über den Rand

# ------------------------------------------------------------------ Export einzelne Teile
T = {}
T["A_schwarz"] = save(A_black, "logoplatte_A_buendig_schwarz", BLACK)
T["A_rot"] = save(A_red, "logoplatte_A_buendig_rot", RED)
T["A_weiss"] = save(A_white, "logoplatte_A_buendig_weiss", WHITE)
T["B_schwarz"] = save(B_black, "logoplatte_B_erhaben_schwarz", BLACK)
T["B_rot"] = save(B_red, "logoplatte_B_erhaben_rot", RED)
T["B_weiss"] = save(B_white, "logoplatte_B_erhaben_weiss", WHITE)
T["kappe"] = save(carrier_print, "kappe_kolben", BLACK)
T["einsatz"] = save(insert, "einsatz_schalterplatte", BLACK)
T["becher"] = save(cup, "becher_mit_oese", [240, 240, 240, 255])
T["pent"] = save(inlays, "becher_fuenfecke_schwarz", BLACK)

for name, wt, wc, vol, size, nf in report:
    print(f"{name:32s} dicht={wt} konsistent={wc} V={vol:8.1f} mm³  "
          f"{size[0]:.2f} x {size[1]:.2f} x {size[2]:.2f}  ({nf} Dreiecke)")

def scene(parts, fn):
    sc = trimesh.Scene()
    for n, t in parts:
        sc.add_geometry(t, node_name=n, geom_name=n)
    sc.export(os.path.join(OUT, fn))
scene([("becher", T["becher"]), ("fuenfecke", T["pent"])], "becher_fussball_mehrfarbig.3mf")
scene([("schwarz", T["A_schwarz"]), ("rot", T["A_rot"]), ("weiss", T["A_weiss"])], "logoplatte_A_buendig_mehrfarbig.3mf")
scene([("schwarz", T["B_schwarz"]), ("rot", T["B_rot"]), ("weiss", T["B_weiss"])], "logoplatte_B_erhaben_mehrfarbig.3mf")

# ------------------------------------------------------------------ Zusammenbau (z=0 Becherunterseite)
def flip(man, ztop):
    return man.rotate((180, 0, 0)).translate((0, 0, ztop))
def asm(press):
    zc = CAP_UNDER_REST + T_CARR - press
    return flip(insert, PLATE_TOP), flip(carrier, zc), zc
for press in (0.0, TRAVEL):
    ins, cap, zc = asm(press)
    print(f"Hub {press:.0f}: Kollision Kappe/Becher {(cap ^ cup).volume():.3f}, Kappe/Einsatz {(cap ^ ins).volume():.3f}, Einsatz/Becher {(ins ^ cup).volume():.3f} mm³; "
          f"Skirt-Unterkante z={zc - T_CARR - SKIRT_L:.2f} (Plattenoberseite {PLATE_TOP:.2f}); "
          f"Deckunterkante z={zc - T_CARR:.2f} (Gehäuseoberkante Schalter {PLATE_TOP + SW_HOUS:.2f}); "
          f"Kappenoberseite A z={zc + T_PLATE:.2f} (Rand {H_CUP:.2f})")
for press in (0.0,):
    _, cap0, zc0 = asm(0.0)
    for nm, pl_ in (("A", A_black), ("B", B_black)):
        print(f"Kappe/Logoplatte {nm} (schwarz): Überschneidung {(cap0 ^ pl_.translate((0, 0, zc0))).volume():.4f} mm³")
    top_nose = zc0 + NOSE_H * 0   # Nasenoberkante liegt NOSE_H über der Deckfläche, Plattenoberkante T_PLATE darüber
    print(f"Nasenoberkante {NOSE_H:.1f} mm, Plattenoberkante {T_PLATE:.1f} mm über der Deckfläche -> Nase ragt nicht heraus")
def export_asm(var, fn):
    ins, cap, zc = asm(0.0)
    parts = [("becher", to_trimesh(cup, [240, 240, 240, 255])), ("fuenfecke", to_trimesh(inlays, BLACK)), ("einsatz", to_trimesh(ins, GREY)), ("kappe", to_trimesh(cap, BLACK))]
    for col in ("schwarz", "rot", "weiss"):
        t = T[f"{var}_{col}"].copy(); t.apply_translation((0, 0, zc)); parts.append((col, t))
    sc = trimesh.Scene()
    for n, t in parts:
        sc.add_geometry(t, node_name=n, geom_name=n)
    sc.export(os.path.join(OUT, fn))
export_asm("A", "_asm_A.glb"); export_asm("B", "_asm_B.glb")
zc = CAP_UNDER_REST + T_CARR
print(f"Becherhöhe {H_CUP:.1f} mm, Gesamthöhe in Ruhe: A {zc + T_PLATE:.1f} mm, B {zc + T_PLATE + H_RED + H_WHITE:.1f} mm, Logo Ø{D_LOGO:.1f} mm")

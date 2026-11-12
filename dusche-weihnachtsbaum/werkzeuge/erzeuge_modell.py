#!/usr/bin/env python3
"""Weihnachtsbaum-Duschkopf mit Hansgrohe-Schnellkupplung erzeugen.

Aus dem Original (DuchaArbolBolas.3mf, QuiqueCrimson/MakerWorld):
- der 1/2"-Gewindezapfen wird durch den Stecker aus
  schnellkupplung_stecker.scad ersetzt,
- der eckige Griff (20 x 20) wird durch einen runden ersetzt (ohne Fase zum Baum),
- mit --geschenke kommt links und rechts ein quadratischer Karton unter den
  Baum (Baum-Material). Die Farbe ist wie die übrige Deko nur aufgebracht:
  Karton weiß, Bänder und Schleife rot, jeweils nur in der obersten Haut
  (0,8 mm), damit nur in wenigen Lagen die Farbe gewechselt wird.

Ziel ist ein Anycubic-Drucker mit ACE (4 Filamente) und Anycubic Slicer Next
(Orca-basiert, liest Bambu-3MF mit Bauteilen und Farbbemalung). Die
Bambu-Druckeinstellungen des Originals werden deshalb nicht übernommen, und
die Bemalung der Kugeln wird auf die Filamente 1–4 umnummeriert.

Ausgabe: STL(s) und eine 3MF (Bambu/Orca-Format) mit Bauteilen und Bemalung.

Aufruf:
  python3 erzeuge_modell.py <original.3mf> <ausgabe_ordner> [--geschenke]
Benötigt: openscad, numpy, trimesh, manifold3d, lxml, shapely
"""
import json, os, re, subprocess, sys, tempfile, uuid, zipfile
import numpy as np
import trimesh
import manifold3d as mf
from lxml import etree
from shapely.geometry import Point, Polygon, box
from shapely import affinity
from shapely.ops import unary_union

HIER = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HIER, '..', 'schnellkupplung_stecker.scad')
NS = {'m': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'}
OBJ = '3D/Objects/object_1.model'

# --- gemessen am Original (Mesh-Koordinaten, Baumspitze bei +x) ---
ACHSE_Y, ACHSE_Z = 0.0, -0.625   # Griffachse = Mitte des Griffs (20 x 20)
Z_BETT, Z_OBEN = -10.625, 10.625 # Unter-/Oberseite des Modells (Stärke 21,25)
X_STECKER = -97.5                # Griffende; links davon saß das Gewinde (bis x = -115)
X_HALS = -15.0                   # Hals 13 x 15 bis zum Baumfuß
X_FUSS = -3.5                    # Unterseite des Fußrands (voll, Hohlraum erst ab x = +1,75)
BOHRUNG_D = 10.0                 # Wasserbohrung im Griff

# --- neuer Griff ---
GRIFF_D = 21.25                  # Achse bei z = -0,625: unten 7,2 mm breit abgeflacht, oben z = 10,0
FASE_GRIFF = 1.0                 # Außenkante der Stirnfläche am Stecker

# --- Filamente (Slots der Original-3MF, 1-basiert) ---
# --- Filamente (ACE, 4 Slots) ---
F_GRUEN, F_ROT, F_GOLD, F_WEISS = 1, 2, 3, 4
# Bemalung im Original: Filament 4 = Gold, 5 = Rot, 6 = Grün (Bambu-Slots) -> neu
UMNUMMERIERUNG = {4: F_GOLD, 5: F_ROT, 6: F_GRUEN}
HAUT = 0.8                       # Dicke der aufgebrachten Farbe oben (4 Lagen à 0,2)

NAME = 'weihnachtsbaum_dusche_quick_connect'


def umnummerieren(code):
    """paint_color (Bambu/Orca TriangleSelector, Hex-Nibbles von hinten gelesen) auf neue Filamente umschreiben."""
    if not code:
        return None
    ein = [int(c, 16) for c in reversed(code)]
    aus, i = [], 0

    def knoten():
        nonlocal i
        c = ein[i]; i += 1
        if c & 3:                                    # geteilt: Kinder folgen
            aus.append(c)
            for _ in range((c & 3) + 1):
                knoten()
            return
        if (c & 0b1100) == 0b1100:
            zustand = ein[i] + 3; i += 1
        else:
            zustand = c >> 2
        zustand = UMNUMMERIERUNG.get(zustand, zustand)
        aus.extend([0b1100, zustand - 3] if zustand >= 3 else [zustand << 2])

    while i < len(ein):
        knoten()
    return ''.join('%X' % n for n in reversed(aus))


def lade_original(xml_bytes):
    """Netz des Originals als Manifold, dazu die Bambu-Bemalung je Dreieck (paint_color)."""
    t = etree.fromstring(xml_bytes)
    v = np.array([[float(e.get(k)) for k in 'xyz'] for e in t.iterfind('.//m:vertex', NS)], np.float32)
    tris = list(t.iterfind('.//m:triangle', NS))
    f = np.array([[int(e.get(k)) for k in ('v1', 'v2', 'v3')] for e in tris], np.uint32)
    farbe = [umnummerieren(e.get('paint_color')) for e in tris]
    k = mf.Manifold(mf.Mesh(vert_properties=v, tri_verts=f, face_id=np.arange(len(f), dtype=np.uint32)))
    assert k.status() == mf.Error.NoError, k.status()
    ids = set(np.asarray(k.to_mesh().run_original_id).tolist())
    assert len(ids) == 1
    return k, ids.pop(), farbe


def zu_manifold(m):
    return mf.Manifold(mf.Mesh(vert_properties=np.asarray(m.vertices, np.float32),
                               tri_verts=np.asarray(m.faces, np.uint32)))


class Teil:
    """Ergebnisnetz mit übernommener Bemalung der Dreiecke, die aus dem Original stammen."""
    def __init__(self, k, original_id=None, farbe=None):
        g = k.to_mesh()
        self.v = np.asarray(g.vert_properties)[:, :3].astype(float)
        self.f = np.asarray(g.tri_verts)
        self.farbe = [None] * len(self.f)
        if original_id is not None:
            ri, ro, fid = np.asarray(g.run_index), np.asarray(g.run_original_id), np.asarray(g.face_id)
            for r, oid in enumerate(ro):
                if oid == original_id:
                    for i in range(ri[r] // 3, ri[r + 1] // 3):
                        self.farbe[i] = farbe[fid[i]]

    def trimesh(self):
        return trimesh.Trimesh(self.v, self.f, process=False)


def quader(x0, x1, y0=-100, y1=100, z0=-100, z1=100):
    return mf.Manifold.cube([x1 - x0, y1 - y0, z1 - z0]).translate([x0, y0, z0])


def zylinder_x(x0, x1, d0, d1=None, drehung=0.0):
    """Kegelstumpf/Zylinder auf der Griffachse von x0 nach x1."""
    d1 = d0 if d1 is None else d1
    z = mf.Manifold.cylinder(x1 - x0, d0 / 2, d1 / 2, 256).rotate([0, 0, drehung])
    return z.rotate([0, 90, 0]).translate([x0, ACHSE_Y, ACHSE_Z])


def stecker():
    with tempfile.TemporaryDirectory() as d:
        p = os.path.join(d, 's.stl')
        subprocess.run(['openscad', '-o', p, SCAD], check=True, capture_output=True)
        m = trimesh.load(p)
    m.apply_transform(trimesh.transformations.rotation_matrix(-np.pi / 2, [0, 1, 0]))  # +z -> -x
    m.apply_translation([X_STECKER, ACHSE_Y, ACHSE_Z])
    return zu_manifold(m)


def runder_griff():
    # stumpf bis an den Hals (keine Fase zum Baum); Stirnkante am Stecker 1 mm gefast
    g = (zylinder_x(X_STECKER, X_STECKER + FASE_GRIFF, GRIFF_D - 2 * FASE_GRIFF, GRIFF_D)
         + zylinder_x(X_STECKER + FASE_GRIFF - 0.01, X_HALS + 0.3, GRIFF_D))
    g = g ^ quader(-200, 200, z0=Z_BETT, z1=Z_OBEN)          # unten abflachen
    # gegen die Bohrung des Originals leicht verdreht, damit keine Ecken zusammenfallen
    return g - zylinder_x(X_STECKER - 1, X_HALS + 1, BOHRUNG_D, drehung=0.37)


# ---------------- Geschenke ----------------
# 2D in der (x, y)-Ebene, x zeigt zur Baumspitze ("oben").
KANTE = 26.0        # Karton quadratisch, 26 x 26 (Stärke wie der Baum: 21,25)
Y_INNEN = 9.6       # 1 mm in den Griffmantel (r = 10,625)
X_DECKEL = -2.5     # 1 mm in den vollen Fußrand (Unterseite x = -3,5, Hohlraum erst ab x = +1,75)
BAND = 3.2          # Breite der aufgemalten Bänder
X_PROFIL = -2.0     # hier wird die Wölbung des Baumfußes abgenommen (knapp über dem gerundeten Rand)
FASE_OBEN = 1.2     # Fase zwischen gewölbter Oberseite und Seitenflächen
FASE_ECKE = 2.0     # senkrechte Außenecke
FASE_BETT = 0.6     # Unterkanten am Bett (klein, sonst fehlt Auflage)


def ellipse(cx, cy, a, b, winkel):
    e = affinity.scale(Point(0, 0).buffer(1, 64), a, b)
    return affinity.translate(affinity.rotate(e, winkel, origin=(0, 0)), cx, cy)


def schleife(yc):
    """Aufgemalte Schleife: Knoten an der Deckelkante, zwei Schlaufen schräg nach oben auf den untersten Ast."""
    xk = X_DECKEL - 0.8
    teile = [Point(xk, yc).buffer(2.6, 48)]
    for s in (1, -1):
        w = s * 50                              # 50° gegen die Baumachse, je eine Seite
        r = np.radians(w)
        cx, cy = xk + 6.2 * np.cos(r), yc + 6.2 * np.sin(r)
        teile.append(ellipse(cx, cy, 6.6, 3.8, w).difference(ellipse(cx, cy, 4.6, 1.8, w)))
    return unary_union(teile)


def geschenke_2d():
    """-> (Kartons, Flächen für die roten Bänder und Schleifen)"""
    kartons, rot = [], []
    for s in (1, -1):
        y0, y1 = sorted((s * Y_INNEN, s * (Y_INNEN + KANTE)))
        x0, x1 = X_DECKEL - KANTE, X_DECKEL
        yc, xc = (y0 + y1) / 2, (x0 + x1) / 2
        kartons.append(box(x0, y0, x1, y1))
        rot += [box(x0, yc - BAND / 2, x1, yc + BAND / 2),      # Band längs
                box(xc - BAND / 2, y0, xc + BAND / 2, y1),      # Band quer
                schleife(yc)]                                   # Schleife, reicht auf den Baum
    return unary_union(kartons), unary_union(rot)


def woelbung(baum):
    """Oberseite des Baumfußes z = f(|y|), abgetastet bei x = X_PROFIL (Strahlen von oben)."""
    m = trimesh.Trimesh(*(lambda g: (np.asarray(g.vert_properties)[:, :3], np.asarray(g.tri_verts)))(baum.to_mesh()))
    ys = np.arange(0, 45.01, 0.25)
    z = np.full(len(ys), np.nan)
    orte, strahl, _ = m.ray.intersects_location(np.c_[np.full(len(ys), X_PROFIL), ys, np.full(len(ys), 50.0)],
                                                np.tile([0, 0, -1.0], (len(ys), 1)))
    for (_, _, zz), i in zip(orte, strahl):
        z[i] = zz if np.isnan(z[i]) else max(z[i], zz)
    ok = ~np.isnan(z)
    letzte = np.nonzero(ok)[0][-1]
    steigung = (z[letzte] - z[letzte - 8]) / (ys[letzte] - ys[letzte - 8])
    z[letzte + 1:] = z[letzte] + steigung * (ys[letzte + 1:] - ys[letzte])   # über den Rand hinaus fortsetzen
    return lambda y: np.interp(np.abs(y), ys, z)


def geschenk_koerper(f):
    """Rechtes Geschenk (y > 0): Grundriss KANTE x KANTE, Oberseite folgt der Wölbung f des Baums,
    Außenkanten gefast. Das linke entsteht durch Spiegeln."""
    x0, x1 = X_DECKEL - KANTE, X_DECKEL
    y0, y1 = Y_INNEN, Y_INNEN + KANTE
    yy = np.linspace(y0, y1 - FASE_OBEN, 120)
    # Querschnitt (y, z): gewölbte Oberseite, außen oben und unten gefast
    oben = [(y, f(y)) for y in yy] + [(y1, f(y1) - FASE_OBEN)]
    profil = Polygon(oben + [(y1, Z_BETT + FASE_BETT), (y1 - FASE_BETT, Z_BETT), (y0, Z_BETT)])
    hoch = Polygon(oben + [(y1 + 5, f(y1) - FASE_OBEN - 5), (y1 + 5, Z_BETT - 50), (y0, Z_BETT - 50)])

    def entlang_x(poly, xa, xb):
        m = trimesh.creation.extrude_polygon(poly, xb - xa)      # (y, z) in xy, Höhe in z
        m.apply_transform(np.array([[0, 0, 1, xa], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1.0]]))
        return zu_manifold(m)

    k = entlang_x(profil, x0, x1)
    # Kante Oberseite / Unterseite des Kartons (x = x0): gescherte Wölbung, 45°
    schraeg = entlang_x(hoch, x0 - 10, x1 + 10).transform(
        np.array([[1, 0, 0, 0], [0, 1, 0, 0], [1, 0, 1, -x0 - FASE_OBEN]], dtype=float))
    k = k ^ schraeg
    # Kante am Bett bei x = x0 und senkrechte Außenecke (x0, y1)
    k = k.trim_by_plane([1 / np.sqrt(2), 0, 1 / np.sqrt(2)], (x0 + Z_BETT + FASE_BETT) / np.sqrt(2))
    k = k.trim_by_plane([1 / np.sqrt(2), -1 / np.sqrt(2), 0], (x0 - y1 + FASE_ECKE) / np.sqrt(2))
    return k


def saeubern(k, min_volumen=0.05):
    """Volumenlose Splitter (Boolesche Reste an senkrechten Kanten) entfernen."""
    return mf.Manifold.batch_boolean([t for t in k.decompose() if t.volume() > min_volumen], mf.OpType.Add)


def haut_oben(k, d):
    """Oberste Schicht der Dicke d (senkrecht gemessen), folgt auch schrägen Flächen:
    Punkte in k, über denen im Abstand d kein Material mehr ist. Nur obere Hälfte,
    sonst kämen Hohlraumböden dazu."""
    return (k - k.translate([0, 0, -d])) ^ quader(-200, 200, z0=ACHSE_Z, z1=50)


def extrudiere(flaeche, rand=0):
    k = mf.Manifold()
    for poly in getattr(flaeche, 'geoms', [flaeche]):
        m = trimesh.creation.extrude_polygon(poly, Z_OBEN - Z_BETT + 2 * rand)
        m.apply_translation([0, 0, Z_BETT - rand])
        k += zu_manifold(m)
    return k


# ---------------- 3MF ----------------
def mesh_xml(m, oid, uid):
    t = [f'  <object id="{oid}" p:UUID="{uid}" type="model">\n   <mesh>\n    <vertices>\n']
    t += [f'     <vertex x="{x:.9g}" y="{y:.9g}" z="{z:.9g}"/>\n' for x, y, z in m.v]
    t.append('    </vertices>\n    <triangles>\n')
    t += [f'     <triangle v1="{a}" v2="{b}" v3="{c}"' + (f' paint_color="{p}"' if p else '') + '/>\n'
          for (a, b, c), p in zip(m.f, m.farbe)]
    t.append('    </triangles>\n   </mesh>\n  </object>\n')
    return ''.join(t)


def schreibe_3mf(quelle, aus, teile, titel):
    """teile: Liste (name, Teil, filament). Ein Objekt, ein Bauteil je Farbe."""
    z = zipfile.ZipFile(quelle)
    vorlage = z.read(OBJ).decode()
    kopf = vorlage.split('<resources>')[0] + '<resources>\n'
    haupt = len(teile) + 1
    with zipfile.ZipFile(aus, 'w', zipfile.ZIP_DEFLATED) as o:
        for info in z.infolist():
            n = info.filename
            if n.startswith(('Auxiliaries/', 'Metadata/plate', 'Metadata/top', 'Metadata/pick')):
                continue  # Fotos/Vorschauen des Originals passen nicht mehr
            if n in ('Metadata/project_settings.config', 'Metadata/slice_info.config',
                     'Metadata/filament_sequence.json'):
                continue  # Bambu-X1C-Einstellungen (19 Filamente) passen nicht zum Anycubic/ACE
            d = z.read(n)
            if n == OBJ:
                d = (kopf + ''.join(mesh_xml(m, i + 1, uuid.uuid4()) for i, (_, m, _) in enumerate(teile))
                     + ' </resources>\n <build/>\n</model>\n').encode()
            elif n == '3D/3dmodel.model':
                s = d.decode()
                s = s.replace('<metadata name="Title">Xmas tree shower head</metadata>',
                              f'<metadata name="Title">{titel}</metadata>')
                s = re.sub(r'\s*<metadata name="Thumbnail_(Middle|Small)">[^<]*</metadata>', '', s)
                komp = ''.join(f'\n    <component p:path="/{OBJ}" objectid="{i + 1}" p:UUID="{uuid.uuid4()}" '
                               f'transform="1 0 0 0 1 0 0 0 1 0 0 0" />' for i in range(len(teile)))
                s = re.sub(r'<object id="2"(.*?)<components>.*?</components>',
                           lambda mo: f'<object id="{haupt}"{mo.group(1)}<components>{komp}\n   </components>', s, flags=re.S)
                s = s.replace('<item objectid="2"', f'<item objectid="{haupt}"')
                d = s.encode()
            elif n == 'Metadata/model_settings.config':
                d = model_settings(teile, haupt, os.path.basename(aus)[:-4]).encode()
            o.writestr(info, d)


def model_settings(teile, haupt, name):
    t = ['<?xml version="1.0" encoding="UTF-8"?>\n<config>\n',
         f'  <object id="{haupt}">\n    <metadata key="name" value="{name}"/>\n',
         f'    <metadata key="extruder" value="{teile[0][2]}"/>\n',
         f'    <metadata face_count="{sum(len(m.f) for _, m, _ in teile)}"/>\n']
    for i, (tn, m, f) in enumerate(teile):
        t.append(f'    <part id="{i + 1}" subtype="normal_part">\n'
                 f'      <metadata key="name" value="{tn}"/>\n'
                 f'      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>\n'
                 f'      <metadata key="extruder" value="{f}"/>\n'
                 f'      <mesh_stat face_count="{len(m.f)}" edges_fixed="0" degenerate_facets="0" '
                 f'facets_removed="0" facets_reversed="0" backwards_edges="0"/>\n    </part>\n')
    t.append('  </object>\n  <plate>\n    <metadata key="plater_id" value="1"/>\n'
             '    <metadata key="plater_name" value=""/>\n    <metadata key="locked" value="false"/>\n'
             f'    <model_instance>\n      <metadata key="object_id" value="{haupt}"/>\n'
             '      <metadata key="instance_id" value="0"/>\n      <metadata key="identify_id" value="368"/>\n'
             '    </model_instance>\n  </plate>\n</config>\n')
    return ''.join(t)


# ---------------- Ablauf ----------------
def main(quelle, ziel, mit_geschenken):
    os.makedirs(ziel, exist_ok=True)
    baum, baum_id, farbe = lade_original(zipfile.ZipFile(quelle).read(OBJ))

    rest = baum ^ quader(X_HALS, 200)                    # Hals und Baum bleiben
    duschkopf = rest + runder_griff() + stecker()
    teile = [('Baum', Teil(duschkopf, baum_id, farbe), F_GRUEN)]
    name, titel = NAME, 'Xmas tree shower head – Hansgrohe Quick Connect'

    if mit_geschenken:
        kartons, rot_2d = geschenke_2d()
        rechts = geschenk_koerper(woelbung(baum))
        karton = rechts + rechts.mirror([0, 1, 0])
        # Kartons berühren nur Griffmantel (|y| > 9,6) und Fußrand (x < -2,5) -> weit weg von
        # Wasserbohrung (r < 5) und Hohlraum (x > 1,75)
        assert karton.bounding_box()[3] <= X_DECKEL + 1e-6
        ganz = duschkopf + karton
        assert len(ganz.decompose()) == 1, 'Karton nicht mit dem Baum verbunden'
        h = haut_oben(ganz, HAUT)
        rot = saeubern(h ^ extrudiere(rot_2d, rand=1))
        weiss = saeubern((h ^ extrudiere(kartons, rand=1)) - rot)
        gruen = ganz - rot - weiss
        summe = gruen.volume() + weiss.volume() + rot.volume()
        assert abs(summe - ganz.volume()) < 0.5, ('Teile überlappen', summe, ganz.volume())
        teile = [('Baum', Teil(gruen, baum_id, farbe), F_GRUEN),
                 ('Geschenke', Teil(weiss), F_WEISS),
                 ('Schleifen', Teil(rot), F_ROT)]
        name += '_geschenke'
        titel += ' – mit Geschenken'

    assert len(duschkopf.decompose()) == 1 and duschkopf.status() == mf.Error.NoError, 'Duschkopf nicht einteilig'

    # um den Ursprung zentrieren (wie im Original), Unterseite bleibt bei z = -10.625
    lo = np.min([t.v.min(axis=0) for _, t, _ in teile], axis=0)
    hi = np.max([t.v.max(axis=0) for _, t, _ in teile], axis=0)
    versatz = np.array([-(lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, 0])
    for tn, t, _ in teile:
        t.v += versatz
        t.trimesh().export(os.path.join(ziel, f'{name}.stl' if len(teile) == 1 else f'{name}_{tn.lower()}.stl'))

    schreibe_3mf(quelle, os.path.join(ziel, name + '.3mf'), teile, titel)
    print(name, 'Maße', np.round(hi - lo, 2), 'Versatz x', round(versatz[0], 3),
          {tn: (len(t.f), sum(c is not None for c in t.farbe)) for tn, t, _ in teile})


if __name__ == '__main__':
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    main(a[0], a[1], '--geschenke' in sys.argv)

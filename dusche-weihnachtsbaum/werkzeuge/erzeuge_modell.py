#!/usr/bin/env python3
"""Weihnachtsbaum-Duschkopf mit Hansgrohe-Schnellkupplung erzeugen.

Aus dem Original (DuchaArbolBolas.3mf, QuiqueCrimson/MakerWorld):
- der 1/2"-Gewindezapfen wird durch den Stecker aus
  schnellkupplung_stecker.scad ersetzt,
- der eckige Griff (20 x 20) wird durch einen runden ersetzt,
- mit --geschenke kommen weiße Geschenke mit roten Schleifen unter den Baum.

Ausgabe: STL(s) und eine Bambu-Studio-3MF, die Druckeinstellungen und
Metadaten des Originals behält.

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
X_GRIFF_ENDE = -17.0             # hier beginnt im Original die Fase zum Hals
X_HALS = -15.0                   # Hals 13 x 15 bis zum Baumfuß
X_FUSS = -3.5                    # Unterseite des Fußrands (voll, Hohlraum erst ab x = +1,75)
BOHRUNG_D = 10.0                 # Wasserbohrung im Griff

# --- neuer Griff ---
GRIFF_D = 21.25                  # Achse bei z = -0,625: unten 7,2 mm breit abgeflacht, oben z = 10,0
HALS_D = 15.0                    # Fase am Griffende auf diesen Durchmesser

# --- Filamente (Slots der Original-3MF, 1-basiert) ---
F_BAUM, F_ROT, F_WEISS = 6, 5, 14  # 6 = Grün Silk (Original), 5 = Rot Silk+, 14 = PLA Basic -> weiß

NAME = 'weihnachtsbaum_dusche_quick_connect'


def lade_original(xml_bytes):
    """Netz des Originals als Manifold, dazu die Bambu-Bemalung je Dreieck (paint_color)."""
    t = etree.fromstring(xml_bytes)
    v = np.array([[float(e.get(k)) for k in 'xyz'] for e in t.iterfind('.//m:vertex', NS)], np.float32)
    tris = list(t.iterfind('.//m:triangle', NS))
    f = np.array([[int(e.get(k)) for k in ('v1', 'v2', 'v3')] for e in tris], np.uint32)
    farbe = [e.get('paint_color') for e in tris]
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
    g = zylinder_x(X_STECKER, X_GRIFF_ENDE, GRIFF_D) + zylinder_x(X_GRIFF_ENDE - 0.01, X_HALS + 0.3, GRIFF_D, HALS_D)
    g = g ^ quader(-200, 200, z0=Z_BETT, z1=Z_OBEN)          # unten abflachen
    # gegen die Bohrung des Originals leicht verdreht, damit keine Ecken zusammenfallen
    return g - zylinder_x(X_STECKER - 1, X_HALS + 1, BOHRUNG_D, drehung=0.37)


# ---------------- Geschenke ----------------
# 2D-Silhouetten in der (x, y)-Ebene, x zeigt zur Baumspitze ("oben").
# Jedes Geschenk: (Boden x, Deckel x, y von, y bis)
GESCHENKE = [
    (-33.0, -11.0, 9.6, 27.5),     # links groß, liegt am Griff an
    (-24.0, -12.0, 27.0, 39.5),    # links klein, außen
    (-29.0, -10.0, -26.0, -9.6),   # rechts, liegt am Griff an
    (-37.0, -12.5, -39.5, -25.5),  # rechts hoch, außen
]
BAND = 3.2          # Breite der Schleifenbänder
X_ANDOCK = -2.0     # Schleifen reichen 1,5 mm in den vollen Fußrand


def ellipse(cx, cy, a, b, winkel):
    e = affinity.scale(Point(0, 0).buffer(1, 64), a, b)
    return affinity.translate(affinity.rotate(e, winkel, origin=(0, 0)), cx, cy)


def schleife(x_deckel, yc, breite):
    """Schleife auf dem Deckel: zwei Schlaufen und Knoten, oben in den Fußrand."""
    h = X_ANDOCK - x_deckel                     # verfügbare Höhe bis in den Fußrand
    teile = []
    for s in (1, -1):
        a = min(breite * 0.30, 0.62 * h + 2)    # halbe Schlaufenlänge
        b = max(2.6, a * 0.55)
        w = 90 - s * 35                         # Schlaufen schräg nach oben-außen
        cx = x_deckel + 0.55 * h
        cy = yc + s * a * 0.55
        aussen = ellipse(cx, cy, a, b, w)
        innen = ellipse(cx, cy, a - 1.8, b - 1.8, w)
        teile.append(aussen.difference(innen))
    teile.append(Point(x_deckel + 1.6, yc).buffer(2.4, 48))     # Knoten
    teile.append(box(x_deckel - 0.5, yc - BAND / 2, x_deckel + 2.0, yc + BAND / 2))
    s = unary_union(teile)
    # nach oben bis zur Andockkante strecken, falls die Schlaufen zu kurz sind
    if s.bounds[2] < X_ANDOCK:
        s = unary_union([s, box(s.bounds[2] - 1, yc - 1.5, X_ANDOCK, yc + 1.5)])
    return s.intersection(box(x_deckel - 0.5, -100, X_ANDOCK, 100))


def geschenke_2d():
    kartons, baender = [], []
    for x0, x1, y0, y1 in GESCHENKE:
        yc, xc = (y0 + y1) / 2, (x0 + x1) / 2
        kartons.append(box(x0, min(y0, y1), x1, max(y0, y1)))
        baender.append(box(x0, yc - BAND / 2, x1, yc + BAND / 2))           # senkrechtes Band
        baender.append(box(xc - BAND / 2, min(y0, y1), xc + BAND / 2, max(y0, y1)))  # waagrechtes Band
        baender.append(schleife(x1, yc, abs(y1 - y0)))
    return unary_union(kartons), unary_union(baender)


def extrudiere(flaeche):
    k = mf.Manifold()
    for poly in getattr(flaeche, 'geoms', [flaeche]):
        m = trimesh.creation.extrude_polygon(poly, Z_OBEN - Z_BETT)
        m.apply_translation([0, 0, Z_BETT])
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
            elif n == 'Metadata/project_settings.config' and any(f == F_WEISS for _, _, f in teile):
                p = json.loads(d)
                p['filament_colour'][F_WEISS - 1] = '#FFFFFF'
                d = json.dumps(p, indent=4).encode()
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
             '    <metadata key="filament_map_mode" value="Auto For Flush"/>\n'
             '    <metadata key="filament_maps" value="1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"/>\n'
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
    teile = [('Baum', Teil(duschkopf, baum_id, farbe), F_BAUM)]
    name, titel = NAME, 'Xmas tree shower head – Hansgrohe Quick Connect'

    if mit_geschenken:
        kartons, baender = geschenke_2d()
        rot_roh, weiss_roh = extrudiere(baender), extrudiere(kartons)
        rot = rot_roh - duschkopf
        weiss = weiss_roh - duschkopf - rot
        ganz = duschkopf + rot_roh + weiss_roh
        # Geschenke berühren nur Griffmantel (|y| > 9,6) und Fußrand (x < -2) -> weit weg von
        # Wasserbohrung (r < 5) und Hohlraum (x > 1,75)
        b = (rot + weiss).bounding_box()
        assert b[3] <= X_ANDOCK + 1e-6, 'Geschenke ragen zu weit in den Baum'
        assert len(ganz.decompose()) == 1, 'Geschenke nicht mit dem Baum verbunden'
        assert abs(ganz.volume() - (duschkopf.volume() + rot.volume() + weiss.volume())) < 1, 'Teile überlappen'
        assert abs((rot ^ weiss).volume()) < 0.01
        teile += [('Geschenke', Teil(weiss), F_WEISS), ('Schleifen', Teil(rot), F_ROT)]
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

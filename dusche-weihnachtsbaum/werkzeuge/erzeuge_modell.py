#!/usr/bin/env python3
"""Weihnachtsbaum-Duschkopf mit Hansgrohe-Schnellkupplung erzeugen.

Schneidet am Original (DuchaArbolBolas.3mf, QuiqueCrimson/MakerWorld) den
1/2"-Gewindezapfen am Griffende ab und setzt den Stecker aus
schnellkupplung_stecker.scad koaxial an den Griff. Ausgabe: STL und eine
Bambu-Studio-3MF, die Druckeinstellungen und Metadaten des Originals behält.

Aufruf:
  python3 erzeuge_modell.py <original.3mf> <ausgabe_ordner>
Benötigt: openscad, numpy, trimesh, manifold3d, lxml, shapely
"""
import os, re, subprocess, sys, tempfile, zipfile
import numpy as np
import trimesh
import manifold3d as mf
from lxml import etree

HIER = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HIER, '..', 'schnellkupplung_stecker.scad')
NS = {'m': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'}
OBJ = '3D/Objects/object_1.model'

# gemessen am Original (Mesh-Koordinaten)
ACHSE_Y, ACHSE_Z = 0.0, -0.625   # Griffachse = Mitte des Griffs (20 x 20)
X_SCHNITT = -97.5                # Griff hier voll 20 x 20; links davon Gewinde ab x = -115
NAME = 'weihnachtsbaum_dusche_quick_connect'


def lade_mesh(xml_bytes):
    t = etree.fromstring(xml_bytes)
    v = np.array([[float(e.get(k)) for k in 'xyz'] for e in t.iterfind('.//m:vertex', NS)])
    f = np.array([[int(e.get(k)) for k in ('v1', 'v2', 'v3')] for e in t.iterfind('.//m:triangle', NS)])
    return trimesh.Trimesh(v, f, process=True)


def zu_manifold(m):
    return mf.Manifold(mf.Mesh(vert_properties=np.asarray(m.vertices, np.float32),
                               tri_verts=np.asarray(m.faces, np.uint32)))


def von_manifold(k):
    g = k.to_mesh()
    return trimesh.Trimesh(np.asarray(g.vert_properties)[:, :3], np.asarray(g.tri_verts), process=True)


def stecker():
    with tempfile.TemporaryDirectory() as d:
        p = os.path.join(d, 's.stl')
        subprocess.run(['openscad', '-o', p, SCAD], check=True, capture_output=True)
        m = trimesh.load(p)
    # Stecker-Achse +z -> -x, Anlagefläche z = 0 -> x = X_SCHNITT
    r = trimesh.transformations.rotation_matrix(-np.pi / 2, [0, 1, 0])  # +z -> -x
    m.apply_transform(r)
    m.apply_translation([X_SCHNITT, ACHSE_Y, ACHSE_Z])
    return m


def modell_xml(m, vorlage):
    kopf = vorlage.split(b'<mesh>')[0].decode()
    fuss = vorlage.split(b'</mesh>')[1].decode()
    teile = [kopf, '<mesh>\n    <vertices>\n']
    teile += [f'     <vertex x="{x:.9g}" y="{y:.9g}" z="{z:.9g}"/>\n' for x, y, z in m.vertices]
    teile.append('    </vertices>\n    <triangles>\n')
    teile += [f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>\n' for a, b, c in m.faces]
    teile.append('    </triangles>\n   </mesh>')
    teile.append(fuss)
    return ''.join(teile).encode()


def main(quelle, ziel):
    os.makedirs(ziel, exist_ok=True)
    z = zipfile.ZipFile(quelle)
    vorlage = z.read(OBJ)
    baum = lade_mesh(vorlage)
    lo, hi = baum.bounds

    rest = zu_manifold(baum) ^ mf.Manifold.cube([hi[0] - X_SCHNITT + 1, 200, 200]).translate([X_SCHNITT, -100, -100])
    neu = von_manifold(rest + zu_manifold(stecker()))
    assert neu.is_watertight and neu.body_count == 1, 'Ergebnis nicht geschlossen/einteilig'

    # wieder um den Ursprung zentrieren (wie im Original), Unterseite bleibt bei z = -10.625
    b = neu.bounds
    neu.apply_translation([-(b[0][0] + b[1][0]) / 2, -(b[0][1] + b[1][1]) / 2, 0])
    neu.export(os.path.join(ziel, NAME + '.stl'))

    aus = os.path.join(ziel, NAME + '.3mf')
    with zipfile.ZipFile(aus, 'w', zipfile.ZIP_DEFLATED) as o:
        for info in z.infolist():
            n = info.filename
            if n.startswith('Auxiliaries/') or n.startswith('Metadata/plate') or n.startswith('Metadata/top') or n.startswith('Metadata/pick'):
                continue  # Fotos/Vorschauen des Originals passen nicht mehr
            d = z.read(n)
            if n == OBJ:
                d = modell_xml(neu, d)
            elif n == 'Metadata/model_settings.config':
                s = d.decode()
                s = s.replace('DuchaArbolBolas.stl', NAME + '.stl')
                s = re.sub(r'face_count="\d+"', f'face_count="{len(neu.faces)}"', s)
                s = re.sub(r'\s*<metadata key="thumbnail[^>]*/>|\s*<metadata key="(top|pick)_file"[^>]*/>', '', s)
                d = s.encode()
            elif n == '3D/3dmodel.model':
                s = d.decode()
                s = s.replace('<metadata name="Title">Xmas tree shower head</metadata>',
                              '<metadata name="Title">Xmas tree shower head – Hansgrohe Quick Connect</metadata>')
                s = re.sub(r'\s*<metadata name="Thumbnail_(Middle|Small)">[^<]*</metadata>', '', s)
                d = s.encode()
            o.writestr(info, d)
    print('Dreiecke', len(neu.faces), 'Volumen', round(neu.volume), 'Maße', np.round(neu.extents, 2))
    print('geschrieben:', aus)


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])

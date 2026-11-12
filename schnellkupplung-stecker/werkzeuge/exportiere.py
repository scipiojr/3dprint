#!/usr/bin/env python3
"""
Erzeugt aus schnellkupplung_stecker.scad die Druckdateien (STL und 3MF im Bambu/Orca-Format,
öffnet Anycubic Slicer Next) für das Einzelteil in beiden Druckrichtungen.

  python3 werkzeuge/exportiere.py [ausgabe_ordner]     (Standard: ../druck)

Benötigt: openscad, trimesh, numpy, lxml
  stehend: runde Bohrung, breiter Körper auf dem Bett, Mündung oben
  liegend: Tropfenbohrung, Spitze oben (+x), Mündung nach -x
"""
import os, subprocess, sys, tempfile, zipfile
import numpy as np, trimesh
from lxml import etree

HIER = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HIER, '..', 'schnellkupplung_stecker.scad')


def rendere(modus):
    with tempfile.TemporaryDirectory() as d:
        p = os.path.join(d, 'a.stl')
        subprocess.run(['openscad', '-o', p, '-D', f'modus="{modus}"', SCAD], check=True, capture_output=True)
        m = trimesh.load(p)
    return m


def aufs_bett(m):
    b = m.bounds
    m.apply_translation([-(b[0][0] + b[1][0]) / 2, -(b[0][1] + b[1][1]) / 2, -b[0][2]])
    m.merge_vertices()
    assert m.is_watertight, 'Netz nicht geschlossen'
    return m


def schreibe_3mf(m, pfad, name):
    ct = ('<?xml version="1.0" encoding="UTF-8"?>\n<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
          '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
          '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
          '<Default Extension="config" ContentType="text/xml"/></Types>')
    rels = ('<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
    v = ''.join(f'     <vertex x="{x:.6f}" y="{y:.6f}" z="{z:.6f}"/>\n' for x, y, z in m.vertices)
    t = ''.join(f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>\n' for a, b, c in m.faces)
    model = ('<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" '
             'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
             'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021">\n'
             ' <metadata name="Application">BambuStudio-02.00.00.00</metadata>\n'
             ' <metadata name="BambuStudio:3mfVersion">1</metadata>\n'
             ' <metadata name="Title">Stecker Schnellkupplung</metadata>\n <resources>\n'
             '  <object id="1" type="model">\n   <mesh>\n    <vertices>\n' + v + '    </vertices>\n    <triangles>\n' + t +
             '    </triangles>\n   </mesh>\n  </object>\n </resources>\n <build>\n'
             '  <item objectid="1" transform="1 0 0 0 1 0 0 0 1 128 128 0" printable="1"/>\n </build>\n</model>\n')
    ms = ('<?xml version="1.0" encoding="UTF-8"?>\n<config>\n  <object id="1">\n'
          f'    <metadata key="name" value="{name}"/>\n    <metadata key="extruder" value="1"/>\n'
          '    <part id="1" subtype="normal_part">\n      <metadata key="name" value="stecker"/>\n'
          '      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>\n'
          '      <metadata key="extruder" value="1"/>\n    </part>\n  </object>\n</config>\n')
    with zipfile.ZipFile(pfad, 'w', zipfile.ZIP_DEFLATED) as z:
        for n, d in [('[Content_Types].xml', ct), ('_rels/.rels', rels), ('3D/3dmodel.model', model),
                     ('Metadata/model_settings.config', ms)]:
            etree.fromstring(d.encode())   # XML-Syntax prüfen
            z.writestr(n, d)


def main(aus):
    os.makedirs(aus, exist_ok=True)
    # stehend: Anlagefläche/Körper unten (Achse schon +z), runde Bohrung
    stehend = aufs_bett(rendere('einzel_rund'))
    # liegend: Achse -> x, Mündung nach -x (+z -> -x), Tropfenspitze (+x) wird oben (+z)
    liegend = rendere('einzel')
    liegend.apply_transform(trimesh.transformations.rotation_matrix(-np.pi / 2, [0, 1, 0]))
    liegend = aufs_bett(liegend)
    for name, m in [('stecker_stehend', stehend), ('stecker_liegend', liegend)]:
        m.export(os.path.join(aus, name + '.stl'))
        schreibe_3mf(m, os.path.join(aus, name + '.3mf'), name)
        print(name, np.round(m.extents, 2), 'geschlossen', m.is_watertight)


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(HIER, '..', 'druck'))

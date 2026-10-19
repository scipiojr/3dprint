#!/usr/bin/env python3
"""Baut korb.3mf (Bambu-Studio-/OrcaSlicer-Projekt) aus den druckfertigen STL-Dateien.

Aufruf: korb_3mf.py <plattform.stl> <buegel.stl> <seitenwand.stl> <aus.3mf> [titel]

Fünf Platten wie im früheren Korb Version 2 (Git-Historie): Plattform, Bügel Langseite A/B, Seitenwand A/B.
Einstellungen je Objekt: Plattform 4 Wände / 25 % Gyroid / Brim 5 mm,
Bügel 3 Wände / 100 %, Seitenwand 4 Wände / 100 % (steif!), oben/unten 5 Lagen, keine Stützen.
Die STL-Dateien sind schon druckfertig orientiert (aus der SCAD-Datei exportiert).
"""
import sys
import zipfile
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from stl_pruefung import lade  # noqa: E402

KOPF = ('<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
        'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
        'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" requiredextensions="p">')
RASTER = [(125.0, 125.0), (439.4, 125.0), (753.8, 125.0), (125.0, -203.8), (439.4, -203.8)]  # Plattenmitten wie V2


def mesh(pfad):
    t = lade(pfad)
    v = np.round(t.reshape(-1, 3), 4)
    u, inv = np.unique(v, axis=0, return_inverse=True)
    tri = inv.reshape(-1, 3)
    # entartete Dreiecke entfernen
    tri = tri[(tri[:, 0] != tri[:, 1]) & (tri[:, 1] != tri[:, 2]) & (tri[:, 0] != tri[:, 2])]
    lo, hi = u.min(0), u.max(0)
    mitte = (lo + hi) / 2
    return u - mitte, tri, hi - lo


def objekt_xml(oid, v, tri):
    zeilen = [KOPF, '<metadata name="BambuStudio:3mfVersion">1</metadata><resources>',
              f'<object id="{oid}" p:UUID="{oid:08d}-81cb-4c03-9d28-80fed5dfa1dc" type="model"><mesh><vertices>']
    zeilen += [f'<vertex x="{a:.5f}" y="{b:.5f}" z="{c:.5f}"/>' for a, b, c in v]
    zeilen.append('</vertices><triangles>')
    zeilen += [f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in tri]
    zeilen.append('</triangles></mesh></object></resources><build/></model>')
    return ''.join(zeilen)


def einstellungen(name, waende, fuellung, muster, brim):
    s = [f'    <metadata key="name" value="{name}"/>', '    <metadata key="extruder" value="1"/>',
         f'    <metadata key="wall_loops" value="{waende}"/>',
         f'    <metadata key="sparse_infill_density" value="{fuellung}"/>',
         f'    <metadata key="sparse_infill_pattern" value="{muster}"/>',
         '    <metadata key="top_shell_layers" value="5"/>', '    <metadata key="bottom_shell_layers" value="5"/>',
         '    <metadata key="enable_support" value="0"/>']
    s += ['    <metadata key="brim_type" value="outer_only"/>', f'    <metadata key="brim_width" value="{brim}"/>'] if brim else \
        ['    <metadata key="brim_type" value="no_brim"/>']
    return '\n'.join(s)


def main(plattform, buegel, wand, aus, titel='Biomuell-Korb v3 (Seitenwaende mit Steckzapfen)'):
    teile = [  # Name, STL, Wände, Füllung, Muster, Brim
        ('Plattform', plattform, 4, '25%', 'gyroid', 5),
        ('Buegel Langseite A', buegel, 3, '100%', 'zig-zag', 0),
        ('Buegel Langseite B', buegel, 3, '100%', 'zig-zag', 0),
        ('Seitenwand A', wand, 4, '100%', 'zig-zag', 0),
        ('Seitenwand B', wand, 4, '100%', 'zig-zag', 0),
    ]
    geladen = {}
    model_res, build, cfg_obj, cfg_plate, rels, dateien = [], [], [], [], [], {}
    for i, (name, stl, w, f, m, brim) in enumerate(teile, start=1):
        if stl not in geladen:
            geladen[stl] = mesh(stl)
        v, tri, maße = geladen[stl]
        dateien[f'3D/Objects/teil_{i}.model'] = objekt_xml(i, v, tri)
        oid = 19 + i
        model_res.append(
            f'<object id="{oid}" p:UUID="{oid:08d}-61cb-4c03-9d28-80fed5dfa1dc" type="model"><components>'
            f'<component p:path="/3D/Objects/teil_{i}.model" objectid="{i}" '
            f'p:UUID="{i:04d}0000-b206-40ff-9872-83e8017abed1" transform="1 0 0 0 1 0 0 0 1 0 0 0"/></components></object>')
        x, y = RASTER[i - 1]
        build.append(f'<item objectid="{oid}" p:UUID="{oid:08d}-b1ec-4553-aec9-835e5b724bb4" '
                     f'transform="1 0 0 0 1 0 0 0 1 {x:.3f} {y:.3f} {maße[2] / 2:.4f}" printable="1"/>')
        rels.append(f'<Relationship Target="/3D/Objects/teil_{i}.model" Id="rel-{i}" '
                    'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>')
        cfg_obj.append(f'  <object id="{oid}">\n{einstellungen(name, w, f, m, brim)}\n'
                       f'    <part id="{i}" subtype="normal_part">\n      <metadata key="name" value="{name}"/>\n'
                       '      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>\n    </part>\n  </object>')
        cfg_plate.append(f'  <plate>\n    <metadata key="plater_id" value="{i}"/>\n    <metadata key="plater_name" value="{name}"/>\n'
                         '    <metadata key="locked" value="false"/>\n    <model_instance>\n'
                         f'      <metadata key="object_id" value="{oid}"/>\n      <metadata key="instance_id" value="0"/>\n'
                         f'      <metadata key="identify_id" value="{200 + i - 1}"/>\n    </model_instance>\n  </plate>')
    dateien['3D/3dmodel.model'] = (KOPF + '<metadata name="Application">BambuStudio-2.0.0.3</metadata>'
                                   '<metadata name="BambuStudio:3mfVersion">1</metadata>'
                                   f'<metadata name="Title">{titel}</metadata><resources>' + ''.join(model_res)
                                   + '</resources><build>' + ''.join(build) + '</build></model>')
    dateien['3D/_rels/3dmodel.model.rels'] = ('<?xml version="1.0" encoding="UTF-8"?>\n<Relationships '
                                              'xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + ''.join(rels) + '</Relationships>')
    dateien['_rels/.rels'] = ('<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                              '<Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
    dateien['[Content_Types].xml'] = ('<?xml version="1.0" encoding="UTF-8"?>\n<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
                                      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
                                      '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
    dateien['Metadata/model_settings.config'] = ('<?xml version="1.0" encoding="UTF-8"?>\n<config>\n' + '\n'.join(cfg_obj) + '\n'
                                                 + '\n'.join(cfg_plate) + '\n</config>\n')
    with zipfile.ZipFile(aus, 'w', zipfile.ZIP_DEFLATED) as z:
        for n in ['[Content_Types].xml', '_rels/.rels', '3D/3dmodel.model', '3D/_rels/3dmodel.model.rels'] + \
                 [k for k in dateien if k.startswith('3D/Objects')] + ['Metadata/model_settings.config']:
            z.writestr(n, dateien[n])
    print('geschrieben:', aus)


if __name__ == '__main__':
    if len(sys.argv) < 5:
        print(__doc__)
        sys.exit(1)
    main(*sys.argv[1:6])

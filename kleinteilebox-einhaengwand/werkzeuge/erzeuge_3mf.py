#!/usr/bin/env python3
"""Baut die 3MF (Bambu-Studio-/OrcaSlicer-Format, öffnet Anycubic Slicer Next) aus den STL-Dateien.

Aufruf: erzeuge_3mf.py <box.stl> <tragzone_modifier.stl> <stuetzbereich.stl> <aus.3mf> [titel]

EIN Objekt mit drei Bauteilen (bleiben beim Verschieben/Anordnen zusammen):
  1. Box           normal_part       3 Wände, 5 % Gyroid, oben/unten 4 Lagen, 0,2 mm
  2. Tragzone      modifier_part     6 Wände, 100 % Füllung im Z-Bereich des Tragrahmens (Haken + Rand)
  3. Stützbereich  support_enforcer  Bereich unter der Hakenlippe: nur dort soll der Slicer Stützen bauen
Stützen: Objekt-Einstellung "normal(manual)" (nur aus Enforcern), nur auf dem Druckbett.
Die Einstellungen stehen als Objekt-/Bauteil-Metadaten in Metadata/model_settings.config. Temperatur, Lüfter
und Geschwindigkeiten kommen aus dem Filament-/Druckerprofil des Slicers (nicht in der 3MF).
Plattenmitte (125, 125) = Mitte des 250 x 250 mm Betts (Anycubic Kobra S1; passt auch auf kleinere Betten ab 220 mm).
Die STL-Dateien sind schon druckfertig orientiert (Box steht aufrecht, Haken oben).
"""
import sys
import zipfile
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from stl_werkzeug import indiziert, lade  # noqa: E402

PLATTE_MITTE = (125.0, 125.0)

KOPF = ('<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
        'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
        'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" requiredextensions="p">')

OBJEKT = {  # gilt für das ganze Objekt (Box); Bauteile können überschreiben
    'layer_height': '0.2', 'wall_loops': '3', 'sparse_infill_density': '5%', 'sparse_infill_pattern': 'gyroid',
    'top_shell_layers': '4', 'bottom_shell_layers': '4', 'brim_type': 'no_brim',
    'enable_support': '1', 'support_type': 'normal(manual)', 'support_on_build_plate_only': '1',
}
TEILE = [  # Name, Subtyp, Überschreibungen
    ('Box', 'normal_part', {}),
    ('Tragzone Haken und Rahmen (massiv)', 'modifier_part',
     {'wall_loops': '6', 'sparse_infill_density': '100%', 'sparse_infill_pattern': 'zig-zag'}),
    ('Stuetzbereich Hakenlippe', 'support_enforcer', {}),
]


def meta(k, v, einzug=4):
    return f'{" " * einzug}<metadata key="{k}" value="{v}"/>'


def mesh_xml(oid, v, t):
    z = [f'  <object id="{oid}" p:UUID="{oid:08d}-81cb-4c03-9d28-80fed5dfa1dc" type="model">\n   <mesh>\n    <vertices>\n']
    z += [f'     <vertex x="{a:.5f}" y="{b:.5f}" z="{c:.5f}"/>\n' for a, b, c in v]
    z.append('    </vertices>\n    <triangles>\n')
    z += [f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>\n' for a, b, c in t]
    z.append('    </triangles>\n   </mesh>\n  </object>\n')
    return ''.join(z)


def main(box, modifier, stuetz, aus, titel='Kleinteilebox Einhaengwand'):
    netze = [indiziert(lade(p)) for p in (box, modifier, stuetz)]
    # Mitte und Höhe aus der Box (Modifier und Stützbereich ragen leicht über, zählen nicht)
    lo, hi = netze[0][0].min(0), netze[0][0].max(0)
    mitte = (lo + hi) / 2
    hoehe = hi[2] - lo[2]
    netze = [(v - mitte, t) for v, t in netze]
    n_obj = len(netze)
    haupt = n_obj + 1

    objekte = ''.join(mesh_xml(i + 1, v, t) for i, (v, t) in enumerate(netze))
    datei_objekte = KOPF + '\n <metadata name="BambuStudio:3mfVersion">1</metadata>\n <resources>\n' + objekte + ' </resources>\n <build/>\n</model>\n'

    komp = ''.join(f'\n    <component p:path="/3D/Objects/kleinteilebox.model" objectid="{i + 1}" '
                   f'p:UUID="{i + 1:04d}0000-b206-40ff-9872-83e8017abed1" transform="1 0 0 0 1 0 0 0 1 0 0 0"/>'
                   for i in range(n_obj))
    haupt_xml = (KOPF + '\n <metadata name="Application">BambuStudio-2.0.0.3</metadata>\n'
                 ' <metadata name="BambuStudio:3mfVersion">1</metadata>\n'
                 f' <metadata name="Title">{titel}</metadata>\n <resources>\n'
                 f'  <object id="{haupt}" p:UUID="{haupt:08d}-61cb-4c03-9d28-80fed5dfa1dc" type="model"><components>{komp}\n   </components></object>\n'
                 f' </resources>\n <build>\n  <item objectid="{haupt}" p:UUID="{haupt:08d}-b1ec-4553-aec9-835e5b724bb4" '
                 f'transform="1 0 0 0 1 0 0 0 1 {PLATTE_MITTE[0]:.3f} {PLATTE_MITTE[1]:.3f} {hoehe / 2:.4f}" printable="1"/>\n </build>\n</model>\n')

    cfg = ['<?xml version="1.0" encoding="UTF-8"?>\n<config>\n', f'  <object id="{haupt}">\n',
           meta('name', Path(aus).stem, 4) + '\n', meta('extruder', '1', 4) + '\n']
    cfg += [meta(k, v, 4) + '\n' for k, v in OBJEKT.items()]
    cfg.append(f'    <metadata face_count="{sum(len(t) for _, t in netze)}"/>\n')
    for i, ((name, art, ueber), (v, t)) in enumerate(zip(TEILE, netze), start=1):
        cfg.append(f'    <part id="{i}" subtype="{art}">\n' + meta('name', name, 6) + '\n'
                   + meta('matrix', '1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1', 6) + '\n' + meta('extruder', '1', 6) + '\n')
        cfg += [meta(k, w, 6) + '\n' for k, w in ueber.items()]
        cfg.append(f'      <mesh_stat face_count="{len(t)}" edges_fixed="0" degenerate_facets="0" '
                   'facets_removed="0" facets_reversed="0" backwards_edges="0"/>\n    </part>\n')
    cfg.append('  </object>\n  <plate>\n    <metadata key="plater_id" value="1"/>\n    <metadata key="plater_name" value=""/>\n'
               '    <metadata key="locked" value="false"/>\n    <model_instance>\n'
               f'      <metadata key="object_id" value="{haupt}"/>\n      <metadata key="instance_id" value="0"/>\n'
               '      <metadata key="identify_id" value="368"/>\n    </model_instance>\n  </plate>\n</config>\n')

    dateien = {
        '[Content_Types].xml': '<?xml version="1.0" encoding="UTF-8"?>\n<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
                               '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
                               '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>',
        '_rels/.rels': '<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                       '<Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>',
        '3D/3dmodel.model': haupt_xml,
        '3D/_rels/3dmodel.model.rels': '<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                                       '<Relationship Target="/3D/Objects/kleinteilebox.model" Id="rel-1" '
                                       'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>',
        '3D/Objects/kleinteilebox.model': datei_objekte,
        'Metadata/model_settings.config': ''.join(cfg),
    }
    with zipfile.ZipFile(aus, 'w', zipfile.ZIP_DEFLATED) as z:
        for n, d in dateien.items():  # fester Zeitstempel: gleicher Inhalt = gleiche Datei (keine Git-Diffs)
            zi = zipfile.ZipInfo(n, date_time=(1980, 1, 1, 0, 0, 0))
            zi.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(zi, d)
    print(f'geschrieben: {aus}  (Höhe {hoehe:.1f} mm, Teile: ' + ', '.join(f'{len(t)} Dreiecke' for _, t in netze) + ')')


if __name__ == '__main__':
    if len(sys.argv) < 5:
        print(__doc__)
        sys.exit(1)
    main(*sys.argv[1:6])

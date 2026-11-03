#!/usr/bin/env python3
"""Packt alle Teile des Filterkastens mit empfohlenen Druckeinstellungen in eine 3MF (PrusaSlicer-Projektformat,
liest auch OrcaSlicer/Bambu Studio/Cura als Geometrie; die Einstellungen werden von PrusaSlicer uebernommen).
Aufruf (aus abluft/):  python3 -I werkzeuge/export_filterkasten_3mf.py [ausgabe.3mf]
Voraussetzung: STL aus werkzeuge/export_filterkasten.sh (Ordner filterkasten/) und dichtung_ventilator_muffe_tpu.stl."""
import sys, zipfile
from pathlib import Path
import numpy as np, trimesh
from xml.sax.saxutils import escape

O = Path(__file__).resolve().parent.parent
out = Path(sys.argv[1]) if len(sys.argv) > 1 else O / "filterkasten" / "filterkasten_alle.3mf"
# (Datei, Name im Slicer, Stueckzahl, Hinweis)
TEILE = [
    ("filterkasten/filterkasten_rahmen.stl", "1 Rahmen", "PETG"),
    ("filterkasten/filterkasten_einlass_stutzen.stl", "2 Einlass Stutzen d100", "PETG"),
    ("filterkasten/filterkasten_auslass_ventilator.stl", "3 Auslass Ventilator-Muffe", "PETG"),
    ("filterkasten/filterkasten_deckel.stl", "4 Deckel", "PETG"),
    ("filterkasten/filterkasten_kassette.stl", "5 Kassette (1 Lage, mit Frontgitter)", "PETG"),
    ("filterkasten/filterkasten_kassette_front.stl", "5b Frontgitter der Kassette (einrasten)", "PETG"),
    ("filterkasten/filterkasten_fuesse.stl", "6 Fuesse 4x (optional, unterkleben)", "PETG"),
    ("filterkasten/filterkasten_lehre.stl", "7 Schneidlehre", "PETG"),
    ("filterkasten/filterkasten_lehre_klemmleiste.stl", "8 Klemmleiste", "PETG"),
    ("dichtung_ventilator_muffe_tpu.stl", "9 O-Ring Muffe - TPU, separat drucken", "TPU"),
]
ABSTAND = 280          # Teile liegen je eine Druckplatte auseinander (im Slicer auf Platten verteilen)
SPALTEN = 3

CONFIG = """; Empfohlene Einstellungen Filterkasten (PETG, 0,4-mm-Duese, ohne Stuetzen)
; layer_height = 0.28
; first_layer_height = 0.28
; perimeters = 3
; top_solid_layers = 4
; bottom_solid_layers = 4
; fill_density = 15%
; fill_pattern = gyroid
; support_material = 0
; support_material_auto = 0
; brim_width = 0
; skirts = 1
; nozzle_diameter = 0.4
; extrusion_width = 0.45
; perimeter_extrusion_width = 0.45
; external_perimeter_extrusion_width = 0.45
; perimeter_generator = arachne
; thin_walls = 0
; elefant_foot_compensation = 0.2
; seam_position = aligned
; avoid_crossing_perimeters = 0
; filament_type = PETG
; temperature = 240
; first_layer_temperature = 240
; bed_temperature = 80
; first_layer_bed_temperature = 80
; cooling = 1
; min_fan_speed = 30
; max_fan_speed = 50
; bridge_fan_speed = 100
; fan_below_layer_time = 20
; slowdown_below_layer_time = 8
; min_print_speed = 15
; perimeter_speed = 45
; external_perimeter_speed = 30
; small_perimeter_speed = 30
; infill_speed = 70
; solid_infill_speed = 50
; bridge_speed = 25
; gap_fill_speed = 40
; travel_speed = 150
"""
README = """Filterkasten - empfohlene Druckeinstellungen (PETG, 0,4-mm-Duese)
Alle Teile in der gezeigten Pose drucken (nicht drehen), KEINE Stuetzen, kein Brim.
 Schicht 0,28 mm (0,24 mm fuer sauberere Trichter), 3 Umrisse (Arachne), 4 Deckel-/Bodenschichten,
 Fuellung 15 % Gyroid, Duese 240 Grad, Bett 80 Grad, Luefter 30-50 % (Bruecken 100 %).
 Teile: 1 Rahmen, 2 Einlass (Stutzen), 3 Auslass (Ventilator-Muffe), 4 Deckel, 5 Kassette,
 6 Schneidlehre + 7 Klemmleiste (fuer das Metallgitter), 8 O-Ring Muffe aus TPU (separater Druck, anderes Filament).
 Mit 0,6-mm-Duese, 0,4 mm Schicht, 2 Umrisse, 10 % Fuellung ca. halbe Druckzeit (Einlass Magnetvariante besser mit 0,4).
 Montage: Einlass und Auslass in den Rahmen einrasten (Rastwulst/-nut, 0,55 mm Eingriff), dann Fuge verkleben bzw. abdichten;
 Scharnierstift 4 mm; zwei Kniehebelverschluesse GH-4001 (Kernloecher 4,2 mm, Blechloecher 6,4 mm, 5-mm-Schrauben).
"""

objs = []
for i, (datei, name, mat) in enumerate(TEILE):
    m = trimesh.load(O / datei)
    m.apply_translation(-m.bounds[0] * np.array([1, 1, 0]))     # Ecke nach (0,0), Unterseite z = 0
    col, row = i % SPALTEN, i // SPALTEN
    objs.append((name, m, (col * ABSTAND, row * ABSTAND)))

model = ['<?xml version="1.0" encoding="UTF-8"?>',
         '<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" xmlns:slic3rpe="http://schemas.slic3r.org/3mf/2017/06">',
         ' <metadata name="Application">Claude / abluft_filterkasten.scad</metadata>', ' <resources>']
cfg = ['<?xml version="1.0" encoding="UTF-8"?>', '<config>']
build = []
for i, (name, m, (ox, oy)) in enumerate(objs, 1):
    model.append(f'  <object id="{i}" type="model">\n   <mesh>\n    <vertices>')
    model += [f'     <vertex x="{x:.4f}" y="{y:.4f}" z="{z:.4f}"/>' for x, y, z in m.vertices]
    model.append('    </vertices>\n    <triangles>')
    model += [f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in m.faces]
    model.append('    </triangles>\n   </mesh>\n  </object>')
    build.append(f'  <item objectid="{i}" transform="1 0 0 0 1 0 0 0 1 {ox:.3f} {oy:.3f} 0" printable="1"/>')
    cfg.append(f' <object id="{i}" instances_count="1">\n  <metadata type="object" key="name" value="{escape(name)}"/>')
    cfg.append(f'  <volume firstid="0" lastid="{len(m.faces) - 1}">\n   <metadata type="volume" key="name" value="{escape(name)}"/>')
    cfg.append('   <metadata type="volume" key="volume_type" value="ModelPart"/>\n   <metadata type="volume" key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>\n  </volume>\n </object>')
model += [' </resources>', ' <build>'] + build + [' </build>', '</model>']
cfg.append('</config>')

ct = ('<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
      '<Default Extension="config" ContentType="text/xml"/><Default Extension="txt" ContentType="text/plain"/></Types>')
rels = ('<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", ct)
    z.writestr("_rels/.rels", rels)
    z.writestr("3D/3dmodel.model", "\n".join(model))
    z.writestr("Metadata/Slic3r_PE_model.config", "\n".join(cfg))
    z.writestr("Metadata/Slic3r_PE.config", CONFIG)
    z.writestr("Metadata/README_Druckeinstellungen.txt", README)
print(f"ok: {out} ({len(objs)} Objekte, {out.stat().st_size/1e6:.1f} MB)")

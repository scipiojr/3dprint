#!/usr/bin/env python3
"""Packt die Teile des DN110-Durchlasses durch die Arbeitsplatte (abluft_dn110_arbeitsplatte.scad) mit empfohlenen Druckeinstellungen
in eine 3MF (PrusaSlicer-Projektformat; OrcaSlicer/Bambu Studio/Cura lesen die Geometrie). Stuetzen sind je Objekt gesetzt (Teil 1, 2, 5, 6).
Aufruf (aus abluft/):  python3 -I werkzeuge/export_dn110_arbeitsplatte_3mf.py [ausgabe.3mf]
Voraussetzung: STL aus werkzeuge/export_dn110_arbeitsplatte.sh (Ordner dn110_arbeitsplatte/) und dichtung_100_anschluss_tpu.stl."""
import sys, zipfile
from pathlib import Path
import numpy as np, trimesh
from xml.sax.saxutils import escape

O = Path(__file__).resolve().parent.parent
out = Path(sys.argv[1]) if len(sys.argv) > 1 else O / "dn110_arbeitsplatte_buendig" / "dn110_buendig_alle.3mf"
SUPPORT = {"support_material": "1", "support_material_auto": "1", "support_material_threshold": "50", "support_material_buildplate_only": "0",
           "support_material_contact_distance": "0.2", "support_material_spacing": "2.5", "support_material_pattern": "rectilinear", "support_material_interface_layers": "2"}
# (Datei, Name im Slicer, Objekt-Einstellungen)
TEILE = [
    ("dn110_arbeitsplatte/dn110_arbeitsplatte_teil_1.stl", "1 Rohr 1 (Stumpf + Linksbogen), liegend, mit Stuetzen", SUPPORT),
    ("dn110_arbeitsplatte_buendig/dn110_buendig_rohr_2.stl", "2 Rohr 2 (Bogen nach oben + Gewinde, 5 mm laenger), mit Stuetzen", SUPPORT),
    ("dn110_arbeitsplatte_buendig/dn110_buendig_ring.stl", "3 Ring d153 mit langem Hals (Magnetflaeche unten), ohne Stuetzen", {}),
    ("dn110_arbeitsplatte_buendig/dn110_buendig_halteflansch.stl", "4 Halteflansch (flach an die Plattenunterseite schrauben)", {}),
    ("dn110_arbeitsplatte_buendig/dn110_buendig_deckel.stl", "5 Deckel d168 mit Klapplasche (Filmscharnier), 2 Magnete", {"perimeters": "3", "top_solid_layers": "4", "bottom_solid_layers": "4", "fill_density": "40%"}),
    ("dn110_arbeitsplatte/dn110_winkeladapter.stl", "6 Winkeladapter (Magnetflansch unten, Stutzen 60 Grad), mit Stuetzen", SUPPORT),
    ("dn110_arbeitsplatte/dn110_winkeladapter_rohr.stl", "7 Winkeladapter-Variante: Rohrstumpf d109 fuer DN110-Muffe, mit Stuetzen (Alternative zu 6)", SUPPORT),
    ("dichtung_100_anschluss_tpu.stl", "8 Dichtring 110er Flansch (U-Profil) - TPU, separat drucken", {"filament_type": "TPU", "perimeters": "2", "top_solid_layers": "3", "bottom_solid_layers": "3", "fill_density": "100%", "temperature": "225", "bed_temperature": "50", "first_layer_bed_temperature": "50", "min_fan_speed": "100", "max_fan_speed": "100", "perimeter_speed": "20", "external_perimeter_speed": "20", "infill_speed": "20", "solid_infill_speed": "20", "bridge_speed": "15", "travel_speed": "150"}),
]
ABSTAND = 280
SPALTEN = 3

CONFIG = """; Empfohlene Einstellungen Arbeitsplatten-Durchlass (PETG, 0,4-mm-Duese; Stuetzen nur an Teil 1, 2, 6, 7 je Objekt)
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
README = """Arbeitsplatten-Durchlass DN110, buendige Ausfuehrung (Version 2) - empfohlene Druckeinstellungen (PETG, 0,4-mm-Duese)
Teile in der gezeigten Pose drucken (nicht drehen). Stuetzen NUR an Teil 1, 2, 6 und 7 (im Projekt je Objekt gesetzt: automatisch, Schwelle 50 Grad, Z-Abstand 0,2 mm).
 Teil 3 (Ring), 4 (Halteflansch), 5 (Deckel) ohne Stuetzen. Schicht 0,28 mm (0,24 mm fuer sauberes Gewinde an Teil 2/3/4), 3 Umrisse, 4 Deckel-/Bodenschichten, Fuellung 15 % Gyroid,
 Duese 240 Grad, Bett 80 Grad, Luefter 30-50 % (Bruecken 100 %), Brim 0. Deckel: 3 Umrisse, 40 % Fuellung, langsam (Filmscharnier der Klapplasche nur 0,8 mm: 4 Bodenschichten, nicht ueber den Film fahren lassen).
 Einbau: durchgehendes Loch d155 in der 30-mm-Platte (kein Absatz noetig). Ring von oben ins Loch stecken, von unten den Halteflansch (Teil 4) auf das Aussengewinde des Halses drehen und mit 6 Senkkopfschrauben 4 mm
 an die Plattenunterseite schrauben (Schraubenkreis r 86); Ring drehen, bis die Magnetflaeche buendig mit der Plattenoberseite ist. Rohr 2 (Teil 2) von unten in den Ring schrauben, Rohr 1 und Rohr 2 verkleben.
 Deckel: 2 Magnete 15x3 (120 Grad auseinander, gleiche Polung), in 60-Grad-Schritten drehen bis er anzieht; zum Abnehmen die Lasche (Filmscharnier) hochklappen und ziehen. Liegt der TPU-Dichtring in der Ringnut, passt er in die Nut an der Deckelunterseite.
 Winkeladapter: Teil 6 (Schlauchstutzen) oder Teil 7 (Rohrstumpf fuer DN110-Muffe), Teil 8 TPU-Dichtring (U-Profil, separat, anderes Filament).
 Nicht gedruckt oder erprobt: Gewindeeingriff Halteflansch (nur 5 mm), Filmscharnier, Passung, Dichtheit, Polung, Stuetzbarkeit der Bogenunterseiten.
"""

objs = []
for i, (datei, name, einst) in enumerate(TEILE):
    m = trimesh.load(O / datei)
    m.apply_translation(-m.bounds[0] * np.array([1, 1, 0]))     # Ecke nach (0,0), Unterseite z = 0
    col, row = i % SPALTEN, i // SPALTEN
    objs.append((name, m, (col * ABSTAND, row * ABSTAND), einst))

model = ['<?xml version="1.0" encoding="UTF-8"?>',
         '<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" xmlns:slic3rpe="http://schemas.slic3r.org/3mf/2017/06">',
         ' <metadata name="Application">Claude / abluft_dn110_durchlass_buendig.scad</metadata>', ' <resources>']
cfg = ['<?xml version="1.0" encoding="UTF-8"?>', '<config>']
build = []
for i, (name, m, (ox, oy), einst) in enumerate(objs, 1):
    model.append(f'  <object id="{i}" type="model">\n   <mesh>\n    <vertices>')
    model += [f'     <vertex x="{x:.4f}" y="{y:.4f}" z="{z:.4f}"/>' for x, y, z in m.vertices]
    model.append('    </vertices>\n    <triangles>')
    model += [f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in m.faces]
    model.append('    </triangles>\n   </mesh>\n  </object>')
    build.append(f'  <item objectid="{i}" transform="1 0 0 0 1 0 0 0 1 {ox:.3f} {oy:.3f} 0" printable="1"/>')
    cfg.append(f' <object id="{i}" instances_count="1">\n  <metadata type="object" key="name" value="{escape(name)}"/>')
    for k, v in einst.items(): cfg.append(f'  <metadata type="object" key="{k}" value="{escape(v)}"/>')
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

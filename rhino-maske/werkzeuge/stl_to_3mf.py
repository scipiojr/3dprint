#!/usr/bin/env python3
"""Packt mehrere STL-Teile in EINE 3MF-Datei (mm), je Teil ein Objekt.

Die Teile werden so vorplatziert, dass sie in Anycubic Slicer Next / OrcaSlicer /
Bambu Studio auf je einer eigenen Druckplatte liegen (Plattenraster 3 Spalten,
Abstand = Bettgröße * 1,2). Falls der Slicer sie nicht direkt Platten zuordnet:
"Alle Objekte anordnen" (Taste A) verteilt sie automatisch.

Aufruf:  python3 stl_to_3mf.py ausgabe.3mf teil1.stl teil2.stl ... [--bett 260]
"""
import sys, struct, zipfile, math
import numpy as np


def lese_stl(pfad):
    with open(pfad, "rb") as f:
        daten = f.read()
    n = struct.unpack_from("<I", daten, 80)[0]
    if 84 + n * 50 == len(daten):                       # binär
        rec = np.frombuffer(daten, dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]),
                            count=n, offset=84)
        tri = rec["v"].reshape(-1, 3, 3).astype(np.float64)
    else:                                                # ASCII
        v = [list(map(float, l.split()[1:4])) for l in daten.decode().splitlines()
             if l.strip().startswith("vertex")]
        tri = np.array(v).reshape(-1, 3, 3)
    flach = np.round(tri.reshape(-1, 3), 4)
    verts, idx = np.unique(flach, axis=0, return_inverse=True)
    faces = idx.reshape(-1, 3)
    faces = faces[(faces[:, 0] != faces[:, 1]) & (faces[:, 1] != faces[:, 2]) & (faces[:, 0] != faces[:, 2])]
    return verts, faces


def main():
    args = sys.argv[1:]
    bett = 260.0
    if "--bett" in args:
        i = args.index("--bett")
        bett = float(args[i + 1])
        del args[i:i + 2]
    ziel, stls = args[0], args[1:]
    spalten = math.ceil(math.sqrt(len(stls)))
    objekte, items = [], []
    for k, pfad in enumerate(stls, 1):
        v, f = lese_stl(pfad)
        mn, mx = v.min(0), v.max(0)
        zeile, spalte = divmod(k - 1, spalten)
        ox = spalte * bett * 1.2 + bett / 2 - (mn[0] + mx[0]) / 2
        oy = -zeile * bett * 1.2 + bett / 2 - (mn[1] + mx[1]) / 2
        oz = -mn[2]
        vx = "".join(f'<vertex x="{a:.4f}" y="{b:.4f}" z="{c:.4f}"/>' for a, b, c in v)
        tx = "".join(f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in f)
        name = pfad.rsplit("/", 1)[-1].rsplit(".", 1)[0]
        objekte.append(f'<object id="{k}" name="{name}" type="model"><mesh><vertices>{vx}</vertices>'
                       f'<triangles>{tx}</triangles></mesh></object>')
        items.append(f'<item objectid="{k}" transform="1 0 0 0 1 0 0 0 1 {ox:.3f} {oy:.3f} {oz:.3f}"/>')
        print(f"  {name}: {len(v)} Vertices, {len(f)} Dreiecke, Platte {k}")
    modell = ('<?xml version="1.0" encoding="UTF-8"?>\n'
              '<model unit="millimeter" xml:lang="de-DE" '
              'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
              '<metadata name="Title">Rhino Lattice Mask</metadata>'
              '<metadata name="Designer">rhino_lattice_mask.py</metadata>'
              f'<resources>{"".join(objekte)}</resources><build>{"".join(items)}</build></model>')
    ct = ('<?xml version="1.0" encoding="UTF-8"?>\n'
          '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
          '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
          '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
          '</Types>')
    rels = ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Target="/3D/3dmodel.model" Id="rel0" '
            'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
    with zipfile.ZipFile(ziel, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", ct)
        z.writestr("_rels/.rels", rels)
        z.writestr("3D/3dmodel.model", modell)
    print(f"-> {ziel}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Ueberhang-Auswertung eines STL in Druckpose (Z nach oben, Bett bei Z = 0).
Aufruf: python3 -I werkzeuge/ueberhang.py teil.stl [...]
Ausgabe: Volumen, Masse, Wasserdichtigkeit, geneigte Flaechen (> 45/50/55/60 Grad von der Senkrechten) und waagerechte
Decken (Bruecken). Faustregel PETG: bis ca. 50 Grad stuetzfrei; waagerechte Decken nur bis ca. 10 mm Spannweite."""
import sys
import numpy as np
import trimesh

for f in sys.argv[1:]:
    m = trimesh.load(f)
    n, a, c = m.face_normals, m.area_faces, m.triangles_center
    ob = c[:, 2] > m.bounds[0][2] + 0.05          # Bettflaeche ausnehmen
    geneigt = ob & (n[:, 2] < -0.5) & (n[:, 2] > -0.99)
    print(f"{f.split('/')[-1]}: Masse {m.extents.round(1)} mm, Volumen {m.volume/1000:.1f} cm3, wasserdicht {m.is_watertight}")
    print("  geneigt " + ", ".join(f">{w} Grad: {a[geneigt & (n[:, 2] < -np.sin(np.radians(w)))].sum():.0f} mm2" for w in (45, 50, 55, 60)))
    print(f"  waagerechte Decken (Bruecken): {a[ob & (n[:, 2] < -0.99)].sum():.0f} mm2")

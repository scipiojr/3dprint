#!/usr/bin/env python3
"""Pruefung des Luefterhalters: wasserdicht, Druckraum, Auflagezunge, Lochbild der Luefterkonsole, Abstand der
Mutterntaschen zu den Magnettaschen, Luftraum zur angesetzten Muffe (Flansch 8 mm + Zylinder r 58,4 als Proxy).
Aufruf: python3 -I werkzeuge/pruefung_luefterhalter.py [stl]   (Standardwerte der SCAD: Muster 100, 1 Muffe)"""
import sys, numpy as np, trimesh
stl = sys.argv[1] if len(sys.argv) > 1 else "luefterhalter/luefterhalter.stl"
m = trimesh.load(stl); ok = True
def chk(name, cond, info=""):
    global ok; ok &= bool(cond); print(("OK    " if cond else "FEHLER"), name, info)
chk("wasserdicht", m.is_watertight and m.is_winding_consistent, f"({m.volume/1000:.1f} cm3)")
chk("Druckraum 240 x 240 x 250", all(m.extents <= [240, 240, 250]), str(m.extents.round(1).tolist()))
# Konsolen-Lochbild: Langloecher bei x = +/-33 (54/2 + 12/2), y = Muffenmitte +/- 29.5; Zunge 25 x 2 mm
yc = 70.7
for sx in (-1, 1):
    for sy in (-1, 1):
        x, y = sx * 33, yc + sy * 29.5
        chk(f"Langloch ({x:+.0f}, {y:.1f}) durchgehend", not m.contains([[x, y, z] for z in (0.5, 4, 7.5)]).any())
        # Tasche: leer ueber dem Boden (z = 6,5), Boden bei z = 4,6 massiv (neben dem Langloch, y + 3,3)
        chk(f"Mutterntasche ({x:+.0f}, {y:.1f})", (not m.contains([[x, y + 3.3, 6.5]])[0]) and m.contains([[x, y + 3.3, 4.0]])[0])
chk("Zunge 25 mm hinter der Wand, 2 mm dick, buendig", m.contains([[0, -12, 1]])[0] and not m.contains([[0, -12, 3]])[0] and abs(m.bounds[0][1] + 25) < 0.05)
# Abstand Mutterntasche (Ecke ~ 4,2 + 3 Hub) zur naechsten Magnettasche (r 7,65)
mag = [(66 * np.cos(np.radians(a)), yc + 66 * np.sin(np.radians(a))) for a in range(0, 360, 60)]
nut = [(sx * 33 + dx, yc + sy * 29.5) for sx in (-1, 1) for sy in (-1, 1) for dx in (-3, 3)]
d = min(np.hypot(a - c, b - e) for a, b in nut for c, e in mag) - 7.65 - 4.2
chk("Mutterntaschen frei von den Magnettaschen", d > 3, f"(Wand zu Wand >= {d:.1f} mm)")
# Muffen-Proxy: Flansch (Dicke 8, Radius 76,5 grob als Kreis r 58,4 + 6 Lappen vereinfacht r 58,4) unter der Magnetseite
fl = trimesh.creation.cylinder(radius=58.4, height=8, sections=120); fl.apply_translation([0, yc, 8 + 4])
inter = trimesh.boolean.intersection([m, fl], engine="manifold")
chk("keine Ueberlappung mit angesetzter Muffe (Proxy)", inter.is_empty or inter.volume < 1e-3, f"({0 if inter.is_empty else inter.volume:.3f} mm3)")
sys.exit(0 if ok else 1)

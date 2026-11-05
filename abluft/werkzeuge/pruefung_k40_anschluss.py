"""Prueft den K40-Anschluss mit der montierten Filterkasten-Baugruppe (Lage nach Ausgangsrichtung).
Aufruf (aus abluft/):  python3 -I werkzeuge/pruefung_k40_anschluss.py [box_assembly.stl] [-D name=wert ...]
  box_assembly.stl:  openscad -o /tmp/box_assembly.stl -D 'auswahl="assembly"' abluft_filterkasten.scad
Ausgabe je Einstecktiefe (Muffe): Ueberlappung (mm3), kleinster Abstand des Kastens zur Rueckwand (y), Hoehenlage.
Kastenmasse: Einlass-Spitze bei x_loc = -70, Achse (yc, zc) = (84.9, 80.35); Scharnier bei +y_loc, wird zur Wand gedreht.
"""
import sys, re, subprocess, tempfile, os
import numpy as np, trimesh

args = sys.argv[1:]
box_stl = "/tmp/box_assembly.stl"
if args and not args[0].startswith("-D"):
    box_stl = args.pop(0)
defs = []
while args:
    a = args.pop(0)
    if a == "-D": defs += ["-D", args.pop(0)]
    elif a.startswith("-D"): defs += ["-D", a[2:]]
tmp = tempfile.mkdtemp(); k_stl = os.path.join(tmp, "k.stl")
r = subprocess.run(["openscad", "-o", k_stl, "-D", 'ausgabe="montiert"'] + defs + ["abluft_k40_anschluss.scad"], capture_output=True, text=True)
log = r.stderr
for l in log.splitlines():
    if "WARNUNG" in l or "Bogenwinkel" in l: print(l.strip())
m = re.search(r'ENDE E=\[([^\]]*)\] T=\[([^\]]*)\] U=\[([^\]]*)\] V=\[([^\]]*)\]', log)
E, T, U, V = [np.array([float(x) for x in g.split(",")]) for g in m.groups()]
ende = "magnet" if any("magnet" in d for d in defs) else "muffe"
muffe_l = 20.0
for d in defs:
    if d.startswith("muffe_l="): muffe_l = float(d.split("=")[1])
k = trimesh.load(k_stl); box = trimesh.load(box_stl)
print(f"Anschluss: wasserdicht={k.is_watertight}, Volumen {k.volume/1000:.1f} cm3")
yc, zc = 84.9, 80.35
Rm = np.column_stack([T, np.cross(V, T), V])          # Kasten lokal x -> Stroemung, y -> quer, z -> oben
for ins in ([20, 15, 10] if ende == "muffe" else [0]):
    T4 = np.eye(4); T4[:3, :3] = Rm
    tip = E + T*(muffe_l + 0.07 - ins) if ende == "muffe" else E + T*8.0   # Magnet: Flaechen aufeinander (8 mm hinter E)
    m_ = box.copy(); m_.apply_translation([70.0, -yc, -zc]); m_.apply_transform(T4); m_.apply_translation(tip)
    inter = k.intersection(m_, engine="manifold")
    v = 0.0 if inter.is_empty else inter.volume
    zmin, zmax = m_.bounds[0][2], m_.bounds[1][2]
    print(f"  Einstecktiefe {ins:2d}: Ueberlappung {v:8.1f} mm3 | Kasten y_min {m_.bounds[0][1]:6.1f} (Rueckwand 0) | z {zmin:.0f}..{zmax:.0f} | Konus bei {tip + T*20 if ende=='muffe' else tip + T*28}")

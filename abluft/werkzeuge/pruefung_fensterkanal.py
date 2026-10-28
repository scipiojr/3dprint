#!/usr/bin/env python3
"""Prueft die Teile des Fensterkanals (abluft_fensterkanal.scad) fuer beliebige Parameter.

Aufruf (aus dem Ordner abluft/):
    python3 -I werkzeuge/pruefung_fensterkanal.py [-D name=wert ...]

Fuer jedes Teil: wasserdicht, passt in den Druckraum (fk_bed, beliebige Drehung um z), und in
Einbaulage ("montiert") ueberlappen sich keine zwei Teile (Steckverbindungen mit Spiel).
Pakete: trimesh, numpy, manifold3d.
"""
import itertools, re, subprocess, sys, tempfile
from pathlib import Path
import numpy as np, trimesh, manifold3d as mf

ORDNER = Path(__file__).resolve().parent.parent
extra, a = [], sys.argv[1:]
while a:
    if a[0] != "-D" or len(a) < 2:
        sys.exit("nur -D name=wert erlaubt")
    extra += ["-D", a[1]]; a = a[2:]


def scad(tmp, name, **d):
    out = Path(tmp) / name
    args = ["openscad", "-o", str(out)] + sum((["-D", f"{k}={v}"] for k, v in d.items()), []) + extra \
        + [str(ORDNER / "abluft_fensterkanal.scad")]
    return out, subprocess.run(args, capture_output=True, text=True).stderr


def manifold(m):
    return mf.Manifold(mf.Mesh(vert_properties=np.array(m.vertices, dtype=np.float32),
                               tri_verts=np.array(m.faces, dtype=np.uint32)))


with tempfile.TemporaryDirectory() as tmp:
    _, log = scad(tmp, "i.stl", ausgabe='"info"')
    n = int(re.search(r"Anzahl Teile: (\d+)", log).group(1))
    bed = [float(x) for x in re.search(r"Druckraum \[([^\]]*)\]", log).group(1).split(",")]
    for z in re.findall(r'ECHO: "((?:WARNUNG|FEHLER)[^"]*)"', log):
        print("  ", z)
    fehler, einbau = 0, []
    for k in range(1, n + 1):
        f, _ = scad(tmp, f"t{k}.stl", ausgabe='"teil"', teil_nr=k)
        m = trimesh.load(f)
        e = m.extents
        passt = e[2] <= bed[2] + 1e-6 and min(e[:2]) <= min(bed[:2]) + 1e-6 and max(e[:2]) <= max(bed[:2]) + 1e-6
        print(f"  Teil {k}: wasserdicht={m.is_watertight} Maße={np.round(e, 1).tolist()} passt={passt} Vol={m.volume/1000:.1f} cm3")
        fehler += (not m.is_watertight) + (not passt)
        g, _ = scad(tmp, f"m{k}.stl", ausgabe='"montiert"', teil_nr=k)
        einbau.append(manifold(trimesh.load(g)))
    for i, j in itertools.combinations(range(n), 2):
        v = mf.Manifold.batch_boolean([einbau[i], einbau[j]], mf.OpType.Intersect).volume()
        if v > 0.5:      # Rundungsrauschen an Kontaktflaechen < 0,5 mm3 ist ok
            print(f"  FEHLER: Teile {i+1} und {j+1} ueberlappen: {v:.3f} mm3"); fehler += 1
    print("== Ergebnis:", "ALLES OK" if not fehler else f"{fehler} FEHLER")
    sys.exit(int(fehler > 0))

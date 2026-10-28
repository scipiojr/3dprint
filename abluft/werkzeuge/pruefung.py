#!/usr/bin/env python3
"""Prueft die STL-Dateien des Abluft-Systems (Geometrie, Passung, Gewinde).

Aufruf (aus dem Ordner abluft/):
    python3 -I werkzeuge/pruefung.py [--ref150 Magnetic_Hose_Adapter_150.stl] [--ref110 Anschluss_110mm_Schlauch.stl]

Pruefungen:
  1. alle STL wasserdicht, Abmessungen/Volumen werden angezeigt
  2. Innenscheibe + Halteplatte mit Plexiglas (Platte mit 155-mm-Loch) zusammengesetzt: keine Ueberlappung,
     Gewinde passt (Drehwinkel-Scan, Drehspiel in Grad)
  3. Verjuengung und (falls angegeben) Referenz-Adapter liegen auf Halteplatte bzw. unter Innenscheibe
     ohne Ueberlappung; 110er-Anschluss passt auf den 110er-Flansch der Verjuengung
Die Maße (Dicken, Loch, Steigung) werden aus abluft_system.scad gelesen, die Pruefung folgt also den Parametern.
Pakete: trimesh, numpy, manifold3d (pip install --break-system-packages trimesh numpy manifold3d).
Die Referenzteile stammen von MakerWorld und liegen nicht im Repository.
"""
import argparse, re, sys
from pathlib import Path
import numpy as np
import trimesh
import manifold3d as mf

tf = trimesh.transformations
ORDNER = Path(__file__).resolve().parent.parent
DATEIEN = {
    "innen": "durchfuehrung_innen.stl",
    "aussen": "durchfuehrung_aussen.stl",
    "magnet": "verjuengung_150_110_magnet.stl",
    "stutzen": "verjuengung_150_110_stutzen.stl",
    "rohr": "verjuengung_150_110_rohr.stl",
    "rohr45": "verjuengung_150_110_rohr_45grad.stl",
    "ventilator": "adapter_ventilator_140_110.stl",
    "ofan": "dichtung_ventilator_muffe_tpu.stl",
    "o150p": "dichtung_150_plexiglas_tpu.stl",
    "o150a": "dichtung_150_anschluss_tpu.stl",
    "o110": "dichtung_110_anschluss_tpu.stl",
}


def scad_wert(name):
    text = (ORDNER / "abluft_system.scad").read_text()
    m = re.search(rf"^{name}\s*=\s*([-0-9.]+)\s*;", text, re.M)
    if not m:
        sys.exit(f"Parameter {name} nicht in abluft_system.scad gefunden")
    return float(m.group(1))


def zu_manifold(m):
    return mf.Manifold(mf.Mesh(vert_properties=np.array(m.vertices, dtype=np.float32),
                               tri_verts=np.array(m.faces, dtype=np.uint32)))


def ueberlappung(a, b):
    return mf.Manifold.batch_boolean([a, b], mf.OpType.Intersect).volume()


def bewegt(mesh, *matrizen):
    m = mesh.copy()
    m.apply_transform(tf.concatenate_matrices(*matrizen))
    return m


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ref150", help="Magnetic_Hose_Adapter_150.stl (Referenz-Adapter 150)")
    ap.add_argument("--ref110", help="Anschluss_110mm_Schlauch.stl (Referenz-Anschluss 110)")
    args = ap.parse_args()

    disc_t, nut_t, plate_t = scad_wert("disc_t"), scad_wert("nut_t"), scad_wert("plate_t")
    hole_r, pitch = scad_wert("hole_d") / 2, scad_wert("thread_pitch")
    fehler = 0

    teile = {}
    print("== Teile")
    for k, name in DATEIEN.items():
        p = ORDNER / name
        if not p.exists():
            print(f"  FEHLT {name}"); fehler += 1; continue
        m = trimesh.load(p); teile[k] = m
        ok = m.is_watertight
        fehler += not ok
        print(f"  {'ok ' if ok else 'FEHLER'} {name:38s} wasserdicht={ok}  Maße={np.round(m.extents, 1).tolist()}  Volumen={m.volume/1000:.1f} cm3")

    if not {"innen", "aussen"} <= teile.keys():
        sys.exit("Innen-/Aussenteil fehlen")

    print("== Zusammenbau Innenscheibe + Plexiglas + Halteplatte")
    innen = zu_manifold(teile["innen"])
    plexi = (mf.Manifold.cube([500, 500, plate_t]).translate([-250, -250, disc_t])
             - mf.Manifold.cylinder(plate_t + 2, hole_r, hole_r, 256).translate([0, 0, disc_t - 1]))
    z_oben = disc_t + plate_t + nut_t          # Magnetflaeche der Halteplatte
    umdrehen = tf.rotation_matrix(np.pi, [1, 0, 0])
    ueber = ueberlappung(innen, plexi)
    print(f"  Innenscheibe/Rohr gegen Plexiglas: {ueber:.4f} mm3 {'ok' if ueber < 1e-3 else 'FEHLER'}")
    fehler += ueber >= 1e-3

    frei = []
    for winkel in range(0, 360, 5):
        n = bewegt(teile["aussen"], tf.translation_matrix([0, 0, z_oben]), umdrehen,
                   tf.rotation_matrix(np.radians(winkel), [0, 0, 1]))
        if ueberlappung(innen, zu_manifold(n)) < 1e-3:
            frei.append(winkel)
    if not frei:
        print("  Gewinde: KEIN freier Drehwinkel -> Gewinde passt nicht"); fehler += 1
        return fehler
    spiel = (frei[-1] - frei[0] + 5)
    print(f"  Gewinde frei bei {frei[0]}..{frei[-1]} Grad -> Drehspiel ca. {spiel} Grad = {spiel / 360 * pitch:.2f} mm axial")
    mitte = frei[len(frei) // 2]
    aussen = bewegt(teile["aussen"], tf.translation_matrix([0, 0, z_oben]), umdrehen,
                    tf.rotation_matrix(np.radians(mitte), [0, 0, 1]))
    aussen_m = zu_manifold(aussen)
    ueber = ueberlappung(aussen_m, plexi)
    print(f"  Halteplatte gegen Plexiglas: {ueber:.4f} mm3 {'ok' if ueber < 1e-3 else 'FEHLER'}")
    fehler += ueber >= 1e-3
    ende = teile["innen"].bounds[1][2]
    print(f"  Rohrende z={ende:.2f}, Unterseite Steg z={z_oben - (scad_wert('groove_depth_150') + 1.6):.2f} (Luft = tube_gap)")

    print("== Anschluesse auf der Halteplatte (Magnetflaeche oben, Drehung 0 und 22,5 Grad)")
    for winkel in (0, 22.5):
        for k in ("magnet", "stutzen", "rohr", "rohr45"):
            if k in teile:
                f = bewegt(teile[k], tf.translation_matrix([0, 0, z_oben]), tf.rotation_matrix(np.radians(winkel), [0, 0, 1]))
                v = ueberlappung(aussen_m, zu_manifold(f))
                print(f"  Verjuengung ({k}) auf Halteplatte, {winkel:4} Grad: {v:.4f} mm3 {'ok' if v < 1e-3 else 'FEHLER'}")
                fehler += v >= 1e-3
        if args.ref150:
            r = trimesh.load(args.ref150)
            a = bewegt(r, tf.translation_matrix([0, 0, z_oben + 15]), tf.rotation_matrix(np.radians(winkel), [0, 0, 1]))
            v = ueberlappung(aussen_m, zu_manifold(a))
            print(f"  Referenz-Adapter 150 auf Halteplatte, {winkel:4} Grad: {v:.4f} mm3 {'ok' if v < 1e-3 else 'FEHLER'}")
            fehler += v >= 1e-3
            # unter der Innenscheibe haengend (Magnetflaeche der Innenscheibe liegt bei z=0 unten)
            a = bewegt(r, tf.translation_matrix([0, 0, -15]), umdrehen, tf.rotation_matrix(np.radians(winkel), [0, 0, 1]))
            v = ueberlappung(innen, zu_manifold(a))
            print(f"  Referenz-Adapter 150 unter Innenscheibe, {winkel:4} Grad: {v:.4f} mm3 {'ok' if v < 1e-3 else 'FEHLER'}")
            fehler += v >= 1e-3

    if args.ref110 and "magnet" in teile:
        r = trimesh.load(args.ref110)
        a = bewegt(r, tf.translation_matrix([0, 0, teile["magnet"].bounds[1][2] + 15]))
        v = ueberlappung(zu_manifold(teile["magnet"]), zu_manifold(a))
        print(f"== Referenz-Anschluss 110 auf 110er-Flansch der Verjuengung: {v:.4f} mm3 {'ok' if v < 1e-3 else 'FEHLER'}")
        fehler += v >= 1e-3

    if "ventilator" in teile:
        print("== Ventilator-Adapter 140 -> 110")
        v = zu_manifold(teile["ventilator"])
        cone = scad_wert("flange110_t") + scad_wert("ad_cone_len")
        sock_d, bore_d = scad_wert("fan_socket_d"), scad_wert("fan_bore_d")
        spigot_od = sock_d - 0.4            # angenommener Aussendurchmesser des Ventilatoranschlusses
        sp = (mf.Manifold.cylinder(60, spigot_od / 2, spigot_od / 2, 256) - mf.Manifold.cylinder(60, bore_d / 2, bore_d / 2, 256)).translate([0, 0, cone])
        o = ueberlappung(v, sp)
        print(f"  Ventilatoranschluss (Annahme AD {spigot_od:.1f} / ID {bore_d:.0f}) in der Muffe bis zur Schulter: {o:.4f} mm3 {'ok' if o < 1e-3 else 'FEHLER'}")
        fehler += o >= 1e-3
        ref = args.ref110
        if ref:
            r = trimesh.load(ref)
            for winkel in (0, 30):
                a = bewegt(r, tf.translation_matrix([0, 0, -15]), umdrehen, tf.rotation_matrix(np.radians(winkel), [0, 0, 1]))
                o = ueberlappung(v, zu_manifold(a))
                print(f"  Referenz-Anschluss 110 unter dem Flansch, {winkel:3} Grad: {o:.4f} mm3 {'ok' if o < 1e-3 else 'FEHLER'}")
                fehler += o >= 1e-3

    print("== Ergebnis:", "ALLES OK" if not fehler else f"{int(fehler)} FEHLER")
    return int(fehler)


if __name__ == "__main__":
    sys.exit(main())

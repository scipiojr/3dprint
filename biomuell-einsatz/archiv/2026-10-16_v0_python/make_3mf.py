#!/usr/bin/env python3
"""
Erzeugt druckfertige 3MF-Dateien (PrusaSlicer-Format, Einstellungen je Objekt) aus den STL-Dateien.
Die Einstellungen stehen nur am Objekt: Drucker- und Filamentprofil (Temperaturen!) bleiben die eigenen.
Zusaetzlich werden dieselben Einstellungen im Bambu/Orca-Format abgelegt.
"""
import struct
import zipfile
import numpy as np

BED = 260.0
MARGIN = 4.0      # Abstand zum Bettrand
GAP = 4.0         # Abstand zwischen Teilen

PLATE_SETTINGS = {
    "prusa": {"layer_height": "0.2", "perimeters": "3", "top_solid_layers": "5",
              "bottom_solid_layers": "4", "fill_density": "25%", "fill_pattern": "gyroid",
              "support_material": "0", "brim_width": "0", "seam_position": "rear"},
    "bambu": {"layer_height": "0.2", "wall_loops": "3", "top_shell_layers": "5",
              "bottom_shell_layers": "4", "sparse_infill_density": "25%",
              "sparse_infill_pattern": "gyroid", "enable_support": "0", "brim_type": "no_brim",
              "seam_position": "back"},
}
BAND_SETTINGS = {
    "prusa": {"layer_height": "0.2", "perimeters": "4", "top_solid_layers": "4",
              "bottom_solid_layers": "4", "fill_density": "100%", "fill_pattern": "concentric",
              "top_fill_pattern": "concentric", "bottom_fill_pattern": "concentric",
              "support_material": "0", "brim_width": "0"},
    "bambu": {"layer_height": "0.2", "wall_loops": "4", "top_shell_layers": "4",
              "bottom_shell_layers": "4", "sparse_infill_density": "100%",
              "sparse_infill_pattern": "concentric", "top_surface_pattern": "concentric",
              "bottom_surface_pattern": "concentric", "internal_solid_infill_pattern": "concentric",
              "enable_support": "0", "brim_type": "no_brim"},
}


def load_stl(path):
    d = open(path, "rb").read()
    n = struct.unpack("<I", d[80:84])[0]
    a = np.frombuffer(d[84:], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]), count=n)
    return a["v"].reshape(-1, 3, 3).astype(np.float64)


def footprint(tris, res=1.0):
    """Grundriss als Rasterbild (Zellen, die von oben gesehen Material haben)."""
    mn = tris[:, :, :2].reshape(-1, 2).min(0)
    mx = tris[:, :, :2].reshape(-1, 2).max(0)
    nx, ny = int(np.ceil((mx[0] - mn[0]) / res)) + 1, int(np.ceil((mx[1] - mn[1]) / res)) + 1
    img = np.zeros((nx, ny), bool)
    for t in tris:
        p = (t[:, :2] - mn) / res
        x0, y0 = np.floor(p.min(0)).astype(int)
        x1, y1 = np.ceil(p.max(0)).astype(int)
        img[max(x0, 0):x1 + 1, max(y0, 0):y1 + 1] = True     # konservativ: Dreiecks-Huelle
    return img, mn


def dilate(img, r):
    out = img.copy()
    for dx in range(-r, r + 1):
        for dy in range(-r, r + 1):
            if dx * dx + dy * dy <= r * r:
                out |= np.roll(np.roll(img, dx, 0), dy, 1)
    return out


def rot180(tris):
    return tris * np.array([-1, -1, 1])


def nest_two(tris):
    """Zweites Teil um 180 Grad gedreht so dicht wie moeglich neben das erste legen."""
    a = tris - tris.reshape(-1, 3).min(0)
    b = rot180(tris)
    b = b - b.reshape(-1, 3).min(0)
    fa, _ = footprint(a)
    fb, _ = footprint(b)
    W = fa.shape[1] + fb.shape[1] + 10
    best = None
    for dy in range(0, fa.shape[1] + 2):
        A = np.zeros((max(fa.shape[0], fb.shape[0]) + 10, W + 10), bool)
        B = A.copy()
        A[5:5 + fa.shape[0], 5:5 + fa.shape[1]] = fa
        B[5:5 + fb.shape[0], 5 + dy:5 + dy + fb.shape[1]] = fb
        if not (dilate(A, int(GAP)) & B).any():
            best = dy
            break
    b = b + np.array([0, best, 0])
    return [a, b]


def center_on_bed(parts):
    allp = np.vstack([p.reshape(-1, 3) for p in parts])
    mn, mx = allp.min(0), allp.max(0)
    size = mx - mn
    assert size[0] <= BED - 2 * MARGIN and size[1] <= BED - 2 * MARGIN, f"passt nicht aufs Bett: {size}"
    off = np.array([BED / 2, BED / 2, 0]) - np.array([(mn[0] + mx[0]) / 2, (mn[1] + mx[1]) / 2, mn[2]])
    return [p + off for p in parts], size


def mesh_xml(tris):
    pts = np.round(tris.reshape(-1, 3), 4)
    uniq, inv = np.unique(pts, axis=0, return_inverse=True)
    inv = inv.reshape(-1, 3)
    v = "".join(f'<vertex x="{x:.4f}" y="{y:.4f}" z="{z:.4f}"/>' for x, y, z in uniq)
    t = "".join(f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in inv)
    return f"<mesh><vertices>{v}</vertices><triangles>{t}</triangles></mesh>", len(inv)


def write_3mf(path, objects):
    """objects: Liste (name, tris_in_bed_coords, settings)"""
    model = ['<?xml version="1.0" encoding="UTF-8"?>\n'
             '<model unit="millimeter" xml:lang="en-US" '
             'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
             'xmlns:slic3rpe="http://schemas.slic3r.org/3mf/2017/06">\n'
             '<metadata name="slic3rpe:Version3mf">1</metadata>\n'
             '<metadata name="Title">Biomuell-Plattform</metadata>\n<resources>\n']
    build = ["<build>\n"]
    prusa = ['<?xml version="1.0" encoding="UTF-8"?>\n<config>\n']
    bambu = ['<?xml version="1.0" encoding="UTF-8"?>\n<config>\n']
    for i, (name, tris, st) in enumerate(objects, start=1):
        c = tris.reshape(-1, 3)
        cen = np.array([(c[:, 0].min() + c[:, 0].max()) / 2, (c[:, 1].min() + c[:, 1].max()) / 2, 0])
        xml, ntri = mesh_xml(tris - cen)
        model.append(f'<object id="{i}" name="{name}" type="model">{xml}</object>\n')
        build.append(f'<item objectid="{i}" transform="1 0 0 0 1 0 0 0 1 '
                     f'{cen[0]:.4f} {cen[1]:.4f} {cen[2]:.4f}" printable="1"/>\n')
        prusa.append(f' <object id="{i}" instances_count="1">\n'
                     f'  <metadata type="object" key="name" value="{name}"/>\n')
        for k, v in st["prusa"].items():
            prusa.append(f'  <metadata type="object" key="{k}" value="{v}"/>\n')
        prusa.append(f'  <volume firstid="0" lastid="{ntri - 1}">\n'
                     f'   <metadata type="volume" key="name" value="{name}"/>\n'
                     f'   <metadata type="volume" key="volume_type" value="ModelPart"/>\n'
                     f'  </volume>\n </object>\n')
        bambu.append(f' <object id="{i}">\n  <metadata key="name" value="{name}"/>\n')
        for k, v in st["bambu"].items():
            bambu.append(f'  <metadata key="{k}" value="{v}"/>\n')
        bambu.append(f'  <part id="{i}" subtype="normal_part">\n'
                     f'   <metadata key="name" value="{name}"/>\n  </part>\n </object>\n')
    model.append("</resources>\n")
    build.append("</build>\n")
    model += build
    model.append("</model>\n")
    prusa.append("</config>\n")
    bambu.append("</config>\n")
    content_types = ('<?xml version="1.0" encoding="UTF-8"?>\n'
                     '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
                     '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
                     '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
                     '<Default Extension="config" ContentType="text/xml"/>'
                     '</Types>')
    rels = ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Target="/3D/3dmodel.model" Id="rel0" '
            'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", content_types)
        z.writestr("_rels/.rels", rels)
        z.writestr("3D/3dmodel.model", "".join(model))
        z.writestr("Metadata/Slic3r_PE_model.config", "".join(prusa))
        z.writestr("Metadata/model_settings.config", "".join(bambu))


if __name__ == "__main__":
    jobs = []
    for plate in ("plattform_6baender", "plattform_4baender"):
        parts, size = center_on_bed([load_stl(plate + ".stl")])
        jobs.append((plate + ".3mf", [(plate, parts[0], PLATE_SETTINGS)], size))
    band = load_stl("band.stl")
    parts, size = center_on_bed(nest_two(band))
    jobs.append(("baender_2x.3mf", [("band_1", parts[0], BAND_SETTINGS),
                                    ("band_2", parts[1], BAND_SETTINGS)], size))
    parts, size = center_on_bed([load_stl("buegel.stl")])
    jobs.append(("buegel.3mf", [("buegel", parts[0], BAND_SETTINGS)], size))
    for path, objs, size in jobs:
        write_3mf(path, objs)
        print(f"{path}: {len(objs)} Teil(e), Belegung {size[0]:.0f} x {size[1]:.0f} mm")

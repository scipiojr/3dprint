#!/usr/bin/env python3
"""Erzeugt aus schluesselknauf.scad eine 3MF mit der Platte und dem Lichtfenster als zwei Teile
eines Objekts (im Slicer dem Fenster transparentes PETG zuweisen).

  python3 erzeuge_3mf.py supermini_frei      -> platte_supermini_frei.3mf
"""
import os, subprocess, sys, tempfile, zipfile

HIER = os.path.dirname(os.path.abspath(__file__))
modul = sys.argv[1] if len(sys.argv) > 1 else "supermini_frei"
TEILE = [("platte", "Platte"), ("led_fenster", "Lichtfenster")]

def stl_lesen(fn):
    pkt, idx, dreiecke = [], {}, []
    ecken = []
    for z in open(fn):
        z = z.strip()
        if z.startswith("vertex"):
            v = tuple(round(float(a), 5) for a in z.split()[1:4])
            if v not in idx:
                idx[v] = len(pkt); pkt.append(v)
            ecken.append(idx[v])
            if len(ecken) == 3:
                if len(set(ecken)) == 3: dreiecke.append(tuple(ecken))
                ecken = []
    return pkt, dreiecke

def mesh_xml(pkt, dreiecke):
    v = "".join('<vertex x="%g" y="%g" z="%g"/>' % p for p in pkt)
    t = "".join('<triangle v1="%d" v2="%d" v3="%d"/>' % d for d in dreiecke)
    return "<mesh><vertices>%s</vertices><triangles>%s</triangles></mesh>" % (v, t)

objekte = []
with tempfile.TemporaryDirectory() as tmp:
    for i, (teil, name) in enumerate(TEILE, start=1):
        fn = os.path.join(tmp, teil + ".stl")
        subprocess.run(["openscad", "-q", "-D", 'modul="%s"' % modul, "-D", 'teil="%s"' % teil,
                        "-o", fn, os.path.join(HIER, "schluesselknauf.scad")], check=True)
        objekte.append('<object id="%d" name="%s" type="model">%s</object>' % (i, name, mesh_xml(*stl_lesen(fn))))

n = len(TEILE) + 1
komp = "".join('<component objectid="%d"/>' % i for i in range(1, n))
modell = ('<?xml version="1.0" encoding="UTF-8"?>'
          '<model unit="millimeter" xml:lang="de-DE" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
          '<metadata name="Title">Platte %s</metadata><resources>%s'
          '<object id="%d" name="Platte %s" type="model"><components>%s</components></object>'
          '</resources><build><item objectid="%d"/></build></model>') % (modul, "".join(objekte), n, modul, komp, n)
ziel = os.path.join(HIER, "platte_%s.3mf" % modul)
with zipfile.ZipFile(ziel, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml",
               '<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
               '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
               '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
    z.writestr("_rels/.rels",
               '<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
               '<Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
    z.writestr("3D/3dmodel.model", modell)
print(ziel)

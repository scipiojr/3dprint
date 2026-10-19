#!/usr/bin/env python3
"""Aktualisiert die Trichter-3MFs: ersetzt die Netze in einer vorhandenen 3MF (Vorlage) durch neue STL-Dateien
und behält alle Druckeinstellungen, Platten und Positionen der Vorlage.

  trichter_3mf.py einfach    <vorlage.3mf> <hälfte_A.stl> <hälfte_B.stl> <aus.3mf>
        für trichter.3mf (zwei Objekte in 3D/3dmodel.model, PrusaSlicer- und Bambu-Einstellungen)
  trichter_3mf.py druckhilfe <vorlage.3mf> <hälfte_A.stl> <steg_A.stl> <hälfte_B.stl> <steg_B.stl> <aus.3mf>
        für trichter_druckhilfe.3mf (je Platte Hälfte + abtrennbarer Steg als zwei Teile)

Die Netze werden auf die Mitte ihrer Bounding-Box (bei Hälfte + Steg: gemeinsam) gelegt, wie in den Vorlagen.
Die STL-Dateien sind druckfertig orientiert (aus der SCAD-Datei exportiert, Kragenoberseite auf dem Bett).
"""
import re
import sys
import zipfile
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from stl_pruefung import lade  # noqa: E402


def netz(pfad):
    t = lade(pfad)
    v = np.round(t.reshape(-1, 3), 4)
    u, inv = np.unique(v, axis=0, return_inverse=True)
    tri = inv.reshape(-1, 3)
    tri = tri[(tri[:, 0] != tri[:, 1]) & (tri[:, 1] != tri[:, 2]) & (tri[:, 0] != tri[:, 2])]
    return u, tri


def zentrieren(netze):
    """Alle Netze um dieselbe Mitte (Bounding-Box aller zusammen) verschieben."""
    alle = np.concatenate([n[0] for n in netze])
    mitte = (alle.min(0) + alle.max(0)) / 2
    return [(v - mitte, t) for v, t in netze], alle.max(0) - alle.min(0)


def netz_xml(v, tri):
    return ('<mesh><vertices>' + ''.join(f'<vertex x="{a:.5f}" y="{b:.5f}" z="{c:.5f}"/>' for a, b, c in v)
            + '</vertices><triangles>' + ''.join(f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in tri)
            + '</triangles></mesh>')


def objekt_ersetzen(xml, oid, v, tri):
    muster = re.compile(r'(<object id="%s"[^>]*>)<mesh>.*?</mesh>' % oid, re.S)
    assert muster.search(xml), f'Objekt {oid} nicht gefunden'
    return muster.sub(lambda m: m.group(1) + netz_xml(v, tri), xml, count=1)


def z_versatz_setzen(xml, hoehe):
    """Build-Items: z-Versatz = halbe Höhe (Netze sind in z zentriert)."""
    return re.sub(r'(transform="1 0 0 0 1 0 0 0 1 [\d.\-]+ [\d.\-]+ )[\d.\-]+(")', lambda m: f'{m.group(1)}{hoehe / 2:.4f}{m.group(2)}', xml)


def kopieren(vorlage, aus, ersetzt):
    with zipfile.ZipFile(vorlage) as zi, zipfile.ZipFile(aus, 'w', zipfile.ZIP_DEFLATED) as zo:
        for info in zi.infolist():
            daten = zi.read(info.filename)
            if info.filename in ersetzt:
                daten = ersetzt[info.filename](daten.decode('utf-8')).encode('utf-8')
            zo.writestr(info.filename, daten)
    print('geschrieben:', aus)


def einfach(vorlage, a, b, aus):
    liste_a, groesse = zentrieren([netz(a)])
    liste_b, _ = zentrieren([netz(b)])
    (va, ta), (vb, tb) = liste_a[0], liste_b[0]

    def modell(x):
        x = objekt_ersetzen(x, 1, va, ta)
        x = objekt_ersetzen(x, 2, vb, tb)
        return z_versatz_setzen(x, groesse[2])

    def pe_config(x):  # Dreiecksbereiche je Volumen (PrusaSlicer)
        bloecke = re.findall(r'<volume firstid="\d+" lastid="\d+">', x)
        for blk, n in zip(bloecke, (len(ta), len(tb))):
            x = x.replace(blk, f'<volume firstid="0" lastid="{n - 1}">', 1)
        return x
    kopieren(vorlage, aus, {'3D/3dmodel.model': modell, 'Metadata/Slic3r_PE_model.config': pe_config})


def druckhilfe(vorlage, a, sa, b, sb, aus):
    def paar(tri_pfad, steg_pfad, id_tri, id_steg):
        (vt, tt), (vs, ts) = zentrieren([netz(tri_pfad), netz(steg_pfad)])[0]
        hoehe = zentrieren([netz(tri_pfad), netz(steg_pfad)])[1][2]
        return (lambda x: objekt_ersetzen(objekt_ersetzen(x, id_tri, vt, tt), id_steg, vs, ts)), hoehe
    fa, h = paar(a, sa, 1, 2)
    fb, _ = paar(b, sb, 3, 4)
    kopieren(vorlage, aus, {
        '3D/Objects/trichter_A.model': fa,
        '3D/Objects/trichter_B.model': fb,
        '3D/3dmodel.model': lambda x: z_versatz_setzen(x, h),
    })


if __name__ == '__main__':
    modus = sys.argv[1] if len(sys.argv) > 1 else ''
    if modus == 'einfach' and len(sys.argv) == 6:
        einfach(*sys.argv[2:])
    elif modus == 'druckhilfe' and len(sys.argv) == 8:
        druckhilfe(*sys.argv[2:])
    else:
        print(__doc__)
        sys.exit(1)

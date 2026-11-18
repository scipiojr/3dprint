"""
Rhino Lattice Mask – prozeduraler Generator für Blender 4.x (getestet auch mit 5.x)
==================================================================================

Ausführen:  blender -b -P rhino_lattice_mask.py
            (oder in Blender: Workspace "Scripting" -> Datei öffnen -> "Run Script")
            Danach: python3 werkzeuge/stl_to_3mf.py druck/rhino_maske_kobra4.3mf druck/stl/rhino_maske_teil_*.stl

Einheiten:  1 Blender-Unit = 1 mm (Szene wird auf Millimeter gestellt).
            Die STL wird in mm exportiert und kann direkt in den Slicer.

Ablauf:
  1. Basisform aus Metaballs (Schädel, Hals, Wangen, Schnauze) + Horn + Ohren
     -> per Voxel-Remesh zu EINER geschlossenen, manifolden Oberfläche verschmolzen
  2. Unterseite des Halses wird plan aufgeschnitten (Kopföffnung), Rest bleibt zu.
     Zusätzlich: solide 4–5-mm-Hülle als Referenz-/Alternativobjekt (Solidify)
  3. Zweilagiges Gitter:
       Lage A (außen): Decimate -> Dual Mesh (Voronoi-artige Waben) -> Wireframe
       Lage B (innen): nach innen versetzt, gröberes Dreiecksnetz -> Wireframe
       Beide Lagen überlappen radial um GITTER_UEBERLAPP mm und verschmelzen so.
     Unten: massiver Kragen (Ring) als stabiler Rand der Kopföffnung.
  4. Zwei solide Augenkugeln; die Hülle darunter wird ausgespart, die Gitterstege
     enden IN den Kugeln -> mechanische Verbindung, keine Löcher in den Augen.

Alternative: IMPORT_PFAD setzen -> Schritt 1 wird durch ein importiertes, glattes
Modell (z.B. aus Meshy.ai) ersetzt; Schritte 2–4 laufen identisch.

Ergebnis-Objekte (Collection "RhinoMask"):
  Rhino_Maske_LATTICE   – druckfertiges Gitter (Lagen + Kragen + Augen, ein Objekt)
  Rhino_Huelle_Solid    – geschlossene, ausgehöhlte Hülle (ausgeblendet)
  Rhino_Oberflaeche     – Basisfläche (ausgeblendet, für eigene Experimente)
"""

import bpy
import bmesh
import math
import os
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

# =============================================================================
#  PARAMETER (alle Maße in mm)
# =============================================================================

# ---- VARIANTE ------------------------------------------------------------------
# "tragbar" = Maske zum Aufsetzen (Werte unten), "mini" = Figur mit ca. 60 mm Kantenlänge.
# Auch per Kommandozeile:  blender -b -P rhino_lattice_mask.py -- mini
PRESET            = "tragbar"
PRESETS = {
    "mini": dict(
        MASKE_HOEHE=59.5,                 # größte Kante ≈ 60 mm (Netz steht 0,4 mm über)
        ZELLE_A=1.6, STEG_A=0.8,          # Löcher ≈ 0,8 mm – Grenze für 0,4-mm-Düse
        NETZ_TIEFE=0.8, NETZ_OFFSET=0.0,  # mittig, sonst sticht es an den dünnen Ohren durch
        MIN_LOCH=0.4,
        KRAGEN_HOEHE=2.0, WANDSTAERKE=1.2, AUGE_WAND=1.2,
        TRAGBAR=False, TEILEN=False, VOLLKOERPER=True,
        EXPORT_PFAD="druck/mini/rhino_mini_gitter.stl",
    ),
}

# ---- HIER EINTRAGEN: Maskengröße und Drucker ---------------------------------
MASKE_HOEHE       = 0.0     # fertige Höhe in mm (Halsrand bis Ohrspitze).
                            # 0 = automatisch: so klein wie möglich, damit der Kopf
                            #     (KOPF_DURCHMESSER + 2*KOPF_SPIEL) durch die Öffnung passt
DRUCKRAUM         = (260.0, 260.0, 260.0)   # Druckraum X, Y, Z in mm (Anycubic Kobra 4)
DRUCKRAND         = 5.0     # Sicherheitsabstand pro Achse (mm)
TEILEN            = True    # Maske automatisch in druckraumgerechte Teile zerlegen
TRAGBAR           = True    # Kopföffnung gegen KOPF_DURCHMESSER prüfen
VOLLKOERPER       = False   # zusätzlich die geschlossene Form (unten plan) als STL
# -------------------------------------------------------------------------------

SKALIERUNG        = 1.0     # (prozedurale Form) wird aus MASKE_HOEHE berechnet
VOXEL_BASIS       = 2.5     # Auflösung der Basisoberfläche

# Kopföffnung / Hülle
SCHNITT_Z         = 0.0     # Höhe der Schnittebene an der Halsunterseite
WANDSTAERKE       = 4.5     # Stärke der soliden Referenzhülle + Kragen
KOPF_DURCHMESSER  = 220.0   # zur Kontrolle der Öffnung
KOPF_SPIEL        = 15.0    # gewünschte Luft rundum (Durchmesser + 2*Spiel)
KRAGEN_HOEHE      = 10.0    # massiver Ring an der Öffnung

# Gitter
GITTER_MODUS      = "lochnetz"  # "lochnetz" = Sichtgitter: wirkt geschlossen, Träger sieht hinaus
                                # "stabgitter" = offenes Stabwerk (zwei Lagen, frühere Variante)
ZELLE_A           = 2.5     # Maschenweite (Mitte zu Mitte); Loch ≈ ZELLE_A - STEG_A
STEG_A            = 0.9     # Stegbreite an der Oberfläche (>= 2 Düsenbahnen)
NETZ_TIEFE        = 2.0     # Stegtiefe nach innen (Steifigkeit; tiefer = engerer Sichtwinkel)
NETZ_OFFSET       = -1.0    # -1 = Netz liegt innerhalb der Außenfläche, 0 = mittig
MIN_LOCH          = 0.5     # kleinere Löcher werden nicht ausgestanzt (Zelle bleibt zu)
# Gitter Lage B (innen, Dreiecke, versetzt)
ZELLE_B           = 10.0
STEG_B            = 2.0
GITTER_UEBERLAPP  = 0.5     # radiale Überlappung der Lagen (Verschmelzung)
LAGE_B            = True    # zweite (innere) Gitterlage (nur GITTER_MODUS "stabgitter")
WIRE_OFFSET_A     = -1.0    # -1 = Stege innerhalb der Außenfläche, 0 = mittig

# Augen
AUGE_RADIUS       = 33.0
AUGE_EINBETTUNG   = 0.45    # Anteil des Durchmessers, der in der Hülle steckt
AUGE_X, AUGE_Z    = 84.0, 336.0
AUGE_GIER         = 24.0    # Grad, wie weit die Augen zur Seite schauen


# Import statt prozeduraler Grundform (z.B. glattes Meshy.ai-Modell)
# Werte unten = Preset für "Meshy_AI_Rhino_Mask_Lattice_20261117_image-to-3d-texture.obj"
IMPORT_PFAD       = "modell/meshy_rhino.obj"   # .stl/.obj/.glb, relativ zum Skript – leer = prozedurale Form
IMPORT_ABSCHNITT_ANTEIL = 0.1326  # Anteil der Modellhöhe, der unten (gerundete Halsunterseite)
                                  # für die Kopföffnung entfällt
IMPORT_AUGE_X_ANTEIL    = 0.157   # Augensuche: X-Abstand von der Mitte / Modellhöhe
IMPORT_AUGE_Z_ANTEIL    = 0.705   # Augensuche: Höhe über Modellunterkante / Modellhöhe
IMPORT_VOXEL      = 0.0     # 0 = Form 1:1 übernehmen (nur wenn das Modell wasserdicht ist),
                            # >0 = Voxel-Remesh (z.B. 1.5) für defekte Meshes
AUGE_FREISTELLUNG = -1.0    # mm: Gitter endet so weit innerhalb der Augenkugel (prozedurale Augen)
AUGE_AUTO_FIT     = True    # Import: vorhandene Augenwölbungen des Modells exakt als solide Augen übernehmen
AUGE_KANTENWINKEL = 14.0    # Grad – Grenze der Augenwölbung (Knick zur Augenhöhle)
AUGE_WAND         = 5.0     # mm Materialstärke der soliden Augen
# Ausrichtung des Imports: Z oben, Schnauze zeigt nach -Y (Blender-Frontansicht),
# Die Schnittebene der Kopföffnung liegt nach dem Import bei Z = SCHNITT_Z.

# Optional
SYMMETRISCH       = True    # Gitter spiegelsymmetrisch (Decimate-Symmetrie)
FINAL_VOXEL_FUSE  = 0.0     # >0 (z.B. 0.35) = alles zu EINEM Volumen verschmelzen
                            # (sehr rechen-/speicherintensiv, v.a. für SLA)
EXPORT_STL        = True
EXPORT_BASIS_STL  = False   # zusätzlich die glatte, geschlossene Grundform aus Schritt 1
EXPORT_PFAD       = "druck/rhino_maske_komplett.stl"   # relativ zum Skript; Teile landen in druck/stl/

# Metaball-Kalibrierung: sichtbarer Radius = 0.5745 * radius (Threshold 0.6, Stiffness 2)
_MB_F = 0.5745
_IMPORT_H, _IMPORT_UNTEN = 0.0, 0.0
_PROZ_HOEHE_S1 = 483.0      # Höhe der prozeduralen Maske bei SKALIERUNG = 1


# =============================================================================
#  HILFSFUNKTIONEN
# =============================================================================
def log(*a):
    print("[RhinoMask]", *a)


def _basisordner():
    try:
        return os.path.dirname(os.path.abspath(__file__))
    except NameError:
        return bpy.path.abspath("//") or os.getcwd()


def pfad(p):
    """Relative Pfade gelten relativ zum Skript (bzw. zur .blend-Datei)."""
    return p if not p or os.path.isabs(p) else os.path.join(_basisordner(), p)


def szene_vorbereiten():
    sc = bpy.context.scene
    sc.unit_settings.system = 'METRIC'
    sc.unit_settings.scale_length = 0.001
    sc.unit_settings.length_unit = 'MILLIMETERS'
    col = bpy.data.collections.get("RhinoMask")
    if col:
        for o in list(col.objects):
            bpy.data.objects.remove(o, do_unlink=True)
    else:
        col = bpy.data.collections.new("RhinoMask")
        sc.collection.children.link(col)
    for v in bpy.context.screen.areas if bpy.context.screen else []:
        if v.type == 'VIEW_3D':
            for s in v.spaces:
                if s.type == 'VIEW_3D':
                    s.clip_end = 100000
    return col


def neues_objekt(name, mesh, col):
    ob = bpy.data.objects.new(name, mesh)
    col.objects.link(ob)
    return ob


def modifier_anwenden(ob):
    """Wendet den gesamten Modifier-Stack an (ohne bpy.ops / Kontextprobleme)."""
    dg = bpy.context.evaluated_depsgraph_get()
    dg.update()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg))
    alt = ob.data
    ob.modifiers.clear()
    ob.data = me
    if alt.users == 0:
        bpy.data.meshes.remove(alt)
    return ob


def kopie(ob, name, col):
    o2 = neues_objekt(name, ob.data.copy(), col)
    o2.matrix_world = ob.matrix_world.copy()
    return o2


def bm_aus(ob):
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    return bm


def bm_nach(bm, ob):
    bm.to_mesh(ob.data)
    ob.data.update()
    bm.free()


def aufraeumen(bm, min_insel=30):
    """Entfernt Fliegen-Vertices (zwei Fächer an einem Punkt) und kleine Inseln –
    beides würde nach dem Wireframe nicht-manifolde Kanten ergeben."""
    for _ in range(5):
        boese = {f for v in bm.verts if not v.is_manifold and v.link_faces
                 and not v.is_boundary for f in v.link_faces}
        boese |= {f for v in bm.verts if v.is_boundary and
                  sum(1 for e in v.link_edges if e.is_boundary) > 2 for f in v.link_faces}
        if not boese:
            break
        bmesh.ops.delete(bm, geom=list(boese), context='FACES')
    gesehen, klein = set(), []
    for f in bm.faces:
        if f in gesehen:
            continue
        insel, stapel = [f], [f]
        gesehen.add(f)
        while stapel:
            g = stapel.pop()
            for e in g.edges:
                for h in e.link_faces:
                    if h not in gesehen:
                        gesehen.add(h)
                        insel.append(h)
                        stapel.append(h)
        if len(insel) < min_insel:
            klein += insel
    if klein:
        bmesh.ops.delete(bm, geom=klein, context='FACES')


def flaeche_mm2(ob):
    return sum(p.area for p in ob.data.polygons)


# =============================================================================
#  1. BASISGEOMETRIE
# =============================================================================
def _q(yaw=0.0, roll=0.0, pitch=0.0):
    """Rotation als Quaternion (Grad): Gieren um Z, Rollen um Y, Nicken um X."""
    return (Matrix.Rotation(math.radians(yaw), 4, 'Z') @
            Matrix.Rotation(math.radians(roll), 4, 'Y') @
            Matrix.Rotation(math.radians(pitch), 4, 'X')).to_quaternion()


def metaball_koerper(col):
    S = SKALIERUNG
    mb = bpy.data.metaballs.new("Rhino_MB")
    mb.resolution = mb.render_resolution = 3.0
    mb.threshold = 0.6
    ob = neues_objekt("Rhino_MB", mb, col)

    # (Zentrum, halbe Ausdehnung, Rotation, negativ?)   – symmetrische Teile mit "±"
    teile = [
        # Hals: zylindrisch, unten leicht ausgestellt (liegt auf den Schultern)
        ((0,  30,  40), (150, 158,  80), None, False),
        ((0,  35, 135), (124, 132,  85), None, False),
        # Schädel, Hinterkopf, Stirn
        ((0,  25, 330), (128, 135, 105), None, False),
        ((0,  70, 270), (118, 100, 100), None, False),
        ((0, -55, 325), ( 92,  75,  70), None, False),
        # Wangen – kräftige Ausbuchtungen hinter den Augen
        ("±", (112, 10, 272), (66, 88, 84), None, False),
        # Schnauze: breit, kastig, weit vorstehend
        ((0, -150, 215), (118, 105,  75), None, False),
        ((0, -222, 215), (100,  58,  70), None, False),
        ("±", (72, -212, 205), (52, 58, 64), None, False),
        ((0, -165, 268), ( 88,  88,  40), None, False),
        # Unterkiefer / Kinn
        ((0, -130, 150), (102,  96,  45), None, False),
        ((0, -195, 160), ( 78,  55,  36), None, False),
        # Horn: kurz, stumpf, breite Basis (Kugelkette)
        ((0, -232, 282), ( 44,  44,  40), None, False),
        ((0, -238, 308), ( 34,  34,  30), None, False),
        ((0, -240, 330), ( 25,  25,  22), None, False),
        ((0, -238, 348), ( 17,  17,  15), None, False),
        ((0, -234, 360), ( 11,  11,  10), None, False),
    ]

    def setze(c, ext, rot, neg):
        e = mb.elements.new(type='ELLIPSOID')
        e.co = Vector(c) * S
        r = max(ext) * S / _MB_F
        e.radius = r
        e.size_x, e.size_y, e.size_z = (x * S / (r * _MB_F) for x in ext)
        e.use_negative = neg
        if rot is not None:
            e.rotation = _q(*rot)

    for t in teile:
        if t[0] == "±":
            _, c, ext, rot, neg = t
            for sx in (1, -1):
                r2 = None if rot is None else (sx * rot[0], sx * rot[1], rot[2])
                if neg:   # negatives Element nach vorne (lokal -Y) verschieben
                    off = _q(*r2) @ Vector((0, -14, 0))
                    cc = (sx * c[0] + off.x, c[1] + off.y, c[2] + off.z)
                else:
                    cc = (sx * c[0], c[1], c[2])
                setze(cc, ext, r2, neg)
        else:
            setze(*t)

    dg = bpy.context.evaluated_depsgraph_get()
    dg.update()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg))
    body = neues_objekt("Rhino_Koerper", me, col)
    bpy.data.objects.remove(ob, do_unlink=True)
    bpy.data.metaballs.remove(mb)
    return body


def ohr_mesh(col, sx):
    """Ohrmuschel als eigene Metaball-Familie (verschmilzt nicht mit dem Kopf-Feld):
    positives Ellipsoid minus nach vorn versetztes negatives Ellipsoid."""
    S = SKALIERUNG
    mb = bpy.data.metaballs.new("Ohr")
    mb.resolution = mb.render_resolution = 2.0
    ob = neues_objekt(f"OhrMB_{'L' if sx > 0 else 'R'}", mb, col)
    rot = _q(sx * 35, sx * 25, -12)
    for c, ext, neg in (((0, 0, 0), (34, 24, 56), False),
                        ((0, -13, 8), (25, 21, 46), True)):
        e = mb.elements.new(type='ELLIPSOID')
        e.co = rot @ (Vector(c) * S)
        r = max(ext) * S / _MB_F
        e.radius = r
        e.size_x, e.size_y, e.size_z = (x * S / (r * _MB_F) for x in ext)
        e.rotation = rot
        e.use_negative = neg
    ob.location = Vector((sx * 100, 50, 440)) * S
    dg = bpy.context.evaluated_depsgraph_get()
    dg.update()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg))
    me.transform(ob.matrix_world)
    bpy.data.objects.remove(ob, do_unlink=True)
    bpy.data.metaballs.remove(mb)
    return me


def raycast(bvh, origin, richtung):
    loc, nor, idx, dist = bvh.ray_cast(Vector(origin), Vector(richtung).normalized())
    if loc is None:
        raise RuntimeError(f"Raycast verfehlt Oberfläche: {origin} -> {richtung}")
    return loc, nor


# Falten (Lippenlinie, Rand der Schnauzenplatte) – Punkte für die +X-Seite, werden gespiegelt
FALTEN = [
    # (Kontrollpunkte, Tiefe mm, Breite mm)
    ([(0, -275, 180), (55, -265, 176), (100, -222, 172), (120, -160, 176),
      (120, -100, 192), (112, -50, 212)], 5.0, 5.0),
    ([(0, -128, 300), (48, -128, 296), (92, -122, 268), (116, -108, 228),
      (120, -100, 198)], 4.5, 5.0),
]


def falten(ob):
    from mathutils.kdtree import KDTree
    S = SKALIERUNG
    bm = bm_aus(ob)
    bm.normal_update()
    bvh = BVHTree.FromBMesh(bm)
    for ctrl, tiefe, breite in FALTEN:
        pts = []
        for sx in (1, -1):
            c = [Vector((sx * x, y, z)) * S for x, y, z in ctrl]
            for a, b in zip(c[:-1], c[1:]):
                n = max(int((b - a).length / 1.5), 1)
                for k in range(n + 1):
                    loc = bvh.find_nearest(a.lerp(b, k / n))[0]
                    if loc is not None:
                        pts.append(loc)
        kd = KDTree(len(pts))
        for i, p in enumerate(pts):
            kd.insert(p, i)
        kd.balance()
        verschieb = []
        for v in bm.verts:
            _, _, d = kd.find(v.co)
            if d < 3 * breite * S:
                verschieb.append((v, v.normal * (tiefe * S * math.exp(-(d / (breite * S)) ** 2))))
        for v, dv in verschieb:
            v.co -= dv
    bm_nach(bm, ob)


def importiere_basis(col):
    """Lädt STL/OBJ/GLB, vereinigt alle Teile, skaliert und setzt die Halsunterseite
    auf Z = SCHNITT_Z - IMPORT_ABSCHNITT. Die Form selbst bleibt unverändert."""
    vorher = set(bpy.data.objects)
    datei = pfad(IMPORT_PFAD)
    ext = os.path.splitext(datei)[1].lower()
    if ext == ".stl":
        try:
            bpy.ops.wm.stl_import(filepath=datei)
        except AttributeError:
            bpy.ops.import_mesh.stl(filepath=datei)
    elif ext == ".obj":
        bpy.ops.wm.obj_import(filepath=datei)
    elif ext in (".glb", ".gltf"):
        bpy.ops.import_scene.gltf(filepath=datei)
    else:
        raise RuntimeError("Nur .stl / .obj / .glb werden unterstützt")
    neu = [o for o in bpy.data.objects if o not in vorher and o.type == 'MESH']
    bm = bmesh.new()
    for o in neu:
        me = o.data.copy()
        me.transform(o.matrix_world)
        bm.from_mesh(me)
        bpy.data.meshes.remove(me)
    for o in [o for o in bpy.data.objects if o not in vorher]:
        bpy.data.objects.remove(o, do_unlink=True)
    zs = [v.co.z for v in bm.verts]
    xs = [v.co.x for v in bm.verts]
    ys = [v.co.y for v in bm.verts]
    h_mod = max(zs) - min(zs)
    z_schnitt = min(zs) + IMPORT_ABSCHNITT_ANTEIL * h_mod
    if MASKE_HOEHE > 0:
        f = MASKE_HOEHE / (h_mod * (1 - IMPORT_ABSCHNITT_ANTEIL))
    else:
        # automatisch: Halsquerschnitt an der Schnitthöhe muss den Kopf aufnehmen
        bm2 = bm.copy()
        r = bmesh.ops.bisect_plane(bm2, geom=bm2.verts[:] + bm2.edges[:] + bm2.faces[:],
                                   plane_co=(0, 0, z_schnitt), plane_no=(0, 0, 1))
        P = [g.co for g in r["geom_cut"] if isinstance(g, bmesh.types.BMVert)]
        bm2.free()
        breite = max(p.x for p in P) - min(p.x for p in P)
        tiefe = max(p.y for p in P) - min(p.y for p in P)
        soll = KOPF_DURCHMESSER + 2 * KOPF_SPIEL + 2 * WANDSTAERKE
        f = soll / min(breite, tiefe) * 1.005
    mitte = Vector(((max(xs) + min(xs)) / 2, (max(ys) + min(ys)) / 2, z_schnitt))
    m = Matrix.Translation((0, 0, SCHNITT_Z)) @ Matrix.Scale(f, 4) @ Matrix.Translation(-mitte)
    bmesh.ops.transform(bm, matrix=m, verts=bm.verts)
    global _IMPORT_H, _IMPORT_UNTEN
    _IMPORT_H = h_mod * f                                   # Modellhöhe in mm
    _IMPORT_UNTEN = SCHNITT_Z - IMPORT_ABSCHNITT_ANTEIL * _IMPORT_H
    log(f"     Maskenhöhe {(1 - IMPORT_ABSCHNITT_ANTEIL) * _IMPORT_H:.0f} mm (Faktor {f:.2f})")
    me = bpy.data.meshes.new("Rhino_Import")
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = True
    return neues_objekt("Rhino_Import", me, col)


def basisform(col):
    log("1/5  Basisform …")
    if IMPORT_PFAD:
        body = importiere_basis(col)
        bm = bm_aus(body)
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
        offen = sum(1 for e in bm.edges if not e.is_manifold)
        bm_nach(bm, body)
        if IMPORT_VOXEL > 0 or offen:
            if offen:
                log(f"     Modell hat {offen} offene Kanten -> Voxel-Remesh")
            rm = body.modifiers.new("Remesh", 'REMESH')
            rm.mode = 'VOXEL'
            rm.voxel_size = IMPORT_VOXEL if IMPORT_VOXEL > 0 else 1.5
            modifier_anwenden(body)
        else:
            log("     Modell ist wasserdicht – Form wird 1:1 übernommen (kein Remesh/Glätten)")
        body.name = "Rhino_Oberflaeche"
        return body
    body = metaball_koerper(col)
    bm = bm_aus(body)
    for sx in (1, -1):
        me = ohr_mesh(col, sx)
        bm.from_mesh(me)
        bpy.data.meshes.remove(me)
    bm_nach(bm, body)
    # Voxel-Remesh -> gleichmäßige, manifolde Fläche
    rm = body.modifiers.new("Remesh", 'REMESH')
    rm.mode = 'VOXEL'
    rm.voxel_size = VOXEL_BASIS
    rm.adaptivity = 0.0
    sm = body.modifiers.new("Glätten", 'CORRECTIVE_SMOOTH')
    sm.iterations = 6
    sm.smooth_type = 'LENGTH_WEIGHTED'
    sm.use_only_smooth = True
    modifier_anwenden(body)
    falten(body)
    body.name = "Rhino_Oberflaeche"
    return body


# =============================================================================
#  2. KOPFÖFFNUNG + AUSGEHÖHLTE HÜLLE
# =============================================================================
def kopfoeffnung(surf):
    log("2/5  Kopföffnung + Hülle …")
    bm = bm_aus(surf)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    geom = bm.verts[:] + bm.edges[:] + bm.faces[:]
    bmesh.ops.bisect_plane(bm, geom=geom, dist=0.01,
                           plane_co=(0, 0, SCHNITT_Z), plane_no=(0, 0, 1),
                           clear_inner=True)
    # Kontrolle der Öffnung (Randschleife)
    rand = [v.co for v in bm.verts if v.is_boundary]
    if not rand:
        bm.free()
        raise RuntimeError("Schnittebene trifft das Modell nicht – IMPORT_ABSCHNITT_ANTEIL prüfen")
    bx = max(c.x for c in rand) - min(c.x for c in rand)
    by = max(c.y for c in rand) - min(c.y for c in rand)
    bm_nach(bm, surf)
    innen_x, innen_y = bx - 2 * WANDSTAERKE, by - 2 * WANDSTAERKE
    soll = KOPF_DURCHMESSER + 2 * KOPF_SPIEL
    log(f"     Öffnung außen {bx:.0f} x {by:.0f} mm, innen ≈ {innen_x:.0f} x {innen_y:.0f} mm "
        + (f"(Soll ≥ {soll:.0f} mm)" if TRAGBAR else "(Figur, nicht tragbar)"))
    if TRAGBAR and min(innen_x, innen_y) < soll:
        log("     WARNUNG: Öffnung kleiner als Soll – MASKE_HOEHE erhöhen (oder 0 = automatisch)!")


def solide_huelle(surf, col):
    h = kopie(surf, "Rhino_Huelle_Solid", col)
    s = h.modifiers.new("Wand", 'SOLIDIFY')
    s.thickness = WANDSTAERKE
    s.offset = -1.0                 # nach innen -> Außenmaß bleibt erhalten
    s.use_even_offset = True
    s.use_rim = True
    s.use_quality_normals = True
    modifier_anwenden(h)
    return h


# =============================================================================
#  4. AUGEN (vor dem Gitter, da die Hülle dort ausgespart wird)
# =============================================================================
def augen_aus_modell(surf, col):
    """Übernimmt die Augenwölbungen des importierten Modells 1:1 als glatte, solide Augen.
    Erkennung: Flächenwachstum vom Augenmittelpunkt bis zum Knick der Augenhöhle."""
    bm = bm_aus(surf)
    bm.normal_update()
    bm.faces.ensure_lookup_table()
    bvh = BVHTree.FromBMesh(bm)
    lay = bm.faces.layers.int.get("auge") or bm.faces.layers.int.new("auge")
    for seite in (1, -1):
        ax = IMPORT_AUGE_X_ANTEIL * _IMPORT_H
        az = _IMPORT_UNTEN + IMPORT_AUGE_Z_ANTEIL * _IMPORT_H
        loc, nor, idx, _ = bvh.ray_cast(Vector((seite * ax, -5000, az)),
                                        Vector((0, 1, 0)))
        if loc is None:
            raise RuntimeError("Auge nicht gefunden – IMPORT_AUGE_X/Z_ANTEIL prüfen")
        start = bm.faces[idx]
        region, stapel = {start}, [start]
        while stapel:
            f = stapel.pop()
            for e in f.edges:
                for g in e.link_faces:
                    if g not in region and \
                       math.degrees(f.normal.angle(g.normal)) < AUGE_KANTENWINKEL and \
                       (g.calc_center_median() - loc).length < 60:
                        region.add(g)
                        stapel.append(g)
        for f in region:
            f[lay] = 1
        log(f"     Auge {'L' if seite > 0 else 'R'}: {len(region)} Faces aus dem Modell")
    bm_nach(bm, surf)

    auge = kopie(surf, "Rhino_Augen", col)
    bm = bm_aus(auge)
    lay = bm.faces.layers.int.get("auge")
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if not f[lay]], context='FACES')
    aufraeumen(bm)
    bm_nach(bm, auge)
    so = auge.modifiers.new("Wand", 'SOLIDIFY')
    so.thickness = AUGE_WAND
    so.offset = -1.0
    so.use_even_offset = True
    so.use_rim = True
    modifier_anwenden(auge)
    return auge, []


def augen(surf, col):
    log("3/5  Augen …")
    if IMPORT_PFAD and AUGE_AUTO_FIT:
        return augen_aus_modell(surf, col)
    S = SKALIERUNG
    bm = bm_aus(surf)
    bvh = BVHTree.FromBMesh(bm)
    bm.free()
    r = AUGE_RADIUS * S
    zentren = []
    me_all = bpy.data.meshes.new("Rhino_Augen")
    bm_e = bmesh.new()
    for seite in (1, -1):
        a = math.radians(AUGE_GIER)
        d = Vector((-seite * math.sin(a), math.cos(a), 0))
        ziel = Vector((seite * AUGE_X * S, -70 * S, AUGE_Z * S))
        loc, nor = raycast(bvh, ziel - d * 600 * S, d)
        c = loc + nor * (r * (1 - 2 * AUGE_EINBETTUNG))   # Mittelpunkt relativ zur Fläche
        zentren.append((c, r))
        bmesh.ops.create_uvsphere(bm_e, u_segments=64, v_segments=32, radius=r,
                                  matrix=Matrix.Translation(c))
    bm_e.to_mesh(me_all)
    bm_e.free()
    for p in me_all.polygons:
        p.use_smooth = True
    ob = neues_objekt("Rhino_Augen", me_all, col)
    return ob, zentren


# =============================================================================
#  3. GITTER
# =============================================================================
_DUAL_NG = "RhinoDualMesh"


def dual_mesh_nodegroup():
    ng = bpy.data.node_groups.get(_DUAL_NG)
    if ng:
        return ng
    ng = bpy.data.node_groups.new(_DUAL_NG, 'GeometryNodeTree')
    ng.interface.new_socket("Geometry", in_out='INPUT', socket_type='NodeSocketGeometry')
    ng.interface.new_socket("Geometry", in_out='OUTPUT', socket_type='NodeSocketGeometry')
    gi = ng.nodes.new('NodeGroupInput')
    go = ng.nodes.new('NodeGroupOutput')
    dm = ng.nodes.new('GeometryNodeDualMesh')
    dm.inputs['Keep Boundaries'].default_value = True
    gi.location, dm.location, go.location = (-300, 0), (0, 0), (300, 0)
    ng.links.new(gi.outputs[0], dm.inputs['Mesh'])
    ng.links.new(dm.outputs['Dual Mesh'], go.inputs[0])
    return ng


def decimieren_auf(ob, kante):
    """Collapse-Decimate auf eine mittlere Dreieckskantenlänge -> organische Zellen."""
    ziel = flaeche_mm2(ob) / (0.433 * kante * kante)
    akt = sum(len(p.vertices) - 2 for p in ob.data.polygons)
    while akt < ziel * 1.5:                   # Ausgangsnetz zu grob -> linear unterteilen
        bm = bm_aus(ob)                        # (keine Glättung, Form bleibt exakt)
        bmesh.ops.triangulate(bm, faces=bm.faces)
        bmesh.ops.subdivide_edges(bm, edges=bm.edges, cuts=1, use_grid_fill=True)
        bmesh.ops.triangulate(bm, faces=bm.faces)
        bm_nach(bm, ob)
        akt = len(ob.data.polygons)
    d = ob.modifiers.new("Decimate", 'DECIMATE')
    d.decimate_type = 'COLLAPSE'
    d.ratio = max(min(ziel / akt, 1.0), 0.0005)
    d.use_collapse_triangulate = True
    if SYMMETRISCH:
        d.use_symmetry = True
        d.symmetry_axis = 'X'
    modifier_anwenden(ob)
    bm = bm_aus(ob)
    bmesh.ops.dissolve_degenerate(bm, edges=bm.edges, dist=0.05)
    aufraeumen(bm)
    bm_nach(bm, ob)


def wireframe(ob, dicke, offset=-1.0):
    w = ob.modifiers.new("Wireframe", 'WIREFRAME')
    w.thickness = dicke
    w.offset = offset                # -1: Stege liegen INNERHALB der Außenfläche
    w.use_even_offset = False        # True erzeugt Spikes an spitzen Wabenecken
    w.use_relative_offset = False
    w.use_boundary = True
    w.use_replace = True
    w.use_crease = False
    modifier_anwenden(ob)


def gitter_quelle(surf, augen_zentren, col):
    """Fläche ohne Augenbereiche und ohne Kragenband (+ kleine Überlappung)."""
    q = kopie(surf, "Gitter_Quelle", col)
    bm = bm_aus(q)
    weg = []
    lay = bm.faces.layers.int.get("auge")
    for f in bm.faces:
        c = f.calc_center_median()
        if lay is not None and f[lay]:
            weg.append(f)
        elif c.z < SCHNITT_Z + KRAGEN_HOEHE - min(4.0, 0.4 * KRAGEN_HOEHE):
            weg.append(f)
        elif any((c - z).length < r + AUGE_FREISTELLUNG for z, r in augen_zentren):
            weg.append(f)
    bmesh.ops.delete(bm, geom=weg, context='FACES')
    aufraeumen(bm)
    bm_nach(bm, q)
    return q


def kragen(surf, col):
    k = kopie(surf, "Kragen", col)
    bm = bm_aus(k)
    weg = [f for f in bm.faces if f.calc_center_median().z > SCHNITT_Z + KRAGEN_HOEHE]
    bmesh.ops.delete(bm, geom=weg, context='FACES')
    bm_nach(bm, k)
    s = k.modifiers.new("Wand", 'SOLIDIFY')
    s.thickness = WANDSTAERKE
    s.offset = -1.0
    s.use_even_offset = True
    s.use_rim = True
    modifier_anwenden(k)
    return k


def quadriflow(ob, kante):
    """Gleichmäßiges Vierecksnetz mit Kantenlänge ≈ kante, das der Fläche folgt
    (Maschen laufen wie ein Gewebe entlang der Form)."""
    ziel = int(flaeche_mm2(ob) / kante ** 2 * 1.15)
    bpy.context.view_layer.objects.active = ob
    for o in bpy.context.view_layer.objects:
        o.select_set(o == ob)
    try:
        with bpy.context.temp_override(object=ob, active_object=ob, selected_objects=[ob],
                                       selected_editable_objects=[ob]):
            r = bpy.ops.object.quadriflow_remesh(target_faces=ziel, use_preserve_boundary=True,
                                                 use_mesh_symmetry=False, seed=1, mode='FACES')
    except Exception as e:                      # noqa: BLE001
        log(f"     QuadriFlow-Fehler: {e}")
        return False
    if 'FINISHED' not in r or not ob.data.polygons:
        return False
    log(f"     QuadriFlow: {len(ob.data.polygons):,} Maschen")
    return True


def gitter_lochnetz(surf, augen_zentren, col):
    """Sichtgitter: gelochte Haut auf der Originalfläche. Maschen (QuadriFlow) werden um
    STEG_A/2 eingerückt und ausgestanzt, der Rahmen per Solidify auf NETZ_TIEFE gebracht.
    Löcher ≈ ZELLE_A - STEG_A; Zellen, deren Loch kleiner als MIN_LOCH wäre, bleiben zu."""
    log(f"4/5  Lochnetz (Maschen {ZELLE_A} mm, Stege {STEG_A} mm, Tiefe {NETZ_TIEFE} mm) …")
    a = gitter_quelle(surf, augen_zentren, col)
    a.name = "Gitter_A"
    if not quadriflow(a, ZELLE_A):
        log("     QuadriFlow nicht verfügbar – Ersatz: Decimate + Dual Mesh (ungleichmäßiger)")
        decimieren_auf(a, ZELLE_A)
        gn = a.modifiers.new("DualMesh", 'NODES')
        gn.node_group = dual_mesh_nodegroup()
        modifier_anwenden(a)
    bm = bm_aus(a)
    aufraeumen(bm)
    loecher = []
    for f in bm.faces:
        umfang = sum(e.calc_length() for e in f.edges)
        innenradius = 2 * f.calc_area() / umfang if umfang else 0
        if innenradius - STEG_A / 2 >= MIN_LOCH / 2:
            loecher.append(f)
    bmesh.ops.inset_individual(bm, faces=loecher, thickness=STEG_A / 2, depth=0.0,
                               use_even_offset=False, use_relative_offset=False)
    bmesh.ops.delete(bm, geom=loecher, context='FACES')     # Innenflächen = Löcher
    aufraeumen(bm, min_insel=3)
    log(f"     {len(loecher):,} Löcher")
    bm_nach(bm, a)
    so = a.modifiers.new("Tiefe", 'SOLIDIFY')
    so.thickness = NETZ_TIEFE
    so.offset = NETZ_OFFSET
    so.use_even_offset = False                  # True erzeugt Spitzen an engen Zellecken
    so.use_rim = True
    so.use_quality_normals = True
    modifier_anwenden(a)
    log(f"     Lochnetz: {len(a.data.polygons):,} Faces")
    return a, None


def gitter(surf, augen_zentren, col):
    if GITTER_MODUS == "lochnetz":
        return gitter_lochnetz(surf, augen_zentren, col)
    log("4/5  Gitter (Lage A Waben, Lage B Dreiecke) …")
    quelle = gitter_quelle(surf, augen_zentren, col)

    # --- Lage A: Waben/Voronoi-artig (Dual Mesh einer irregulären Triangulierung)
    a = kopie(quelle, "Gitter_A", col)
    decimieren_auf(a, ZELLE_A)
    gn = a.modifiers.new("DualMesh", 'NODES')
    gn.node_group = dual_mesh_nodegroup()
    modifier_anwenden(a)
    wireframe(a, STEG_A, WIRE_OFFSET_A)
    log(f"     Lage A: {len(a.data.polygons):,} Faces")

    if not LAGE_B:
        bpy.data.objects.remove(quelle, do_unlink=True)
        return a, None

    # --- Lage B: nach innen versetzt, Dreiecksnetz
    b = kopie(quelle, "Gitter_B", col)
    versatz = STEG_A - GITTER_UEBERLAPP
    # dünne Bereiche (Ohrränder): dort keine Innenlage, sonst stößt sie auf der Gegenseite durch
    bm_s = bm_aus(surf)
    bvh_s = BVHTree.FromBMesh(bm_s)
    bm_s.free()
    min_dicke = 2 * (versatz + STEG_B) + 0.5
    bm = bm_aus(b)
    bm.normal_update()
    duenn = []
    for f in bm.faces:
        for v in f.verts:
            hit = bvh_s.ray_cast(v.co - v.normal * 0.05, -v.normal, min_dicke)[0]
            if hit is not None:
                duenn.append(f)
                break
    if duenn:
        log(f"     {len(duenn)} Faces in dünnen Bereichen ohne Innenlage")
        bmesh.ops.delete(bm, geom=duenn, context='FACES')
        aufraeumen(bm)
    for v in bm.verts:
        v.co -= v.normal * versatz
    bm_nach(bm, b)
    decimieren_auf(b, ZELLE_B)
    wireframe(b, STEG_B)
    log(f"     Lage B: {len(b.data.polygons):,} Faces")
    log(f"     Gesamtwandstärke Gitter ≈ {versatz + STEG_B:.1f} mm")

    bpy.data.objects.remove(quelle, do_unlink=True)
    return a, b


# =============================================================================
#  ZUSAMMENFÜHREN + EXPORT
# =============================================================================
def zusammenfuehren(objs, name, col):
    bm = bmesh.new()
    for o in objs:
        tmp = o.data.copy()
        tmp.transform(o.matrix_world)
        bm.from_mesh(tmp)
        bpy.data.meshes.remove(tmp)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    for o in objs:
        bpy.data.objects.remove(o, do_unlink=True)
    return neues_objekt(name, me, col)


def exportieren(ob, dateiname=None, unterordner=""):
    ziel = pfad(EXPORT_PFAD) or os.path.join(_basisordner(), "rhino_maske_komplett.stl")
    if dateiname:
        ziel = os.path.join(os.path.dirname(ziel), unterordner, dateiname)
    os.makedirs(os.path.dirname(ziel), exist_ok=True)
    pfad_out = ziel
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    try:                                              # Blender ≥ 4.1
        bpy.ops.wm.stl_export(filepath=pfad_out, export_selected_objects=True,
                              global_scale=1.0, apply_modifiers=True)
    except AttributeError:                            # Blender 4.0
        bpy.ops.export_mesh.stl(filepath=pfad_out, use_selection=True, global_scale=1.0)
    log(f"     STL exportiert: {pfad_out}")


def teilen(maske, col):
    """Zerlegt die Maske in ein Raster von Teilen, die in DRUCKRAUM passen.
    Wählt die Ausrichtung mit den wenigsten Teilen; Schnittflächen werden geschlossen."""
    import itertools
    bett = [d - DRUCKRAND for d in DRUCKRAUM]
    co = [v.co for v in maske.data.vertices]
    mn = Vector([min(c[i] for c in co) for i in range(3)])
    mx = Vector([max(c[i] for c in co) for i in range(3)])
    dim = mx - mn
    beste = None
    for perm in itertools.permutations(range(3)):           # Maskenachse i -> Druckerachse perm[i]
        n = [max(1, math.ceil(dim[i] / bett[perm[i]])) for i in range(3)]
        key = (n[0] * n[1] * n[2], n[2], perm != (0, 1, 2))
        if beste is None or key < beste[0]:
            beste = (key, perm, n)
    _, perm, n = beste
    gesamt = n[0] * n[1] * n[2]
    if gesamt == 1 and perm == (0, 1, 2):
        log("     Maske passt am Stück in den Druckraum")
        return [maske]
    # Drehung, die die Maskenachsen auf die Druckerachsen legt (det = +1)
    R = Matrix(((0.0,) * 3,) * 3)
    for i in range(3):
        R[perm[i]][i] = 1.0
    if R.determinant() < 0:
        R[perm[0]][0] = -1.0
    R = R.to_4x4()
    log(f"     Zerlege in {n[0]} x {n[1]} x {n[2]} = {gesamt} Teile "
        f"(Ausrichtung Maske XYZ -> Drucker {''.join('XYZ'[p] for p in perm)})")

    teile = []
    nr = 0
    for iz in range(n[2]):
        for iy in range(n[1]):
            for ix in range(n[0]):
                idx = (ix, iy, iz)
                bm = bmesh.new()
                bm.from_mesh(maske.data)
                for ax in range(3):
                    lo = mn[ax] + dim[ax] * idx[ax] / n[ax]
                    hi = mn[ax] + dim[ax] * (idx[ax] + 1) / n[ax]
                    nrm = Vector((0, 0, 0)); nrm[ax] = 1.0
                    if idx[ax] > 0:
                        p = Vector((0, 0, 0)); p[ax] = lo
                        bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:],
                                               dist=1e-4, plane_co=p, plane_no=nrm, clear_inner=True)
                    if idx[ax] < n[ax] - 1:
                        p = Vector((0, 0, 0)); p[ax] = hi
                        bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:],
                                               dist=1e-4, plane_co=p, plane_no=nrm, clear_outer=True)
                if not bm.faces:
                    bm.free()
                    continue
                for _ in range(4):                           # Schnittflächen schließen
                    rand = [e for e in bm.edges if e.is_boundary]
                    if not rand:
                        break
                    neu = bmesh.ops.holes_fill(bm, edges=rand, sides=0)["faces"]
                    bmesh.ops.triangulate(bm, faces=neu)
                    rest = [e for e in bm.edges if not e.is_manifold]
                    if not rest:
                        break
                    # Problemstellen: angrenzende Faces entfernen, Loch im nächsten Durchgang schließen
                    bmesh.ops.delete(bm, geom=list({f for e in rest for f in e.link_faces}),
                                     context='FACES')
                offen = sum(1 for e in bm.edges if not e.is_manifold)
                nr += 1
                me = bpy.data.meshes.new(f"Teil_{nr:02d}")
                bm.to_mesh(me)
                bm.free()
                me.transform(R)
                ob = neues_objekt(f"Rhino_Teil_{nr:02d}", me, col)
                d = ob.dimensions
                passt = all(d[i] <= DRUCKRAUM[i] for i in range(3))
                log(f"     Teil {nr:02d}: {d.x:.0f} x {d.y:.0f} x {d.z:.0f} mm"
                    f"{'' if passt else '  (!) passt NICHT'}"
                    f"{f', {offen} offene Kanten' if offen else ''}")
                teile.append(ob)
    for t in teile:
        t.location.x = 0
    return teile


def preset_anwenden():
    import sys
    name = PRESET
    if "--" in sys.argv[1:]:
        rest = sys.argv[sys.argv.index("--") + 1:]
        if rest:
            name = rest[0]
    if name in PRESETS:
        globals().update(PRESETS[name])
        log(f"Variante: {name}")
    elif name != "tragbar":
        raise RuntimeError(f"Unbekannte Variante '{name}' – möglich: tragbar, {', '.join(PRESETS)}")


def vollkoerper(surf, col):
    """Geschlossene Form: Modell mit planer Unterseite (für eine massive Figur)."""
    v = kopie(surf, "Rhino_Vollkoerper", col)
    bm = bm_aus(v)
    rand = [e for e in bm.edges if e.is_boundary]
    neu = bmesh.ops.holes_fill(bm, edges=rand, sides=0)["faces"]
    bmesh.ops.triangulate(bm, faces=neu)
    bm_nach(bm, v)
    return v


def main():
    global SKALIERUNG
    preset_anwenden()
    if not IMPORT_PFAD:
        SKALIERUNG = MASKE_HOEHE / _PROZ_HOEHE_S1 if MASKE_HOEHE > 0 else 1.0
    col = szene_vorbereiten()
    surf = basisform(col)
    if EXPORT_BASIS_STL:
        exportieren(surf, "rhino_basis_schritt1.stl", "stl")
    kopfoeffnung(surf)
    huelle = solide_huelle(surf, col)
    augen_ob, zentren = augen(surf, col)
    a, b = gitter(surf, zentren, col)
    k = kragen(surf, col)

    log("5/5  Zusammenführen …")
    maske = zusammenfuehren([o for o in (a, b, k, augen_ob) if o], "Rhino_Maske_LATTICE", col)
    if FINAL_VOXEL_FUSE > 0:
        log(f"     Voxel-Fusion mit {FINAL_VOXEL_FUSE} mm – das dauert …")
        rm = maske.modifiers.new("Fuse", 'REMESH')
        rm.mode = 'VOXEL'
        rm.voxel_size = FINAL_VOXEL_FUSE
        modifier_anwenden(maske)

    for o in (surf, huelle):
        o.hide_set(True)
        o.hide_render = True

    dim = maske.dimensions
    log(f"FERTIG – Maske {dim.x:.0f} x {dim.y:.0f} x {dim.z:.0f} mm, "
        f"{len(maske.data.polygons):,} Faces")
    if EXPORT_STL:
        exportieren(maske)
    if VOLLKOERPER and EXPORT_STL:
        exportieren(vollkoerper(surf, col), os.path.basename(pfad(EXPORT_PFAD)).replace("gitter", "massiv"))
    if TEILEN:
        log("6/6  Aufteilen für den Druckraum …")
        teile = teilen(maske, col)
        if EXPORT_STL and len(teile) > 1:
            for i, t in enumerate(teile, 1):
                exportieren(t, f"rhino_maske_teil_{i:02d}_von_{len(teile):02d}.stl", "stl")
            maske.hide_set(True)


if __name__ == "__main__":
    main()

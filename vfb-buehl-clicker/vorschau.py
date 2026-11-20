import numpy as np, trimesh, pyvista as pv, os, sys
pv.OFF_SCREEN=True
D=sys.argv[1]
PLATE_TOP=10.3; ZC=22.6   # aus build4: Plattenoberseite, Oberseite Deckscheibe der Kappe in Ruhe
def L(n): return trimesh.load(os.path.join(D,n))
def flip(m,ztop):
    m=m.copy(); m.apply_transform(trimesh.transformations.rotation_matrix(np.pi,[1,0,0])); m.apply_translation((0,0,ztop)); return m
def box(sx,sy,z0,z1,cx=0,cy=0):
    b=trimesh.creation.box((sx,sy,z1-z0)); b.apply_translation((cx,cy,(z0+z1)/2)); return b
def cyl(d,z0,z1,cx=0,cy=0):
    c=trimesh.creation.cylinder(d/2,z1-z0,sections=48); c.apply_translation((cx,cy,(z0+z1)/2)); return c
# Schalter-Attrappe MX (Maße: Platte->Pin 8,3; Gehäuse oben 6,6; Stößel oben 10,6)
sw=trimesh.boolean.union([
  box(13.9,13.9,PLATE_TOP-5.0,PLATE_TOP), box(15.6,15.6,PLATE_TOP,PLATE_TOP+6.6),
  cyl(4,PLATE_TOP-6.9,PLATE_TOP-5.0), cyl(1.5,PLATE_TOP-8.3,PLATE_TOP-5.0,-3.81,2.54), cyl(1.5,PLATE_TOP-8.3,PLATE_TOP-5.0,2.54,5.08),
  box(4.0,1.2,PLATE_TOP+6.6,PLATE_TOP+10.6), box(1.2,4.0,PLATE_TOP+6.6,PLATE_TOP+10.6)],engine='manifold')
sw.export(os.path.join(D,"schalter_attrappe_mx.stl"))
cup=L("becher_mit_oese.stl"); pent=L("becher_fuenfecke_schwarz.stl")
ins=flip(L("einsatz_schalterplatte.stl"),PLATE_TOP); cap=L("kappe_kolben_mit_zapfen.stl"); cap.apply_translation((0,0,ZC-5.7))
def logo(v):
    r=[]
    for c in ("schwarz","rot","weiss"):
        m=L(f"logoplatte_{v}.stl".replace("*",c) if False else (f"logoplatte_A_buendig_{c}.stl" if v=="A" else f"logoplatte_B_erhaben_{c}.stl")); m.apply_translation((0,0,ZC)); r.append((c,m))
    return r
# Kollisionsprüfung Schalter <-> Einsatz / Kappe
for n,m in (("Einsatz",ins),("Kappe",cap)):
    try:
        v=trimesh.boolean.intersection([m,sw],engine="manifold").volume
    except Exception as e: v=float("nan")
    print(f"Schalter-Attrappe/{n}: Überschneidung {v:.3f} mm³")
COL={"becher":(.93,.93,.93),"pent":(.08,.08,.08),"ins":(.75,.65,.25),"sw":(.2,.45,.85),"cap":(.45,.52,.66),"schwarz":(.08,.08,.08),"rot":(.85,.08,.08),"weiss":(.95,.95,.95)}
def add(pl,m,key,dz=0,clip=False,opacity=1.0):
    m=m.copy(); m.apply_translation((0,0,dz)); p=pv.wrap(m)
    if clip:
        try: p=p.clip_closed_surface(normal=(-1,0,0),origin=(0.01,0,0))
        except ValueError:
            print('nicht geschlossen, einfacher Schnitt:',key); p=p.clip(normal=(-1,0,0),origin=(0.01,0,0))
    pl.add_mesh(p,color=COL[key],smooth_shading=False,specular=0.3,opacity=opacity)
def scene(pl,dz,clip,variant="A"):
    add(pl,cup,"becher",0,clip); add(pl,pent,"pent",0,clip)
    add(pl,ins,"ins",dz[0],clip); add(pl,sw,"sw",dz[1],clip); add(pl,cap,"cap",dz[2],clip)
    for c,m in logo(variant): add(pl,m,c,dz[3],clip)
# 1) Schnitt, zusammengebaut mit Schalter
pl=pv.Plotter(window_size=(1600,1000)); pl.set_background("white")
scene(pl,(0,0,0,0),True); pl.camera_position=[(190,0,15),(0,0,13),(0,0,1)]; pl.enable_parallel_projection(); pl.camera.zoom(1.5)
pl.screenshot(os.path.join(D,"_prev_schnitt_schalter.png"))
# 2) Explosion (halb aufgeschnitten, beschriftet)
dz=(16,36,56,70)
pl=pv.Plotter(window_size=(1700,1200)); pl.set_background("white")
scene(pl,dz,True)
labels=[("Becher (Fußball-Muster, Öse)",(22,0,6)),("Einsatz mit Schalter-Aufnahme\n(14,1-mm-Ausschnitt)",(22,0,PLATE_TOP+dz[0]-4)),
        ("MX-Schalter (Attrappe)",(12,0,PLATE_TOP+dz[1]+4)),("Kappe mit Kreuz-Aufnahme\nfür den Stößel",(22,0,ZC+dz[2]-6)),("Logoplatte",(22,0,ZC+dz[3]+1))]
pl.add_point_labels(np.array([p for _,p in labels]),[t for t,_ in labels],font_size=18,point_size=1,shape=None,always_visible=True,text_color="black",show_points=False)
pl.camera_position=[(190,-20,50),(0,0,48),(0,0,1)]; pl.enable_parallel_projection(); pl.camera.parallel_scale=58
pl.screenshot(os.path.join(D,"_prev_explosion.png"))
# 3) Explosion ohne Schnitt
pl=pv.Plotter(window_size=(1600,1200)); pl.set_background("white")
scene(pl,dz,False)
pl.camera_position=[(120,-130,120),(0,0,45),(0,0,1)]; pl.camera.zoom(0.85)
pl.screenshot(os.path.join(D,"_prev_explosion_iso.png"))
# komplette Baugruppen als 3MF (nur zur Ansicht)
for v in ("A","B"):
    sc=trimesh.Scene()
    def put(n,m,key):
        m=m.copy(); m.visual.face_colors=np.array(list(COL[key])+[1.0])*255; sc.add_geometry(m,node_name=n,geom_name=n)
    put("becher",cup,"becher"); put("fuenfecke",pent,"pent"); put("einsatz",ins,"ins"); put("schalter",sw,"sw"); put("kappe",cap,"cap")
    for c,m in logo(v): put("logo_"+c,m,c)
    sc.export(os.path.join(D,f"clicker_komplett_{v}_zusammengebaut_nur_ansicht.3mf"))
# 4) Clips: Kappe von oben, Logoplatte von unten (Taschen)
plate=L("logoplatte_B_erhaben_schwarz.stl")           # Unterseite liegt bei z=0
pl=pv.Plotter(window_size=(1800,1000)); pl.set_background("white")
c=cap.copy(); c.apply_translation((-22,0,-ZC))
p=plate.copy(); p.apply_transform(trimesh.transformations.rotation_matrix(np.pi,[1,0,0])); p.apply_translation((22,0,2.0))   # Unterseite nach oben gedreht
pl.add_mesh(pv.wrap(c),color=COL["cap"],smooth_shading=False,specular=0.3); pl.add_mesh(pv.wrap(p),color=(.2,.2,.2),smooth_shading=False,specular=0.3)
pl.add_point_labels(np.array([(-22,-26,0),(22,-26,0)]),["Kappe mit zwei Clips","Logoplatte von unten: zwei Taschen"],font_size=18,point_size=1,shape=None,show_points=False,text_color="black",always_visible=True)
pl.camera_position=[(0,-80,100),(0,0,0),(0,0,1)]; pl.camera.zoom(1.05)
pl.screenshot(os.path.join(D,"_prev_clips.png"))
# 5) Schnitt durch einen Clip (Platte B + Kappe), Schnittebene durch die Nasenmitte quer zum Arm
import math
phi=math.radians(45); u=np.array([math.cos(phi),math.sin(phi),0]); cn=np.array([12.8*u[0],12.8*u[1],0])
pl=pv.Plotter(window_size=(1500,1000)); pl.set_background("white")
for m,col in ((cap,COL["cap"]),(plate,(.15,.15,.15))):
    mm=m.copy()
    if m is plate: mm.apply_translation((0,0,ZC))
    pp=pv.wrap(mm)
    try: pp=pp.clip_closed_surface(normal=tuple(-u),origin=tuple(cn))
    except ValueError: pp=pp.clip(normal=tuple(-u),origin=tuple(cn))
    pl.add_mesh(pp,color=col,smooth_shading=False)
vv=np.array([-u[1],u[0],0])
pl.camera_position=[tuple(cn+u*60+np.array([0,0,ZC+1.2])),tuple(cn+np.array([0,0,ZC+1.2])),(0,0,1)]
pl.enable_parallel_projection(); pl.camera.parallel_scale=4.2
pl.screenshot(os.path.join(D,"_prev_clip_schnitt.png"))

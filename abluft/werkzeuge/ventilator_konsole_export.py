import numpy as np, trimesh
from shapely.geometry import box, Point, Polygon
from shapely.ops import unary_union
W,L,T,TT,XS=120,120,5,2,95
sw,pitch,cx0=6,59,60
SLOT_LEN,GAP=12,54
YC=[L/2-GAP/2-SLOT_LEN/2,L/2+GAP/2+SLOT_LEN/2]
LEGS=[(0,19),(36,19),(65,19),(101,19)]
LH,LT,R=46,5,9
NAF,NH=7.2,3.4
sd,cd=5.5,10; sz=[-18,-34]
def B(x0,x1,y0_,y1_,z0,z1):
    m=trimesh.creation.box(extents=[x1-x0,y1_-y0_,z1-z0]); m.apply_translation([(x0+x1)/2,(y0_+y1_)/2,(z0+z1)/2]); return m
def U(a,b): return a.union(b,engine='manifold')
def D(a,b): return a.difference(b,engine='manifold')
m=U(B(0,XS,0,L,-T,0),B(XS-0.01,W,0,L,-TT,0))
M=np.eye(4); M[:3,:3]=[[0,0,1],[1,0,0],[0,1,0]]
def tear(d):
    r=d/2
    pts=[(r*np.cos(a),r*np.sin(a)) for a in np.linspace(0,2*np.pi,64,endpoint=False)]+[(0,-r*np.sqrt(2))]
    from shapely.geometry import MultiPoint
    return MultiPoint(pts).convex_hull
def hole(yc,z,d,x0,length):
    e=trimesh.creation.extrude_polygon(tear(d),length); e.apply_transform(M); e.apply_translation([x0,yc,z]); return e
def csk(yc,z):
    pts=[]
    for d,x in ((cd,XS-LT-0.01),(sd,XS-LT+2.5)):
        for (py,pz) in tear(d).exterior.coords: pts.append([x,yc+py,z+pz])
    return trimesh.convex.convex_hull(np.array(pts))
def leg(ys,LL):
    inner=box(R,-LH+R,LL-R,-0).buffer(0)  # placeholder
    rr=box(R,-LH+R,LL-R,-20).buffer(R)
    poly=unary_union([rr,box(0,-20,LL,0)]).intersection(box(0,-LH,LL,0))
    g=trimesh.creation.extrude_polygon(poly,LT); g.apply_transform(M); g.apply_translation([XS-LT,ys,0]); 
    for z in sz:
        g=D(g,hole(ys+LL/2,z,sd,XS-LT-0.01,LT+0.02))
        g=D(g,csk(ys+LL/2,z))
    return g
from shapely.affinity import scale as sc
A,RT=70,4
def ribs(ys,LL):
    prof=box(XS-LT-A,-LH,XS-LT,-T).difference(sc(Point(XS-LT-A,-LH).buffer(1,128),A,LH-T,origin=(XS-LT-A,-LH)))
    r=trimesh.creation.extrude_polygon(prof,RT)
    r.apply_transform(trimesh.transformations.rotation_matrix(np.pi/2,[1,0,0]))   # z->-y
    out=[]
    leg2=unary_union([box(R,-LH+R,LL-R,-20).buffer(R),box(0,-20,LL,0)]).intersection(box(0,-LH,LL,0))
    clip=trimesh.creation.extrude_polygon(leg2,W); clip.apply_transform(M); clip.apply_translation([0,ys,0])
    for off in (0,LL-RT):
        g=r.copy(); g.apply_translation([0,ys+off+RT,0]); out.append(g.intersection(clip,engine='manifold'))
    return out
for ys,LL in LEGS:
    m=U(m,leg(ys,LL))
    for g in ribs(ys,LL): m=U(m,g)
for cx in (cx0-pitch/2,cx0+pitch/2):
    for yc in YC:
        p=Point(cx,yc)
        s=unary_union([Point(cx,yc-(SLOT_LEN-sw)/2).buffer(sw/2),Point(cx,yc+(SLOT_LEN-sw)/2).buffer(sw/2),box(cx-sw/2,yc-(SLOT_LEN-sw)/2,cx+sw/2,yc+(SLOT_LEN-sw)/2)])
        e=trimesh.creation.extrude_polygon(s,T+2); e.apply_translation([0,0,-T-1]); m=D(m,e)
        Rn=NAF/np.sqrt(3); hx=lambda dy:[(cx+Rn*np.cos(np.radians(90+60*k)),yc+dy+Rn*np.sin(np.radians(90+60*k))) for k in range(6)]
        from shapely.geometry import MultiPoint
        h=MultiPoint(hx(-(SLOT_LEN-sw)/2)+hx((SLOT_LEN-sw)/2)).convex_hull
        p=trimesh.creation.extrude_polygon(h,NH+0.01); p.apply_translation([0,0,-T-0.01]); m=D(m,p)
m.apply_transform(trimesh.transformations.rotation_matrix(np.pi,[1,0,0])); m.apply_translation([0,L,0])
m.export('../ventilator_konsole/ventilator_konsole.stl')
m.export('../ventilator_konsole/ventilator_konsole.3mf')
print(m.is_watertight, m.bounds.tolist(), round(m.volume/1000,2),'cm3')

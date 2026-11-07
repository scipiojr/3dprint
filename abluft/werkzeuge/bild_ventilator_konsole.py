import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyBboxPatch, Polygon
fig,ax=plt.subplots(1,2,figsize=(15,7.5),gridspec_kw={'width_ratios':[1.1,1]})
# Draufsicht
a=ax[0]; a.set_aspect('equal'); a.set_title('Draufsicht (X = Breite zur Wand, Y = Länge)')
a.add_patch(Rectangle((0,0),120,120,fc='#dde6f0',ec='k'))
a.add_patch(Rectangle((95,0),25,120,fc='#b9c9dc',ec='k'))
a.axvline(95,color='r',ls='--',lw=1)
for cx in (30.5,89.5):
    for yc in (27,93):
        if False: a.add_patch(Polygon([(cx-3.6,yc-3-2.08),(cx,yc-3-4.16),(cx+3.6,yc-3-2.08),(cx+3.6,yc+3+2.08),(cx,yc+3+4.16),(cx-3.6,yc+3+2.08)],fc='none',ec='gray',ls='--',lw=.8))
        a.add_patch(FancyBboxPatch((cx-3,yc-6),6,12,boxstyle='round,pad=0,rounding_size=3',fc='w',ec='k'))
for ys,w in ((0,19),(36,19),(65,19),(101,19)):
    a.add_patch(Rectangle((90,ys),5,w,fc='#e8b0a0',ec='k',alpha=.8))
    for off in (0,w-4): a.add_patch(Rectangle((20,ys+off),70,4,fc='#e8b0a0',ec='k',alpha=.6,ls=':'))
def dim(ax_,p,q,txt,off=(0,0),**k): ax_.annotate('',p,q,arrowprops=dict(arrowstyle='<->',lw=.8)); ax_.text((p[0]+q[0])/2+off[0],(p[1]+q[1])/2+off[1],txt,ha='center',va='center',fontsize=8,bbox=dict(fc='w',ec='none',pad=.5))
dim(a,(0,-8),(120,-8),'120'); dim(a,(0,-16),(95,-16),'95 (dick 5 mm)'); dim(a,(95,-24),(120,-24),'25 (dünn 2 mm)')
dim(a,(-8,0),(-8,120),'120',(-3,0))
dim(a,(27.5,128),(92.5,128),'65 außen'); dim(a,(33.5,122),(86.5,122),'53 innen',(0,-0))
dim(a,(131,33),(131,87),'54'); dim(a,(138,21),(138,33),'12',(0,0)); a.text(145,27,'Langloch\n6 × 12\n(ohne Mutterntasche,\nliegt zwischen den\nTrägerhälften)',fontsize=7)
dim(a,(-18,0),(-18,19),'Träger 19'); dim(a,(-18,36),(-18,55),'19'); dim(a,(-26,19),(-26,36),'17 Lücke');
a.text(100,-34,'Wandanlage bei X=95 (rot)',color='r',fontsize=8)
a.set_xlim(-30,160); a.set_ylim(-40,138); a.axis('off')
# Seitenansicht
b=ax[1]; b.set_aspect('equal'); b.set_title('Seitenansicht (Z nach unten, Oberseite = 0)')
b.add_patch(Polygon([(0,0),(120,0),(120,-2),(95,-2),(95,-5),(0,-5)],fc='#dde6f0',ec='k'))
b.add_patch(Rectangle((90,-46),5,41,fc='#e8b0a0',ec='k'))
import numpy as np
t=np.linspace(0,np.pi/2,60); ex=20+70*np.cos(t); ez=-46+41*np.sin(t)
b.add_patch(Polygon([(55,-5),(90,-5),(90,-46)]+list(zip(ex[::-1][:0],ez[::-1][:0]))+[(x,z) for x,z in zip(ex,ez)][::-1][::-1][:0],fc='none',ec='none'))
b.fill(list(ex)+[90,55],list(ez)+[-46,-46],alpha=0)
b.fill([90]+list(ex[::-1])+[55,90][:0],[-46]+list(ez[::-1]),alpha=0)
b.fill(list(ex)+[90],list(ez)+[-5],fc='#e8b0a0',ec='k',alpha=.6)
b.text(30,-30,'Rippe\nR=70×41\n(Auskragung)',fontsize=7)
b.axvline(95,color='r',ls='--',lw=1)
b.add_patch(Rectangle((95,-60),40,58,fc='#cccccc',ec='k',hatch='//',alpha=.5)); b.text(115,-30,'Wand',ha='center')
for z in (-18,-34): b.plot([90,95],[z,z],'k',lw=1.2); b.text(86,z,f'Ø5,5\nSenkung',ha='right',va='center',fontsize=7)
dim(b,(-8,0),(-8,-5),'5',(-4,0)); dim(b,(125,0),(125,-2),'2',(5,0)); dim(b,(99,0),(99,-46),'46',(4,0))
dim(b,(0,6),(95,6),'95'); dim(b,(95,12),(120,12),'25')
b.set_xlim(-20,140); b.set_ylim(-62,20); b.axis('off')
plt.tight_layout(); plt.savefig('../bilder/ventilator_konsole.png',dpi=130)

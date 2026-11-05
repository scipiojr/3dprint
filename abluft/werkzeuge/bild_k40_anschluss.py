"""Draufsicht/Seitenansicht des K40-Anschlusses mit Filterkasten (Schnitt auf Achshoehe).
Aufruf (aus abluft/):  python3 -I werkzeuge/bild_k40_anschluss.py [box_assembly.stl] [-D name=wert ...]  (z.B. -D aus_yaw=30)
box_assembly.stl: openscad -o /tmp/box_assembly.stl -D 'auswahl="assembly"' abluft_filterkasten.scad
"""
import sys, re, subprocess, tempfile, os
import numpy as np, trimesh, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

args = sys.argv[1:]
box_stl = "/tmp/box_assembly.stl"
if args and not args[0].startswith("-D"): box_stl = args.pop(0)
defs = []
while args:
    a_ = args.pop(0)
    if a_ == "-D": defs += ["-D", args.pop(0)]
    elif a_.startswith("-D"): defs += ["-D", a_[2:]]
tmp = tempfile.mkdtemp(); k_stl = os.path.join(tmp, "k.stl")
log = subprocess.run(["openscad", "-o", k_stl, "-D", 'ausgabe="montiert"'] + defs + ["abluft_k40_anschluss.scad"],
                     capture_output=True, text=True).stderr
def par(name):  # Parameter aus der SCAD lesen
    for l in open("abluft_k40_anschluss.scad"):
        if l.startswith(name + " ") or l.startswith(name + "="):
            return float(l.split("=")[1].split(";")[0])
x_ax, kw, sue, sfr = [par(n) for n in ["x_ax", "kasten_w", "scharnier_ueber", "scharnier_frei"]]
muffe_l = 20.0; y_ax = kw/2 + sue + sfr
for d in defs:
    if d.startswith("muffe_l="): muffe_l = float(d.split("=")[1])
    if d.startswith("scharnier_frei="): y_ax = kw/2 + sue + float(d.split("=")[1])
m_ = re.search(r'ENDE E=\[([^\]]*)\] T=\[([^\]]*)\] U=\[([^\]]*)\] V=\[([^\]]*)\]', log)
E, T, U, V = [np.array([float(x) for x in g.split(",")]) for g in m_.groups()]
Rm = np.column_stack([T, np.cross(V, T), V]); T4 = np.eye(4); T4[:3, :3] = Rm
yc, zc = 84.9, 80.35                       # Kastenachse (box_w/2, box_box_wall + inner_h/2)
k = trimesh.load(k_stl); box = trimesh.load(box_stl)
fig, ax = plt.subplots(1, 2, figsize=(15, 8), gridspec_kw={"width_ratios": [1.6, 1]})
def sec(a, m, n, o, i, j, **kw_):
    s = m.section(plane_origin=o, plane_normal=n)
    lab = kw_.pop("label", None)
    for n_, e in enumerate(s.entities):
        p = s.vertices[e.points]; a.plot(p[:, i], p[:, j], label=lab if n_ == 0 else None, **kw_)
for ins, col in [(20, "#2a9d8f"), (15, "#e9a23b"), (10, "#c0392b")]:
    m = box.copy(); m.apply_translation([70.0, -yc, -zc]); m.apply_transform(T4)
    m.apply_translation(E + T*(muffe_l + 0.07 - ins))
    sec(ax[0], m, [0, 0, 1], [0, 0, 0], 0, 1, color=col, lw=1.0 if ins != 15 else 1.4, label=f"Kasten, Einstecktiefe {ins} mm")
sec(ax[0], k, [0, 0, 1], [0, 0, 0], 0, 1, color="k", lw=1.6)
ax[0].axhline(0, color="#555", lw=3, alpha=.4); ax[0].text(70, -9, "Rückwand K40+", ha="right", fontsize=9, color="#555")
ax[0].axvline(-62, color="#888", ls=":", lw=1); ax[0].text(-62, 215, "Ausschnittkante\nx = -62", ha="center", fontsize=8, color="#666")
ax[0].annotate("", (-95, 0), (-95, y_ax), arrowprops=dict(arrowstyle="<->")); ax[0].text(-98, y_ax/2, f"Achse {y_ax:.1f}", rotation=90, va="center", ha="right", fontsize=9)
ax[0].set_xlim(100, -300); ax[0].set_ylim(-20, 260); ax[0].set_aspect("equal"); ax[0].grid(alpha=.25)
ax[0].set_title("Draufsicht (Schnitt auf Achshöhe), x nach rechts = Laserseite →  Strömung nach links"); ax[0].legend(loc="lower left", fontsize=8, framealpha=.9)
ax[0].set_xlabel("x [mm] (von hinten auf den Laser gesehen, + = rechts)"); ax[0].set_ylabel("y [mm] Abstand von der Rückwand")
sec(ax[1], k, [1, 0, 0], [x_ax, 0, 0], 1, 2, color="k", lw=1.6)
ax[1].set_title("Schnitt x = %g (Seitenansicht, Rückwand links)" % x_ax); ax[1].set_aspect("equal"); ax[1].grid(alpha=.25)
ax[1].set_xlabel("y [mm]"); ax[1].set_ylabel("z [mm] (0 = Plattenmitte)")
plt.tight_layout(); os.makedirs("bilder", exist_ok=True); plt.savefig("bilder/k40_anschluss.png", dpi=80)
print("ok bilder/k40_anschluss.png")

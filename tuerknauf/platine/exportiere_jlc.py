# Erzeugt das JLCPCB-Paket (Gerber-ZIP, BOM, CPL) für eine Platine: python3 exportiere_jlc.py <name>
import sys, os, csv, subprocess, shutil, collections, re
name = sys.argv[1]; pcb = f"{name}.kicad_pcb"; out = f"jlcpcb_{name}"; g = f"{out}/gerber"
shutil.rmtree(out, ignore_errors=True); os.makedirs(g)
run = lambda *a: subprocess.run(["kicad-cli", "pcb", "export", *a, pcb], check=True, capture_output=True)
run("gerbers", "-o", g + "/", "-l", "F.Cu,B.Cu,F.Mask,B.Mask,F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,Edge.Cuts", "--subtract-soldermask")
run("drill", "-o", g + "/", "--format", "excellon", "--excellon-separate-th", "--drill-origin", "absolute", "--excellon-units", "mm")
run("pos", "-o", f"{out}/pos.csv", "--side", "front", "--format", "csv", "--units", "mm")
shutil.make_archive(f"{out}/{name}_gerber", "zip", g); shutil.rmtree(g)
rows = list(csv.DictReader(open(f"{out}/pos.csv"))); os.remove(f"{out}/pos.csv")
with open(f"{out}/CPL_{name}.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerow(["Designator", "Mid X", "Mid Y", "Layer", "Rotation"])
    for r in rows: w.writerow([r["Ref"], r["PosX"] + "mm", r["PosY"] + "mm", "Top", f'{float(r["Rot"]) % 360:.1f}'])
# LCSC-Nummern aus den Footprint-Eigenschaften der Platinendatei
txt = open(pcb).read(); teile = collections.OrderedDict()
for blk in re.split(r'\n  \(footprint ', txt)[1:]:
    ref = re.search(r'\(property "Reference" "([^"]+)"', blk) or re.search(r'fp_text reference "([^"]+)"', blk)
    val = re.search(r'\(property "Value" "([^"]+)"', blk) or re.search(r'fp_text value "([^"]+)"', blk)
    lcsc = re.search(r'\(property "LCSC" "([^"]+)"', blk)
    if not lcsc: continue
    fpn = blk.split('"')[1].split(":")[-1]
    teile.setdefault((val.group(1), fpn, lcsc.group(1)), []).append(ref.group(1))
with open(f"{out}/BOM_{name}.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerow(["Comment", "Designator", "Footprint", "LCSC Part #"])
    for (val, fpn, lcsc), refs in teile.items(): w.writerow([val, ",".join(sorted(refs)), fpn, lcsc])
print(open(f"{out}/BOM_{name}.csv").read(), open(f"{out}/CPL_{name}.csv").read())

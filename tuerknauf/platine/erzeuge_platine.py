# Sensorplatine für den Schlüsselknauf: 2x DRV5012 (Hall-Latch) + 2x 100 nF, 4 Lötaugen.
# Koordinaten im Plattensystem (mm): Ursprung = Knaufachse, x rechts, y oben (von vorne gesehen).
import math, os, pcbnew
HIER = os.path.dirname(os.path.abspath(__file__))
from pcbnew import FromMM, VECTOR2I

R_IN, R_OUT, XCLIP, YTOP = 16.4, 21.3, 16.2, -10.0
R_CHIP, R_J = 19.8, 18.0
A_U1, A_U2 = 225.0, 315.0

def P(x, y):                      # Plattenkoordinaten -> KiCad (y nach unten)
    return VECTOR2I(FromMM(x), FromMM(-y))
def pol(r, a):
    return (r*math.cos(math.radians(a)), r*math.sin(math.radians(a)))

board = pcbnew.BOARD()
ds = board.GetDesignSettings()
ds.SetCopperLayerCount(2)
ds.SetBoardThickness(FromMM(1.6))   # AISLER 2 Lagen gibt es nur in 1,6 mm
ds.m_TrackMinWidth = FromMM(0.127)
ds.m_MinClearance = FromMM(0.127)
ds.m_ViasMinSize = FromMM(0.5)
ds.m_MinThroughDrill = FromMM(0.3)
ds.m_CopperEdgeClearance = FromMM(0.3)
ds.m_HoleToHoleMin = FromMM(0.25)

nc = ds.m_NetSettings.m_DefaultNetClass
nc.SetClearance(FromMM(0.127)); nc.SetTrackWidth(FromMM(0.15)); nc.SetViaDiameter(FromMM(0.55)); nc.SetViaDrill(FromMM(0.3))
ds.m_SolderMaskMinWidth = FromMM(0.0)
nets = {}
for n in ("VCC", "GND", "A", "B"):
    ni = pcbnew.NETINFO_ITEM(board, n); board.Add(ni); nets[n] = ni

# ---------- Umriss: Kreisringsegment, seitlich bei |x|=16,2 und oben bei y=-10 begrenzt ----------
def inside(x, y):
    r = math.hypot(x, y)
    return R_IN - 1e-9 <= r <= R_OUT + 1e-9 and abs(x) <= XCLIP + 1e-9 and y <= YTOP + 1e-9
pts = []
# außen: von links (x=-16,2) nach rechts
a0 = math.degrees(math.atan2(-math.sqrt(R_OUT**2 - XCLIP**2), -XCLIP)) % 360   # ~218,9°
a1 = 360 - (a0 - 180)                                                          # ~321,1°
n = 60
for i in range(n + 1):
    a = a0 + (a1 - a0) * i / n; pts.append(pol(R_OUT, a))
pts.append((XCLIP, YTOP))
xi = math.sqrt(R_IN**2 - YTOP**2)                                              # 13,0
ai1 = math.degrees(math.atan2(YTOP, xi)) % 360                                 # ~322,4°
ai0 = math.degrees(math.atan2(YTOP, -xi)) % 360                                # ~217,6°
for i in range(n + 1):
    a = ai1 - (ai1 - ai0) * i / n; pts.append(pol(R_IN, a))
pts.append((-XCLIP, YTOP))
UMRISS = pts
for i in range(len(pts)):
    s = pcbnew.PCB_SHAPE(board); s.SetShape(pcbnew.SHAPE_T_SEGMENT)
    s.SetStart(P(*pts[i])); s.SetEnd(P(*pts[(i+1) % len(pts)]))
    s.SetLayer(pcbnew.Edge_Cuts); s.SetWidth(FromMM(0.05)); board.Add(s)

# ---------- Footprints ----------
def drv5012(ref, r, a, dreh=0):
    """X2SON-4 (DMR0004A) 1,1x1,4 mm. Pins an den Längsseiten: 1 oben-links, 2 unten-links, 3 unten-rechts, 4 oben-rechts.
    Footprint-+y zeigt radial nach außen, +x tangential (im Uhrzeigersinn)."""
    fp = pcbnew.FOOTPRINT(board); fp.SetReference(ref); fp.SetValue("DRV5012AEDMRR"); fp.SetAttributes(pcbnew.FP_SMD)
    fp.SetProperty("MPN", "DRV5012AEDMRR"); fp.SetProperty("MFG", "Texas Instruments"); fp.SetProperty("LCSC", "C2655038")
    fp.SetFPID(pcbnew.LIB_ID("schloss", "TI_X2SON-4-1EP_1.1x1.4mm_P0.5mm"))
    fp.Reference().SetVisible(False); fp.Value().SetVisible(False)
    for num, (px, py) in {"1": (-0.53, 0.25), "2": (-0.53, -0.25), "3": (0.53, -0.25), "4": (0.53, 0.25)}.items():
        pd = pcbnew.PAD(fp); pd.SetNumber(num); pd.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
        pd.SetShape(pcbnew.PAD_SHAPE_ROUNDRECT); pd.SetRoundRectRadiusRatio(0.2)
        pd.SetSize(VECTOR2I(FromMM(0.40), FromMM(0.22))); pd.SetLayerSet(pd.SMDMask())
        q = VECTOR2I(FromMM(px), FromMM(-py)); pd.SetPos0(q); pd.SetPosition(q); fp.Add(pd)
    ep = pcbnew.PAD(fp); ep.SetNumber("5"); ep.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
    ep.SetShape(pcbnew.PAD_SHAPE_RECT); ep.SetSize(VECTOR2I(FromMM(0.35), FromMM(0.70)))
    ep.SetLayerSet(ep.SMDMask()); ep.SetPos0(VECTOR2I(0, 0)); ep.SetPosition(VECTOR2I(0, 0)); fp.Add(ep)
    # Bestückungsrahmen + Pin-1-Punkt im Bestückungsdruck (Fab)
    board.Add(fp)
    x, y = pol(r, a)
    fp.SetPosition(P(x, y))
    fp.SetOrientationDegrees(a - 90 + dreh)      # dreh=0: Footprint-+y radial nach außen
    return fp

def kondensator(ref, r, a, innen=False):
    fp = pcbnew.FootprintLoad("/usr/share/kicad/footprints/Capacitor_SMD.pretty", "C_0402_1005Metric")
    fp.SetReference(ref); fp.SetValue("100nF"); fp.SetProperty("MPN", "CL05B104KO5NNNC"); fp.SetProperty("MFG", "Samsung Electro-Mechanics"); fp.SetProperty("LCSC", "C1525"); fp.Reference().SetVisible(False); fp.Value().SetVisible(False)
    board.Add(fp)
    x, y = pol(r, a); fp.SetPosition(P(x, y))
    fp.SetOrientationDegrees(a if innen else a + 180)     # Pad 1 (VCC) radial außen bzw. innen
    return fp

def loetaugen(ref, r, a):
    fp = pcbnew.FOOTPRINT(board); fp.SetReference(ref); fp.SetValue("Kabel"); fp.SetAttributes(pcbnew.FP_THROUGH_HOLE | pcbnew.FP_EXCLUDE_FROM_BOM | pcbnew.FP_EXCLUDE_FROM_POS_FILES)
    fp.SetFPID(pcbnew.LIB_ID("schloss", "Loetaugen_2x2_P1.0mm_D0.5mm"))
    fp.Reference().SetVisible(False); fp.Value().SetVisible(False)
    lay = {"1": (0.5, -0.5), "2": (-0.5, 0.5), "3": (-0.5, -0.5), "4": (0.5, 0.5)}   # in Plattenachsen
    for num, (dx, dy) in lay.items():
        pd = pcbnew.PAD(fp); pd.SetNumber(num); pd.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
        pd.SetShape(pcbnew.PAD_SHAPE_RECT if num == "1" else pcbnew.PAD_SHAPE_CIRCLE)
        pd.SetSize(VECTOR2I(FromMM(0.8), FromMM(0.8))); pd.SetDrillSize(VECTOR2I(FromMM(0.5), FromMM(0.5)))
        pd.SetLayerSet(pd.PTHMask())
        q = VECTOR2I(FromMM(dx), FromMM(-dy)); pd.SetPos0(q); pd.SetPosition(q); fp.Add(pd)
    board.Add(fp)
    cx, cy = pol(r, a); fp.SetPosition(P(cx, cy))
    return fp, (cx, cy)

U1 = drv5012("U1", R_CHIP, A_U1)            # Pins 1/4 außen, 1/2 zur Mitte
U2 = drv5012("U2", R_CHIP, A_U2, 180)       # gedreht: Pins 1/2 zur Mitte, 1 innen, 2 außen
C1 = kondensator("C1", R_CHIP, A_U1 + 4.4)
C2 = kondensator("C2", R_CHIP, A_U2 - 4.4, innen=True)
J1, JC = loetaugen("J1", R_J, A_U1)

def setnet(fp, num, net):
    for pd in fp.Pads():
        if pd.GetNumber() == num: pd.SetNet(nets[net])
for U, out in ((U1, "A"), (U2, "B")):
    setnet(U, "1", "VCC"); setnet(U, "2", "GND"); setnet(U, "3", out); setnet(U, "4", "GND")
for C in (C1, C2):
    setnet(C, "1", "VCC"); setnet(C, "2", "GND")
for num, net in {"1": "VCC", "2": "GND", "3": "A", "4": "B"}.items():
    setnet(J1, num, net)

def padpos(fp, num):
    for pd in fp.Pads():
        if pd.GetNumber() == num:
            p = pd.GetPosition(); return (pcbnew.ToMM(p.x), -pcbnew.ToMM(p.y))
def spur(a, b, net, layer=pcbnew.F_Cu, w=0.15):
    t = pcbnew.PCB_TRACK(board); t.SetStart(P(*a)); t.SetEnd(P(*b)); t.SetWidth(FromMM(w))
    t.SetLayer(layer); t.SetNet(nets[net]); board.Add(t)
def via(p, net):
    v = pcbnew.PCB_VIA(board); v.SetPosition(P(*p)); v.SetDrill(FromMM(0.3)); v.SetWidth(FromMM(0.55))
    v.SetNet(nets[net]); v.SetViaType(pcbnew.VIATYPE_THROUGH); board.Add(v)
def bogen(r, a0, a1, net, layer=pcbnew.F_Cu, start=None, ende=None):
    n = max(2, int(abs(a1 - a0) / 2)); pts = [pol(r, a0 + (a1 - a0) * i / n) for i in range(n + 1)]
    if start: pts = [start] + pts
    if ende: pts = pts + [ende]
    for p, q in zip(pts, pts[1:]): spur(p, q, net, layer)

# --- U1 / C1 ---
spur(padpos(U1, "1"), padpos(C1, "1"), "VCC")
spur(padpos(U1, "2"), padpos(C1, "2"), "GND")
g1 = pol(18.75, 231.5); via(g1, "GND"); spur(padpos(C1, "2"), g1, "GND")
spur(padpos(U1, "3"), padpos(J1, "3"), "A")
g2 = pol(20.55, 221.5); via(g2, "GND"); spur(padpos(U1, "4"), g2, "GND")
# --- U2 / C2 ---
spur(padpos(U2, "1"), padpos(C2, "1"), "VCC")
spur(padpos(U2, "2"), padpos(C2, "2"), "GND")
g3 = pol(20.6, A_U2 - 6.6); via(g3, "GND"); spur(padpos(C2, "2"), g3, "GND")
g4 = pol(18.4, A_U2 + 5.5); via(g4, "GND"); spur(padpos(U2, "4"), g4, "GND")
vb = pol(20.35, A_U2 + 3.6); via(vb, "B"); spur(padpos(U2, "3"), vb, "B")
# --- VCC-Bahn oben: C1 außen (r 20,65) -> Mitte -> innen (r 18,3) -> C2 ---
bogen(20.65, A_U1 + 5.5, 266, "VCC", start=padpos(C1, "1"))
bogen(18.3, 274, A_U2 - 6.0, "VCC", start=pol(20.65, 266), ende=padpos(C2, "1"))
# --- J1 VCC: unten zu einem Via in der Mitte, oben radial zur VCC-Bahn ---
v1 = pol(18.0, 234.5); via(v1, "VCC")
bogen(18.0, 227.2, 234.5, "VCC", layer=pcbnew.B_Cu, start=padpos(J1, "1"))
spur(v1, pol(20.65, 234.5), "VCC")
# --- B unten: von U2 radial nach innen, Bogen r=16,95 bis Lötauge B ---
rb = 16.95
p = pol(rb, A_U2 + 4.0); spur(vb, p, "B", pcbnew.B_Cu)
bogen(rb, A_U2 + 4.0, 227.0, "B", layer=pcbnew.B_Cu, start=None, ende=padpos(J1, "4"))

# ---------- Flächen: oben VCC, unten GND ----------
def flaeche(net, layer, prio):
    z = pcbnew.ZONE(board); z.SetLayer(layer); z.SetNet(nets[net]); z.SetAssignedPriority(prio)
    z.SetLocalClearance(FromMM(0.15)); z.SetMinThickness(FromMM(0.15))
    z.SetThermalReliefGap(FromMM(0.2)); z.SetThermalReliefSpokeWidth(FromMM(0.2))
    z.SetPadConnection(pcbnew.ZONE_CONNECTION_THERMAL)
    o = z.Outline(); o.NewOutline()
    for x, y in UMRISS:
        q = P(x, y); o.Append(q.x, q.y)
    board.Add(z)
flaeche("GND", pcbnew.B_Cu, 0)


# Pin-1-Markierung (Punkt im Bestückungsdruck) neben Pin 1 der Sensoren
for U in (U1, U2):
    p1 = padpos(U, "1"); c = padpos(U, "2")
    d = (p1[0]-c[0], p1[1]-c[1]); L = math.hypot(*d); m = (p1[0] + d[0]/L*0.5, p1[1] + d[1]/L*0.5)
    k = pcbnew.PCB_SHAPE(board); k.SetShape(pcbnew.SHAPE_T_CIRCLE); k.SetCenter(P(*m)); k.SetEnd(P(m[0]+0.1, m[1]))
    k.SetLayer(pcbnew.F_SilkS); k.SetWidth(FromMM(0.15)); k.SetFilled(True); board.Add(k)

# ---------- Beschriftung (Bestückungsdruck oben) ----------
def text(s, x, y, h=0.8, layer=pcbnew.F_SilkS, ang=0):
    t = pcbnew.PCB_TEXT(board); t.SetText(s); t.SetPosition(P(x, y)); t.SetLayer(layer)
    t.SetTextSize(VECTOR2I(FromMM(h), FromMM(h))); t.SetTextThickness(FromMM(0.15)); t.SetTextAngleDegrees(ang)
    if layer == pcbnew.B_SilkS: t.SetMirrored(True)
    board.Add(t)
text("SCHLOSS v1", *pol(19.5, 252), h=0.8, ang=-18)
text("1=V 2=G 3=A 4=B", *pol(19.0, 253), h=0.8, layer=pcbnew.B_SilkS, ang=-17)

pcbnew.SaveBoard(os.path.join(HIER, "schloss_sensor.kicad_pcb"), board)
board = pcbnew.LoadBoard(os.path.join(HIER, "schloss_sensor.kicad_pcb"))
board.BuildConnectivity()
filler = pcbnew.ZONE_FILLER(board); filler.Fill(board.Zones())
pcbnew.SaveBoard(os.path.join(HIER, "schloss_sensor.kicad_pcb"), board)
pcbnew.WriteDRCReport(board, os.path.join(HIER, "schloss_sensor_drc.txt"), pcbnew.EDA_UNITS_MILLIMETRES, True)
fps={f.GetReference():f for f in board.GetFootprints()}
U1,U2,J1=fps["U1"],fps["U2"],fps["J1"]
for ref, fp in (("U1", U1), ("U2", U2)):
    print(ref, {pd.GetNumber(): tuple(round(v, 3) for v in padpos(fp, pd.GetNumber())) for pd in fp.Pads()})
print("J1", JC, {pd.GetNumber(): tuple(round(v,3) for v in padpos(J1, pd.GetNumber())) for pd in J1.Pads()})

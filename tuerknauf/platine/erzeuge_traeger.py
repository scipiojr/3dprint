# Trägerplatine für den Seeed XIAO ESP32C6 (wird flach aufgelötet, Randkontakte + 2 Durchlötbohrungen)
# mit schaltbarem Akku-Spannungsteiler, RGB-Status-LED, Reset-Taster und Lötaugen für Akku und Sensorkabel.
#
# Koordinaten in mm, von vorne gesehen: Ursprung = Mitte des XIAO, x rechts, y oben (zum Knauf).
# Der XIAO liegt mit den Bauteilen nach vorne auf der Trägerplatine, USB-C zeigt nach unten (-y).
#
# Schaltung:
#   VBAT ─┬──────────── S  Q2 AO3401A (P)  D ──┬── R1 100k ──┬── A0 (D0)      R2 100k / C3 100n nach GND
#         R3 1M               G                │             │
#         └───────────────────┴── D  Q1 2N7002 └── RGB-LED-Anode, Kathoden über R5 330 / R6 100 / R7 100
#                                     G ── D3 (R4 1M nach GND)       an D8 (rot) / D9 (grün) / D10 (blau)
#   SW1: EN (Reset) gegen GND
import os, sys, subprocess, pcbnew
HIER = os.path.dirname(os.path.abspath(__file__))
from pcbnew import FromMM, VECTOR2I

OUT = os.path.join(HIER, "traeger")
FR = os.environ.get("FREEROUTING_JAR", "freerouting-1.9.0.jar")   # https://github.com/freerouting/freerouting/releases
BX = 22.0; Y_UNTEN, Y_OBEN = -10.5, 28.5          # Platine 22 x 39 mm
DICKE = 0.8

def P(x, y): return VECTOR2I(FromMM(x), FromMM(-y))

board = pcbnew.BOARD()
ds = board.GetDesignSettings()
ds.SetCopperLayerCount(2); ds.SetBoardThickness(FromMM(DICKE))
ds.m_TrackMinWidth = FromMM(0.15); ds.m_MinClearance = FromMM(0.15); ds.m_ViasMinSize = FromMM(0.5)
ds.m_MinThroughDrill = FromMM(0.3); ds.m_CopperEdgeClearance = FromMM(0.3); ds.m_HoleToHoleMin = FromMM(0.25)
ds.m_SolderMaskMinWidth = FromMM(0.0)
nc = ds.m_NetSettings.m_DefaultNetClass
nc.SetClearance(FromMM(0.16)); nc.SetTrackWidth(FromMM(0.2)); nc.SetViaDiameter(FromMM(0.6)); nc.SetViaDrill(FromMM(0.3))

NETZE = ["VBAT", "GND", "V3V3", "SA", "SB", "ADC", "MESS", "PG", "DIV", "KR", "KG", "KB", "LR", "LG", "LB", "EN"]
nets = {}
for n in NETZE:
    ni = pcbnew.NETINFO_ITEM(board, n); board.Add(ni); nets[n] = ni

ECKEN = [(-BX/2, Y_UNTEN), (BX/2, Y_UNTEN), (BX/2, Y_OBEN), (-BX/2, Y_OBEN)]
for i in range(4):
    s = pcbnew.PCB_SHAPE(board); s.SetShape(pcbnew.SHAPE_T_SEGMENT)
    s.SetStart(P(*ECKEN[i])); s.SetEnd(P(*ECKEN[(i+1) % 4])); s.SetLayer(pcbnew.Edge_Cuts); s.SetWidth(FromMM(0.05)); board.Add(s)

def padpos(fp, num):
    for pd in fp.Pads():
        if pd.GetNumber() == num:
            p = pd.GetPosition(); return (pcbnew.ToMM(p.x), -pcbnew.ToMM(p.y))
def setnet(fp, num, net):
    for pd in fp.Pads():
        if pd.GetNumber() == num: pd.SetNet(nets[net])

def lib(ref, libname, name, x, y, rot, value, mpn="", mfg="", lcsc=""):
    fp = pcbnew.FootprintLoad("/usr/share/kicad/footprints/%s.pretty" % libname, name)
    fp.SetReference(ref); fp.SetValue(value); fp.Reference().SetVisible(False); fp.Value().SetVisible(False)
    if lcsc: fp.SetProperty("MPN", mpn); fp.SetProperty("MFG", mfg); fp.SetProperty("LCSC", lcsc)
    board.Add(fp); fp.SetPosition(P(x, y)); fp.SetOrientationDegrees(rot)
    return fp

def widerstand(ref, x, y, senkrecht, n_a, n_b, value, mpn, lcsc):
    """n_a = Netz am oberen (senkrecht) bzw. linken Pad."""
    fp = lib(ref, "Resistor_SMD", "R_0402_1005Metric", x, y, 90 if senkrecht else 0, value, mpn, "UNI-ROYAL", lcsc)
    p1, p2 = padpos(fp, "1"), padpos(fp, "2")
    a = (p1[1] > p2[1]) if senkrecht else (p1[0] < p2[0])
    setnet(fp, "1", n_a if a else n_b); setnet(fp, "2", n_b if a else n_a)
    return fp

def kond(ref, x, y, senkrecht, n_a, n_b):
    fp = lib(ref, "Capacitor_SMD", "C_0402_1005Metric", x, y, 90 if senkrecht else 0, "100nF", "CL05B104KO5NNNC", "Samsung Electro-Mechanics", "C1525")
    p1, p2 = padpos(fp, "1"), padpos(fp, "2")
    a = (p1[1] > p2[1]) if senkrecht else (p1[0] < p2[0])
    setnet(fp, "1", n_a if a else n_b); setnet(fp, "2", n_b if a else n_a)
    return fp

# ---------- XIAO ESP32C6 (Lage aus Seeed OPL_Kicad_Library "XIAO-ESP32-C6-SMD", um 180° gedreht) ----------
U1 = pcbnew.FOOTPRINT(board); U1.SetReference("U1"); U1.SetValue("XIAO_ESP32C6")
U1.SetFPID(pcbnew.LIB_ID("schloss", "XIAO_ESP32C6_Traeger"))
U1.SetAttributes(pcbnew.FP_THROUGH_HOLE | pcbnew.FP_EXCLUDE_FROM_BOM | pcbnew.FP_EXCLUDE_FROM_POS_FILES)
U1.Reference().SetVisible(False); U1.Value().SetVisible(False)
XL, XR = -8.1, 8.065
XIAO_PADS = {   # Nummer: (x, y, Netz)   rechts D0..D6 von unten (USB) nach oben, links VBUS..D7
    "1": (XR, -7.62, "ADC"), "2": (XR, -5.08, "SA"), "3": (XR, -2.54, "SB"), "4": (XR, 0.0, "MESS"),
    "5": (XR, 2.54, None), "6": (XR, 5.08, None), "7": (XR, 7.62, None),
    "8": (XL, 7.62, None), "9": (XL, 5.08, "LR"), "10": (XL, 2.54, "LG"), "11": (XL, 0.0, "LB"),
    "12": (XL, -2.54, "V3V3"), "13": (XL, -5.08, "GND"), "14": (XL, -7.62, None)}
for num, (x, y, net) in XIAO_PADS.items():
    pd = pcbnew.PAD(U1); pd.SetNumber(num); pd.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
    pd.SetShape(pcbnew.PAD_SHAPE_ROUNDRECT); pd.SetRoundRectRadiusRatio(0.15)
    pd.SetSize(VECTOR2I(FromMM(2.75), FromMM(2.0)))
    ls = pcbnew.LSET(); ls.AddLayer(pcbnew.F_Cu); ls.AddLayer(pcbnew.F_Mask); pd.SetLayerSet(ls)   # keine Paste: XIAO wird von Hand gelötet
    q = P(x, y); pd.SetPos0(q); pd.SetPosition(q); U1.Add(pd)
# Durchlötbohrungen unter den Unterseiten-Pads VBAT (23) und EN (17)
for num, (x, y, w, h, net) in {"23": (1.79, 5.53, 1.1, 2.5, "VBAT"), "17": (1.28, -6.10, 1.7, 1.7, "EN")}.items():
    pd = pcbnew.PAD(U1); pd.SetNumber(num); pd.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
    pd.SetShape(pcbnew.PAD_SHAPE_OVAL if num == "23" else pcbnew.PAD_SHAPE_CIRCLE)
    pd.SetSize(VECTOR2I(FromMM(w), FromMM(h))); pd.SetDrillSize(VECTOR2I(FromMM(0.7), FromMM(0.7)))
    pd.SetLayerSet(pd.PTHMask()); q = P(x, y); pd.SetPos0(q); pd.SetPosition(q); U1.Add(pd)
board.Add(U1)
for num, (x, y, net) in XIAO_PADS.items():
    if net: setnet(U1, num, net)
setnet(U1, "23", "VBAT"); setnet(U1, "17", "EN")

# ---------- Lötaugen: Sensorkabel (links 3V3/GND, rechts A/B) und Akku (Mitte) ----------
J = pcbnew.FOOTPRINT(board); J.SetReference("J1"); J.SetValue("Kabel")
J.SetFPID(pcbnew.LIB_ID("schloss", "Loetaugen_6x_D0.8mm"))
J.SetAttributes(pcbnew.FP_THROUGH_HOLE | pcbnew.FP_EXCLUDE_FROM_BOM | pcbnew.FP_EXCLUDE_FROM_POS_FILES)
J.Reference().SetVisible(False); J.Value().SetVisible(False)
YL = 12.6
LOECHER = {"1": (-9.0, YL, "V3V3"), "2": (-7.0, YL, "GND"), "3": (-1.0, YL, "VBAT"), "4": (1.0, YL, "GND"),
           "5": (7.0, YL, "SA"), "6": (9.0, YL, "SB")}
for num, (x, y, net) in LOECHER.items():
    pd = pcbnew.PAD(J); pd.SetNumber(num); pd.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
    pd.SetShape(pcbnew.PAD_SHAPE_RECT if num in ("1", "3") else pcbnew.PAD_SHAPE_CIRCLE)
    pd.SetSize(VECTOR2I(FromMM(1.4), FromMM(1.4))); pd.SetDrillSize(VECTOR2I(FromMM(0.8), FromMM(0.8)))
    pd.SetLayerSet(pd.PTHMask()); q = P(x, y); pd.SetPos0(q); pd.SetPosition(q); J.Add(pd)
board.Add(J)
for num, (x, y, net) in LOECHER.items(): setnet(J, num, net)

# ---------- Reset-Taster und RGB-LED ----------
SW = (2.0, 17.2); LEDP = (-6.8, 17.2)
SW1 = lib("SW1", "Button_Switch_SMD", "SW_Push_1P1T_XKB_TS-1187A", SW[0], SW[1], 0, "TS-1187A-B-A-B", "TS-1187A-B-A-B", "XKB Connection", "C318884")
setnet(SW1, "1", "EN"); setnet(SW1, "2", "GND")
LED = lib("LED1", "LED_SMD", "LED_LiteOn_LTST-C19HE1WT", LEDP[0], LEDP[1], 0, "LTST-C19HE1WT", "LTST-C19HE1WT", "Lite-On", "C458749")
for num, net in (("1", "KR"), ("2", "KG"), ("3", "KB"), ("4", "DIV")): setnet(LED, num, net)
R5 = widerstand("R5", -9.3, 17.2, True, "KR", "LR", "330", "0402WGF3300TCE", "C25104")
R6 = widerstand("R6", -6.8, 19.5, False, "KG", "LG", "100", "0402WGF1000TCE", "C25076")
R7 = widerstand("R7", -4.4, 17.2, True, "KB", "LB", "100", "0402WGF1000TCE", "C25076")

# ---------- Schaltbarer Spannungsteiler ----------
YK = 24.8
Q2 = lib("Q2", "Package_TO_SOT_SMD", "SOT-23", -3.8, YK, 0,   "AO3401A", "AO3401A", "Alpha & Omega", "C15127")
Q1 = lib("Q1", "Package_TO_SOT_SMD", "SOT-23",  4.2, YK, 180, "2N7002",  "2N7002",  "CJ",            "C8545")
for q, s_, g, d in ((Q2, "VBAT", "PG", "DIV"), (Q1, "GND", "MESS", "PG")):
    setnet(q, "1", g); setnet(q, "2", s_); setnet(q, "3", d)      # SOT-23: 1 = G, 2 = S, 3 = D
R3 = widerstand("R3", -6.6, YK, True, "PG", "VBAT", "1M", "0402WGF1004TCE", "C26083")
R4 = widerstand("R4", 7.0, YK, True, "GND", "MESS", "1M", "0402WGF1004TCE", "C26083")
R1 = widerstand("R1", -0.9, 21.6, True, "DIV", "ADC", "100k", "0402WGF1003TCE", "C25741")
R2 = widerstand("R2", 0.4, 21.6, True, "ADC", "GND", "100k", "0402WGF1003TCE", "C25741")
C3 = kond("C3", 1.7, 21.6, True, "ADC", "GND")

# ---------- Sperrflächen ----------
def sperre(pts, layers, tracks=True, vias=True, pour=True):
    z = pcbnew.ZONE(board); z.SetIsRuleArea(True)
    ls = pcbnew.LSET()
    for l in layers: ls.AddLayer(l)
    z.SetLayerSet(ls)
    z.SetDoNotAllowTracks(tracks); z.SetDoNotAllowVias(vias); z.SetDoNotAllowCopperPour(pour)
    z.SetDoNotAllowPads(False); z.SetDoNotAllowFootprints(False)
    o = z.Outline(); o.NewOutline()
    for x, y in pts:
        q = P(x, y); o.Append(q.x, q.y)
    board.Add(z)
def rechteck(x0, y0, x1, y1): return [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
# Oberseite unter dem XIAO: Leiterbahnen nur in einem schmalen Streifen an den Randkontakten (zum Via),
# nicht unter der Modulmitte (freiliegende Unterseiten-Pads) und nicht außen neben den Lötstellen
for r in (rechteck(-2.3, -9.8, 2.3, 0.2), rechteck(-1.7, 4.0, 0.2, 7.1)):   # MTDI/MTDO/EN/GND/MTMS/MTCK/BOOT/3V3 und GND-Pad
    sperre(r, [pcbnew.F_Cu])
sperre(rechteck(-BX/2, Y_UNTEN, -9.55, 10.6), [pcbnew.F_Cu]); sperre(rechteck(9.55, Y_UNTEN, BX/2, 10.6), [pcbnew.F_Cu])
# Randstreifen 0,45 mm ohne Leiterbahnen (Abstand Kupfer - Platinenrand)
R_ = 0.45; CU2 = [pcbnew.F_Cu, pcbnew.B_Cu]
for r in (rechteck(-BX/2, Y_UNTEN, -BX/2 + R_, Y_OBEN), rechteck(BX/2 - R_, Y_UNTEN, BX/2, Y_OBEN),
          rechteck(-BX/2, Y_UNTEN, BX/2, Y_UNTEN + R_), rechteck(-BX/2, Y_OBEN - R_, BX/2, Y_OBEN)):
    sperre(r, CU2, pour=False)

# ---------- Beschriftung ----------
def text(s, x, y, h=0.8, layer=pcbnew.F_SilkS, ang=0):
    t = pcbnew.PCB_TEXT(board); t.SetText(s); t.SetPosition(P(x, y)); t.SetLayer(layer)
    t.SetTextSize(VECTOR2I(FromMM(h), FromMM(h))); t.SetTextThickness(FromMM(0.15)); t.SetTextAngleDegrees(ang)
    if layer == pcbnew.B_SilkS: t.SetMirrored(True)
    board.Add(t)
B = pcbnew.B_SilkS
text("3V3", -9.0, 14.0, 0.8, B); text("GND", -7.0, 11.1, 0.8, B)
text("+", -1.0, 14.0, 1.0, B); text("-", 1.0, 14.0, 1.0, B); text("AKKU", 0, 11.1, 0.8, B)
text("A", 7.0, 14.0, 0.8, B); text("B", 9.0, 14.0, 0.8, B)
text("VBAT", 1.8, 8.0, 0.8, B); text("EN", 1.3, -8.2, 0.8, B)
text("SCHLOSS-TRAEGER v1", 0, 27.6, 0.8, B)
text("XIAO ESP32C6", 0, 0, 1.0, pcbnew.F_SilkS)
text("USB", 0, -9.4, 0.8, pcbnew.F_SilkS)

pcbnew.SaveBoard(OUT + "_unrouted.kicad_pcb", board)

# ---------- Autorouter (Freerouting) ----------
if "--route" in sys.argv:
    pcbnew.ExportSpecctraDSN(board, OUT + ".dsn")
    subprocess.run(["xvfb-run", "-a", "java", "-jar", FR, "-de", OUT + ".dsn", "-do", OUT + ".ses",
                    "-mp", "60", "-dct", "0"], check=False, timeout=900, capture_output=True)
if "--route" in sys.argv or "--ses" in sys.argv:
    sys.path.insert(0, HIER); import ses_import
    print("Import:", ses_import.importiere(board, OUT + ".ses"))
nc.SetClearance(FromMM(0.15))   # Router mit 0,18 mm, Prüfung gegen die Fertigungsgrenze

# keine Kupferfläche am Antennenende des XIAO (erst nach dem Routen, Specctra kennt keine reinen Flächensperren)
sperre(rechteck(-BX/2, 6.0, BX/2, 11.5), [pcbnew.F_Cu, pcbnew.B_Cu], tracks=False, vias=False, pour=True)

# ---------- Massefläche unten ----------
z = pcbnew.ZONE(board); z.SetLayer(pcbnew.B_Cu); z.SetNet(nets["GND"])
z.SetLocalClearance(FromMM(0.25)); z.SetMinThickness(FromMM(0.25))
z.SetThermalReliefGap(FromMM(0.25)); z.SetThermalReliefSpokeWidth(FromMM(0.3)); z.SetPadConnection(pcbnew.ZONE_CONNECTION_THERMAL)
o = z.Outline(); o.NewOutline()
for x, y in ECKEN:
    q = P(x, y); o.Append(q.x, q.y)
board.Add(z)

pcbnew.SaveBoard(OUT + ".kicad_pcb", board)
board = pcbnew.LoadBoard(OUT + ".kicad_pcb")
board.BuildConnectivity()
pcbnew.ZONE_FILLER(board).Fill(board.Zones())
pcbnew.SaveBoard(OUT + ".kicad_pcb", board)
pcbnew.WriteDRCReport(board, OUT + "_drc.txt", pcbnew.EDA_UNITS_MILLIMETRES, True)
fps = {f.GetReference(): f for f in board.GetFootprints()}
for r in ("SW1", "LED1"):
    print(r, {pd.GetNumber(): (pd.GetNetname(), tuple(round(v, 2) for v in padpos(fps[r], pd.GetNumber()))) for pd in fps[r].Pads()})

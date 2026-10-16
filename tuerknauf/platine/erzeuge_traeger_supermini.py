# Trägerplatine für das ESP32-C6 Super Mini (wird flach aufgelötet, über die 20 Randkontakte)
# mit schaltbarem Akku-Spannungsteiler und Lötaugen für Akku und Sensorkabel.
# Status-LED (WS2812 an GPIO8), Reset-Taster und Ladeschaltung (LTH7R) sitzen schon auf dem Modul.
#
# Koordinaten in mm, von vorne gesehen: Ursprung = Mitte des Moduls, x rechts, y oben (zum Knauf).
# Das Modul liegt mit den Bauteilen nach vorne auf der Trägerplatine, USB-C zeigt nach unten (-y).
# Unter dem Modul ist die Platine ausgeschnitten (Fenster, unten offen):
#   - die Haltelaschen der USB-C-Buchse stehen auf der Modulunterseite über,
#   - die Akku-Pads B+/B- des Moduls (Unterseite, am USB-Ende zwischen den Laschen) bleiben von hinten erreichbar,
#   - unter der Keramikantenne liegt kein Leiterplattenmaterial und kein Kupfer.
#
# Schaltung:
#   VBAT ─┬──────────── S  Q2 AO3401A (P)  D ── R1 100k ──┬── ADC (GPIO0)    R2 100k / C3 100n nach GND
#         R3 1M               G                           │
#         └───────────────────┴── D  Q1 2N7002
#                                     G ── MESS (GPIO3, R4 1M nach GND)
#   VBAT kommt vom Akku (Lötaugen AKKU) und geht über eine kurze Drahtbrücke (Lötauge BAT) an das
#   Akku-Pad des Moduls; dort lädt die Ladeschaltung des Moduls den Akku über USB-C.
import os, sys, subprocess, pcbnew
HIER = os.path.dirname(os.path.abspath(__file__))
from pcbnew import FromMM, VECTOR2I

OUT = os.path.join(HIER, "traeger_supermini")
FR = os.environ.get("FREEROUTING_JAR", "freerouting-1.9.0.jar")   # https://github.com/freerouting/freerouting/releases
BX = 24.0
M_L, M_B = 25.5, 18.0                 # Modul 25,5 x 18 mm (Foto: 25,5 x 17,9)
Y_UNTEN = -M_L / 2                    # Platine beginnt an der USB-Kante des Moduls
Y_OBEN = 26.0                         # Platine 24 x 38,75 mm
FX = 5.7; FY = 12.2                   # Fenster unter dem Modul: |x| < 5,7, von der Unterkante bis y = 12,2
DICKE = 0.8
RASTER = 2.54; Y_PIN0 = -11.43 - 0.2  # Lötaugen des Moduls: 10 je Seite, Reihe 0,2 mm zur USB-Kante versetzt (Foto)
X_PIN = 7.62                          # Bohrungsmitte der Randkontakte (Reihenabstand 15,24)

def P(x, y): return VECTOR2I(FromMM(x), FromMM(-y))

board = pcbnew.BOARD()
ds = board.GetDesignSettings()
ds.SetCopperLayerCount(2); ds.SetBoardThickness(FromMM(DICKE))
ds.m_TrackMinWidth = FromMM(0.15); ds.m_MinClearance = FromMM(0.15); ds.m_ViasMinSize = FromMM(0.5)
ds.m_MinThroughDrill = FromMM(0.3); ds.m_CopperEdgeClearance = FromMM(0.3); ds.m_HoleToHoleMin = FromMM(0.25)
ds.m_SolderMaskMinWidth = FromMM(0.0)
nc = ds.m_NetSettings.m_DefaultNetClass
nc.SetClearance(FromMM(0.16)); nc.SetTrackWidth(FromMM(0.2)); nc.SetViaDiameter(FromMM(0.6)); nc.SetViaDrill(FromMM(0.3))

NETZE = ["VBAT", "GND", "V3V3", "SA", "SB", "ADC", "MESS", "PG", "DIV"]
nets = {}
for n in NETZE:
    ni = pcbnew.NETINFO_ITEM(board, n); board.Add(ni); nets[n] = ni

# Umriss mit Fenster (U-Form, unten offen)
UMRISS = [(-BX/2, Y_UNTEN), (-FX, Y_UNTEN), (-FX, FY), (FX, FY), (FX, Y_UNTEN), (BX/2, Y_UNTEN),
          (BX/2, Y_OBEN), (-BX/2, Y_OBEN)]
for i in range(len(UMRISS)):
    s = pcbnew.PCB_SHAPE(board); s.SetShape(pcbnew.SHAPE_T_SEGMENT)
    s.SetStart(P(*UMRISS[i])); s.SetEnd(P(*UMRISS[(i+1) % len(UMRISS)])); s.SetLayer(pcbnew.Edge_Cuts); s.SetWidth(FromMM(0.05)); board.Add(s)

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

def zweipol(ref, libname, name, x, y, senkrecht, n_a, n_b, value, mpn, mfg, lcsc):
    """n_a = Netz am oberen (senkrecht) bzw. linken Pad."""
    fp = lib(ref, libname, name, x, y, 90 if senkrecht else 0, value, mpn, mfg, lcsc)
    p1, p2 = padpos(fp, "1"), padpos(fp, "2")
    a = (p1[1] > p2[1]) if senkrecht else (p1[0] < p2[0])
    setnet(fp, "1", n_a if a else n_b); setnet(fp, "2", n_b if a else n_a)
    return fp
def widerstand(ref, x, y, senkrecht, n_a, n_b, value, mpn, lcsc):
    return zweipol(ref, "Resistor_SMD", "R_0402_1005Metric", x, y, senkrecht, n_a, n_b, value, mpn, "UNI-ROYAL", lcsc)
def kond(ref, x, y, senkrecht, n_a, n_b):
    return zweipol(ref, "Capacitor_SMD", "C_0402_1005Metric", x, y, senkrecht, n_a, n_b, "100nF",
                   "CL05B104KO5NNNC", "Samsung Electro-Mechanics", "C1525")

# ---------- ESP32-C6 Super Mini ----------
# Von vorne, USB unten: rechts (von USB nach oben) TX/16, RX/17, 0 … 7; links 5V, GND, 3V3, 20, 19, 18, 15, 14, 9, 8
# (auf dem Produktfoto mit USB oben ist es seitenverkehrt: links TX … 7, rechts 5V … 8)
U1 = pcbnew.FOOTPRINT(board); U1.SetReference("U1"); U1.SetValue("ESP32-C6_SuperMini")
U1.SetFPID(pcbnew.LIB_ID("schloss", "ESP32C6_SuperMini_Traeger"))
U1.SetAttributes(pcbnew.FP_THROUGH_HOLE | pcbnew.FP_EXCLUDE_FROM_BOM | pcbnew.FP_EXCLUDE_FROM_POS_FILES)
U1.Reference().SetVisible(False); U1.Value().SetVisible(False)
RECHTS = ["IO16", "IO17", "IO0", "IO1", "IO2", "IO3", "IO4", "IO5", "IO6", "IO7"]
LINKS  = ["5V", "GND", "3V3", "IO20", "IO19", "IO18", "IO15", "IO14", "IO9", "IO8"]
BELEGT = {"IO0": "ADC", "IO1": "SA", "IO2": "SB", "IO3": "MESS", "GND": "GND", "3V3": "V3V3"}
MODUL_PADS = {}
for i in range(10):
    y = Y_PIN0 + RASTER * i
    MODUL_PADS[str(i + 1)] = (X_PIN + 0.78, y, RECHTS[i])
    MODUL_PADS[str(i + 11)] = (-X_PIN - 0.78, y, LINKS[i])
for num, (x, y, name) in MODUL_PADS.items():
    pd = pcbnew.PAD(U1); pd.SetNumber(num); pd.SetAttribute(pcbnew.PAD_ATTRIB_SMD)
    pd.SetShape(pcbnew.PAD_SHAPE_ROUNDRECT); pd.SetRoundRectRadiusRatio(0.15)
    pd.SetSize(VECTOR2I(FromMM(2.8), FromMM(1.6)))       # von x = 7,0 (unter dem Lötauge) bis 9,8 (0,8 mm vor der Modulkante)
    ls = pcbnew.LSET(); ls.AddLayer(pcbnew.F_Cu); ls.AddLayer(pcbnew.F_Mask); pd.SetLayerSet(ls)   # keine Paste: Modul wird von Hand gelötet
    q = P(x, y); pd.SetPos0(q); pd.SetPosition(q); U1.Add(pd)
board.Add(U1)
for num, (x, y, name) in MODUL_PADS.items():
    if name in BELEGT: setnet(U1, num, BELEGT[name])

# ---------- Lötaugen: Sensorkabel (links 3V3/GND, rechts A/B), Akku (Mitte), Brücke zum Akku-Pad des Moduls ----------
J = pcbnew.FOOTPRINT(board); J.SetReference("J1"); J.SetValue("Kabel")
J.SetFPID(pcbnew.LIB_ID("schloss", "Loetaugen_7x_D0.8mm"))
J.SetAttributes(pcbnew.FP_THROUGH_HOLE | pcbnew.FP_EXCLUDE_FROM_BOM | pcbnew.FP_EXCLUDE_FROM_POS_FILES)
J.Reference().SetVisible(False); J.Value().SetVisible(False)
YL = 15.6
LOECHER = {"1": (-9.0, YL, "V3V3"), "2": (-7.0, YL, "GND"), "3": (-1.0, YL, "VBAT"), "4": (1.0, YL, "GND"),
           "5": (7.0, YL, "SA"), "6": (9.0, YL, "SB"), "7": (-4.6, FY + 1.3, "VBAT")}
for num, (x, y, net) in LOECHER.items():
    pd = pcbnew.PAD(J); pd.SetNumber(num); pd.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
    pd.SetShape(pcbnew.PAD_SHAPE_RECT if num in ("1", "3") else pcbnew.PAD_SHAPE_CIRCLE)
    pd.SetSize(VECTOR2I(FromMM(1.4), FromMM(1.4))); pd.SetDrillSize(VECTOR2I(FromMM(0.8), FromMM(0.8)))
    pd.SetLayerSet(pd.PTHMask()); q = P(x, y); pd.SetPos0(q); pd.SetPosition(q); J.Add(pd)
board.Add(J)
for num, (x, y, net) in LOECHER.items(): setnet(J, num, net)

# ---------- Schaltbarer Spannungsteiler ----------
YR = YL + 4.0; YK = YL + 7.2
Q2 = lib("Q2", "Package_TO_SOT_SMD", "SOT-23", -3.8, YK, 0,   "AO3401A", "AO3401A", "Alpha & Omega", "C15127")
Q1 = lib("Q1", "Package_TO_SOT_SMD", "SOT-23",  4.2, YK, 180, "2N7002",  "2N7002",  "CJ",            "C8545")
for q, s_, g, d in ((Q2, "VBAT", "PG", "DIV"), (Q1, "GND", "MESS", "PG")):
    setnet(q, "1", g); setnet(q, "2", s_); setnet(q, "3", d)      # SOT-23: 1 = G, 2 = S, 3 = D
R3 = widerstand("R3", -6.6, YK, True, "PG", "VBAT", "1M", "0402WGF1004TCE", "C26083")
R4 = widerstand("R4", 7.0, YK, True, "GND", "MESS", "1M", "0402WGF1004TCE", "C26083")
R1 = widerstand("R1", -0.9, YR, True, "DIV", "ADC", "100k", "0402WGF1003TCE", "C25741")
R2 = widerstand("R2", 0.4, YR, True, "ADC", "GND", "100k", "0402WGF1003TCE", "C25741")
C3 = kond("C3", 1.7, YR, True, "ADC", "GND")

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
CU2 = [pcbnew.F_Cu, pcbnew.B_Cu]
# Oberseite unter dem Modul: nur die Lötflächen. Keine Leiterbahnen/Vias an den freiliegenden Lötaugen der
# Modulunterseite (Randkontakte, GPIO23); Leiterbahnen verlassen die Lötflächen nach außen (|x| > 9,2).
# (Die Lötflächen selbst dürfen nicht in einer Sperrfläche liegen, sonst schließt Freerouting sie nicht an:
#  gesperrt werden die Streifen innen neben den Lötflächen und die Lücken zwischen ihnen.)
for s in (-1, 1):
    sperre(rechteck(s*FX, Y_UNTEN, s*6.95, M_L/2 + 0.2), [pcbnew.F_Cu])
    kanten = [Y_UNTEN] + [Y_PIN0 + RASTER*i + d for i in range(10) for d in (-0.85, 0.85)] + [M_L/2 + 0.2]
    for y0, y1 in zip(kanten[0::2], kanten[1::2]):
        sperre(rechteck(s*6.95, y0, s*(M_B/2 + 0.2), y1), [pcbnew.F_Cu])
# Randstreifen 0,45 mm ohne Leiterbahnen (Abstand Kupfer - Platinenrand), auch am Fenster
R_ = 0.45
for r in (rechteck(-BX/2, Y_UNTEN, -BX/2 + R_, Y_OBEN), rechteck(BX/2 - R_, Y_UNTEN, BX/2, Y_OBEN),
          rechteck(-BX/2, Y_UNTEN, -FX, Y_UNTEN + R_), rechteck(FX, Y_UNTEN, BX/2, Y_UNTEN + R_),
          rechteck(-BX/2, Y_OBEN - R_, BX/2, Y_OBEN),
          rechteck(-FX - R_, Y_UNTEN, -FX, FY + R_), rechteck(FX, Y_UNTEN, FX + R_, FY + R_), rechteck(-FX, FY, FX, FY + R_)):
    sperre(r, CU2, pour=False)

# ---------- Beschriftung ----------
def text(s, x, y, h=0.8, layer=pcbnew.F_SilkS, ang=0):
    t = pcbnew.PCB_TEXT(board); t.SetText(s); t.SetPosition(P(x, y)); t.SetLayer(layer)
    t.SetTextSize(VECTOR2I(FromMM(h), FromMM(h))); t.SetTextThickness(FromMM(0.15)); t.SetTextAngleDegrees(ang)
    if layer == pcbnew.B_SilkS: t.SetMirrored(True)
    board.Add(t)
B = pcbnew.B_SilkS
text("3V3", -9.0, YL + 1.4, 0.8, B); text("GND", -7.0, YL - 1.5, 0.8, B)
text("+", -1.0, YL + 1.4, 1.0, B); text("-", 1.0, YL + 1.4, 1.0, B); text("AKKU", 0, YL - 1.5, 0.8, B)
text("A", 7.0, YL + 1.4, 0.8, B); text("B", 9.0, YL + 1.4, 0.8, B)
text("BAT", -2.5, FY + 1.0, 0.8, B)
text("SCHLOSS-TRAEGER SM v1", 0, Y_OBEN - 0.9, 0.8, B)
text("C6 SUPER MINI", 0, Y_OBEN - 0.9, 0.8, pcbnew.F_SilkS)
text("USB v", 2.6, FY + 1.1, 0.8, pcbnew.F_SilkS)   # Merkhilfe beim Auflegen: USB-C zur offenen Seite

pcbnew.SaveBoard(OUT + "_unrouted.kicad_pcb", board)

# ---------- Autorouter (Freerouting) ----------
if "--route" in sys.argv:
    pcbnew.ExportSpecctraDSN(board, OUT + ".dsn")
    subprocess.run(["xvfb-run", "-a", "java", "-jar", FR, "-de", OUT + ".dsn", "-do", OUT + ".ses",
                    "-mp", "60", "-dct", "0"], check=False, timeout=900, capture_output=True)
if "--route" in sys.argv or "--ses" in sys.argv:
    sys.path.insert(0, HIER); import ses_import
    print("Import:", ses_import.importiere(board, OUT + ".ses"))
nc.SetClearance(FromMM(0.15))   # Router mit 0,16 mm, Prüfung gegen die Fertigungsgrenze

# keine Kupferfläche neben der Antenne (Modulende) – erst nach dem Routen, Specctra kennt keine reinen Flächensperren
sperre(rechteck(-BX/2, 6.0, BX/2, YL - 1.0), CU2, tracks=False, vias=False, pour=True)

# ---------- Massefläche unten ----------
z = pcbnew.ZONE(board); z.SetLayer(pcbnew.B_Cu); z.SetNet(nets["GND"])
z.SetLocalClearance(FromMM(0.25)); z.SetMinThickness(FromMM(0.25))
z.SetThermalReliefGap(FromMM(0.25)); z.SetThermalReliefSpokeWidth(FromMM(0.3)); z.SetPadConnection(pcbnew.ZONE_CONNECTION_THERMAL)
o = z.Outline(); o.NewOutline()
for x, y in UMRISS:
    q = P(x, y); o.Append(q.x, q.y)
board.Add(z)

pcbnew.SaveBoard(OUT + ".kicad_pcb", board)
board = pcbnew.LoadBoard(OUT + ".kicad_pcb")
board.BuildConnectivity()
pcbnew.ZONE_FILLER(board).Fill(board.Zones())
pcbnew.SaveBoard(OUT + ".kicad_pcb", board)
pcbnew.WriteDRCReport(board, OUT + "_drc.txt", pcbnew.EDA_UNITS_MILLIMETRES, True)

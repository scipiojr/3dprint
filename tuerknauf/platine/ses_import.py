# Minimaler Import einer Specctra-Session (Freerouting) in ein pcbnew-Board
import re, pcbnew
from pcbnew import FromMM, VECTOR2I
def tokens(s):
    for m in re.finditer(r'"[^"]*"|\(|\)|[^\s()]+', s): yield m.group(0)
def parse(s):
    st = [[]]
    for t in tokens(s):
        if t == "(": st.append([])
        elif t == ")": x = st.pop(); st[-1].append(x)
        else: st[-1].append(t.strip('"'))
    return st[0][0]
def find(node, key):
    return [c for c in node if isinstance(c, list) and c and c[0] == key]
def importiere(board, fn, via_d=0.6, via_bohr=0.3):
    ses = parse(open(fn).read())
    routes = find(ses, "routes")[0]
    res = find(routes, "resolution")[0]; div = float(res[2]) * (1000.0 if res[1] == "um" else 1.0)  # Einheiten pro mm
    lay = {"F.Cu": pcbnew.F_Cu, "B.Cu": pcbnew.B_Cu}
    n_w = n_v = 0
    for net in find(find(routes, "network_out")[0], "net"):
        ni = board.FindNet(net[1])
        for w in find(net, "wire"):
            p = find(w, "path")[0]; L = lay[p[1]]; wd = float(p[2]) / div
            xy = [float(v) / div for v in p[3:]]
            pts = list(zip(xy[0::2], xy[1::2]))
            for a, b in zip(pts, pts[1:]):
                t = pcbnew.PCB_TRACK(board); t.SetStart(VECTOR2I(FromMM(a[0]), FromMM(-a[1]))); t.SetEnd(VECTOR2I(FromMM(b[0]), FromMM(-b[1])))
                t.SetWidth(FromMM(wd)); t.SetLayer(L); t.SetNet(ni); board.Add(t); n_w += 1
        for v in find(net, "via"):
            x, y = float(v[2]) / div, float(v[3]) / div
            vi = pcbnew.PCB_VIA(board); vi.SetPosition(VECTOR2I(FromMM(x), FromMM(-y))); vi.SetDrill(FromMM(via_bohr)); vi.SetWidth(FromMM(via_d))
            vi.SetNet(ni); vi.SetViaType(pcbnew.VIATYPE_THROUGH); board.Add(vi); n_v += 1
    return n_w, n_v

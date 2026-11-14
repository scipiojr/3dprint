#!/usr/bin/env python3
"""Erzeugt ein STEP-Volumenmodell (echtes CAD, keine Dreiecke) der Kleinteilebox.

Aufruf:  python3 -I werkzeuge/erzeuge_step.py [BxT ...] [name=wert ...]
         (ohne Größe: 1x2 und 2x3; Parameter wie in kleinteilebox.scad überschreibbar)
Ergebnis: kleinteilebox_BxT.step im Projektordner.

Voraussetzung: pip install build123d
Die Geometrie ist eine 1:1-Nachbildung von kleinteilebox.scad (gleiche Parameter, gelesen aus der SCAD-Datei).
Zum Slicen bleiben STL/3MF maßgeblich; STEP ist für CAD, Fertigungsangebote und Nachbearbeitung gedacht.
"""
import importlib.util
import math
import sys
from pathlib import Path

from build123d import (Align, Box, BuildLine, BuildPart, BuildSketch, Locations, Mode, Plane, Polyline, Pos,
                       Rectangle, extrude, fillet, loft, make_face, export_step)

PROJEKT = Path(__file__).resolve().parent.parent
_spec = importlib.util.spec_from_file_location('traglast', Path(__file__).with_name('traglast.py'))
_tl = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_tl)

MIN = (Align.MIN, Align.MIN, Align.MIN)


def quader(x, y, z, dx, dy, dz):
    return Pos(x, y, z) * Box(dx, dy, dz, align=MIN)


def grundriss(x0, x1, y0, y1, rr, ebene):
    """Rechteck, vorne (y1) mit Eckradius rr gerundet; als Face auf der Ebene."""
    with BuildSketch(ebene) as sk:
        with Locations(((x0 + x1) / 2, (y0 + y1) / 2)):
            Rectangle(x1 - x0, y1 - y0)
        if rr > 0:
            vs = sk.vertices().filter_by(lambda v: abs(v.Y - y1) < 1e-6)
            fillet(vs, radius=rr)
    return sk.sketch


def bauen(p, uw, ul):
    g = lambda k: p[k]
    H, wall, wb = g('H'), g('wall'), g('wall_band')
    W = uw * g('grid') - g('tol')
    Ltot = ul * g('grid') - g('tol')
    hook_over = g('hook_t') + g('rail_t') + g('hook_clear')
    label_on = bool(g('label_on'))
    front_over = g('label_gap') + g('label_lip') if label_on else 0
    y0 = hook_over
    L = Ltot - hook_over - front_over
    yf = y0 + L
    r = g('r')
    ts = wb if g('band_ring') else wall

    # Bodenstärke wie in der SCAD-Datei
    iw0, il0 = W - 2 * wall, L - 2 * wall
    bs, as_ = min(iw0, il0), max(iw0, il0)
    q_f = g('rho_bulk') * 9.81e-6 * (H - 2)
    a = _tl.interp([(t[0], t[1]) for t in _tl.PLATTE], as_ / bs, 1)
    t_req = (a * q_f * bs ** 4 / (g('E_mod') * g('sag_max'))) ** (1 / 3)
    ft = g('floor_t') if g('floor_t') > 0 else max(1.0, math.ceil(t_req / 0.2 - 0.001) * 0.2)
    band_h = g('band_h')
    dr = wb - wall
    zb = H - band_h - dr
    zl = H - g('hook_top') - g('hook_drop')

    def ebene(z):
        return Plane.XY.offset(z)

    # --- Körper ---
    with BuildPart() as bp:
        # Außenform (Grundriss in Weltkoordinaten: y0..yf)
        extrude(grundriss(0, W, y0, yf, r, ebene(0)), amount=H)
        # Hohlraum (dünne Wand) bis zum Beginn des Übergangs
        cav = lambda tr, tside, z: grundriss(tside, W - tside, y0 + tr, yf - tside, max(r - tside, 0.01), ebene(z))
        extrude(cav(wall, wall, ft), amount=zb - ft, mode=Mode.SUBTRACT)
        # 45°-Übergang zur dicken Rückwand
        loft([cav(wall, wall, zb).face(), cav(wb, ts, zb + dr).face()], ruled=True, mode=Mode.SUBTRACT)
        # Hohlraum im Tragrahmen
        extrude(cav(wb, ts, zb + dr), amount=H - (zb + dr) + 1, mode=Mode.SUBTRACT)
    teil = bp.part

    # --- Haken (über die ganze Breite) ---
    teil += quader(0, 0, H - g('hook_top'), W, hook_over + wb, g('hook_top'))
    teil += quader(0, 0, zl, W, g('hook_t'), g('hook_drop') + g('hook_top'))
    if g('support_rib'):
        teil += quader(0, 0, 0, W, hook_over + wall, g('rib_h'))

    # --- Trennwände ---
    dh = min(g('div_h'), H)
    dt = g('div_t')
    iw, il = W - 2 * wall, L - 2 * wall
    nl, nq = int(g('n_laengs')), int(g('n_quer'))
    if nl > 0:
        c = (iw - nl * dt) / (nl + 1)
        for i in range(1, nl + 1):
            teil += quader(wall + i * c + (i - 1) * dt, y0 + wall - 0.3, 0, dt, il + 0.6, dh)
    if nq > 0:
        c = (il - nq * dt) / (nq + 1)
        for i in range(1, nq + 1):
            teil += quader(wall - 0.3, y0 + wall + i * c + (i - 1) * dt, 0, iw + 0.6, dt, dh)

    # --- Etiketteneinschub (oben geschlossen, seitlich offen) ---
    if label_on:
        lh, rail, gap, lip, ovl = g('label_h'), g('label_rail'), g('label_gap'), g('label_lip'), g('label_ovl')
        lw = g('label_w') if g('label_w') > 0 else W - 20
        fw, fh = lw + 2 * rail, lh + 2 * rail
        fz_top = min(H - H / 6 + fh / 2, H - g('label_top_margin'))
        fz_bot = fz_top - fh
        d = front_over
        x0 = (W - fw) / 2
        zs = fz_bot + rail
        ein = 0.5  # Einbindung in die Vorderwand (liegt vollständig im Wandmaterial)
        rahmen = quader(x0, yf - ein, fz_bot, fw, d + ein, fh)
        sx0 = x0 - 1 if g('label_open_left') else x0 + rail
        sx1 = x0 + fw + 1 if g('label_open_right') else x0 + fw - rail
        rahmen -= quader(sx0, yf, zs, sx1 - sx0, gap, lh)
        wx0, ww = x0 + rail + ovl, fw - 2 * (rail + ovl)
        wz0, wh = zs + ovl, lh - 2 * ovl
        n_posts = max(0, math.ceil(ww / g('label_bridge_max')) - 1)
        seg = (ww - n_posts * g('label_post_w')) / (n_posts + 1)
        for i in range(n_posts + 1):
            rahmen -= quader(wx0 + i * (seg + g('label_post_w')), yf + gap, wz0, seg, lip + 0.1, wh)
        teil += rahmen
        # 45°-Fase unter dem Rahmen (druckbar ohne Stützen): Dreieck im Y-Z-Schnitt
        with BuildPart() as fase:
            with BuildSketch(Plane.YZ.offset(x0)):
                with BuildLine():
                    Polyline((yf - ein, fz_bot), (yf + d, fz_bot), (yf - ein, fz_bot - d - ein), close=True)
                make_face()
            extrude(amount=fw)
        teil += fase.part

    return teil.clean(), dict(W=W, Ltot=Ltot, H=H, ft=ft)


def main():
    p = _tl.parameter()
    p.setdefault('label_on', True)
    groessen = []
    for a in sys.argv[1:]:
        if '=' in a:
            k, v = a.split('=', 1)
            p[k] = (v == 'true') if v in ('true', 'false') else float(v)
        else:
            groessen.append(a)
    for gr in groessen or ['1x2', '2x3']:
        uw, ul = (int(x) for x in gr.split('x'))
        p['units_w'], p['units_l'] = uw, ul
        teil, info = bauen(p, uw, ul)
        out = PROJEKT / f'kleinteilebox_{gr}.step'
        export_step(teil, str(out))
        bb = teil.bounding_box()
        print(f'{out.name}: gültig={teil.is_valid}, Körper={len(teil.solids())}, '
              f'Volumen={teil.volume / 1000:.2f} cm³, Maße={bb.size.X:.2f} x {bb.size.Y:.2f} x {bb.size.Z:.2f} mm, '
              f'Boden={info["ft"]:.1f} mm')


if __name__ == '__main__':
    main()

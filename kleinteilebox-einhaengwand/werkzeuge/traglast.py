#!/usr/bin/env python3
"""Traglastrechnung für die Kleinteilebox (Metallschrauben als Füllgut).

Aufruf:
  traglast.py                      Tabelle für übliche Größen (Breite x Tiefe in Rastereinheiten)
  traglast.py 2x3 4x4              nur diese Größen
  traglast.py --md 2x3 4x4         Tabelle als Markdown (für README)
  traglast.py hook_t=3 4x4         Parameter der SCAD-Datei überschreiben (beliebig viele name=wert)

Die Geometrie wird aus ../kleinteilebox.scad gelesen (Parameter wall, wall_band, band_h, hook_*, rail_t, H ...),
damit Rechnung und Modell nicht auseinanderlaufen. Es sind Handrechnungen (Balken-/Plattentheorie) mit
bewusst vorsichtigen Annahmen, keine FEM und keine Messung. Erst ein Belastungsversuch mit gedrucktem Teil
zeigt, ob die Annahmen für das eigene Filament stimmen.
"""
import math
import re
import sys
from pathlib import Path

SCAD = Path(__file__).resolve().parent.parent / 'kleinteilebox.scad'

# ---- Annahmen (anpassbar) ----
G = 9.81
K_DYN = 1.5          # Zuschlag für Ruck beim Einhängen/Herausziehen und Schrauben, die hineinfallen
SIG_Z = 10.0         # zulässige Zugspannung quer zu den Schichten (Z) [MPa], PETG, Dauerlast: Schichthaftung ca. 20 MPa, Faktor 2 für Kriechen/Streuung
SIG_XY = 15.0        # zulässige Spannung in der Schichtebene [MPa], PETG: ca. 40 MPa Zugfestigkeit, Faktor ~2,5 für Dauerlast
P_ZUL = 5.0          # zulässige Flächenpressung Rastersteg auf Hakendach [MPa]
ZUSTAND = 'Dauerlast'
SF_ZIEL = 2.0        # gewünschte Reserve für die Füllempfehlung

# Plattenbeiwerte (allseitig gelenkig, ν = 0,3): Seitenverhältnis -> (a' für Durchbiegung, β für Spannung)
PLATTE = [(1.0, 0.04434, 0.2874), (1.2, 0.06159, 0.3762), (1.4, 0.07699, 0.4530), (1.6, 0.09064, 0.5172),
          (1.8, 0.10167, 0.5688), (2.0, 0.11062, 0.6102), (3.0, 0.13355, 0.7134), (5.0, 0.14218, 0.7500)]


def parameter():
    """Liest die Standardwerte (erste Zuweisung je Name, vor `// ----------`) aus der SCAD-Datei."""
    p = {}
    for zeile in SCAD.read_text(encoding='utf-8').splitlines():
        if zeile.startswith('// ---------- abgeleitete'):
            break
        m = re.match(r'^(\w+)\s*=\s*(-?[\d.]+|true|false)\s*;', zeile)
        if m and m.group(1) not in p:
            w = m.group(2)
            p[m.group(1)] = (w == 'true') if w in ('true', 'false') else float(w)
    return p


def interp(tab, v, i):
    if v <= tab[0][0]:
        return tab[0][i]
    for a, b in zip(tab, tab[1:]):
        if v <= b[0]:
            f = (v - a[0]) / (b[0] - a[0])
            return a[i] + f * (b[i] - a[i])
    return tab[-1][i]


def rechne(uw, ul, p):
    grid, tol, H = p['grid'], p['tol'], p['H']
    wall, wall_band, band_h = p['wall'], p['wall_band'], p['band_h']
    hook_t, hook_top, hook_drop = p['hook_t'], p['hook_top'], p['hook_drop']
    rail_t, hook_clear = p['rail_t'], p['hook_clear']
    hook_over = hook_t + rail_t + hook_clear
    front_over = p['label_gap'] + p['label_lip'] if p.get('label_on', True) else 0
    W = uw * grid - tol
    Ltot = ul * grid - tol
    L = Ltot - hook_over - front_over
    iw, il = W - 2 * wall, L - 2 * wall
    bs, as_ = min(iw, il), max(iw, il)
    ra = as_ / bs
    # Boden (wie im SCAD)
    q_f = p['rho_bulk'] * G * 1e-6 * (H - 2)
    t_req = (interp(PLATTE, ra, 1) * q_f * bs ** 4 / (p['E_mod'] * p['sag_max'])) ** (1 / 3)
    ft = p['floor_t'] if p['floor_t'] > 0 else max(1.0, math.ceil(t_req / 0.2 - 0.001) * 0.2)
    vol = iw * il * (H - ft) / 1e6                          # Liter
    m_voll = vol * p['rho_bulk']                            # kg bei 100 % Füllung
    F = m_voll * G * K_DYN                                  # N, mit Zuschlag
    # 1) Rückwand zieht an Hakendach: Zug quer zu den Schichten (nur Rückwand, ohne Hilfe der Seitenwände)
    s_wand = F / (W * wall)                                 # dünner Teil der Rückwand
    s_band = F / (W * wall_band)                            # Tragrahmen
    # 2) Hakenlippe: Kippmoment der Füllung -> Horizontalkraft T (Wandanlage unten hält dagegen)
    y_cg = hook_over + wall + il / 2
    y_r = hook_t + rail_t / 2
    z_lip = H - hook_top - hook_drop / 2
    T = F * (y_cg - y_r) / z_lip
    s_lippe = 6 * T * hook_drop / (W * hook_t ** 2)         # Biegezug an der Lippenwurzel (quer zu den Schichten!)
    # 3) Flächenpressung Steg unter Hakendach
    pr = F / (W * rail_t)
    # 4) Boden: Spannung und Durchbiegung
    s_boden = interp(PLATTE, ra, 2) * (K_DYN * q_f) * bs ** 2 / ft ** 2
    sag = interp(PLATTE, ra, 1) * q_f * bs ** 4 / (p['E_mod'] * ft ** 3)
    # 5) Seitenwand als eingespannter Träger (Last aus Boden, Hälfte je Seite), in der Schichtebene
    h = H - ft
    s_seite = 6 * (F / 2) * (il / 2) / (wall * h ** 2)
    # Reserven
    res = {'Rückwand (Zug quer)': SIG_Z / s_wand, 'Tragrahmen (Zug quer)': SIG_Z / s_band,
           'Hakenlippe (Biegung quer)': SIG_Z / s_lippe, 'Steg-Pressung': P_ZUL / pr,
           'Boden (Biegung)': SIG_XY / s_boden, 'Seitenwand (Biegung)': SIG_XY / s_seite}
    tilt = math.degrees(math.atan2(hook_over, z_lip))       # Neigung bis die Rückwandunterkante die Wand berührt (ohne Rippe)
    return dict(W=W, Ltot=Ltot, L=L, ft=ft, t_req=t_req, vol=vol, m_voll=m_voll, F=F, T=T, T_F=T / F,
                s_wand=s_wand, s_band=s_band, s_lippe=s_lippe, pr=pr, s_boden=s_boden, sag=sag,
                s_seite=s_seite, res=res, sf=min(res.values()), kritisch=min(res, key=res.get), tilt=tilt)


def groesse(s):
    m = re.fullmatch(r'(\d+)x(\d+)', s)
    if not m:
        sys.exit(f'Größe "{s}" nicht verstanden, erwartet z. B. 2x3 (Breite x Tiefe)')
    return int(m.group(1)), int(m.group(2))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    md = '--md' in sys.argv
    p = parameter()
    for a in [a for a in args if '=' in a]:
        k, v = a.split('=')
        if k not in p:
            sys.exit(f'Parameter {k} nicht in der SCAD-Datei')
        p[k] = float(v)
    groessen = [groesse(a) for a in args if '=' not in a] or [(1, 2), (2, 3), (3, 3), (4, 3), (4, 4), (6, 4)]
    zeilen = []
    for uw, ul in groessen:
        r = rechne(uw, ul, p)
        zeilen.append((f'{uw}x{ul}', r))
    if md:
        print('| Größe | außen B×T×H [mm] | Boden [mm] | Inhalt [l] | voll [kg] | Lippe quer [MPa] | Boden [MPa] / Durchb. [mm] | kleinste Reserve | empf. max. Füllung [kg] | kritisch |')
        print('|---|---|---|---|---|---|---|---|---|---|')
        for n, r in zeilen:
            print(f"| {n} | {r['W']:.1f} × {r['Ltot']:.1f} × {p['H']:.0f} | {r['ft']:.1f} | {r['vol']:.2f} | {r['m_voll']:.1f} | "
                  f"{r['s_lippe']:.1f} | {r['s_boden']:.1f} / {r['sag']:.1f} | **{r['sf']:.1f}×** | "
                  f"{min(r['m_voll'], r['m_voll'] * r['sf'] / SF_ZIEL):.1f} | {r['kritisch']} |")
    else:
        print(f"Annahmen: Füllgut {p['rho_bulk']} kg/l, Zuschlag Ruck ×{K_DYN}, zul. quer zu Schichten {SIG_Z} MPa, "
              f"in Schichtebene {SIG_XY} MPa, Steg-Pressung {P_ZUL} MPa ({ZUSTAND})\n")
        for n, r in zeilen:
            print(f"== {n}: {r['W']:.1f} x {r['Ltot']:.1f} x {p['H']:.0f} mm, Boden {r['ft']:.1f} mm (nötig {r['t_req']:.2f}), "
                  f"Inhalt {r['vol']:.2f} l, voll {r['m_voll']:.2f} kg (mit Zuschlag {r['F'] / G:.2f} kg)")
            print(f"   Kippmoment: Horizontalkraft an Lippe/Wandanlage T = {r['T']:.0f} N = {r['T_F']:.2f} x Gewichtskraft; "
                  f"Neigung bis Wandanlage ohne Rippe {r['tilt']:.1f} Grad")
            for k, v in r['res'].items():
                print(f"   {k:28s} Reserve {v:5.1f}x" + ('   <-- kleinste' if k == r['kritisch'] else ''))
            print(f"   empfohlene Maximalfüllung (Reserve {SF_ZIEL:.0f}x): {min(r['m_voll'], r['m_voll'] * r['sf'] / SF_ZIEL):.1f} kg")
            print(f"   Spannungen: Rückwand {r['s_wand']:.2f}, Rahmen {r['s_band']:.2f}, Lippe {r['s_lippe']:.1f}, "
                  f"Steg {r['pr']:.2f}, Boden {r['s_boden']:.1f}, Seitenwand {r['s_seite']:.2f} MPa; Boden-Durchbiegung {r['sag']:.1f} mm")


if __name__ == '__main__':
    main()

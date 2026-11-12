"""Ueberschlag fuer den Eigenbau-Demonstrator (alles Schaetzungen, nicht gemessen).

Aufruf: python3 -I demonstrator_rechnung.py
Aendere die Annahmen oben und vergleiche mit der Messung am Pruefgriff.
"""
import math

# --- Annahmen (Schaetzung) ---
Q_lpm = 8.0            # Durchfluss Dusche, l/min (Nutzer misst noch)
d_bore = 9.0           # freier Innendurchmesser Rotor, mm
dp_bar = 0.05          # Druckverlust Turbine, bar (Ziel 0.05-0.1)
eta_list = (0.05, 0.10, 0.20)   # Gesamtwirkungsgrad, optimistisch bei Eigenbau
r_rotor = 7.0          # Rotor-Aussenradius, mm
tip_ratio = 1.0        # Umfangsgeschw. / Axialgeschw. (kleine Turbine, grob)
n_mag = 8              # Magnete am Rotor, alternierend gepolt
mag_gap = 0.5 + 0.8    # Luftspalt + gedruckte Wand, mm
B_surf = 0.40          # Oberflaechenfeld Magnet 5x4x1 N, T (grob)
coil_w, coil_l = 4.0, 5.0   # Spulenflaeche pro Magnet, mm
wire_d = 0.10          # Kupferlackdraht, mm
turns_per_coil = 340
LED_Vf, LED_I, n_led = 2.0, 0.002, 5   # gelbe LEDs in Reihe

# --- Hydraulik ---
Q = Q_lpm / 60e3                         # m3/s
A = math.pi * (d_bore / 2) ** 2 * 1e-6   # m2
v_ax = Q / A
P_hyd = dp_bar * 1e5 * Q
print(f"Axialgeschw. im Rotor: {v_ax:.2f} m/s")
print(f"Hydraulische Leistung bei {dp_bar} bar: {P_hyd*1000:.0f} mW")
for e in eta_list:
    print(f"  elektrisch bei {e*100:.0f} %: {P_hyd*e*1000:.0f} mW")

# --- Drehzahl und Frequenz ---
v_tip = tip_ratio * v_ax
omega = v_tip / (r_rotor * 1e-3)
rpm = omega * 60 / (2 * math.pi)
f_el = (n_mag / 2) * rpm / 60
print(f"Drehzahl: {rpm:.0f} U/min, elektrische Frequenz: {f_el:.0f} Hz")

# --- Induzierte Spannung ---
B_coil = B_surf * 0.35    # Abfall ueber Spalt und Spulentiefe, grob
phi = B_coil * coil_w * coil_l * 1e-6
emf_turn = phi * 2 * math.pi * f_el
N = n_mag * turns_per_coil
emf_pk = emf_turn * N
print(f"Fluss pro Spule: {phi*1e6:.2f} uWb, Spitze/Windung: {emf_turn*1e3:.2f} mV")
print(f"Windungen gesamt: {N}, Leerlauf-Spitzenspannung: {emf_pk:.1f} V")

# --- Draht ---
len_turn = 2 * (coil_w + coil_l) + 4 * wire_d * 6   # grob, mm
R = N * len_turn * 1e-3 * 2.2   # 0.1 mm Cu ~ 2.2 ohm/m
print(f"Drahtlaenge: {N*len_turn/1000:.0f} m, Widerstand: {R:.0f} ohm")

# --- LED-Last ---
V_led = LED_Vf * n_led
P_led = V_led * LED_I
print(f"LED-Kette: {n_led} x {LED_Vf} V = {V_led:.0f} V, {LED_I*1e3:.0f} mA, {P_led*1e3:.0f} mW")
print(f"Reserve Spitzenspannung/LED-Spannung (Diodenverlust 0.6 V): {(emf_pk-0.6)/V_led:.1f}")

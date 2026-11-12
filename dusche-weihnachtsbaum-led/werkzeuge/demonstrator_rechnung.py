"""Überschlag für den Eigenbau-Demonstrator (alles Schätzungen, nicht gemessen).

Aufruf: python3 -I demonstrator_rechnung.py
Rechnet drei Dinge, die sich gegenseitig begrenzen:
  1. Drehzahl: folgt aus der Steigung der Schaufeln (Leerlauf = v_axial / Steigung),
     unter Last etwa die Hälfte.
  2. Spannung: aus dem Feld der Magnete (Blockformel) und der Frequenz.
  3. Kupfer: Platz im Spulenfenster begrenzt Windungszahl und Widerstand. Daraus
     folgt die größte Leistung bei angepasster Last. Sie hängt kaum von der
     Windungszahl ab, nur von Platz, Feld und Drehzahl.
"""
import math

# ---- Annahmen (Schätzung) ----
Q_lpm      = 8.0      # Durchfluss, l/min (Nutzer misst noch)
d_kanal    = 9.0      # freier Rotordurchmesser, mm
d_nabe     = 3.6
n_blatt, t_blatt = 4, 0.9
rotor_l    = 25.0     # mm
last_faktor = 0.5     # Betriebsdrehzahl / Leerlaufdrehzahl
pol_paare  = 4        # 8 Magnete
Br         = 1.4      # T, N50
mag_a, mag_b, mag_t = 4.0, 5.0, 1.0   # mm
tiefe      = 3.0      # radiale Tiefe der Spule, mm
fenster_b, fenster_l = 4.4, 5.4
fuell      = 0.55     # Kupferfüllfaktor (Hand gewickelt)
flaechen_faktor = 0.6 # mittlere Flussfläche / Spulenumriss
n_spulen   = 8
rho_cu     = 0.0175   # Ohm mm²/m

def block_B(z, a, b, L, Br):
    """Feld auf der Achse eines Quadermagneten, Abstand z von der Fläche (mm)."""
    t1 = math.atan(a*b/(2*z*math.sqrt(4*z*z + a*a + b*b)))
    t2 = math.atan(a*b/(2*(z+L)*math.sqrt(4*(z+L)**2 + a*a + b*b)))
    return Br/math.pi*(t1 - t2)

def rechne(twist_deg, wand, draht_d, spiel=0.5, ausgabe=True):
    # Drehzahl
    A_frei = math.pi/4*(d_kanal**2 - d_nabe**2) - n_blatt*t_blatt*(d_kanal-d_nabe)/2
    v = Q_lpm/60e3*1e9/A_frei                     # mm/s
    steigung = 360.0*rotor_l/twist_deg            # mm pro Umdrehung
    n_leer = v/steigung*60                        # U/min
    n_last = n_leer*last_faktor
    f_el = pol_paare*n_last/60
    # Feld und Fluss
    z0 = wand + spiel
    zs = [z0 + i*tiefe/10 for i in range(11)]
    B = sum(block_B(z, mag_a, mag_b, mag_t, Br) for z in zs)/len(zs)
    phi = B*flaechen_faktor*fenster_b*fenster_l*1e-6
    # Kupfer
    d_iso = draht_d + 0.015
    n_win = int((tiefe*fenster_b/2)*fuell/(d_iso**2))
    l_win = 9.0                                   # mm mittlere Windungslänge
    A_cu = math.pi/4*draht_d**2
    R = n_spulen*n_win*l_win*1e-3*rho_cu/A_cu
    emf = phi*2*math.pi*f_el*n_win*n_spulen       # Spitze Leerlauf
    P_max = (emf/math.sqrt(2))**2/(4*R)           # angepasste Last, effektiv
    if ausgabe:
        print(f"Verdrehung {twist_deg:.0f}°, Wand {wand} mm, Draht Ø{draht_d} mm:")
        print(f"  Steigung {steigung:.0f} mm/U, Leerlauf {n_leer:.0f} U/min, unter Last {n_last:.0f} U/min, {f_el:.0f} Hz")
        print(f"  Feld im Mittel {B*1000:.0f} mT, Fluss/Spule {phi*1e6:.2f} µWb")
        print(f"  Windungen/Spule {n_win}, gesamt {n_win*n_spulen}, Widerstand {R:.0f} Ω")
        print(f"  Leerlauf-Spitzenspannung {emf:.1f} V, größte Leistung bei Anpassung {P_max*1000:.1f} mW")
    return emf, R, P_max

if __name__ == "__main__":
    print(f"Hydraulik: {Q_lpm} l/min, freie Fläche im Rotor wird in rechne() berechnet\n")
    for tw, wand, dd in [(200, 1.0, 0.10), (200, 1.0, 0.08), (300, 1.0, 0.08), (300, 0.8, 0.08)]:
        rechne(tw, wand, dd)
        print()
    # LED-Bedarf
    print("LED-Bedarf (gelb, Vf ≈ 2 V):")
    for n, i_ma in [(3, 1.0), (3, 2.0), (5, 1.0), (5, 2.0)]:
        print(f"  {n} LEDs a {i_ma} mA: {n*2.0*i_ma:.0f} mW")
    print("\nGleichrichter (Schottky-Brücke) kostet ca. 0,8 V Spitze. Reihenschaltung: Spannung > n*2 V + 0,8 V nötig;")
    print("Parallelschaltung mit je einem Vorwiderstand braucht nur etwa 3 V, aber mehr Strom.")

// =====================================================================
//  DN110-Doppelbogen fuer den Einbau unter einer Arbeitsplatte an der Dachschraege.   OpenSCAD 2021.01 oder neuer.
//
//  Einbausituation (Seitenansicht, x = nach vorn von der Wand weg, z = nach oben, Nullpunkt = Schnittkante Dachschraege/Plattenoberseite):
//    - Die Dachschraege (dp_dach, 30 Grad zur Waagerechten) steigt zum Raum hin an; die Arbeitsplatte (waagerecht, Dicke dp_platte)
//      stoesst mit ihrer Hinterkante an das Dach.
//    - Das DN110-Rohr (Stumpf) liegt quer zur Zeichenebene im Knick zwischen Dach und Plattenunterseite
//      (Muffenaussenradius dp_muffe_r, dp_spiel_oben Luft nach oben zur Platte), laeuft nach dem 90-Grad-Knick nach vorn,
//      biegt durch die Platte nach oben und endet in einem Flanschring (Magnetflansch), der waagerecht auf der Platte sitzt.
//    - Auf den Flansch kommt der Winkeladapter: Flansch unten, Stutzen um 60 Grad aus der Senkrechten gekippt (Einschlusswinkel 120 Grad),
//      so dass der Schlauch parallel zur Dachschraege (30 Grad) nach vorn/oben am Dach entlang laeuft. (Die Dateien Hose_Adapter_Angled_v4/v41
//      haben nur 30 bzw. 45 Grad; der Mindestabstand unten ist fuer einen 60-Grad-Adapter mit Biegeradius 65-90 mm gerechnet.)
//      Der Flansch muss so weit vom Dach weg sitzen, dass der Adapter unter der Dachschraege Platz hat.
//
//  Aufbau: Das Teil ist der Doppelbogen aus abluft_dn110_winkel.scad; hier werden nur dessen Laengen aus der Einbausituation berechnet.
//  Export: werkzeuge/export_dn110_arbeitsplatte.sh
// =====================================================================

/* [Einbausituation] */
// dp_dach: Neigung der Dachschraege zur Waagerechten, Grad
dp_dach = 30;                    // [10:1:60]
// dp_platte: Dicke der Arbeitsplatte = Strecke, die das Rohr senkrecht durch die Platte laeuft, mm
dp_platte = 30;                  // [15:1:60]
// dp_muffe_r: Aussenradius des DN110-Rohrs samt Muffe (Schaetzung: Aussendurchmesser 118), mm
dp_muffe_r = 59;                 // [50:1:70]
// dp_spiel_oben: Luft zwischen Muffe und Plattenunterseite (Befestigung), mm
dp_spiel_oben = 4;               // [0:1:15]
// dp_spiel_dach: Luft zwischen Muffe und Dachschraege, mm
dp_spiel_dach = 3;               // [0:1:15]
// dp_u_flansch: waagerechter Abstand der Flanschmitte (Magnetflansch) von der Schnittkante Dach/Plattenoberseite, mm.
//   Mindestwert fuer einen 60-Grad-Adapter (Stutzen parallel zum Dach nach vorn, Flansch 22,9 mm ueber der Platte, 5 mm Luft zum Dach):
//   ca. 300 mm bei Biegeradius 65 mm, ca. 325 mm bei 90 mm. Bei kleinerem Wert Adapter pruefen. Standard 320 (laengere Strecke braucht 3 Teile).
dp_u_flansch = 320;              // [200:5:450]

// ---- aus der Einbausituation abgeleitete Laengen des Doppelbogens ----
dp_t = tan(dp_dach);
dp_r_bogen = 59.5;                                           // enger Bogen: Mittellinie 5 mm ueber Rohrradius (= pipe_od/2 + 5)
dp_u_unten = -dp_platte / dp_t;                              // Dachschnitt an der Plattenunterseite
dp_zc = -dp_platte - dp_muffe_r - dp_spiel_oben;             // Rohrachse unter der Plattenoberseite
dp_u_stumpf = dp_u_unten + ((dp_muffe_r + dp_spiel_dach) / cos(dp_dach) - dp_muffe_r - dp_spiel_oben) / dp_t;  // Rohrachse, tangential am Dach
dp_lauf = dp_u_flansch - dp_u_stumpf;                        // Achse Stumpf -> Flanschmitte (waagerecht)
dp_ring_l = 20;                                              // Gewindelaenge am Rohrende = Einschraubtiefe des Ringes (wk_thread_l)

include <abluft_dn110_winkel.scad>
// Ueberschreibt die Standardwerte des Doppelbogens (Literale oder nur bereits oben definierte Variablen verwenden!)
wk_r = dp_r_bogen;
wk_h = dp_lauf - 2 * dp_r_bogen;
wk_thread_l = dp_ring_l;
wk_v = dp_ring_l - dp_zc - dp_r_bogen;   // Ringauflage (Gewindelaenge ueber der Plattenoberseite) minus Hoehe des Bogenendes
wk_links = true;
wk_split = 125;                  // Teil 1 bekommt 125 mm der Waagerechten (so passen beide Teile in 240 mm)
echo(str("Einbau: Rohrachse ", round(dp_zc), " mm unter Plattenoberseite, ", round(-dp_u_stumpf), " mm hinter der Dach/Platten-Kante; Flanschmitte ", dp_u_flansch, " mm davor; waagerechte Strecke wk_h = ", round(wk_h), " mm, Senkrechte wk_v = ", round(wk_v), " mm"));

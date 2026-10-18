#!/usr/bin/env bash
# Erzeugt alle README-Bilder in ../bilder aus biomuell_system.scad.
# Nutzt natives OpenSCAD, wenn vorhanden, sonst den WebAssembly-Build (wird bei Bedarf geladen).
# Benötigt: python3 mit numpy + matplotlib; ohne natives OpenSCAD zusätzlich node und curl.
set -euo pipefail
HIER="$(cd "$(dirname "$0")" && pwd)"
PROJ="$(dirname "$HIER")"
SCAD="$PROJ/biomuell_system.scad"
TMP="${TMPDIR:-/tmp}/biomuell_bilder"
mkdir -p "$TMP"

if command -v openscad >/dev/null 2>&1; then
    oscad() { openscad "$@"; }
else
    export OPENSCAD_WASM_DIR="${OPENSCAD_WASM_DIR:-$HOME/.cache/openscad-wasm}"
    if [ ! -f "$OPENSCAD_WASM_DIR/openscad.wasm" ]; then
        mkdir -p "$OPENSCAD_WASM_DIR"
        for f in openscad.wasm openscad.wasm.js; do
            curl -sSL -o "$OPENSCAD_WASM_DIR/$f" \
                "https://github.com/openscad/openscad-wasm/releases/download/2022.03.20/$f"
        done
    fi
    # Reihenfolge wie bei openscad: <ein> -o <aus> [-D ...]
    oscad() { local ein="$1" aus="$3"; shift 3; node "$HIER/openscad_wasm.mjs" "$ein" "$aus" "$@"; }
fi

# Baugruppe: Teil an Einbauposition (teil="keins" unterdrückt die normale Ausgabe)
baugruppe() {  # name  openscad-ausdruck
    { cat "$SCAD"; echo "$2"; } > "$TMP/_$1.scad"
    oscad "$TMP/_$1.scad" -o "$TMP/$1" -D 'teil="keins"' > "$TMP/$1.log" 2>&1
}
TR_HAELFTEN='for (i = [0, 1]) translate([(i == 0 ? -1 : 1) * MT / 2, 0, 0]) intersection() { trichter_roh(); kasten(i, 0, T_CX, T_CY); }'

baugruppe asm_plattform.stl  'translate([0,0,PLATTE_OBEN_Z]) plattform_roh();' &
baugruppe asm_baender.stl    'baender_alle();' &
baugruppe asm_waende.stl     'waende_alle();' &
baugruppe asm_trichter.stl   "translate([0,0,absatz_z]) { $TR_HAELFTEN }" &
# Mittelteil nur, wenn eingestellt (Standard: keins)
MITTELTEIL=$(grep -oP '^mittelteil = \K[0-9.]+' "$SCAD" || echo 0)
if [ "${MITTELTEIL%.*}" != "0" ]; then
    baugruppe asm_mittelteil.stl 'translate([0,0,absatz_z]) mittelteil_roh();' &
else
    rm -f "$TMP/asm_mittelteil.stl"
fi
baugruppe asm_eimer.stl      'eimer_geist();' &
for p in plattform langseite seitenwand rastprobe; do
    oscad "$SCAD" -o "$TMP/$p.stl" -D "teil=\"$p\"" > "$TMP/$p.log" 2>&1 &
done
oscad "$SCAD" -o "$TMP/trichter0.stl" -D 'teil="trichter"' -D 'stueck=0' > "$TMP/trichter0.log" 2>&1 &
# Band der Schmalseite (Version 2, nur bei schmalseite_typ = band)
oscad "$SCAD" -o "$TMP/schmalseite.stl" -D 'teil="schmalseite"' -D 'schmalseite_typ="band"' > "$TMP/schmalseite.log" 2>&1 &
wait

# Schnitte als SVG: Längsschnitt y = 0 und Querschnitt x = 55 (durch ein Bügelbein), Schnitt durch die Wandstege
declare -A TEIL=(
    [plattform]='translate([0,0,PLATTE_OBEN_Z]) plattform_roh();'
    [baender]='baender_alle();'
    [waende]='waende_alle();'
    [trichter]='translate([0,0,absatz_z]) trichter_montiert();'
    [eimer]='eimer_geist();'
    [sack]='translate([-sack_b / 2, -sack_t / 2, PLATTE_OBEN_Z]) cube([sack_b, sack_t, absatz_z + absatz_bis_rand - 5 - PLATTE_OBEN_Z]);'
)
for k in "${!TEIL[@]}"; do
    baugruppe "sy_$k.svg" "projection(cut=true) rotate([90,0,0]) { ${TEIL[$k]} }" &
    baugruppe "sx_$k.svg" "projection(cut=true) rotate([0,-90,0]) translate([-55,0,0]) { ${TEIL[$k]} }" &
done
wait

# Schnitt durch einen Seitensteg der Wand (y = YC): Zapfen, Tasche, Rastnase (x, z)
for k in plattform waende; do
    baugruppe "sw_$k.svg" "projection(cut=true) rotate([90,0,0]) translate([0,-YC,0]) { ${TEIL[$k]} }" &
done
wait

grep -h "ECHO" "$TMP/plattform.log" || true
python3 "$HIER/bilder.py" "$TMP" "$PROJ/bilder"

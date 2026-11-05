#!/usr/bin/env bash
# Erzeugt den K40+-Abluftanschluss (abluft_k40_anschluss.scad) als STL in Druckpose:
#   k40_anschluss/k40_anschluss_muffe.stl     Platte + Bogen nach links + Muffe ueber den ø100-Stutzen (Standard)
#   k40_anschluss/k40_anschluss_magnet.stl    dasselbe mit 100er Magnetflansch statt Muffe
#   k40_anschluss/k40_anschluss_oring_tpu.stl TPU-O-Ring (3 mm Schnur) fuer die Muffen-Nut
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_k40_anschluss.sh [zielordner] [-D name=wert ...]
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-k40_anschluss}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
openscad -o "$ZIEL/k40_anschluss_muffe.stl"  -D 'ende="muffe"'  -D 'ausgabe="druck"' "$@" abluft_k40_anschluss.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
openscad -o "$ZIEL/k40_anschluss_magnet.stl" -D 'ende="magnet"' -D 'ausgabe="druck"' "$@" abluft_k40_anschluss.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
openscad -o "$ZIEL/k40_anschluss_oring_tpu.stl" -D 'ausgabe="oring"' "$@" abluft_k40_anschluss.scad 2>&1 | grep -E "WARNING|ERROR|Simple" || true
ls -la "$ZIEL"/*.stl

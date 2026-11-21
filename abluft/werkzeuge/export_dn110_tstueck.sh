#!/usr/bin/env bash
# Erzeugt das DN110-T-Stueck (abluft_dn110_tstueck.scad): dn110_tstueck/dn110_tstueck.stl und den TPU-Ring fuer die Muffen-Nut
# Aufruf (aus dem Ordner abluft/):   werkzeuge/export_dn110_tstueck.sh [zielordner] [-D name=wert ...]
#   Beispiel:  werkzeuge/export_dn110_tstueck.sh dn110_tstueck -D tm_muffe_t=45 -D tm_spiel=0.25
set -euo pipefail
cd "$(dirname "$0")/.."
ZIEL="${1:-dn110_tstueck}"; [[ $# -gt 0 ]] && shift
mkdir -p "$ZIEL"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
for t in "druck:dn110_tstueck.stl" "oring:dichtung_muffe_110_tpu.stl"; do
  a="${t%%:*}"; f="${t##*:}"
  openscad -o "$TMP/$f" -D "ausgabe=\"$a\"" "$@" abluft_dn110_tstueck.scad >"$TMP/log" 2>&1 || { cat "$TMP/log"; exit 1; }
  grep -E "WARN|ERROR|WARNUNG" "$TMP/log" || true
  grep -q "Simple:        yes" "$TMP/log" || { echo "WARNUNG: $f nicht 'Simple'"; cat "$TMP/log"; }
  cp "$TMP/$f" "$ZIEL/$f"; echo "ok: $ZIEL/$f"
done

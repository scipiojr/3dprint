@echo off
rem ===================================================================
rem  Exportiert die vier Druckteile des Randhalters als getrennte STL:
rem    randhalter_v3_1_clip.stl, randhalter_v3_2_gabel.stl,
rem    randhalter_v3_3_steckachse.stl, randhalter_v3_4_riegel.stl
rem  Diese Datei in denselben Ordner wie pool_randhalter_v3.scad legen
rem  und doppelklicken. Das Rendern dauert einige Minuten.
rem
rem  Verwendet die Werte, die in der .scad-Datei stehen. Wer Werte im
rem  Customizer geaendert hat: dort als Preset speichern und unten
rem  PRESET=Name eintragen.
rem ===================================================================
setlocal
set "OPENSCAD=C:\Program Files\OpenSCAD\openscad.exe"
if not exist "%OPENSCAD%" set "OPENSCAD=C:\Program Files (x86)\OpenSCAD\openscad.exe"
if not exist "%OPENSCAD%" (
  echo OpenSCAD wurde nicht gefunden. Bitte den Pfad in dieser Datei bei OPENSCAD anpassen.
  pause
  exit /b 1
)
set "SRC=%~dp0pool_randhalter_v3.scad"
set "PRESET="
set "PRESETARGS="
if not "%PRESET%"=="" set PRESETARGS=-p "%~dp0pool_randhalter_v3.json" -P "%PRESET%"

for %%T in (1:clip 2:gabel 3:steckachse 4:riegel) do (
  for /f "tokens=1,2 delims=:" %%a in ("%%T") do (
    echo Exportiere Teil %%a: %%b ...
    "%OPENSCAD%" %PRESETARGS% -D teil=%%a -o "%~dp0randhalter_v3_%%a_%%b.stl" "%SRC%"
  )
)
echo.
echo Fertig. Die STL-Dateien liegen im selben Ordner.
pause

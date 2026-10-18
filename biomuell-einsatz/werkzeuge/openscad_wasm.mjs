// OpenSCAD als WebAssembly unter Node ausführen (für Umgebungen ohne natives OpenSCAD).
// Aufruf: node openscad_wasm.mjs <eingabe.scad> <ausgabe.stl|.svg|.png> [-D name=wert ...]
// Erwartet openscad.wasm und openscad.wasm.js im Ordner $OPENSCAD_WASM_DIR (Standard: neben diesem Skript).
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { createRequire } from 'module';
const dir = path.dirname(fileURLToPath(import.meta.url));
const [inp, out, ...rest] = process.argv.slice(2);
const wdir = process.env.OPENSCAD_WASM_DIR || dir;
const wasmBinary = fs.readFileSync(path.join(wdir, 'openscad.wasm'));
const src = fs.readFileSync(path.join(wdir, 'openscad.wasm.js'), 'utf8');
const inst = { noInitialRun: true, wasmBinary,
  print: t => console.log(t), printErr: t => console.error(t) };
const ready = new Promise(r => { inst.onRuntimeInitialized = r; });
globalThis.OpenSCAD = inst;
const require = createRequire(import.meta.url);
(new Function('require', '__dirname', '__filename', src))(require, dir, path.join(dir, 'openscad.wasm.js'));
await ready;
inst.FS.writeFile('/in.scad', fs.readFileSync(inp, 'utf8'));
const ext = path.extname(out);
const args = ['/in.scad', '-o', '/out' + ext, ...rest];
let rc = 0;
try { rc = inst.callMain(args); } catch (e) { console.error('ERR', e); rc = 1; }
try { fs.writeFileSync(out, inst.FS.readFile('/out' + ext)); } catch (e) { console.error('no output'); rc = rc || 2; }
process.exit(rc);

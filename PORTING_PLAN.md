# Porting Plan: Godot 3.x (Mono) → Godot 4.7 (pure GDScript)

## Context and goals

This project is a small Control/UI-only desktop tool (~1,250 lines of GDScript, 10 scenes)
that talks to TuFFrabit devices over USB serial using a JSON-per-line protocol at 115200 baud.
The only reason it is a Godot Mono project is one 82-line C# class (`serial.cs`) wrapping
`System.IO.Ports` — Godot 3 had no other viable serial story. Godot 3.x is end-of-life
(3.6 was the final feature branch), so the port to 4.7.x is a maintenance necessity.

Decisions already made (see discussion in repo history / PR notes):

- **Target engine:** Godot 4.7.x, standard build (not .NET).
- **Serial:** [GdSerial](https://github.com/SujithChristopher/gdserial) (Rust GDExtension,
  MIT, actively maintained, prebuilt binaries for Windows/Linux/macOS on x64 + ARM64).
  Vendored into the repo, not pulled at build time.
- **Rejected:** godot-go (experimental, self-described memory leaks, single maintainer,
  cgo shim — worse maintenance risk than the C# it replaces), keeping Godot .NET
  (+50–80 MB of bundled runtime per export for 82 lines of code), full rewrites.
- **Invariants:** device protocol, scene layout, and user-facing behavior do not change.

---

## Phase 0 — Prep and de-risking spikes ✅ COMPLETE

Do these before touching project files. If a spike fails, the plan changes, not the code.

**Results (executed on the `godot-4-port` branch):**

1. ✅ Branch `godot-4-port` created; HEAD tagged `godot-3-final`. Main untouched.
2. ✅ Godot **4.7.1-stable standard** (`4.7.1.stable.official.a13da4feb`) downloaded to
   `tools/` (gitignored).
3. ✅ **Spike A — GdSerial v0.3.4 loads clean on 4.7.1** (`spikes/gdserial-test/`).
   `Initialize godot-rust (API v4.4.stable, runtime v4.7.1.stable)`, `GdSerial.new()`
   resolves, `list_ports()` executes (returned the machine's `/dev/ttyS*` UARTs — no USB
   serial attached, which is fine; the spike proves loading + API, not hardware).
   **Two gotchas:**
   - The release **zip asset ships a 0-byte `gdserial.gdextension`** (packaging bug).
     Vendor from the **`.tar.gz` asset** (or the file from the repo tag) instead.
   - On a fresh project the extension is **not loaded until one editor scan** has run
     (`--editor --headless --quit` generates `.godot/extension_list.cfg`). Do one
     editor scan before any headless run in Phases 1–2.
4. ✅ **Spike B — converter runs fully headless** (`spikes/convert-test/`):
   `godot --headless --editor --path <copy> --convert-3to4 --quit` (dry-run:
   `--validate-conversion-3to4`). **30/30 files converted, zero warnings/errors.** No
   editor dialog needed — the Phase 1 conversion step is scriptable. Confirmed the
   known traps are NOT auto-fixed: `stickGraph.gd` still gets `@export var size`
   (rename to `graph_size` still required, incl. the two `size = 160.0` overrides in
   `device.tscn`), and `dialogs.gd` still connects the nonexistent `modal_closed`
   signal (rework still required).
5. ⏳ Vendor the verified GdSerial version (**v0.3.4, from the `.tar.gz` asset**) into
   the real branch under `addons/gdserial/` and record version + source URL + license
   in the README. (First task of Phase 2.)

---

## Phase 1 — Mechanical engine port (3.x → 4.7)

Run the converter on the real branch (verified headless in Spike B:
`tools/Godot_v4.7.1-stable_linux.x86_64 --headless --editor --path <project> --convert-3to4 --quit`),
then apply the manual fixups below. The converter handles most renames; everything listed
here was confirmed by reading every script and by the Spike B spot-checks.

### Global GDScript changes

| Godot 3 | Godot 4 | Files affected |
|---|---|---|
| `onready var x = $y` | `@onready var x = $y` | all |
| `export var x setget fn` | `@export var x: set = fn` | `stickGraph.gd`, `spinBoxSliderCombo.gd` |
| `scene.instance()` | `scene.instantiate()` | `main.gd`, `device.gd`, `dialogs.gd` |
| `connect("sig", self, "m")` | `sig.connect(m)` | `device.gd`, `profileBase.gd`, `spinBoxSliderCombo.gd`, `dialogs.gd`, `main.gd` |
| `emit_signal("s", v)` | `s.emit(v)` | `device.gd`, `profiles.gd`, `textInputDialog.gd`, `connect.gd`, `spinBoxSliderCombo.gd` |
| `PoolIntArray` | `PackedInt32Array` | `profiles.gd` |
| `CheckBox/CheckButton.pressed` | `.button_pressed` | `device.gd`, `profile.gd`, `profileJoystick.gd` |
| `parse_json(s)` | `JSON.parse_string(s)` | `serialHelper.gd` |
| `JSON.print(v)` | `JSON.stringify(v)` | `serialHelper.gd` |
| `Directory` / `File` | `DirAccess` / `FileAccess` | `device.gd` (save flow) |
| `rect_size` / `rect_position` / `rect_min_size` | `size` / `position` / `custom_minimum_size` | `stickGraph.gd` |

### File-specific notes

- **`stickGraph.gd` — exported property name collision (required change).** It exports
  `var size`, which collides with `Control.size` in Godot 4, and `device.tscn` sets
  `size = 160.0` on both StickGraph instances. Rename the export to `graph_size`
  (script + the two `.tscn` property overrides). Everything else in the file
  (`draw_line`, `ReferenceRect`, `Color8`, `Color("8b8b8b")`) survives the port.
- **`dialogs.gd` — signal renames.** `AcceptDialog.window_title` → `title`.
  The `modal_closed` signal does not exist in Godot 4; free dialogs via
  `confirmed`/`canceled` (and `close_requested` if the window close button should
  also dismiss). `Engine.get_main_loop()` is unchanged.
- **`project.godot`.** Converter removes `_global_script_classes` (all classes already
  use `class_name`). Manually delete the `[mono]` section. Autoloads
  (`SerialHelper`, `Inputs`, `Dialogs`) carry over unchanged.
- **Delete .NET artifacts:** `serial.cs`, `godot-narwhal-manager.csproj`,
  `godot-narwhal-manager.sln`, `.mono/`, and the `serial.tscn` C# node scene
  (replaced in Phase 2). Remove `.mono` entries from `.gitignore`.
- **`.tscn` files.** Converter rewrites most properties. Manually re-check afterwards:
  - signal connections in the editor (Node → Signals),
  - anchors/offsets — the Godot 4 layout system conversion sometimes leaves controls
    one pixel off; eyeball every scene at 960×540,
  - the `device.tscn` StickGraph `size` overrides (see above).

### Validation gate for Phase 1

Project opens in 4.7 with zero errors, all scenes render correctly, and the app reaches
the connect screen. Serial functionality will still be broken — that is Phase 2.

---

## Phase 2 — Replace the serial layer with GdSerial

Keep `serialHelper.gd`'s public surface (`setSerial`, `doHandshake`,
`sendCommandAndGetResponse`, `deviceType`) identical so **no other script changes**.
Only its internals and the `serial` node swap out.

### API mapping (`serial.cs` → GdSerial)

| Current C# | GdSerial |
|---|---|
| `SerialPort.GetPortNames()` | `list_ports()` (Dictionary of port info) |
| `new SerialPort(name, 115200, None, 8, One)` + `DtrEnable` | `set_port()` / `set_baud_rate(115200)` / `set_data_bits(8)` / `set_parity(0)` / `set_stop_bits(1)` |
| `Open()` / `IsOpen` / `Close()` | `open()` / `is_open()` / `close()` |
| `ReadTimeout`/`WriteTimeout = 1000` | `set_timeout(1000)` |
| `WriteLine(s)` | `writeline(s)` |
| `ReadLine()` | `readline()` |

### Steps

1. Add a `GdSerial` node (or plain `RefCounted` instance) where `serial.tscn`'s C# node
   used to live; wire it into `SerialHelper.setSerial()` in `main.gd` as today.
2. Rewrite `serialHelper.gd` internals against GdSerial using the table above.
3. Port-name handling becomes per-OS for free (`COM*`, `/dev/ttyUSB*`/`/dev/ttyACM*`,
   `/dev/tty.usbserial-*` come out of `list_ports()`). Document the Linux `dialout`
   group requirement in the README.
4. **Optional 2b (recommended, still no UI change):** use `GdSerialManager` (async,
   signal-based, line-buffered mode) for the handshake and the stick-reading timer.
   Today every `readline()` blocks the main thread up to 1 s — `doHandshake()` loops
   over ports and can freeze the UI for several seconds, and `readStickValuesTimer`
   stalls every poll. Signals + `poll_events()` fix this without touching the UI.
   Defer to 2b if the synchronous port proves correct first.

### Validation gate for Phase 2

Full handshake with real hardware, `getGlobalSettings` load, a round-trip of every
`set*` command, live stick graphs, save, and disconnect/reconnect — on Windows and Linux.

---

## Phase 3 — Low-hanging fruit (no API or UI changes)

Bugs and cleanups found while reading the code. Each is small; do them as separate
commits after the port is green. Items marked *(string)* alter a user-visible message
only to fix wrong text.

1. **Leaked profile instance** — `device.gd:78-83`: `profileScene.instance()` is called
   unconditionally, then reassigned in the `if/elif`. For Tuffjoystick the first
   instance is orphaned and never freed. Create the instance only inside the branches.
2. **Controls stay disabled after a failed update** — `device.gd` (e.g.
   `stickBoundLowXValueChanged`, repeated 8×): `setEditable(false)` is reverted with
   `setEditable(true)` only on success. On failure the control is dead until reconnect.
   Re-enable on the failure path too (or in a `finally`-style single exit).
3. **Leaked device screen on disconnect** — `main.gd` `disconnectClick()` and
   `_on_pingTimer_timeout()`: `deviceInstance` is `remove_child`'d but never
   `queue_free()`'d; leaks once per disconnect/reconnect cycle.
4. **Dialogs may leak** — `dialogs.gd`: dialogs are freed only via `modal_closed`;
   after the Godot 4 signal rework (Phase 1), make every exit path
   (confirm / cancel / window close) free the dialog.
5. **Debug print in production path** — `profileBase.gd:16`:
   `print(childContainer.get_class())` runs on every profile load. Delete.
6. **Dead code** — `device.gd:104-118` `getCorrectDriveName()` (v1) is unused
   (only `getCorrectDriveName2()` is called), and the commented-out
   `saveEverything` line at `device.gd:102`. Remove.
7. **Copy-paste error message** *(string)* — `profiles.gd:174`: rename failure shows
   "Profile creation failed on the device." Should say rename failed.
8. **Windows-only save path** — `device.gd:120-132` scans `A:`–`Z:` with `\\` paths.
   Godot 4's `DirAccess.get_drive_count()`/`get_drive()` works cross-platform
   (volumes on Linux/macOS). Rework the scan to be per-OS so the save flow works
   everywhere the app now runs. No UI change.
9. **Slow connect** (covered by Phase 2b if taken) — handshake probes every port with
   a 1 s blocking read each. Even staying synchronous, a shorter probe timeout or
   skipping ports whose names can't match is a cheap win.

---

## Phase 4 — Minimizing the shipped binary

Ordered by impact. Reference: Godot docs,
[Optimizing a build for size](https://docs.godotengine.org/en/stable/contributing/development/compiling/optimizing_for_size.html).

### 4.1 Already won by the port itself

- **Dropping .NET** is the single largest reduction: no bundled Mono/.NET runtime
  (~50–80 MB per export), and exports use the standard template.

### 4.2 Export hygiene (no engine rebuild)

- Export preset: `binary_format/embed_pck=true`, only the texture formats we need.
- Prune dead resources before export: `.import/` leftovers, unused assets; the export
  `export_filter` can exclude everything but `*.gd`, `*.tscn`, `*.tres`, `icon.png`,
  `addons/gdserial/**`.
- Distribute as a 7-Zip archive (`7z a -mx9`) rather than plain zip.

### 4.3 Custom export templates (engine rebuild — the big lever)

Official templates contain the whole engine. Build lean templates from the
`4.7.x-stable` source tag, per target platform. Keep using the **official editor**;
only templates are custom.

Base invocation (per platform):

```
scons platform=<windows|linux|macos> target=template_release production=yes \
      lto=full optimize=size debug_symbols=no disable_3d=yes \
      module_text_server_adv_enabled=no module_text_server_fb_enabled=yes
```

- `lto=full`, `optimize=size`, `debug_symbols=no` — high savings, no behavior change.
  (With MinGW, `strip` the binary afterwards instead of relying on `debug_symbols=no`.)
- `disable_3d=yes` — ~15% smaller; this app has zero 3D. Also disables navigation,
  which we don't use. Editor builds can't use this flag; templates can.
- Fallback text server — the UI is English-only, so dropping the advanced text server
  (complex scripts, ligatures) is safe. **Always pair** `module_text_server_adv_enabled=no`
  with `module_text_server_fb_enabled=yes` or no text renders at all.
- **Do NOT use `disable_advanced_gui=yes`.** It removes classes this project depends on:
  `OptionButton`, `SpinBox`, `ColorPickerButton`, `AcceptDialog`, `ConfirmationDialog`.
- Module pruning via `custom.py` in the build tree. Candidates from the docs' list that
  are safe here: `basis_universal, csg, dds, enet, gridmap, jsonrpc, ktx, meshoptimizer,
  mobile_vr, msdfgen, multiplayer, noise, navigation, ogg, openxr, raycast, squish,
  theora, tinyexr, upnp, vhacd, vorbis, webrtc, websocket, webxr`. **Keep** freetype,
  png, jpg, `text_server_fb`, and anything GUI/theme related; run `scons --help` and
  prune conservatively — each removal is a template rebuild + app smoke test.
- Register the result in the export preset as a custom template
  (`custom_template/release`, `custom_template/debug`).

**Ongoing cost:** templates must be rebuilt for each Godot patch release you ship on,
and the app must be smoke-tested against them (they're the runtime your users get).
Script the build (`build_templates.sh`) so this is one command, and record the flags
in the repo.

### 4.4 Measure

Track template + final zip sizes per release in the README so regressions are visible.
Don't chase the last few MB at the cost of unbuildable templates.

---

## Phase 5 — Final QA checklist

- [ ] Project opens clean in 4.7 editor, no conversion warnings outstanding
- [ ] Handshake + full settings round-trip on real Tuffpad and Tuffjoystick hardware
- [ ] Profile create / rename / delete / reorder / activate
- [ ] Live stick graphs start/stop, no UI stalls
- [ ] Save-to-device flow (Windows drive + Linux/macOS volume)
- [ ] Disconnect → reconnect cycle repeatedly (watch for leaks from Phase 3 items 1/3)
- [ ] Windows, Linux, macOS exports from the custom templates
- [ ] Linux: serial works for a user in `dialout`; failure message is sane otherwise
- [ ] No `serial.cs`/Mono artifacts left in exports; binary sizes recorded

## Risks and open questions

- ~~**GdSerial on 4.7**~~ — **resolved by Spike A**: v0.3.4 loads and runs on 4.7.1
  (see Phase 0 for the two packaging gotchas). Remaining fallback if trouble appears
  later: build from source, or temporarily keep Godot .NET.
- **Scene layout drift** from the anchor/offset conversion — cosmetic, caught in
  Phase 1 review.
- **Firmware protocol is unchanged** — the device doesn't know or care what engine
  version the manager runs; risk here is nil as long as the byte-level behavior of
  `serialHelper` is preserved.
- **Custom template maintenance** — one rebuild per Godot patch release; scripted.

## Explicitly out of scope

- godot-go or any non-GDScript scripting layer
- UI redesign, new features, protocol changes
- Mobile/web exports (GDExtension serial is desktop-only anyway)

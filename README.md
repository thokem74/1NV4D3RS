# 1NV4D3RS

An endless neon arcade shooter, built with Godot 4.7.2 and GDScript. Original pixel-style graphics are drawn in code; original synth music and sound effects are included locally. No network services or external dependencies are used at runtime.

## Play

Open `project.godot` in Godot and press **F6 on main.tscn**, or **F5** from anywhere. From a terminal:

```sh
godot --path .
# Reproduce a run's formations and pickup rolls:
godot --path . -- --seed=42
```

| Action | Keyboard | Controller |
| --- | --- | --- |
| Move | A/D or left/right arrows | Left stick or D-pad |
| Fire (hold) | Space | A / cross (primary face button) |
| Dash | Shift | B / circle (secondary face button) |
| Pause / resume | Escape | Start |
| Menu navigation | Arrows, Enter | D-pad, primary face button |

Survive with three hull points. Dash grants brief invulnerability and recharges in 1.2 seconds. Damage grants 1.3 seconds of protection. Destroy every enemy to advance; a flagship arrives every fifth wave. Pickups fall toward your ship:

- **R**: rapid fire for ten seconds.
- **W**: three-way spread for ten seconds.
- **S**: shield absorbs one hit.
- **+**: repairs one hull point, up to three.

Weapon pickups refresh their own duration and can coexist. Shield does not stack. Wave clears, enemies, and bosses award score. Runs start fresh; only the best score and settings persist. Settings include three volume controls, shake intensity, reduced flashes, and fullscreen.

## Design and tuning

`scenes/main.tscn` coordinates reusable actor, projectile, pickup, effect, and UI scenes. Run flow is in `scripts/game.gd`; wave generation, projectile spawning, scorekeeping, audio, and settings have separate components. Combat signals drive sound and effects. The HUD is outside the shaken world and postprocessing layer.

The `.tres` resources in `resources/` configure enemy health, points, colors and firing intervals, pickup duration, and difficulty limits. Wave layouts use a seeded RNG and three formation/movement templates. Enemy count caps at 42, hostile shots at 64, and enemy bullet speed at 155 logical pixels/second. Bosses alternate fan volleys and twin aimed spreads. Reproducibility applies to the same sequence of player actions and kills; cosmetic particles/audio pitch are intentionally independent.

The game uses a 640×360 logical canvas with aspect-preserving scaling and Forward Plus. Synth assets can be regenerated with `python tools/generate_audio.py` using only the Python standard library. Saves live in Godot's `user://pilot.cfg` (normally `~/.local/share/godot/app_userdata/1NV4D3RS/` on Linux). Invalid values fall back to defaults or are clamped.

## Validation

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/smoke.gd
godot --headless --path . --script tests/combat.gd
# Opens a rendering window and writes screenshots to /tmp/invaders-*.png:
godot --path . --script tests/visual.gd -- --seed=42
```

The smoke suite checks movement, dash protection, damage grace, pickups, restart, persistence using a separate test save, generation across 300 waves, projectile caps, boss alternation, and cleanup. Combat integration checks all enemy types, kill scoring, a late-run boss, projectile speeds, and synthetic keyboard/controller bindings. Rendering checks cover title, settings, gameplay, and boss screens. A physical controller and extended human difficulty/play-feel testing are still recommended; no controller was attached during development.

## Desktop export

Install Godot **4.7.2 export templates** via Editor → Manage Export Templates. A Linux x86_64 preset is included. Create a `build` directory, then run:

```sh
mkdir -p build
godot --headless --path . --export-release "Linux" build/1NV4D3RS.x86_64
```

For Windows or macOS, add the corresponding desktop preset through Project → Export and install matching templates. Keep Forward Plus and test on the target GPU. This repository has no browser export or online leaderboard. Exported binaries require the matching templates and have not been packaged here.

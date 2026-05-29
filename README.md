# Uff-Duh Card Game (Godot 4 + Steam)

Initial scaffold for a PC card game targeting **Windows + Linux** with:

- Godot 4
- GodotSteam
- Steam Datagram Relay (planned integration)
- Rule-based AI opponents

## Current status

This repository now includes a first playable local loop:

- Uff-Duh domain model (cards, round flow, turn order)
- Full Uff-Duh deck generator (00..99 unique pairs, 55 cards total)
- Branch matching logic and first-turn branch protection rule
- Draw/pass behavior
- UFF-DA declaration + catch penalty flow
- 10-round scoring framework with increasing round bonus
- Baseline rule-based AI for local bots
- Steam service and online session placeholders for GodotSteam + SDR wiring
- Local human-vs-AI turn loop wired to the main scene UI
- Linux export preset scaffold (`export_presets.cfg`)

## Project layout

- `/project.godot` — Godot project config
- `/scenes/main.tscn` — minimal startup scene
- `/scenes/ui/game_ui.tscn` — UI mock scene for table/hand layout
- `/scripts/core` — game rules and match state
- `/scripts/ai` — rule-based AI decisions
- `/scripts/net` — Steam/network integration stubs
- `/scripts/game` — game bootstrap controller
- `/docs/ui_scene_layout_spec.md` — Godot UI scene layout spec for table/hand UX
- `/.vscode` — workspace config for local pickup in VS Code

## Next steps

1. Improve card visuals and branch interaction affordances.
2. Add missing rule polish (UFF-DA catch interactions in UI flow).
3. Wire Steam lobby lifecycle and P2P transport through GodotSteam + SDR.
4. Add deterministic replay/test fixtures for rule validation.
5. Add CI smoke checks for headless startup + script linting.

## Local pickup in VS Code (PC)

1. Open this folder in VS Code:
   - `/tmp/workspace/thedevgeek/uff-duh-card-game` (in this environment)
   - Your local clone path on your PC
2. Install recommended extensions when prompted.
3. Ensure Godot 4 is installed. Tasks call `./run_godot.sh`, which auto-detects `godot4`, `godot`, or Flatpak `org.godotengine.Godot`.
4. Run a task:
   - `Godot: Open Editor`
   - `Godot: Run Project`
   - `Godot: Run Headless Check`

If no executable is found, install Godot 4 and rerun `Godot: Run Headless Check`.

# Uff-Duh Card Game (Godot 4 + Steam)

Initial scaffold for a PC card game targeting **Windows + Linux** with:

- Godot 4
- GodotSteam
- Steam Datagram Relay (planned integration)
- Rule-based AI opponents

## Current status

This repository now includes a first playable simulation layer:

- Uff-Duh domain model (cards, round flow, turn order)
- Full Uff-Duh deck generator (00..99 unique pairs, 55 cards total)
- Branch matching logic and first-turn branch protection rule
- Draw/pass behavior
- UFF-DA declaration + catch penalty flow
- 10-round scoring framework with increasing round bonus
- Baseline rule-based AI for local bots
- Steam service and online session placeholders for GodotSteam + SDR wiring

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

1. Add card/branch table UI and player hand UX.
2. Add real turn actions (input-driven + remote RPC events).
3. Replace bootstrap simulation loop with proper game loop/state machine.
4. Wire Steam lobby lifecycle and P2P transport through GodotSteam + SDR.
5. Add deterministic replay/test fixtures for rule validation.

## Local pickup in VS Code (PC)

1. Open this folder in VS Code:
   - `/tmp/workspace/thedevgeek/uff-duh-card-game` (in this environment)
   - Your local clone path on your PC
2. Install recommended extensions when prompted.
3. Ensure `godot4` is on your PATH (or update `.vscode/tasks.json` to your Godot executable path).
4. Run a task:
   - `Godot: Open Editor`
   - `Godot: Run Project`
   - `Godot: Run Headless Check`

If your Godot executable is named `godot` instead of `godot4`, replace `godot4` in `.vscode/tasks.json` and `.vscode/launch.json`.

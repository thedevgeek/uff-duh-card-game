# Uff-Duh Card Game (Godot 4 + Steam)

Initial scaffold for a PC card game targeting **Windows + Linux** with:

- Godot 4
- GodotSteam
- Steam Datagram Relay (planned integration)
- Rule-based AI opponents

## Current status

This repository now includes a first playable simulation layer:

- Uff-Duh domain model (cards, round flow, turn order)
- Branch matching logic and first-turn branch protection rule
- Draw/pass behavior
- UFF-DA declaration + catch penalty flow
- 10-round scoring framework with increasing round bonus
- Baseline rule-based AI for local bots
- Steam service and online session placeholders for GodotSteam + SDR wiring

## Project layout

- `/project.godot` — Godot project config
- `/scenes/main.tscn` — minimal startup scene
- `/scripts/core` — game rules and match state
- `/scripts/ai` — rule-based AI decisions
- `/scripts/net` — Steam/network integration stubs
- `/scripts/game` — game bootstrap controller

## Next steps

1. Add card/branch table UI and player hand UX.
2. Add real turn actions (input-driven + remote RPC events).
3. Replace bootstrap simulation loop with proper game loop/state machine.
4. Wire Steam lobby lifecycle and P2P transport through GodotSteam + SDR.
5. Add deterministic replay/test fixtures for rule validation.

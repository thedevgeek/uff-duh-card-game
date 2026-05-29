# Uff-Duh UI Scene Layout Spec (Godot 4)

## Purpose
A practical scene layout for the in-game table UI that supports:
- local play
- AI opponents
- future online play via Steam

## Scene file target
`scenes/ui/game_ui.tscn`

## Control tree

```text
GameUI (Control)
├─ SafeArea (MarginContainer)
│  └─ RootVBox (VBoxContainer)
│     ├─ TopBar (HBoxContainer)
│     │  ├─ RoundLabel (Label)
│     │  ├─ Spacer (Control)
│     │  ├─ DeckCountLabel (Label)
│     │  └─ UffDaButton (Button)
│     ├─ TableArea (PanelContainer)
│     │  └─ TableCenter (Control)
│     │     ├─ CenterCard (PanelContainer)
│     │     │  └─ CenterCardValue (Label)
│     │     ├─ BranchNorth (PanelContainer)
│     │     │  └─ BranchNorthValue (Label)
│     │     ├─ BranchEast (PanelContainer)
│     │     │  └─ BranchEastValue (Label)
│     │     ├─ BranchSouth (PanelContainer)
│     │     │  └─ BranchSouthValue (Label)
│     │     └─ BranchWest (PanelContainer)
│     │        └─ BranchWestValue (Label)
│     ├─ OpponentsRow (HBoxContainer)
│     │  ├─ OpponentSlot1 (PanelContainer)
│     │  ├─ OpponentSlot2 (PanelContainer)
│     │  ├─ OpponentSlot3 (PanelContainer)
│     │  └─ OpponentSlot4 (PanelContainer)
│     ├─ PlayerHandRow (HBoxContainer)
│     │  ├─ HandScroll (ScrollContainer)
│     │  │  └─ HandCards (HBoxContainer)
│     │  └─ ActionColumn (VBoxContainer)
│     │     ├─ DrawButton (Button)
│     │     ├─ PassButton (Button)
│     │     └─ PlaySelectedButton (Button)
│     └─ FooterBar (HBoxContainer)
│        ├─ StatusLabel (Label)
│        └─ ScoresLabel (Label)
└─ Overlays (CanvasLayer)
   ├─ PenaltyToast (PanelContainer)
   └─ RoundEndDialog (AcceptDialog)
```

## Theme tokens
- Background: `#121826`
- Surface: `#F8F6F2`
- Ink: `#1B1B1B`
- Accent (Playable): `#3A7BD5`
- Accent (Warning): `#E24A4A`
- Accent (Selected): `#E0B84C`
- Radius: `14`
- Border width: `2`

## Card visual token mapping
- Card base: rounded panel, Surface + Ink border
- Corner values: top-left and top-right labels
- Main value: centered vertical `a / b` display
- Selection state: Selected accent border
- Playable state: blue glow outline
- Penalty state: red flash animation

## Data bindings
- `RoundLabel`: `game_state.round_number`
- `DeckCountLabel`: `game_state.deck.size()`
- `Branch*Value`: `game_state.branches[index]`
- `ScoresLabel`: formatted `game_state.score_totals`
- `StatusLabel`: turn state + prompts (e.g. declare UFF-DA)

## Input flows
1. Select card in `HandCards`.
2. Click branch target in `TableCenter`.
3. Confirm with `PlaySelectedButton`.
4. If no move, use `DrawButton`.
5. Use `UffDaButton` when one card remains.

## Integration notes
- Keep this UI scene independent from networking transport.
- Drive it with a presenter/controller script that consumes `UffDuhGameState`.
- Reuse for local and online modes by swapping input source only.

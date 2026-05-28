extends Node

const State := preload("res://scripts/core/uff_duh_game_state.gd")
const AI := preload("res://scripts/ai/uff_duh_rule_ai.gd")

var game_state := UffDuhGameState.new()
var ai := UffDuhRuleAI.new()

func _ready() -> void:
game_state.new_match(2)
_run_bootstrap_simulation(20)

func _run_bootstrap_simulation(max_turns: int) -> void:
for _turn in range(max_turns):
var current := game_state.turn_index
var action := ai.choose_action(game_state, current)
match action.get("type", "wait"):
"declare_uff_da":
game_state.declare_uff_da(current)
"play":
game_state.play_move(current, action["move"])
"draw":
game_state.draw_and_pass(current)
_:
pass
if game_state.round_winner() >= 0:
var winner := game_state.apply_round_scoring()
print("Round %d winner: Player %d" % [game_state.round_number, winner])
game_state.advance_round()
break

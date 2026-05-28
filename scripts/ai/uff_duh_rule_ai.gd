class_name UffDuhRuleAI
extends RefCounted

func choose_action(state: UffDuhGameState, player_id: int) -> Dictionary:
if player_id != state.turn_index:
return {"type": "wait"}

if state.hands[player_id].size() == 1 and not state.declared_uff_da[player_id]:
return {"type": "declare_uff_da"}

var moves := state.legal_moves(player_id)
if moves.is_empty():
return {"type": "draw"}

var best_move := moves[0]
var best_score := 1_000_000
for m in moves:
var card: UffDuhCard = state.hands[player_id][m["card_index"]]
var remaining_pips := _remaining_pips_after_play(state.hands[player_id], m["card_index"])
var branch_bonus := 0
if int(m["branch"]) == player_id:
branch_bonus = -1
var total := remaining_pips + card.pip_total() + branch_bonus
if total < best_score:
best_score = total
best_move = m

return {"type": "play", "move": best_move}

func _remaining_pips_after_play(hand: Array, card_index: int) -> int:
var sum := 0
for idx in range(hand.size()):
if idx == card_index:
continue
sum += hand[idx].pip_total()
return sum

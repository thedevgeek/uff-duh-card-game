class_name UffDuhGameState
extends RefCounted

const Rules := preload("res://scripts/core/uff_duh_rules.gd")

var player_count := 0
var round_number := 1
var turn_index := 0

var branches: Array[int] = []
var hands: Array[Array[UffDuhCard]] = []
var deck: Array[UffDuhCard] = []
var discard: Array[UffDuhCard] = []
var score_totals: Array[int] = []
var protected_branch: Array[bool] = []
var declared_uff_da: Array[bool] = []

func new_match(total_players: int) -> void:
player_count = clampi(total_players, 2, 8)
round_number = 1
score_totals = []
for _i in range(player_count):
score_totals.append(0)
start_round()

func start_round() -> void:
turn_index = 0
branches = []
hands = []
protected_branch = []
declared_uff_da = []
for _i in range(player_count):
branches.append(0)
hands.append([])
protected_branch.append(false)
declared_uff_da.append(false)

deck = Rules.build_standard_deck()
deck.shuffle()
discard = [UffDuhCard.new(0, 0)]
for p in range(player_count):
for _n in range(Rules.HAND_SIZE):
hands[p].append(deck.pop_back())

func legal_moves(player_id: int) -> Array[Dictionary]:
var moves: Array[Dictionary] = []
for card_idx in range(hands[player_id].size()):
var card: UffDuhCard = hands[player_id][card_idx]
if not protected_branch[player_id]:
if card.matches(branches[player_id]):
moves.append({"card_index": card_idx, "branch": player_id})
continue
for branch_idx in range(player_count):
if card.matches(branches[branch_idx]):
moves.append({"card_index": card_idx, "branch": branch_idx})
return moves

func play_move(player_id: int, move: Dictionary) -> bool:
if player_id != turn_index:
return false
if not move.has("card_index") or not move.has("branch"):
return false

var card_index: int = move["card_index"]
var branch_idx: int = move["branch"]
if card_index < 0 or card_index >= hands[player_id].size():
return false
if branch_idx < 0 or branch_idx >= player_count:
return false

var card: UffDuhCard = hands[player_id][card_index]
if not card.matches(branches[branch_idx]):
return false
if not protected_branch[player_id] and branch_idx != player_id:
return false

branches[branch_idx] = card.other_side(branches[branch_idx])
hands[player_id].remove_at(card_index)
discard.append(card)
protected_branch[player_id] = true
declared_uff_da[player_id] = false
advance_turn()
return true

func draw_and_pass(player_id: int) -> void:
if player_id != turn_index:
return
if deck.is_empty() and discard.size() > 1:
var top: UffDuhCard = discard.pop_back()
deck = discard
deck.shuffle()
discard = [top]
if not deck.is_empty():
hands[player_id].append(deck.pop_back())
advance_turn()

func declare_uff_da(player_id: int) -> void:
if hands[player_id].size() == 1:
declared_uff_da[player_id] = true

func catch_missing_uff_da(caller_id: int, target_id: int) -> bool:
if caller_id == target_id:
return false
if hands[target_id].size() != 1:
return false
if declared_uff_da[target_id]:
return false
if deck.is_empty():
return false
hands[target_id].append(deck.pop_back())
return true

func round_winner() -> int:
for p in range(player_count):
if hands[p].is_empty():
return p
return -1

func apply_round_scoring() -> int:
var winner := round_winner()
if winner < 0:
return -1
var bonus := Rules.round_bonus(round_number)
for p in range(player_count):
score_totals[p] += Rules.hand_penalty_score(hands[p])
score_totals[winner] -= bonus
return winner

func is_match_finished() -> bool:
return round_number > Rules.ROUNDS

func advance_round() -> void:
round_number += 1
if not is_match_finished():
start_round()

func advance_turn() -> void:
turn_index = (turn_index + 1) % player_count

class_name UffDuhRules
extends RefCounted

const HAND_SIZE := 7
const ROUNDS := 10
const MAX_PIP := 9

static func build_standard_deck() -> Array[UffDuhCard]:
var deck: Array[UffDuhCard] = []
for left in range(MAX_PIP + 1):
for right in range(left, MAX_PIP + 1):
deck.append(UffDuhCard.new(left, right))
return deck

static func round_bonus(round_number: int) -> int:
return round_number * 5

static func hand_penalty_score(cards: Array[UffDuhCard]) -> int:
var sum := 0
for c in cards:
sum += c.pip_total()
return sum

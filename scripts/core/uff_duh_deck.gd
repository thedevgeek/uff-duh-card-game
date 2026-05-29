class_name UffDuhDeck
extends RefCounted

const MAX_PIP := 9

static func create_standard_deck() -> Array[UffDuhCard]:
	var deck: Array[UffDuhCard] = []
	for left in range(MAX_PIP + 1):
		for right in range(left, MAX_PIP + 1):
			deck.append(UffDuhCard.new(left, right))
	return deck

static func create_shuffled_standard_deck() -> Array[UffDuhCard]:
	var deck := create_standard_deck()
	deck.shuffle()
	return deck

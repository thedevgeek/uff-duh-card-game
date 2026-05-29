extends Node

const AI := preload("res://scripts/ai/uff_duh_rule_ai.gd")
const CARD_BUTTON_SCENE := preload("res://scenes/ui/card_button.tscn")
const CARD_BUTTON_SCRIPT := preload("res://scripts/ui/card_button.gd")
const DECK_SCRIPT := preload("res://scripts/core/uff_duh_deck.gd")

const HUMAN_PLAYER_ID := 0
const AI_DELAY_SECONDS := 0.35

@onready var game_ui: Control = $GameUI
@onready var round_label: Label = $GameUI/SafeArea/RootVBox/TopBar/RoundLabel
@onready var deck_count_label: Label = $GameUI/SafeArea/RootVBox/TopBar/DeckCountLabel
@onready var theme_toggle_button: BaseButton = $GameUI/SafeArea/RootVBox/TopBar/ThemeToggleButton
@onready var uff_da_button: Button = $GameUI/SafeArea/RootVBox/TopBar/UffDaButton
@onready var center_card_value: Label = $GameUI/SafeArea/RootVBox/TableArea/TableCenter/CenterCard/CenterCardValue
@onready var branch_north_value: Label = $GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchNorth/BranchNorthValue
@onready var branch_east_value: Label = $GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchEast/BranchEastValue
@onready var branch_south_value: Label = $GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchSouth/BranchSouthValue
@onready var branch_west_value: Label = $GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchWest/BranchWestValue
@onready var opponents_row: HBoxContainer = $GameUI/SafeArea/RootVBox/OpponentsRow
@onready var hand_cards: HBoxContainer = $GameUI/SafeArea/RootVBox/PlayerHandRow/HandScroll/HandCards
@onready var draw_button: Button = $GameUI/SafeArea/RootVBox/PlayerHandRow/ActionColumn/DrawButton
@onready var pass_button: Button = $GameUI/SafeArea/RootVBox/PlayerHandRow/ActionColumn/PassButton
@onready var play_selected_button: Button = $GameUI/SafeArea/RootVBox/PlayerHandRow/ActionColumn/PlaySelectedButton
@onready var debug_selection_label: Label = $GameUI/SafeArea/RootVBox/DebugPanel/DebugVBox/DebugSelectionLabel
@onready var debug_legal_moves_label: Label = $GameUI/SafeArea/RootVBox/DebugPanel/DebugVBox/DebugLegalMovesLabel
@onready var style_qa_toggle_button: Button = $GameUI/SafeArea/RootVBox/DebugPanel/DebugVBox/StyleQAToggleButton
@onready var status_label: Label = $GameUI/SafeArea/RootVBox/FooterBar/StatusLabel
@onready var scores_label: Label = $GameUI/SafeArea/RootVBox/FooterBar/ScoresLabel
@onready var round_end_dialog: AcceptDialog = $GameUI/Overlays/RoundEndDialog
@onready var style_qa_overlay: Control = $GameUI/Overlays/StyleQAOverlay
@onready var style_qa_close_button: Button = $GameUI/Overlays/StyleQAOverlay/Panel/VBox/Header/CloseButton
@onready var style_qa_grid: GridContainer = $GameUI/Overlays/StyleQAOverlay/Panel/VBox/Scroll/StyleQAGrid

var game_state := UffDuhGameState.new()
var ai := UffDuhRuleAI.new()
var selected_card_index := -1
var selected_branch_index := -1
var status_text := ""
var style_qa_built := false
var dark_mode_enabled := false

func _ready() -> void:
	print("UFF_DUH_RUNTIME: game_controller_ready")
	DisplayServer.window_set_title("Uff-Duh Card Game - Runtime")
	theme_toggle_button.button_pressed = false
	theme_toggle_button.text = "Dark: Off"
	_wire_ui()
	game_state.new_match(2)
	selected_branch_index = HUMAN_PLAYER_ID
	_apply_theme_mode()
	_set_status("Your turn")
	_refresh_ui()
	_process_turn_state()

func _wire_ui() -> void:
	draw_button.pressed.connect(_on_draw_pressed)
	pass_button.pressed.connect(_on_pass_pressed)
	play_selected_button.pressed.connect(_on_play_selected_pressed)
	uff_da_button.pressed.connect(_on_uff_da_pressed)
	theme_toggle_button.toggled.connect(_on_theme_toggle_toggled)
	round_end_dialog.confirmed.connect(_on_round_dialog_confirmed)
	style_qa_toggle_button.pressed.connect(_on_style_qa_toggle_pressed)
	style_qa_close_button.pressed.connect(_on_style_qa_close_pressed)

	var panels := _branch_panels()
	for idx in range(panels.size()):
		panels[idx].gui_input.connect(_on_branch_gui_input.bind(idx))

func _on_draw_pressed() -> void:
	if not _is_human_turn():
		return
	game_state.draw_and_pass(HUMAN_PLAYER_ID)
	selected_card_index = -1
	_set_status("You drew and passed.")
	_refresh_ui()
	_process_turn_state()

func _on_pass_pressed() -> void:
	if not _is_human_turn():
		return
	game_state.pass_turn(HUMAN_PLAYER_ID)
	selected_card_index = -1
	_set_status("You passed.")
	_refresh_ui()
	_process_turn_state()

func _on_play_selected_pressed() -> void:
	if not _is_human_turn():
		return
	if selected_card_index < 0 or selected_branch_index < 0:
		_set_status("Select a card and branch first.")
		_refresh_ui()
		return

	var move := {"card_index": selected_card_index, "branch": selected_branch_index}
	if not game_state.play_move(HUMAN_PLAYER_ID, move):
		_set_status("That move is not legal.")
		_refresh_ui()
		return

	selected_card_index = -1
	_set_status("You played a card.")
	_refresh_ui()
	_process_turn_state()

func _on_uff_da_pressed() -> void:
	if not _is_human_turn():
		return
	game_state.declare_uff_da(HUMAN_PLAYER_ID)
	_set_status("UFF-DA declared.")
	_refresh_ui()

func _on_round_dialog_confirmed() -> void:
	_refresh_ui()
	_process_turn_state()

func _on_branch_gui_input(event: InputEvent, branch_idx: int) -> void:
	if not _is_human_turn():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected_branch_index = branch_idx
		_refresh_ui()

func _on_hand_card_pressed(card_index: int) -> void:
	if not _is_human_turn():
		return
	selected_card_index = card_index
	_refresh_ui()

func _on_style_qa_toggle_pressed() -> void:
	_set_style_qa_overlay_visible(not style_qa_overlay.visible)

func _on_style_qa_close_pressed() -> void:
	_set_style_qa_overlay_visible(false)

func _on_theme_toggle_toggled(pressed: bool) -> void:
	dark_mode_enabled = pressed
	CARD_BUTTON_SCRIPT.set_dark_theme_enabled(dark_mode_enabled)
	if style_qa_built:
		_build_style_qa_grid()
	_apply_theme_mode()
	_refresh_ui()

func _process_turn_state() -> void:
	if _resolve_round_if_needed():
		_refresh_ui()
		if game_state.is_match_finished():
			return

	if game_state.turn_index == HUMAN_PLAYER_ID:
		if game_state.hands[HUMAN_PLAYER_ID].size() == 1 and not game_state.declared_uff_da[HUMAN_PLAYER_ID]:
			_set_status("Declare UFF-DA or play your last card.")
		elif status_text.is_empty():
			_set_status("Your turn")
		_refresh_ui()
		return

	_set_status("AI thinking...")
	_refresh_ui()
	var timer := get_tree().create_timer(AI_DELAY_SECONDS)
	timer.timeout.connect(_run_ai_turn, CONNECT_ONE_SHOT)

func _run_ai_turn() -> void:
	if game_state.is_match_finished():
		return

	var ai_player := game_state.turn_index
	var action := ai.choose_action(game_state, ai_player)
	match action.get("type", "wait"):
		"declare_uff_da":
			game_state.declare_uff_da(ai_player)
			_set_status("Player %d declared UFF-DA." % (ai_player + 1))
		"play":
			if game_state.play_move(ai_player, action.get("move", {})):
				_set_status("Player %d played." % (ai_player + 1))
			else:
				game_state.draw_and_pass(ai_player)
				_set_status("Player %d drew and passed." % (ai_player + 1))
		"draw":
			game_state.draw_and_pass(ai_player)
			_set_status("Player %d drew and passed." % (ai_player + 1))
		_:
			game_state.pass_turn(ai_player)
			_set_status("Player %d passed." % (ai_player + 1))

	_refresh_ui()
	_process_turn_state()

func _resolve_round_if_needed() -> bool:
	var winner := game_state.round_winner()
	if winner < 0:
		return false

	var scored_winner := game_state.apply_round_scoring()
	var message := "Round %d complete. Winner: Player %d" % [game_state.round_number, scored_winner + 1]
	round_end_dialog.dialog_text = message
	round_end_dialog.popup_centered()
	_set_status(message)

	game_state.advance_round()
	selected_card_index = -1
	selected_branch_index = HUMAN_PLAYER_ID

	if game_state.is_match_finished():
		_set_status("Match complete.")

	return true

func _refresh_ui() -> void:
	round_label.text = "Round %d/10" % game_state.round_number
	deck_count_label.text = "Deck: %d" % game_state.deck.size()
	center_card_value.text = _top_discard_text()

	var branch_labels := [branch_north_value, branch_east_value, branch_south_value, branch_west_value]
	for idx in range(branch_labels.size()):
		if idx < game_state.player_count:
			branch_labels[idx].text = "%s: %d" % [_branch_name(idx), game_state.branches[idx]]
		else:
			branch_labels[idx].text = "%s: -" % _branch_name(idx)

	_refresh_branch_selection_style()
	_refresh_opponents()
	_refresh_hand()
	status_label.text = status_text
	scores_label.text = _score_text()

	var human_turn := _is_human_turn()
	var can_play := selected_card_index >= 0 and selected_branch_index >= 0 and _is_selected_move_legal()
	_refresh_debug_panel(can_play)
	draw_button.disabled = not human_turn or game_state.is_match_finished()
	pass_button.disabled = not human_turn or game_state.is_match_finished()
	play_selected_button.disabled = not human_turn or not can_play or game_state.is_match_finished()
	uff_da_button.disabled = not human_turn or game_state.hands[HUMAN_PLAYER_ID].size() != 1 or game_state.declared_uff_da[HUMAN_PLAYER_ID]

func _refresh_debug_panel(selected_move_legal: bool) -> void:
	var card_text := "-"
	if selected_card_index >= 0 and selected_card_index < game_state.hands[HUMAN_PLAYER_ID].size():
		card_text = game_state.hands[HUMAN_PLAYER_ID][selected_card_index].to_text()

	var branch_text := "-"
	if selected_branch_index >= 0:
		branch_text = _branch_name(selected_branch_index)

	debug_selection_label.text = "Selection: card=%s branch=%s legal=%s" % [card_text, branch_text, str(selected_move_legal)]

	var legal_moves := game_state.legal_moves(HUMAN_PLAYER_ID)
	if legal_moves.is_empty():
		debug_legal_moves_label.text = "Legal Moves: none"
		return

	var move_text_parts: Array[String] = []
	for move in legal_moves:
		var card_index := int(move["card_index"])
		var branch_index := int(move["branch"])
		if card_index < 0 or card_index >= game_state.hands[HUMAN_PLAYER_ID].size():
			continue
		var card: UffDuhCard = game_state.hands[HUMAN_PLAYER_ID][card_index] as UffDuhCard
		move_text_parts.append("%s->%s" % [card.to_text(), _branch_name(branch_index)])

	debug_legal_moves_label.text = "Legal Moves: %s" % ", ".join(move_text_parts)

func _refresh_opponents() -> void:
	for idx in range(opponents_row.get_child_count()):
		var panel := opponents_row.get_child(idx) as PanelContainer
		if panel == null:
			continue
		var slot := _ensure_opponent_slot(panel)
		var back := slot.get_node("CardBack") as TextureRect
		var label_node := slot.get_node("CountLabel") as Label
		if back.texture == null:
			back.modulate = Color(0.1, 0.14, 0.2) if CARD_BUTTON_SCRIPT.is_dark_theme_enabled() else Color(0.14, 0.2, 0.28)
		var player_id := idx + 1
		if player_id < game_state.player_count:
			back.visible = true
			label_node.text = "P%d: %d cards" % [player_id + 1, game_state.hands[player_id].size()]
		else:
			back.visible = false
			label_node.text = "Open"

func _refresh_hand() -> void:
	for child in hand_cards.get_children():
		child.queue_free()

	for card_idx in range(game_state.hands[HUMAN_PLAYER_ID].size()):
		var card: UffDuhCard = game_state.hands[HUMAN_PLAYER_ID][card_idx]
		var button := CARD_BUTTON_SCENE.instantiate()
		button.custom_minimum_size = Vector2(72, 104)
		button.setup_from_card(card, true, card_idx == selected_card_index)
		button.disabled = not _is_human_turn()
		button.pressed.connect(_on_hand_card_pressed.bind(card_idx))
		hand_cards.add_child(button)

func _refresh_branch_selection_style() -> void:
	var panels := _branch_panels()
	for idx in range(panels.size()):
		var panel := panels[idx]
		if idx == selected_branch_index and _is_human_turn():
			panel.modulate = Color(1.0, 0.9, 0.65)
		else:
			panel.modulate = Color(1.0, 1.0, 1.0)

func _is_human_turn() -> bool:
	return game_state.turn_index == HUMAN_PLAYER_ID and not game_state.is_match_finished()

func _is_selected_move_legal() -> bool:
	if selected_card_index < 0 or selected_branch_index < 0:
		return false
	for move in game_state.legal_moves(HUMAN_PLAYER_ID):
		if int(move["card_index"]) == selected_card_index and int(move["branch"]) == selected_branch_index:
			return true
	return false

func _top_discard_text() -> String:
	if game_state.discard.is_empty():
		return "-"
	var top: UffDuhCard = game_state.discard.back() as UffDuhCard
	return "%d|%d" % [top.a, top.b]

func _score_text() -> String:
	var parts: Array[String] = []
	for idx in range(game_state.score_totals.size()):
		parts.append("P%d:%d" % [idx + 1, game_state.score_totals[idx]])
	return " ".join(parts)

func _branch_name(index: int) -> String:
	match index:
		0:
			return "N"
		1:
			return "E"
		2:
			return "S"
		3:
			return "W"
		_:
			return "B%d" % (index + 1)

func _branch_panels() -> Array[PanelContainer]:
	return [
		$GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchNorth,
		$GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchEast,
		$GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchSouth,
		$GameUI/SafeArea/RootVBox/TableArea/TableCenter/BranchWest
	]

func _set_status(text: String) -> void:
	status_text = text

func _apply_theme_mode() -> void:
	CARD_BUTTON_SCRIPT.set_dark_theme_enabled(dark_mode_enabled)
	theme_toggle_button.text = "Dark: On" if dark_mode_enabled else "Dark: Off"
	if game_ui.has_method("set_dark_mode"):
		game_ui.call("set_dark_mode", dark_mode_enabled)

func _set_style_qa_overlay_visible(visible: bool) -> void:
	if visible and not style_qa_built:
		_build_style_qa_grid()
	style_qa_overlay.visible = visible
	style_qa_toggle_button.text = "Hide Style IDs (55)" if visible else "Show Style IDs (55)"

func _build_style_qa_grid() -> void:
	for child in style_qa_grid.get_children():
		child.queue_free()

	var deck: Array[UffDuhCard] = DECK_SCRIPT.create_standard_deck()
	for card in deck:
		var slot := VBoxContainer.new()
		slot.custom_minimum_size = Vector2(180, 250)
		slot.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.add_theme_constant_override("separation", 6)

		var card_button := CARD_BUTTON_SCENE.instantiate()
		card_button.custom_minimum_size = Vector2(120, 172)
		card_button.disabled = true
		card_button.focus_mode = Control.FOCUS_NONE
		card_button.setup_from_card(card, true, false)
		slot.add_child(card_button)

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "%d|%d\n%s" % [card.a, card.b, CARD_BUTTON_SCRIPT.style_id_for_values(card.a, card.b)]
		slot.add_child(label)

		style_qa_grid.add_child(slot)

	style_qa_built = true

func _ensure_opponent_slot(panel: PanelContainer) -> VBoxContainer:
	if panel.get_child_count() > 0 and panel.get_child(0) is VBoxContainer:
		return panel.get_child(0) as VBoxContainer

	var slot := VBoxContainer.new()
	slot.alignment = BoxContainer.ALIGNMENT_CENTER
	slot.add_theme_constant_override("separation", 4)
	panel.add_child(slot)

	var back := TextureRect.new()
	back.name = "CardBack"
	back.custom_minimum_size = Vector2(42, 60)
	back.texture = _try_load_texture("res://assets/cards/card_back.png")
	back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	back.modulate = Color(1.0, 1.0, 1.0) if back.texture != null else Color(0.14, 0.2, 0.28)
	slot.add_child(back)

	var label := Label.new()
	label.name = "CountLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_child(label)

	return slot

func _try_load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

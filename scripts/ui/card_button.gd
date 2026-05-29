class_name UffDuhCardButton
extends Button

@export var front_texture_path := "res://assets/cards/card_front.png"
@export var back_texture_path := "res://assets/cards/card_back.png"

var _front_texture: Texture2D
var _back_texture: Texture2D
var _pair_art_cache: Dictionary = {}
var _hover_tween: Tween
var _visual_tilt_degrees := 0.0
var _current_card: UffDuhCard
var _current_face_up := true
var _current_selected := false
static var _dark_theme_enabled := false
static var _global_gloss_intensity := 1.0

static func set_dark_theme_enabled(enabled: bool) -> void:
	_dark_theme_enabled = enabled

static func is_dark_theme_enabled() -> bool:
	return _dark_theme_enabled

static func set_global_gloss_intensity(value: float) -> void:
	_global_gloss_intensity = clampf(value, 0.0, 1.5)

static func get_global_gloss_intensity() -> float:
	return _global_gloss_intensity

func _ready() -> void:
	add_to_group("uff_duh_cards")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	resized.connect(_update_pivot)
	_update_pivot()

func setup_from_card(card: UffDuhCard, face_up: bool, selected: bool) -> void:
	_current_card = card
	_current_face_up = face_up
	_current_selected = selected
	var card_art := get_node("CardArt") as TextureRect
	var variant_overlay := get_node("VariantOverlay") as TextureRect
	var card_gloss := get_node("CardGloss") as ColorRect
	var edge_tint := get_node("CardEdgeTint") as ColorRect
	var top_left_value := get_node("TopLeftValue") as Label
	var top_right_value := get_node("TopRightValue") as Label
	var center_value := get_node("CenterValue") as Label
	text = ""
	_visual_tilt_degrees = -2.0 + float(posmod(card.a * 9 + card.b * 4, 9)) * 0.5
	var value_color := Color(0.95, 0.45, 0.52) if _dark_theme_enabled else Color(0.78, 0.11, 0.22)
	if _is_high_value_pair(card):
		value_color = Color(0.98, 0.55, 0.4) if _dark_theme_enabled else Color(0.8, 0.2, 0.1)
	elif _is_double(card):
		value_color = Color(0.99, 0.88, 0.56) if _dark_theme_enabled else Color(0.73, 0.46, 0.08)
	top_left_value.add_theme_color_override("font_color", value_color)
	top_right_value.add_theme_color_override("font_color", value_color)
	center_value.add_theme_color_override("font_color", value_color)
	top_left_value.text = str(card.a)
	top_right_value.text = str(card.b)
	center_value.text = "%d | %d" % [card.a, card.b]
	if card_gloss != null:
		var gloss_alpha := 0.1 * _global_gloss_intensity
		if _is_double(card):
			gloss_alpha += 0.04
		card_gloss.color = Color(0.99, 0.98, 0.95, gloss_alpha) if face_up else Color(0.72, 0.83, 0.95, 0.05 * _global_gloss_intensity)
	if edge_tint != null:
		edge_tint.color = Color(0.05, 0.08, 0.12, 0.07 + (_global_gloss_intensity - 1.0) * 0.03) if face_up else Color(0.02, 0.03, 0.06, 0.12)
	_set_face_up(face_up, card, card_art, variant_overlay, top_left_value, top_right_value, center_value)
	_set_selected(selected)

func _set_face_up(face_up: bool, card: UffDuhCard, card_art: TextureRect, variant_overlay: TextureRect, top_left_value: Label, top_right_value: Label, center_value: Label) -> void:
	card_art.texture = _get_texture(face_up)
	var fallback_front := Color(0.95, 0.93, 0.88) if not _dark_theme_enabled else Color(0.22, 0.26, 0.33)
	var fallback_back := Color(0.14, 0.2, 0.28) if not _dark_theme_enabled else Color(0.1, 0.14, 0.2)
	card_art.modulate = Color(1.0, 1.0, 1.0) if card_art.texture != null else (fallback_front if face_up else fallback_back)
	variant_overlay.texture = _get_pair_art_texture(card, face_up)
	variant_overlay.visible = face_up and variant_overlay.texture != null
	variant_overlay.modulate = Color(1, 1, 1, 0.7) if face_up else Color(1, 1, 1, 0.18)
	var fill := Color(0.98, 0.96, 0.92) if face_up else Color(0.12, 0.2, 0.29)
	var border := Color(0.1, 0.1, 0.1) if face_up else Color(0.8, 0.74, 0.6)
	var border_width := 2
	if face_up and _is_double(card):
		border = Color(0.99, 0.88, 0.58) if _dark_theme_enabled else Color(0.78, 0.58, 0.1)
		border_width = 3
	elif face_up and _is_high_value_pair(card):
		border = Color(0.98, 0.56, 0.34) if _dark_theme_enabled else Color(0.86, 0.24, 0.13)
		border_width = 3
	if _dark_theme_enabled:
		fill = Color(0.24, 0.28, 0.35) if face_up else Color(0.1, 0.14, 0.21)
		if not _is_double(card) and not _is_high_value_pair(card):
			border = Color(0.87, 0.9, 0.97) if face_up else Color(0.57, 0.67, 0.81)
	add_theme_stylebox_override("normal", _style(fill, border, border_width))
	add_theme_stylebox_override("hover", _style(fill.lightened(0.04), border, border_width))
	add_theme_stylebox_override("pressed", _style(fill.darkened(0.07), border, border_width))
	add_theme_stylebox_override("disabled", _style(fill.darkened(0.2), border.darkened(0.2), border_width))
	top_left_value.visible = face_up
	top_right_value.visible = face_up
	center_value.visible = face_up

func _set_selected(selected: bool) -> void:
	if selected:
		var selected_fill := Color(1.0, 0.96, 0.9)
		var selected_border := Color(0.95, 0.82, 0.38)
		if _dark_theme_enabled:
			selected_fill = Color(0.3, 0.25, 0.15)
			selected_border = Color(0.99, 0.88, 0.58)
		add_theme_stylebox_override("normal", _style(selected_fill, selected_border, 4))
		add_theme_stylebox_override("hover", _style(selected_fill, selected_border, 4))

func refresh_visual_style() -> void:
	if _current_card == null:
		return
	setup_from_card(_current_card, _current_face_up, _current_selected)

func _get_pair_art_texture(card: UffDuhCard, face_up: bool) -> Texture2D:
	if not face_up:
		return null
	var key := "%d_%d" % [card.a, card.b]
	if _pair_art_cache.has(key):
		return _pair_art_cache[key] as Texture2D

	var texture := _build_pair_art_texture(card)
	_pair_art_cache[key] = texture
	return texture

func _build_pair_art_texture(card: UffDuhCard) -> Texture2D:
	const ART_W := 192
	const ART_H := 288
	var image := Image.create(ART_W, ART_H, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var red := Color(0.78, 0.11, 0.22, 0.45)
	var blue := Color(0.12, 0.33, 0.64, 0.42)
	var gold := Color(0.94, 0.82, 0.38, 0.4)
	var accent_a := _pick_palette_color(card.a * 13 + card.b * 7)
	var accent_b := _pick_palette_color(card.a * 5 + card.b * 17 + 3)

	# Distinct top and bottom bands from the two values.
	var top_h := 14 + card.a * 3
	var bottom_h := 14 + card.b * 3
	image.fill_rect(Rect2i(0, 22, ART_W, top_h), _alpha(accent_a, 0.32))
	image.fill_rect(Rect2i(0, ART_H - 22 - bottom_h, ART_W, bottom_h), _alpha(accent_b, 0.32))

	# Scandinavian cross-like center motif with thickness based on the pair.
	var v_thickness := 6 + (card.a % 4) * 2
	var h_thickness := 6 + (card.b % 4) * 2
	image.fill_rect(Rect2i(ART_W / 2 - v_thickness, 40, v_thickness * 2, ART_H - 80), blue)
	image.fill_rect(Rect2i(32, ART_H / 2 - h_thickness, ART_W - 64, h_thickness * 2), red)

	# Deterministic grid glyphs produce unique signatures for every value pair.
	var cols := 6
	var rows := 9
	var cell_w := ART_W / cols
	var cell_h := ART_H / rows
	for i in range(card.a + 1):
		var idx := (i * 5 + card.b * 3) % (cols * rows)
		var cx := idx % cols
		var cy := idx / cols
		image.fill_rect(
			Rect2i(cx * cell_w + 5, cy * cell_h + 5, cell_w - 10, cell_h - 10),
			_alpha(accent_a, 0.22)
		)

	for j in range(card.b + 1):
		var idx_b := (j * 7 + card.a * 4 + 9) % (cols * rows)
		var dx := idx_b % cols
		var dy := idx_b / cols
		image.fill_rect(
			Rect2i(dx * cell_w + 11, dy * cell_h + 11, cell_w - 22, cell_h - 22),
			_alpha(accent_b, 0.3)
		)

	# Frame emblem gives each pair a custom center silhouette.
	var frame_w := 44 + card.a * 9
	var frame_h := 44 + card.b * 9
	frame_w = clampi(frame_w, 54, 136)
	frame_h = clampi(frame_h, 54, 136)
	var frame_x := (ART_W - frame_w) / 2
	var frame_y := (ART_H - frame_h) / 2
	_stroke_rect(image, Rect2i(frame_x, frame_y, frame_w, frame_h), 4, gold)
	_stroke_rect(image, Rect2i(frame_x + 8, frame_y + 8, frame_w - 16, frame_h - 16), 2, _alpha(accent_a, 0.45))

	# Value-dependent diagonals add unique movement and make each card identifiable.
	var spacing := 20 + ((card.a + card.b) % 4) * 4
	var thickness := 2 + (card.pip_total() % 3)
	_draw_diagonal_bands(image, spacing, thickness, _alpha(accent_b, 0.18))

	return ImageTexture.create_from_image(image)

static func style_id_for_values(a: int, b: int) -> String:
	var top_h := 14 + a * 3
	var bottom_h := 14 + b * 3
	var v_thickness := 6 + (a % 4) * 2
	var h_thickness := 6 + (b % 4) * 2
	var palette_a := _palette_index(a * 13 + b * 7)
	var palette_b := _palette_index(a * 5 + b * 17 + 3)
	var frame_w := clampi(44 + a * 9, 54, 136)
	var frame_h := clampi(44 + b * 9, 54, 136)
	var spacing := 20 + ((a + b) % 4) * 4
	var thickness := 2 + ((a + b) % 3)
	return "A%dB%d-P%d%d-T%d_%d-C%d_%d-F%d_%d-D%d_%d" % [
		a,
		b,
		palette_a,
		palette_b,
		top_h,
		bottom_h,
		v_thickness,
		h_thickness,
		frame_w,
		frame_h,
		spacing,
		thickness
	]

func _draw_diagonal_bands(image: Image, spacing: int, thickness: int, color: Color) -> void:
	var w := image.get_width()
	var h := image.get_height()
	for start_x in range(-h, w + h, spacing):
		for t in range(thickness):
			for y in range(h):
				var x := start_x + y + t
				if x >= 0 and x < w:
					image.set_pixel(x, y, color)

func _stroke_rect(image: Image, rect: Rect2i, thickness: int, color: Color) -> void:
	image.fill_rect(Rect2i(rect.position.x, rect.position.y, rect.size.x, thickness), color)
	image.fill_rect(Rect2i(rect.position.x, rect.position.y + rect.size.y - thickness, rect.size.x, thickness), color)
	image.fill_rect(Rect2i(rect.position.x, rect.position.y, thickness, rect.size.y), color)
	image.fill_rect(Rect2i(rect.position.x + rect.size.x - thickness, rect.position.y, thickness, rect.size.y), color)

func _pick_palette_color(seed: int) -> Color:
	var palette: Array[Color] = [
		Color(0.78, 0.11, 0.22, 1.0),
		Color(0.12, 0.33, 0.64, 1.0),
		Color(0.93, 0.82, 0.38, 1.0),
		Color(0.15, 0.54, 0.58, 1.0),
		Color(0.62, 0.2, 0.68, 1.0)
	]
	return palette[posmod(seed, palette.size())]

static func _palette_index(seed: int) -> int:
	return posmod(seed, 5)

func _alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)

func _animate_to_scale(target_scale: Vector2, duration: float) -> void:
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.set_parallel(true)
	_hover_tween.tween_property(self, "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "rotation_degrees", _visual_tilt_degrees * (target_scale.x - 1.0) * 18.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	_animate_to_scale(Vector2(1.045, 1.045), 0.11)

func _on_mouse_exited() -> void:
	_animate_to_scale(Vector2.ONE, 0.12)

func _on_button_down() -> void:
	_animate_to_scale(Vector2(0.975, 0.975), 0.06)

func _on_button_up() -> void:
	_animate_to_scale(Vector2(1.045, 1.045), 0.08)

func _update_pivot() -> void:
	pivot_offset = size * 0.5

func _style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = border
	sb.border_width_left = border_width
	sb.border_width_top = border_width
	sb.border_width_right = border_width
	sb.border_width_bottom = border_width
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_right = 10
	sb.corner_radius_bottom_left = 10
	sb.shadow_size = int(round((4 if _dark_theme_enabled else 3) * (0.8 + _global_gloss_intensity * 0.2)))
	sb.shadow_color = Color(0, 0, 0, 0.32) if _dark_theme_enabled else Color(0.03, 0.05, 0.08, 0.22)
	sb.anti_aliasing = true
	sb.anti_aliasing_size = 0.9
	return sb

func _is_double(card: UffDuhCard) -> bool:
	return card.a == card.b

func _is_high_value_pair(card: UffDuhCard) -> bool:
	return card.pip_total() >= 14

func _get_texture(face_up: bool) -> Texture2D:
	if face_up:
		if _front_texture == null:
			_front_texture = _try_load_texture(front_texture_path)
		return _front_texture

	if _back_texture == null:
		_back_texture = _try_load_texture(back_texture_path)
	return _back_texture

func _try_load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

extends Control

const CARD_BUTTON_SCRIPT := preload("res://scripts/ui/card_button.gd")

const LIGHT_COL_BG := Color(0.95, 0.97, 1.0)
const LIGHT_COL_SURFACE := Color(0.98, 0.99, 1.0)
const LIGHT_COL_INK := Color(0.1, 0.15, 0.24)
const LIGHT_COL_RED := Color(0.78, 0.11, 0.22)
const LIGHT_COL_BLUE := Color(0.12, 0.33, 0.64)
const LIGHT_COL_GOLD := Color(0.95, 0.82, 0.38)

const DARK_COL_BG := Color(0.08, 0.11, 0.16)
const DARK_COL_SURFACE := Color(0.14, 0.18, 0.25)
const DARK_COL_INK := Color(0.9, 0.93, 0.98)
const DARK_COL_RED := Color(0.95, 0.45, 0.52)
const DARK_COL_BLUE := Color(0.45, 0.7, 1.0)
const DARK_COL_GOLD := Color(0.95, 0.84, 0.56)

var _dark_mode := false
var _light_pattern: Texture2D
var _dark_pattern: Texture2D
var _light_shimmer: Texture2D
var _dark_shimmer: Texture2D
var _aura_intensity := 1.0
var _pattern_intensity := 1.0
var _gloss_intensity := 1.0
var _shimmer_time := 0.0
var _popover_tween: Tween

func _ready() -> void:
	_wire_visual_settings()
	CARD_BUTTON_SCRIPT.set_global_gloss_intensity(_gloss_intensity)
	refresh_theme()
	set_process(true)

func set_dark_mode(enabled: bool) -> void:
	_dark_mode = enabled
	refresh_theme()

func is_dark_mode() -> bool:
	return _dark_mode

func refresh_theme() -> void:
	_apply_background()
	_skin_panels()
	_skin_buttons()
	_skin_labels()
	_skin_branch_values()
	_skin_overlays()

func _apply_background() -> void:
	var bg := get_node_or_null("ThemeBackdrop") as ColorRect
	if bg == null:
		return
	bg.color = DARK_COL_BG if _dark_mode else LIGHT_COL_BG

	var pattern := get_node_or_null("ThemePattern") as TextureRect
	if pattern != null:
		pattern.texture = _get_pattern_texture(_dark_mode)
		var base_pattern_alpha := 0.3 if _dark_mode else 0.23
		pattern.modulate = Color(1, 1, 1, base_pattern_alpha * _pattern_intensity)

	var aura := get_node_or_null("SafeArea/RootVBox/TableArea/TableCenter/TableAura") as ColorRect
	if aura != null:
		var base_aura := Color(0.38, 0.62, 0.95, 0.12) if _dark_mode else Color(0.12, 0.33, 0.64, 0.12)
		aura.color = Color(base_aura.r, base_aura.g, base_aura.b, base_aura.a * _aura_intensity)

	var shimmer := get_node_or_null("SafeArea/RootVBox/TableArea/TableCenter/TableShimmer") as TextureRect
	if shimmer != null:
		shimmer.texture = _get_shimmer_texture(_dark_mode)

func _skin_panels() -> void:
	var surface := DARK_COL_SURFACE if _dark_mode else LIGHT_COL_SURFACE
	var blue := DARK_COL_BLUE if _dark_mode else LIGHT_COL_BLUE
	var red := DARK_COL_RED if _dark_mode else LIGHT_COL_RED
	var gold := DARK_COL_GOLD if _dark_mode else LIGHT_COL_GOLD
	var table_surface := Color(0.17, 0.22, 0.31) if _dark_mode else Color(0.96, 0.98, 1.0)

	for panel in find_children("*", "PanelContainer", true, false):
		var panel_node := panel as PanelContainer
		if panel_node == null:
			continue
		panel_node.add_theme_stylebox_override("panel", _panel_style(surface, blue, 2, 14, 0.07))

	var table := get_node_or_null("SafeArea/RootVBox/TableArea") as PanelContainer
	if table != null:
		table.add_theme_stylebox_override("panel", _panel_style(table_surface, blue, 3, 16, 0.11))

	var center := get_node_or_null("SafeArea/RootVBox/TableArea/TableCenter/CenterCard") as PanelContainer
	if center != null:
		center.add_theme_stylebox_override("panel", _panel_style(surface, red, 3, 12, 0.12))

	for path in [
		"SafeArea/RootVBox/TableArea/TableCenter/BranchNorth",
		"SafeArea/RootVBox/TableArea/TableCenter/BranchEast",
		"SafeArea/RootVBox/TableArea/TableCenter/BranchSouth",
		"SafeArea/RootVBox/TableArea/TableCenter/BranchWest"
	]:
		var branch := get_node_or_null(path) as PanelContainer
		if branch != null:
			branch.add_theme_stylebox_override("panel", _panel_style(surface, gold, 2, 12, 0.08))

func _skin_buttons() -> void:
	var blue := DARK_COL_BLUE if _dark_mode else LIGHT_COL_BLUE
	var ink := Color(0.07, 0.09, 0.14) if _dark_mode else LIGHT_COL_INK
	var red := DARK_COL_RED if _dark_mode else LIGHT_COL_RED
	var gold := DARK_COL_GOLD if _dark_mode else LIGHT_COL_GOLD
	var font_disabled := Color(0.56, 0.62, 0.74) if _dark_mode else Color(0.85, 0.88, 0.93)
	var disabled_fill := Color(0.26, 0.3, 0.4) if _dark_mode else Color(0.5, 0.58, 0.7)
	var disabled_border := Color(0.2, 0.23, 0.31) if _dark_mode else Color(0.37, 0.42, 0.53)

	for node in find_children("*", "Button", true, false):
		var button := node as Button
		if button == null:
			continue
		button.add_theme_color_override("font_color", Color(1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		button.add_theme_color_override("font_disabled_color", font_disabled)
		button.add_theme_stylebox_override("normal", _panel_style(blue, ink, 2, 10, 0.16))
		button.add_theme_stylebox_override("hover", _panel_style(blue.lightened(0.08), gold, 2, 10, 0.2))
		button.add_theme_stylebox_override("pressed", _panel_style(blue.darkened(0.12), ink, 2, 10, 0.1))
		button.add_theme_stylebox_override("disabled", _panel_style(disabled_fill, disabled_border, 2, 10, 0.05))

	var uff_da := get_node_or_null("SafeArea/RootVBox/TopBar/UffDaButton") as Button
	if uff_da != null:
		uff_da.add_theme_stylebox_override("normal", _panel_style(red, ink, 2, 10, 0.2))
		uff_da.add_theme_stylebox_override("hover", _panel_style(red.lightened(0.07), gold, 2, 10, 0.24))
		uff_da.add_theme_stylebox_override("pressed", _panel_style(red.darkened(0.1), ink, 2, 10, 0.12))

	var play := get_node_or_null("SafeArea/RootVBox/PlayerHandRow/ActionColumn/PlaySelectedButton") as Button
	if play != null:
		play.add_theme_stylebox_override("normal", _panel_style(red, ink, 2, 10, 0.2))
		play.add_theme_stylebox_override("hover", _panel_style(red.lightened(0.07), gold, 2, 10, 0.24))

	var theme_toggle := get_node_or_null("SafeArea/RootVBox/TopBar/ThemeToggleButton") as Button
	if theme_toggle != null:
		theme_toggle.add_theme_stylebox_override("normal", _panel_style(gold.darkened(0.16), ink, 2, 10, 0.18))
		theme_toggle.add_theme_stylebox_override("hover", _panel_style(gold.darkened(0.08), ink, 2, 10, 0.22))
		theme_toggle.add_theme_stylebox_override("pressed", _panel_style(gold.darkened(0.26), ink, 2, 10, 0.08))
		theme_toggle.add_theme_color_override("font_color", ink)
		theme_toggle.add_theme_color_override("font_hover_color", ink)
		theme_toggle.add_theme_color_override("font_pressed_color", ink)

func _skin_labels() -> void:
	var ink := DARK_COL_INK if _dark_mode else LIGHT_COL_INK
	var shadow := Color(0, 0, 0, 0.7) if _dark_mode else Color(1, 1, 1, 0.6)
	var blue := DARK_COL_BLUE if _dark_mode else LIGHT_COL_BLUE
	var red := DARK_COL_RED if _dark_mode else LIGHT_COL_RED

	for node in find_children("*", "Label", true, false):
		var label := node as Label
		if label == null:
			continue
		label.add_theme_color_override("font_color", ink)
		label.add_theme_color_override("font_shadow_color", shadow)
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)

	for path in [
		"SafeArea/RootVBox/TopBar/RoundLabel",
		"SafeArea/RootVBox/TopBar/DeckCountLabel",
		"SafeArea/RootVBox/FooterBar/ScoresLabel"
	]:
		var accent_label := get_node_or_null(path) as Label
		if accent_label != null:
			accent_label.add_theme_color_override("font_color", blue)

	var status := get_node_or_null("SafeArea/RootVBox/FooterBar/StatusLabel") as Label
	if status != null:
		status.add_theme_color_override("font_color", red)

func _skin_branch_values() -> void:
	var blue := DARK_COL_BLUE if _dark_mode else LIGHT_COL_BLUE
	var red := DARK_COL_RED if _dark_mode else LIGHT_COL_RED

	for path in [
		"SafeArea/RootVBox/TableArea/TableCenter/BranchNorth/BranchNorthValue",
		"SafeArea/RootVBox/TableArea/TableCenter/BranchEast/BranchEastValue",
		"SafeArea/RootVBox/TableArea/TableCenter/BranchSouth/BranchSouthValue",
		"SafeArea/RootVBox/TableArea/TableCenter/BranchWest/BranchWestValue"
	]:
		var label := get_node_or_null(path) as Label
		if label == null:
			continue
		label.add_theme_color_override("font_color", blue)

	var center := get_node_or_null("SafeArea/RootVBox/TableArea/TableCenter/CenterCard/CenterCardValue") as Label
	if center != null:
		center.add_theme_color_override("font_color", red)

func _skin_overlays() -> void:
	var dimmer := get_node_or_null("Overlays/StyleQAOverlay/Dimmer") as ColorRect
	if dimmer != null:
		dimmer.color = Color(0.01, 0.02, 0.03, 0.78) if _dark_mode else Color(0.05, 0.07, 0.1, 0.6)

	var qa_panel := get_node_or_null("Overlays/StyleQAOverlay/Panel") as PanelContainer
	if qa_panel != null:
		var border := DARK_COL_GOLD if _dark_mode else LIGHT_COL_BLUE
		var fill := Color(0.16, 0.2, 0.28) if _dark_mode else Color(0.98, 0.99, 1.0)
		qa_panel.add_theme_stylebox_override("panel", _panel_style(fill, border, 3, 16, 0.14))

func _panel_style(fill: Color, border: Color, width: int, radius: int, gloss: float = 0.0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var effective_gloss := clampf(gloss * _gloss_intensity, 0.0, 0.42)
	var tint := Color(1, 1, 1, effective_gloss)
	sb.bg_color = fill.lerp(Color(1, 1, 1), 0.04) if effective_gloss > 0.0 else fill
	sb.border_blend = true
	sb.border_color = border
	sb.border_width_left = width
	sb.border_width_top = width
	sb.border_width_right = width
	sb.border_width_bottom = width
	sb.anti_aliasing = true
	sb.anti_aliasing_size = 0.9
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_right = radius
	sb.corner_radius_bottom_left = radius
	sb.expand_margin_top = 1
	sb.expand_margin_left = 1
	sb.expand_margin_right = 1
	sb.expand_margin_bottom = 1
	sb.shadow_size = 2 if _dark_mode else 1
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.4) if _dark_mode else Color(0.06, 0.09, 0.14, 0.2)
	sb.skew = Vector2(0, 0)
	sb.set_corner_detail(8)
	if effective_gloss > 0.0:
		sb.draw_center = true
		sb.bg_color = fill.lerp(tint, effective_gloss)
	return sb

func _process(delta: float) -> void:
	_shimmer_time += delta
	_animate_table_shimmer()

func _get_pattern_texture(dark: bool) -> Texture2D:
	if dark:
		if _dark_pattern == null:
			_dark_pattern = _build_pattern_texture(true)
		return _dark_pattern
	if _light_pattern == null:
		_light_pattern = _build_pattern_texture(false)
	return _light_pattern

func _build_pattern_texture(dark: bool) -> Texture2D:
	const W := 256
	const H := 256
	var image := Image.create(W, H, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var line := Color(0.55, 0.72, 1.0, 0.08) if dark else Color(0.2, 0.38, 0.65, 0.08)
	var accent := Color(0.95, 0.82, 0.38, 0.06) if dark else Color(0.78, 0.11, 0.22, 0.05)

	for x in range(0, W, 32):
		image.fill_rect(Rect2i(x, 0, 1, H), line)
	for y in range(0, H, 32):
		image.fill_rect(Rect2i(0, y, W, 1), line)

	for d in range(-H, W, 48):
		for t in range(2):
			for y in range(H):
				var x := d + y + t
				if x >= 0 and x < W:
					image.set_pixel(x, y, accent)

	# Add a soft center ring to keep focus near the table.
	var cx := W / 2
	var cy := H / 2
	for r in range(64, 106, 10):
		var ring_alpha := 0.028 - float(r - 64) * 0.00023
		if ring_alpha <= 0.0:
			continue
		for a in range(360):
			var rad := deg_to_rad(float(a))
			var x := int(round(cx + cos(rad) * r))
			var y := int(round(cy + sin(rad) * r))
			if x >= 0 and x < W and y >= 0 and y < H:
				image.set_pixel(x, y, Color(line.r, line.g, line.b, ring_alpha))

	return ImageTexture.create_from_image(image)

func _get_shimmer_texture(dark: bool) -> Texture2D:
	if dark:
		if _dark_shimmer == null:
			_dark_shimmer = _build_shimmer_texture(true)
		return _dark_shimmer
	if _light_shimmer == null:
		_light_shimmer = _build_shimmer_texture(false)
	return _light_shimmer

func _build_shimmer_texture(dark: bool) -> Texture2D:
	const W := 256
	const H := 256
	var image := Image.create(W, H, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var color_main := Color(0.68, 0.84, 1.0, 0.12) if dark else Color(0.26, 0.45, 0.78, 0.11)
	var color_soft := Color(0.98, 0.92, 0.68, 0.09) if dark else Color(0.84, 0.68, 0.24, 0.07)
	for start in range(-H, W + H, 36):
		for y in range(H):
			var x := start + y
			if x >= 0 and x < W:
				image.set_pixel(x, y, color_main)
			if x + 2 >= 0 and x + 2 < W:
				image.set_pixel(x + 2, y, color_soft)

	return ImageTexture.create_from_image(image)

func _animate_table_shimmer() -> void:
	var shimmer := get_node_or_null("SafeArea/RootVBox/TableArea/TableCenter/TableShimmer") as TextureRect
	if shimmer == null:
		return

	var pulse := (sin(_shimmer_time * 1.9) + 1.0) * 0.5
	var drift := sin(_shimmer_time * 0.7)
	var base_alpha := (0.11 if _dark_mode else 0.08) * _aura_intensity
	shimmer.modulate = Color(1, 1, 1, base_alpha * (0.55 + pulse * 0.45))
	shimmer.rotation_degrees = drift * 2.2
	shimmer.scale = Vector2(1.0 + pulse * 0.02, 1.0 + pulse * 0.015)

func _wire_visual_settings() -> void:
	var visuals_button := get_node_or_null("SafeArea/RootVBox/TopBar/VisualSettingsButton") as Button
	var popover := get_node_or_null("SafeArea/VisualSettingsPopover") as PanelContainer
	var aura_slider := get_node_or_null("SafeArea/VisualSettingsPopover/VBox/AuraRow/AuraSlider") as HSlider
	var pattern_slider := get_node_or_null("SafeArea/VisualSettingsPopover/VBox/PatternRow/PatternSlider") as HSlider
	var gloss_slider := get_node_or_null("SafeArea/VisualSettingsPopover/VBox/GlossRow/GlossSlider") as HSlider
	if visuals_button != null:
		visuals_button.pressed.connect(_on_visuals_button_pressed)
	if popover != null:
		popover.visible = false
		popover.modulate = Color(1, 1, 1, 0)
		popover.scale = Vector2(0.97, 0.97)
	if aura_slider == null or pattern_slider == null or gloss_slider == null:
		return

	aura_slider.value = _aura_intensity * 100.0
	pattern_slider.value = _pattern_intensity * 100.0
	gloss_slider.value = _gloss_intensity * 100.0

	aura_slider.value_changed.connect(_on_aura_slider_changed)
	pattern_slider.value_changed.connect(_on_pattern_slider_changed)
	gloss_slider.value_changed.connect(_on_gloss_slider_changed)

	_update_visual_setting_labels()
	_update_visuals_button_text()

func _on_aura_slider_changed(value: float) -> void:
	_aura_intensity = clampf(value / 100.0, 0.2, 1.5)
	_update_visual_setting_labels()
	refresh_theme()

func _on_pattern_slider_changed(value: float) -> void:
	_pattern_intensity = clampf(value / 100.0, 0.0, 1.5)
	_update_visual_setting_labels()
	refresh_theme()

func _on_gloss_slider_changed(value: float) -> void:
	_gloss_intensity = clampf(value / 100.0, 0.0, 1.5)
	CARD_BUTTON_SCRIPT.set_global_gloss_intensity(_gloss_intensity)
	_update_visual_setting_labels()
	refresh_theme()
	_notify_card_style_changed()

func _update_visual_setting_labels() -> void:
	var aura_value := get_node_or_null("SafeArea/VisualSettingsPopover/VBox/AuraRow/AuraValue") as Label
	var pattern_value := get_node_or_null("SafeArea/VisualSettingsPopover/VBox/PatternRow/PatternValue") as Label
	var gloss_value := get_node_or_null("SafeArea/VisualSettingsPopover/VBox/GlossRow/GlossValue") as Label
	if aura_value != null:
		aura_value.text = "%d%%" % int(round(_aura_intensity * 100.0))
	if pattern_value != null:
		pattern_value.text = "%d%%" % int(round(_pattern_intensity * 100.0))
	if gloss_value != null:
		gloss_value.text = "%d%%" % int(round(_gloss_intensity * 100.0))

func _on_visuals_button_pressed() -> void:
	var popover := get_node_or_null("SafeArea/VisualSettingsPopover") as PanelContainer
	if popover == null:
		return
	_set_visuals_popover_visible(not popover.visible, true)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	var popover := get_node_or_null("SafeArea/VisualSettingsPopover") as PanelContainer
	var button := get_node_or_null("SafeArea/RootVBox/TopBar/VisualSettingsButton") as Button
	if popover == null or button == null or not popover.visible:
		return

	var point := get_global_mouse_position()
	if popover.get_global_rect().has_point(point):
		return
	if button.get_global_rect().has_point(point):
		return

	_set_visuals_popover_visible(false, true)

func _update_visuals_button_text() -> void:
	var button := get_node_or_null("SafeArea/RootVBox/TopBar/VisualSettingsButton") as Button
	var popover := get_node_or_null("SafeArea/VisualSettingsPopover") as PanelContainer
	if button == null:
		return
	if popover != null and popover.visible:
		button.text = "Visuals ^"
	else:
		button.text = "Visuals v"

func _set_visuals_popover_visible(visible: bool, animate: bool) -> void:
	var popover := get_node_or_null("SafeArea/VisualSettingsPopover") as PanelContainer
	if popover == null:
		return

	if _popover_tween != null and _popover_tween.is_valid():
		_popover_tween.kill()

	if not animate:
		popover.visible = visible
		popover.modulate = Color(1, 1, 1, 1) if visible else Color(1, 1, 1, 0)
		popover.scale = Vector2.ONE if visible else Vector2(0.97, 0.97)
		_update_visuals_button_text()
		return

	popover.pivot_offset = Vector2(maxf(popover.size.x - 10.0, 0.0), 8.0)
	if visible:
		popover.visible = true
		popover.modulate = Color(1, 1, 1, 0)
		popover.scale = Vector2(0.97, 0.97)
		_popover_tween = create_tween()
		_popover_tween.set_parallel(true)
		_popover_tween.tween_property(popover, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_popover_tween.tween_property(popover, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_update_visuals_button_text()
		return

	_popover_tween = create_tween()
	_popover_tween.set_parallel(true)
	_popover_tween.tween_property(popover, "modulate:a", 0.0, 0.09).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_popover_tween.tween_property(popover, "scale", Vector2(0.97, 0.97), 0.09).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_popover_tween.set_parallel(false)
	_popover_tween.tween_callback(func():
		popover.visible = false
		_update_visuals_button_text()
	)

func _notify_card_style_changed() -> void:
	if get_tree() != null:
		get_tree().call_group("uff_duh_cards", "refresh_visual_style")

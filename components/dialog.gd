class_name MaterialDialog
extends Control
## Material 3 dialog: scrim, a 28dp panel from the theme's `M3Dialog`
## variation, a headline, supporting copy and two actions. It is a reusable
## scene rather than a Godot Window so it renders the same way inside an
## embedded plate as it does over a real screen.

signal confirmed
signal cancelled

var headline := "Replace this file?"
var body := "The old version stays in your history for 30 days."
var confirm_label := "Replace"
var cancel_label := "Keep both"
var destructive := false

var _panel: PanelContainer
var _headline_label: Label
var _body_label: Label
var _confirm: Button
var _cancel: Button


func _ready() -> void:
	if _panel == null:
		_build()
	_apply()


func setup(dialog_headline: String, dialog_body: String, confirm: String = "Replace", cancel: String = "Keep both", is_destructive: bool = false) -> MaterialDialog:
	headline = dialog_headline
	body = dialog_body
	confirm_label = confirm
	cancel_label = cancel
	destructive = is_destructive
	if _panel != null:
		_apply()
	return self


func _build() -> void:
	var scrim := ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.32)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scrim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	_panel.theme_type_variation = "M3Dialog"
	_panel.custom_minimum_size = Vector2(260, 0)
	_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.add_child(_panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	_panel.add_child(column)

	_headline_label = Label.new()
	_headline_label.theme_type_variation = "M3LabelHeadline"
	_headline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_headline_label)

	_body_label = Label.new()
	_body_label.theme_type_variation = "M3LabelMuted"
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_body_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 8)
	column.add_child(actions)

	_cancel = Button.new()
	_cancel.theme_type_variation = "TextButton"
	actions.add_child(_cancel)
	_cancel.pressed.connect(func() -> void:
		cancelled.emit()
		close())

	_confirm = Button.new()
	actions.add_child(_confirm)
	_confirm.pressed.connect(func() -> void:
		confirmed.emit()
		close())


func open() -> void:
	visible = true
	modulate.a = 1.0
	_confirm.grab_focus()


func close() -> void:
	visible = false


func get_panel() -> PanelContainer:
	return _panel


func _apply() -> void:
	if _headline_label == null:
		return
	var source := theme if theme else Theme.new()
	_headline_label.text = headline
	_body_label.text = body
	_cancel.text = cancel_label
	_confirm.text = confirm_label
	if destructive:
		_confirm.add_theme_stylebox_override("normal", _box(source, "error", 20))
		_confirm.add_theme_stylebox_override("hover", _box(source, "error", 20, 0.08))
		_confirm.add_theme_stylebox_override("pressed", _box(source, "error", 20, 0.12))
		_confirm.add_theme_color_override("font_color", source.get_color("on_error", "M3Roles"))
		_confirm.add_theme_color_override("font_hover_color", source.get_color("on_error", "M3Roles"))
		_confirm.add_theme_color_override("font_pressed_color", source.get_color("on_error", "M3Roles"))


func _box(source: Theme, role_name: String, radius: int, overlay := 0.0) -> StyleBoxFlat:
	var base: Color = source.get_color(role_name, "M3Roles")
	var on_role: Color = source.get_color("on_error", "M3Roles")
	var box := StyleBoxFlat.new()
	box.bg_color = base.lerp(on_role, overlay) if overlay > 0.0 else base
	box.set_corner_radius_all(radius)
	box.content_margin_left = 24
	box.content_margin_right = 24
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box

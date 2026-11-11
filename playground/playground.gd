extends Control
## The kit's test bench: one page where every themed control is a real control.
##
## Nothing here is a specimen. Buttons take the mouse, fields take the keyboard,
## the switch flips the scheme underneath everything, and the dialogs open over
## the page — so every state can be tried by hand rather than read off a picture.

const LIGHT_PATH := "res://theme/material_light.tres"
const DARK_PATH := "res://theme/material_dark.tres"

var theme_light: Theme
var theme_dark: Theme
var dark_mode := false
var initial_dark := false

var _bg: ColorRect
var _status: Label
var _dialog: MaterialDialog
var _light_button: Button
var _dark_button: Button
var _name_field: LineEdit
var _name_hint: Label
var _list: ItemList
var _select: OptionButton


func _ready() -> void:
	theme_light = load(LIGHT_PATH)
	theme_dark = load(DARK_PATH)
	dark_mode = initial_dark
	theme = theme_dark if dark_mode else theme_light
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()


func _build() -> void:
	_bg = ColorRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.color = role("surface")
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	var shell := VBoxContainer.new()
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.add_theme_constant_override("separation", 0)
	add_child(shell)

	var header_host := MarginContainer.new()
	header_host.add_theme_constant_override("margin_left", 32)
	header_host.add_theme_constant_override("margin_right", 32)
	header_host.add_theme_constant_override("margin_top", 20)
	header_host.add_theme_constant_override("margin_bottom", 16)
	header_host.add_child(_header())
	shell.add_child(header_host)
	shell.add_child(_rule())

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 32)
	scroll.add_child(margin)

	margin.add_child(_columns())

	shell.add_child(_rule())
	var status_host := MarginContainer.new()
	status_host.add_theme_constant_override("margin_left", 32)
	status_host.add_theme_constant_override("margin_right", 32)
	status_host.add_theme_constant_override("margin_top", 10)
	status_host.add_theme_constant_override("margin_bottom", 10)
	status_host.add_child(_status_bar())
	shell.add_child(status_host)

	_dialog = MaterialDialog.new()
	_dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dialog.visible = false
	_dialog.confirmed.connect(func() -> void: say("Dialog confirmed"))
	_dialog.cancelled.connect(func() -> void: say("Dialog dismissed"))
	add_child(_dialog)
	_name_field.grab_focus()


func _header() -> Control:
	var bar := HFlowContainer.new()
	bar.add_theme_constant_override("h_separation", 16)
	bar.add_theme_constant_override("v_separation", 10)

	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 2)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.text = "Material Theme — test bench"
	title.theme_type_variation = "M3LabelPage"
	left.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Live controls: click them, tab through them, type in them. Light / Dark re-themes everything below."
	subtitle.theme_type_variation = "M3LabelMuted"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(subtitle)
	bar.add_child(left)

	var switch_row := HBoxContainer.new()
	switch_row.add_theme_constant_override("separation", 8)
	_light_button = _scheme_button("Light", not dark_mode)
	_light_button.pressed.connect(_set_dark.bind(false))
	switch_row.add_child(_light_button)
	_dark_button = _scheme_button("Dark", dark_mode)
	_dark_button.pressed.connect(_set_dark.bind(true))
	switch_row.add_child(_dark_button)
	bar.add_child(switch_row)
	return bar


func _scheme_button(text: String, active: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.theme_type_variation = "TonalButton" if active else "OutlinedButton"
	button.add_theme_font_size_override("font_size", 12)
	return button


func _rule() -> ColorRect:
	var line := ColorRect.new()
	line.color = role("outline_variant")
	line.custom_minimum_size = Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line


func _status_bar() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var caption := Label.new()
	caption.text = "Last event"
	caption.theme_type_variation = "M3LabelCaption"
	row.add_child(caption)
	_status = Label.new()
	_status.text = "Ready — nothing pressed yet."
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status.theme_type_variation = "M3LabelBody"
	row.add_child(_status)
	return row


func _columns() -> Control:
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 24)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 24)
	for section in [_section_buttons(), _section_fields(), _section_selection()]:
		left.add_child(section)
	for section in [_section_cards(), _section_lists(), _section_dialogs()]:
		right.add_child(section)
	columns.add_child(left)
	columns.add_child(right)
	return columns


func _section(title: String, spec: String, body: Control) -> PanelContainer:
	var plate := PanelContainer.new()
	plate.theme_type_variation = "M3Plate"
	plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	plate.add_child(column)

	var heading := Label.new()
	heading.text = title
	heading.theme_type_variation = "M3LabelTitle"
	column.add_child(heading)

	if spec != "":
		var spec_label := Label.new()
		spec_label.text = spec
		spec_label.theme_type_variation = "M3LabelCaption"
		spec_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(spec_label)

	column.add_child(body)
	return plate


func _section_buttons() -> PanelContainer:
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 12)
	for pair in [["Button", "Filled"], ["TonalButton", "Tonal"], ["OutlinedButton", "Outlined"], ["TextButton", "Text"]]:
		var button := Button.new()
		button.text = pair[1]
		button.theme_type_variation = pair[0]
		button.pressed.connect(func() -> void: say("%s button pressed" % button.text))
		row.add_child(button)
	var disabled := Button.new()
	disabled.text = "Disabled"
	disabled.disabled = true
	row.add_child(disabled)
	return _section("Buttons", "Hover, press and tab through them; the focus ring is the theme's own.", row)


func _section_fields() -> PanelContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)

	_name_field = LineEdit.new()
	_name_field.placeholder_text = "Project name"
	_name_field.text_changed.connect(_on_name_changed)
	column.add_child(_name_field)

	_name_hint = Label.new()
	_name_hint.text = "Type a name; clear it to see the error variation."
	_name_hint.theme_type_variation = "M3LabelMuted"
	column.add_child(_name_hint)

	var notes := TextEdit.new()
	notes.text = "TextEdit keeps the same fill and underline."
	notes.custom_minimum_size = Vector2(0, 84)
	notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	notes.text_changed.connect(func() -> void: say("TextEdit changed (%d characters)" % notes.text.length()))
	column.add_child(notes)

	return _section("Text fields", "LineEdit validates live: empty swaps in M3FieldError.", column)


func _on_name_changed(value: String) -> void:
	if value.strip_edges() == "":
		_name_field.theme_type_variation = "M3FieldError"
		_name_hint.text = "A project name is required."
		_name_hint.theme_type_variation = "M3LabelError"
		say("Field is empty — error state")
	else:
		_name_field.theme_type_variation = ""
		_name_hint.text = "Looks good: %s" % value
		_name_hint.theme_type_variation = "M3LabelMuted"
		say("Typing “%s”" % value)


func _section_selection() -> PanelContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)

	var check := CheckBox.new()
	check.text = "Sync automatically"
	check.button_pressed = true
	check.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	check.toggled.connect(func(on: bool) -> void: say("CheckBox %s" % ("checked" if on else "unchecked")))
	column.add_child(check)

	var switch := CheckButton.new()
	switch.text = "Dark at night"
	switch.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	switch.toggled.connect(func(on: bool) -> void: say("Switch %s" % ("on" if on else "off")))
	column.add_child(switch)

	_select = OptionButton.new()
	_select.theme_type_variation = "M3Select"
	for option in ["Roboto", "Roboto Condensed", "Roboto Mono"]:
		_select.add_item(option)
	_select.select(0)
	_select.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_select.item_selected.connect(func(index: int) -> void: say("Select: %s" % _select.get_item_text(index)))
	column.add_child(_select)

	var disabled := CheckBox.new()
	disabled.text = "Requires Pro"
	disabled.disabled = true
	disabled.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.add_child(disabled)

	return _section("Selection", "Click, toggle and pick; a disabled control is the same mark at 38%.", column)


func _section_cards() -> PanelContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)

	var card := MaterialCard.new()
	card.setup("Material 3 tokens", "Colour, type and shape resolve from roles, so a scheme change restyles every control on this page.", "Report event", MaterialCard.Variant.FILLED)
	card.action_pressed.connect(func() -> void: say("Card action pressed"))
	column.add_child(card)

	var outlined := MaterialCard.new()
	outlined.setup("Outlined card", "For content that sits on a plain surface.", "", MaterialCard.Variant.OUTLINED)
	column.add_child(outlined)

	return _section("Cards", "Cards are containers; the action is a real text button.", column)


func _section_lists() -> PanelContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)

	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(0, 248)
	for item in ["Surface roles", "Type scale", "Shape", "State layers"]:
		_list.add_item(item)
	_list.item_selected.connect(func(index: int) -> void: say("List row selected: %s" % _list.get_item_text(index)))
	column.add_child(_list)

	return _section("Lists", "Click a row: selection, hover and the cursor outline are theme styleboxes.", column)


func _section_dialogs() -> PanelContainer:
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 12)

	var confirm := Button.new()
	confirm.text = "Open dialog"
	confirm.pressed.connect(func() -> void:
		_dialog.setup("Replace this file?", "The old version stays in your history for 30 days.", "Replace", "Keep both", false)
		_dialog.open()
		say("Dialog opened"))
	row.add_child(confirm)

	var destructive := Button.new()
	destructive.theme_type_variation = "OutlinedButton"
	destructive.text = "Delete…"
	destructive.pressed.connect(func() -> void:
		_dialog.setup("Delete project?", "This removes the demo scene and both theme resources. It cannot be undone.", "Delete", "Cancel", true)
		_dialog.open()
		say("Destructive dialog opened"))
	row.add_child(destructive)

	return _section("Dialogs", "A 32% scrim over this page, 28dp panel, two actions wired to the status bar.", row)


func _set_dark(dark: bool) -> void:
	if dark == dark_mode:
		return
	dark_mode = dark
	theme = theme_dark if dark else theme_light
	_bg.color = role("surface")
	_light_button.theme_type_variation = "OutlinedButton" if dark else "TonalButton"
	_dark_button.theme_type_variation = "TonalButton" if dark else "OutlinedButton"
	say("Scheme switched to %s" % ("dark" if dark else "light"))


func say(message: String) -> void:
	if _status:
		_status.text = message


func role(role_name: String) -> Color:
	return theme.get_color(role_name, "M3Roles")

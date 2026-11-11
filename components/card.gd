class_name MaterialCard
extends PanelContainer
## Material 3 card: filled (surface-container-high) or outlined, with an
## optional supporting line and a text action. The look comes from the theme's
## `M3Card` / `M3CardOutlined` type variations; this script only assembles the
## content and names the variant.

enum Variant { FILLED, OUTLINED }

var headline := ""
var supporting := ""
var action := ""

var _headline_label: Label
var _supporting_label: Label
var _action_button: Button
var _column: VBoxContainer


func _ready() -> void:
	if _column == null:
		_build()


func setup(card_headline: String, card_supporting: String = "", card_action: String = "", variant: Variant = Variant.FILLED) -> MaterialCard:
	headline = card_headline
	supporting = card_supporting
	action = card_action
	theme_type_variation = "M3CardOutlined" if variant == Variant.OUTLINED else "M3Card"
	if _column != null:
		_apply()
	return self


func _build() -> void:
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 8)
	add_child(_column)

	_headline_label = Label.new()
	_headline_label.add_theme_font_override("font", _medium())
	_headline_label.add_theme_font_size_override("font_size", 16)
	_column.add_child(_headline_label)

	_supporting_label = Label.new()
	_supporting_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_supporting_label.add_theme_font_size_override("font_size", 14)
	_supporting_label.add_theme_color_override("font_color", _role("on_surface_variant"))
	_column.add_child(_supporting_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 8)
	_column.add_child(actions)

	_action_button = Button.new()
	_action_button.theme_type_variation = "TextButton"
	_action_button.focus_mode = Control.FOCUS_NONE
	actions.add_child(_action_button)
	_apply()


func _apply() -> void:
	if _headline_label == null:
		return
	_headline_label.text = headline
	_headline_label.add_theme_color_override("font_color", _role("on_surface"))
	_supporting_label.text = supporting
	_supporting_label.visible = supporting != ""
	_action_button.text = action
	_action_button.visible = action != ""
	_action_button.add_theme_color_override("font_color", _role("primary"))
	_action_button.add_theme_color_override("font_hover_color", _role("primary"))
	_action_button.add_theme_color_override("font_pressed_color", _role("primary"))


func _medium() -> Font:
	var loaded := theme.default_font if theme else null
	var medium := load("res://theme/fonts/Roboto-500.ttf")
	return medium if medium else loaded


func _role(role_name: String) -> Color:
	var source := theme if theme else Theme.new()
	return source.get_color(role_name, "M3Roles")

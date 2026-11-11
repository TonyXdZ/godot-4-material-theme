extends SceneTree
## Builds the kit's two Theme resources from the Material 3 baseline roles.
##
##   godot --headless --script res://theme/build_theme.gd
##
## Everything a downstream project needs is baked into the .tres files; this
## script is the source of truth for the tokens, and it also publishes every
## role and metric back into the theme under the `M3Roles` / `M3Metrics` types
## so a consuming scene can read one palette instead of duplicating hexes.

const LIGHT := {
	"primary": "#6750A4",
	"on_primary": "#FFFFFF",
	"primary_container": "#EADDFF",
	"on_primary_container": "#21005D",
	"secondary": "#625B71",
	"on_secondary": "#FFFFFF",
	"secondary_container": "#E8DEF8",
	"on_secondary_container": "#1D192B",
	"tertiary": "#7D5260",
	"on_tertiary": "#FFFFFF",
	"tertiary_container": "#FFD8E4",
	"on_tertiary_container": "#31111D",
	"error": "#B3261E",
	"on_error": "#FFFFFF",
	"error_container": "#F9DEDC",
	"on_error_container": "#410E0B",
	"surface": "#FFFBFE",
	"on_surface": "#1C1B1F",
	"surface_variant": "#E7E0EC",
	"on_surface_variant": "#49454F",
	"surface_container_lowest": "#FFFFFF",
	"surface_container_low": "#F7F2FA",
	"surface_container": "#F3EDF7",
	"surface_container_high": "#ECE6F0",
	"surface_container_highest": "#E6E0E9",
	"outline": "#79747E",
	"outline_variant": "#CAC4D0",
	"inverse_surface": "#313033",
	"inverse_on_surface": "#F4EFF4",
	"inverse_primary": "#D0BCFF",
	"shadow": "#000000",
	"scrim": "#000000",
}

const DARK := {
	"primary": "#D0BCFF",
	"on_primary": "#381E72",
	"primary_container": "#4F378B",
	"on_primary_container": "#EADDFF",
	"secondary": "#CCC2DC",
	"on_secondary": "#332D41",
	"secondary_container": "#4A4458",
	"on_secondary_container": "#E8DEF8",
	"tertiary": "#EFB8C8",
	"on_tertiary": "#492532",
	"tertiary_container": "#633B48",
	"on_tertiary_container": "#FFD8E4",
	"error": "#F2B8B5",
	"on_error": "#601410",
	"error_container": "#8C1D18",
	"on_error_container": "#F9DEDC",
	"surface": "#141218",
	"on_surface": "#E6E1E5",
	"surface_variant": "#49454F",
	"on_surface_variant": "#CAC4D0",
	"surface_container_lowest": "#0F0D13",
	"surface_container_low": "#1D1B20",
	"surface_container": "#211F26",
	"surface_container_high": "#2B2930",
	"surface_container_highest": "#36343B",
	"outline": "#938F99",
	"outline_variant": "#49454F",
	"inverse_surface": "#E6E1E5",
	"inverse_on_surface": "#313033",
	"inverse_primary": "#6750A4",
	"shadow": "#000000",
	"scrim": "#000000",
}

const HOVER := 0.08
const FOCUS := 0.12
const PRESSED := 0.12
const DRAG := 0.16
const DISABLED_CONTAINER := 0.12
const DISABLED_LABEL := 0.38

const RADIUS_FIELD := 4
const RADIUS_CARD := 12
const RADIUS_BUTTON := 20
const RADIUS_DIALOG := 28

const HEIGHT_BUTTON := 40
const HEIGHT_FIELD := 56
const HEIGHT_ROW := 56
const TARGET_MIN := 48
const PAD_BUTTON := 24
const PAD_CARD := 16
const PAD_DIALOG := 24

var font_regular: FontFile
var font_medium: FontFile
var font_bold: FontFile

var _scheme := ""
var _roles := {}


func _initialize() -> void:
	_load_fonts()
	for pair in [["light", LIGHT], ["dark", DARK]]:
		var scheme: String = pair[0]
		var theme := _build(scheme, pair[1])
		var path := "res://theme/material_%s.tres" % scheme
		var err := ResourceSaver.save(theme, path)
		print("build_theme: %s -> %s (err %d)" % [scheme, path, err])
	quit()


func _load_fonts() -> void:
	font_regular = _font("res://theme/fonts/Roboto-400.ttf")
	font_medium = _font("res://theme/fonts/Roboto-500.ttf")
	font_bold = _font("res://theme/fonts/Roboto-700.ttf")


func _font(path: String) -> FontFile:
	var file := FontFile.new()
	var err := file.load_dynamic_font(path)
	if err != OK:
		push_warning("build_theme: falling back to imported font for %s" % path)
		return load(path)
	return file


func _build(scheme: String, roles: Dictionary) -> Theme:
	_scheme = scheme
	_roles = roles
	var theme := Theme.new()
	theme.default_font = font_regular
	theme.default_font_size = 14

	_publish_tokens(theme)
	_theme_label(theme)
	_theme_buttons(theme)
	_theme_fields(theme)
	_theme_selection_controls(theme)
	_theme_option_button(theme)
	_theme_lists(theme)
	_theme_surfaces(theme)
	_theme_menus(theme)
	_theme_scrollbars(theme)
	_align_heights(theme)
	return theme


## Godot rounds a stylebox's content margins, so a symmetric 11.5dp pad can
## never land on Material's 40dp button. The heights are pinned here instead,
## once, on the styleboxes the components actually draw.
func _align_heights(theme: Theme) -> void:
	for type_name in ["Button", "TonalButton", "OutlinedButton", "TextButton"]:
		for state in ["normal", "hover", "pressed", "disabled"]:
			var box := theme.get_stylebox(state, type_name)
			if box:
				box.content_margin_top = 11
				box.content_margin_bottom = 12
	for type_name in ["LineEdit", "TextEdit", "M3FieldError"]:
		for state in ["normal", "read_only"]:
			var box := theme.get_stylebox(state, type_name)
			if box:
				box.content_margin_top = 18
				box.content_margin_bottom = 19


# --- token plumbing ---------------------------------------------------------

func _publish_tokens(theme: Theme) -> void:
	for role in _roles.keys():
		theme.set_color(str(role), "M3Roles", _c(str(role)))
	theme.set_constant("height_button", "M3Metrics", HEIGHT_BUTTON)
	theme.set_constant("height_field", "M3Metrics", HEIGHT_FIELD)
	theme.set_constant("height_row", "M3Metrics", HEIGHT_ROW)
	theme.set_constant("radius_button", "M3Metrics", RADIUS_BUTTON)
	theme.set_constant("radius_field", "M3Metrics", RADIUS_FIELD)
	theme.set_constant("radius_card", "M3Metrics", RADIUS_CARD)
	theme.set_constant("radius_dialog", "M3Metrics", RADIUS_DIALOG)
	theme.set_constant("pad_button", "M3Metrics", PAD_BUTTON)
	theme.set_constant("pad_card", "M3Metrics", PAD_CARD)
	theme.set_constant("pad_dialog", "M3Metrics", PAD_DIALOG)
	theme.set_constant("state_hover", "M3Metrics", int(HOVER * 100))
	theme.set_constant("state_focus", "M3Metrics", int(FOCUS * 100))
	theme.set_constant("state_pressed", "M3Metrics", int(PRESSED * 100))
	theme.set_color("scheme_is_dark", "M3Roles", Color(1, 1, 1) if _scheme == "dark" else Color(0, 0, 0))


func _c(role: String) -> Color:
	return Color(_roles[role])


func _over(base: Color, tint: Color, alpha: float) -> Color:
	return base.lerp(tint, alpha)


func _wash(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)


func _flat(bg: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	return box


func _outlined(bg: Color, border: Color, radius: int, width: int = 1) -> StyleBoxFlat:
	var box := _flat(bg, radius)
	box.set_border_width_all(width)
	box.border_color = border
	return box


func _padded(box: StyleBox, h: int, v: int) -> StyleBox:
	box.content_margin_left = h
	box.content_margin_right = h
	box.content_margin_top = v
	box.content_margin_bottom = v
	return box


func _focus_ring(layer: Color, ring_color: Color, radius: int) -> StyleBoxFlat:
	var box := _flat(layer, radius + 3)
	box.set_border_width_all(3)
	box.border_color = ring_color
	box.set_expand_margin_all(3)
	return box


func _shadow(box: StyleBoxFlat, color: Color, size: int, offset: Vector2) -> StyleBoxFlat:
	box.shadow_color = color
	box.shadow_size = size
	box.shadow_offset = offset
	return box


# --- components -------------------------------------------------------------

func _theme_label(theme: Theme) -> void:
	theme.set_font("font", "Label", font_regular)
	theme.set_font_size("font_size", "Label", 14)
	theme.set_color("font_color", "Label", _c("on_surface"))


func _theme_buttons(theme: Theme) -> void:
	var filled := _c("primary")
	var on_filled := _c("on_primary")
	var disabled_bg := _over(_c("surface"), _c("on_surface"), DISABLED_CONTAINER)
	var disabled_label := _over(disabled_bg, _c("on_surface"), DISABLED_LABEL)

	theme.set_stylebox("normal", "Button", _padded(_flat(filled, RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("hover", "Button", _padded(_flat(_over(filled, on_filled, HOVER), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("pressed", "Button", _padded(_flat(_over(filled, on_filled, PRESSED), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("disabled", "Button", _padded(_flat(disabled_bg, RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("focus", "Button", _focus_ring(_over(filled, on_filled, FOCUS), _c("on_primary"), RADIUS_BUTTON))
	theme.set_font("font", "Button", font_medium)
	theme.set_font_size("font_size", "Button", 14)
	theme.set_color("font_color", "Button", on_filled)
	theme.set_color("font_hover_color", "Button", on_filled)
	theme.set_color("font_pressed_color", "Button", on_filled)
	theme.set_color("font_focus_color", "Button", on_filled)
	theme.set_color("font_disabled_color", "Button", disabled_label)
	theme.set_color("icon_normal_color", "Button", on_filled)
	theme.set_color("icon_hover_color", "Button", on_filled)
	theme.set_color("icon_pressed_color", "Button", on_filled)
	theme.set_color("icon_disabled_color", "Button", disabled_label)
	theme.set_constant("h_separation", "Button", 8)
	theme.set_constant("outline_size", "Button", 0)

	# Tonal
	theme.set_type_variation("TonalButton", "Button")
	var tonal := _c("secondary_container")
	var on_tonal := _c("on_secondary_container")
	theme.set_stylebox("normal", "TonalButton", _padded(_flat(tonal, RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("hover", "TonalButton", _padded(_flat(_over(tonal, on_tonal, HOVER), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("pressed", "TonalButton", _padded(_flat(_over(tonal, on_tonal, PRESSED), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("disabled", "TonalButton", _padded(_flat(disabled_bg, RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("focus", "TonalButton", _focus_ring(_over(tonal, on_tonal, FOCUS), _c("primary"), RADIUS_BUTTON))
	theme.set_color("font_color", "TonalButton", on_tonal)
	theme.set_color("font_hover_color", "TonalButton", on_tonal)
	theme.set_color("font_pressed_color", "TonalButton", on_tonal)
	theme.set_color("font_focus_color", "TonalButton", on_tonal)
	theme.set_color("font_disabled_color", "TonalButton", disabled_label)

	# Outlined
	theme.set_type_variation("OutlinedButton", "Button")
	var primary := _c("primary")
	theme.set_stylebox("normal", "OutlinedButton", _padded(_outlined(Color.TRANSPARENT, _c("outline"), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("hover", "OutlinedButton", _padded(_outlined(_wash(primary, HOVER), _c("outline"), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("pressed", "OutlinedButton", _padded(_outlined(_wash(primary, PRESSED), _c("outline"), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("disabled", "OutlinedButton", _padded(_outlined(Color.TRANSPARENT, _over(_c("surface"), _c("on_surface"), DISABLED_CONTAINER), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("focus", "OutlinedButton", _focus_ring(_wash(primary, FOCUS), primary, RADIUS_BUTTON))
	theme.set_color("font_color", "OutlinedButton", primary)
	theme.set_color("font_hover_color", "OutlinedButton", primary)
	theme.set_color("font_pressed_color", "OutlinedButton", primary)
	theme.set_color("font_focus_color", "OutlinedButton", primary)
	theme.set_color("font_disabled_color", "OutlinedButton", _over(_c("surface"), _c("on_surface"), DISABLED_LABEL))

	# Text
	theme.set_type_variation("TextButton", "Button")
	theme.set_stylebox("normal", "TextButton", _padded(_flat(Color.TRANSPARENT, RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("hover", "TextButton", _padded(_flat(_wash(primary, HOVER), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("pressed", "TextButton", _padded(_flat(_wash(primary, PRESSED), RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("disabled", "TextButton", _padded(_flat(Color.TRANSPARENT, RADIUS_BUTTON), PAD_BUTTON, 11.75))
	theme.set_stylebox("focus", "TextButton", _focus_ring(_wash(primary, FOCUS), primary, RADIUS_BUTTON))
	theme.set_color("font_color", "TextButton", primary)
	theme.set_color("font_hover_color", "TextButton", primary)
	theme.set_color("font_pressed_color", "TextButton", primary)
	theme.set_color("font_focus_color", "TextButton", primary)
	theme.set_color("font_disabled_color", "TextButton", _over(_c("surface"), _c("on_surface"), DISABLED_LABEL))


func _theme_fields(theme: Theme) -> void:
	var container := _c("surface_container_highest")
	var text := _c("on_surface")
	var hint := _c("on_surface_variant")
	var primary := _c("primary")

	for type_name in ["LineEdit", "TextEdit"]:
		var base := _flat(container, RADIUS_FIELD)
		base.corner_radius_top_left = RADIUS_FIELD
		base.corner_radius_top_right = RADIUS_FIELD
		base.corner_radius_bottom_left = 0
		base.corner_radius_bottom_right = 0
		base.border_width_bottom = 1
		base.border_color = hint
		_padded(base, 16, 18.25)
		theme.set_stylebox("normal", type_name, base)

		var focus := _flat(Color.TRANSPARENT, RADIUS_FIELD)
		focus.corner_radius_bottom_left = 0
		focus.corner_radius_bottom_right = 0
		focus.border_width_bottom = 2
		focus.border_color = primary
		theme.set_stylebox("focus", type_name, focus)

		var readonly := _flat(_over(_c("surface"), container, 0.45), RADIUS_FIELD)
		readonly.corner_radius_bottom_left = 0
		readonly.corner_radius_bottom_right = 0
		readonly.border_width_bottom = 1
		readonly.border_color = _over(readonly.bg_color, hint, 0.38)
		_padded(readonly, 16, 18.25)
		theme.set_stylebox("read_only", type_name, readonly)

		theme.set_font("font", type_name, font_regular)
		theme.set_font_size("font_size", type_name, 16)
		theme.set_color("font_color", type_name, text)
		theme.set_color("font_placeholder_color", type_name, hint)
		theme.set_color("font_selected_color", type_name, _c("on_secondary_container"))
		theme.set_color("selection_color", type_name, _wash(_c("secondary"), 0.35))
		theme.set_color("caret_color", type_name, primary)
		theme.set_constant("caret_width", type_name, 2)
		theme.set_constant("minimum_character_width", type_name, 4)
		theme.set_constant("line_spacing", type_name, 4)
		theme.set_color("font_uneditable_color", type_name, _over(container, text, 0.38))
		theme.set_color("font_readonly_color", type_name, _over(container, text, 0.38))

	# Error state for a filled field: the underline and the hint both take the
	# error role instead of a hand-picked red.
	theme.set_type_variation("M3FieldError", "LineEdit")
	var error_base := _flat(container, RADIUS_FIELD)
	error_base.corner_radius_bottom_left = 0
	error_base.corner_radius_bottom_right = 0
	error_base.border_width_bottom = 2
	error_base.border_color = _c("error")
	_padded(error_base, 16, 18)
	theme.set_stylebox("normal", "M3FieldError", error_base)
	var error_focus := _flat(Color.TRANSPARENT, RADIUS_FIELD)
	error_focus.corner_radius_bottom_left = 0
	error_focus.corner_radius_bottom_right = 0
	error_focus.border_width_bottom = 2
	error_focus.border_color = _c("error")
	theme.set_stylebox("focus", "M3FieldError", error_focus)
	theme.set_font("font", "M3FieldError", font_regular)
	theme.set_font_size("font_size", "M3FieldError", 16)
	theme.set_color("font_color", "M3FieldError", text)
	theme.set_color("font_placeholder_color", "M3FieldError", _c("error"))
	theme.set_color("caret_color", "M3FieldError", _c("error"))


func _theme_selection_controls(theme: Theme) -> void:
	var text := _c("on_surface")
	var disabled := _over(_c("surface"), _c("on_surface"), DISABLED_LABEL)
	var primary := _c("primary")

	for type_name in ["CheckBox", "CheckButton"]:
		var idle := _padded(_flat(Color.TRANSPARENT, 20), 10, 8)
		var hover := _padded(_flat(_wash(primary, HOVER), 20), 10, 8)
		var pressed := _padded(_flat(_wash(primary, PRESSED), 20), 10, 8)
		theme.set_stylebox("normal", type_name, idle)
		theme.set_stylebox("hover", type_name, hover)
		theme.set_stylebox("hover_pressed", type_name, pressed)
		theme.set_stylebox("pressed", type_name, pressed)
		theme.set_stylebox("disabled", type_name, idle)
		theme.set_stylebox("focus", type_name, _focus_ring(_wash(primary, FOCUS), primary, 20))
		theme.set_font("font", type_name, font_regular)
		theme.set_font_size("font_size", type_name, 14)
		theme.set_color("font_color", type_name, text)
		theme.set_color("font_hover_color", type_name, text)
		theme.set_color("font_pressed_color", type_name, text)
		theme.set_color("font_focus_color", type_name, text)
		theme.set_color("font_disabled_color", type_name, disabled)
		theme.set_constant("h_separation", type_name, 12)
		theme.set_constant("check_v_offset", type_name, 0)

	var check_on: Texture2D = load("res://theme/icons/check_box_on_%s.svg" % _scheme)
	var check_off: Texture2D = load("res://theme/icons/check_box_off_%s.svg" % _scheme)
	var switch_on: Texture2D = load("res://theme/icons/switch_on_%s.svg" % _scheme)
	var switch_off: Texture2D = load("res://theme/icons/switch_off_%s.svg" % _scheme)

	theme.set_icon("checked", "CheckBox", check_on)
	theme.set_icon("unchecked", "CheckBox", check_off)

	theme.set_icon("checked", "CheckButton", switch_on)
	theme.set_icon("unchecked", "CheckButton", switch_off)


func _theme_option_button(theme: Theme) -> void:
	theme.set_type_variation("M3Select", "OptionButton")
	theme.set_icon("arrow", "M3Select", load("res://theme/icons/arrow_down_%s.svg" % _scheme))
	var box := _outlined(_c("surface_container_highest"), _c("outline"), RADIUS_FIELD)
	_padded(box, 16, 12)
	theme.set_stylebox("normal", "M3Select", box)
	theme.set_stylebox("hover", "M3Select", _padded(_outlined(_over(_c("surface_container_highest"), _c("on_surface"), HOVER), _c("outline"), RADIUS_FIELD), 16, 12))
	theme.set_stylebox("pressed", "M3Select", _padded(_outlined(_over(_c("surface_container_highest"), _c("on_surface"), PRESSED), _c("primary"), RADIUS_FIELD), 16, 12))
	theme.set_stylebox("disabled", "M3Select", _padded(_outlined(_c("surface"), _over(_c("surface"), _c("on_surface"), DISABLED_CONTAINER), RADIUS_FIELD), 16, 12))
	theme.set_stylebox("focus", "M3Select", _focus_ring(_wash(_c("primary"), FOCUS), _c("primary"), RADIUS_FIELD))
	theme.set_font("font", "M3Select", font_regular)
	theme.set_font_size("font_size", "M3Select", 16)
	theme.set_color("font_color", "M3Select", _c("on_surface"))
	theme.set_color("font_hover_color", "M3Select", _c("on_surface"))
	theme.set_color("font_pressed_color", "M3Select", _c("on_surface"))
	theme.set_color("font_focus_color", "M3Select", _c("on_surface"))
	theme.set_color("font_disabled_color", "M3Select", _over(_c("surface"), _c("on_surface"), DISABLED_LABEL))


func _theme_lists(theme: Theme) -> void:
	theme.set_font("font", "ItemList", font_regular)
	theme.set_font_size("font_size", "ItemList", 14)
	theme.set_color("font_color", "ItemList", _c("on_surface"))
	theme.set_color("font_hovered_color", "ItemList", _c("on_surface"))
	theme.set_color("font_selected_color", "ItemList", _c("on_secondary_container"))
	theme.set_color("guide_color", "ItemList", _wash(_c("outline_variant"), 0.6))

	var panel := _outlined(_c("surface_container_lowest"), _c("outline_variant"), RADIUS_CARD)
	_padded(panel, 8, 8)
	theme.set_stylebox("panel", "ItemList", panel)

	var radius_item := RADIUS_CARD
	var selected := _flat(_c("secondary_container"), radius_item)
	_padded(selected, 12, 16)
	theme.set_stylebox("selected", "ItemList", selected)
	theme.set_stylebox("selected_focus", "ItemList", selected)

	var hovered := _flat(_over(_c("surface_container_lowest"), _c("on_surface"), HOVER), radius_item)
	_padded(hovered, 12, 16)
	theme.set_stylebox("hovered", "ItemList", hovered)

	theme.set_stylebox("cursor", "ItemList", _outlined(Color.TRANSPARENT, _c("primary"), radius_item, 1))
	theme.set_stylebox("cursor_unfocused", "ItemList", StyleBoxEmpty.new())
	theme.set_stylebox("focus", "ItemList", _focus_ring(_wash(_c("primary"), FOCUS), _c("primary"), RADIUS_CARD))
	theme.set_constant("h_separation", "ItemList", 12)
	theme.set_constant("v_separation", "ItemList", 32)
	theme.set_constant("icon_margin", "ItemList", 8)
	theme.set_constant("line_separation", "ItemList", 2)


func _theme_surfaces(theme: Theme) -> void:
	theme.set_stylebox("panel", "PanelContainer", StyleBoxEmpty.new())
	theme.set_stylebox("panel", "Panel", StyleBoxEmpty.new())

	theme.set_type_variation("M3Card", "PanelContainer")
	var card := _flat(_c("surface_container_highest"), RADIUS_CARD)
	_padded(card, PAD_CARD, PAD_CARD)
	theme.set_stylebox("panel", "M3Card", card)

	theme.set_type_variation("M3CardOutlined", "PanelContainer")
	var outlined := _outlined(_c("surface"), _c("outline_variant"), RADIUS_CARD)
	_padded(outlined, PAD_CARD, PAD_CARD)
	theme.set_stylebox("panel", "M3CardOutlined", outlined)

	theme.set_type_variation("M3Dialog", "PanelContainer")
	var dialog := _flat(_c("surface_container_high"), RADIUS_DIALOG)
	_padded(dialog, PAD_DIALOG, PAD_DIALOG)
	_shadow(dialog, _wash(_c("shadow"), 0.32), 24, Vector2(0, 10))
	theme.set_stylebox("panel", "M3Dialog", dialog)

	theme.set_type_variation("M3Plate", "PanelContainer")
	var plate := _outlined(_c("surface"), _c("outline_variant"), 16)
	_padded(plate, 24, 24)
	theme.set_stylebox("panel", "M3Plate", plate)

	theme.set_type_variation("M3InsetLight", "PanelContainer")
	theme.set_stylebox("panel", "M3InsetLight", _padded(_flat(LIGHT["surface_container_low"], 12), 20, 20))

	theme.set_type_variation("M3InsetDark", "PanelContainer")
	theme.set_stylebox("panel", "M3InsetDark", _padded(_flat(DARK["surface_container_low"], 12), 20, 20))

	theme.set_stylebox("panel", "PopupPanel", _padded(_outlined(_c("surface_container"), _c("outline_variant"), RADIUS_CARD), 8, 8))


func _theme_menus(theme: Theme) -> void:
	var menu := _outlined(_c("surface_container"), _c("outline_variant"), RADIUS_CARD)
	_shadow(menu, _wash(_c("shadow"), 0.24), 16, Vector2(0, 6))
	theme.set_stylebox("panel", "PopupMenu", menu)
	theme.set_stylebox("hover", "PopupMenu", _flat(_c("secondary_container"), 8))
	theme.set_stylebox("separator", "PopupMenu", _flat(_c("outline_variant"), 0))
	theme.set_stylebox("labeled_separator_left", "PopupMenu", StyleBoxEmpty.new())
	theme.set_stylebox("labeled_separator_right", "PopupMenu", StyleBoxEmpty.new())
	theme.set_font("font", "PopupMenu", font_regular)
	theme.set_font_size("font_size", "PopupMenu", 14)
	theme.set_color("font_color", "PopupMenu", _c("on_surface"))
	theme.set_color("font_hover_color", "PopupMenu", _c("on_secondary_container"))
	theme.set_color("font_disabled_color", "PopupMenu", _over(_c("surface_container"), _c("on_surface"), DISABLED_LABEL))
	theme.set_color("font_accelerator_color", "PopupMenu", _c("on_surface_variant"))
	theme.set_color("font_separator_color", "PopupMenu", _c("on_surface_variant"))
	theme.set_constant("item_start_padding", "PopupMenu", 12)
	theme.set_constant("item_end_padding", "PopupMenu", 12)
	theme.set_constant("v_separation", "PopupMenu", 6)
	theme.set_constant("h_separation", "PopupMenu", 8)


func _theme_scrollbars(theme: Theme) -> void:
	for type_name in ["VScrollBar", "HScrollBar"]:
		theme.set_stylebox("scroll", type_name, _padded(_flat(Color.TRANSPARENT, 4), 2, 2))
		theme.set_stylebox("grabber", type_name, _padded(_flat(_wash(_c("on_surface"), 0.32), 4), 2, 2))
		theme.set_stylebox("grabber_highlight", type_name, _padded(_flat(_wash(_c("on_surface"), 0.48), 4), 2, 2))
		theme.set_stylebox("grabber_pressed", type_name, _padded(_flat(_wash(_c("primary"), 0.7), 4), 2, 2))

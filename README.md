![Material Theme for Godot: the kit's icon, name and three of its controls](docs/screenshots/banner.png)

# Material Theme for Godot

A Material 3 theme for Godot 4.7. Two Theme resources, a bundled Roboto, and the
component styling that makes a Godot app look like a current app instead of an
engine demo — buttons, text fields, cards, dialogs and lists, in light and dark,
with hover, focus, pressed and disabled states.

The project opens on a test bench: every control is live there — click the
buttons, type in the fields, toggle the switch, open the dialogs, and the
Light / Dark switch re-themes the whole page. The component plates further down
are the same theme rendered for the record, measurements called out, light block
above dark block.

## Screenshots

Captured from the running project at 1440dp, into `docs/screenshots/`.

### Test bench

The page you get when you run the project: live buttons, fields, selection
controls, a card with a working action, a selectable list and dialogs over the
page, with the last interaction reported at the bottom.

![The test bench, light scheme](docs/screenshots/playground.png)

![The test bench, dark scheme](docs/screenshots/playground-dark.png)

### Component plates

One plate per family: the specimen with its measurements, the state strip, and
the same controls again under the dark scheme.

![The plates in the light scheme: header, button plate and text-field plate](docs/screenshots/overview-light.png)

![The same page with the dark scheme applied to the shell](docs/screenshots/overview-dark.png)

### Buttons

Filled (the default), tonal, outlined and text, plus the five-state strip painted
from the theme's own hover, focus, pressed and disabled styleboxes.

![Buttons](docs/screenshots/buttons.png)

### Text fields

56dp filled field with its 1dp resting underline and 2dp focus underline, the
error variation, a clipped long value, and the multiline `TextEdit`.

![Text fields](docs/screenshots/text-fields.png)

### Cards

Filled card on `surface-container-highest` and the outlined variant, 12dp radius
with 16dp padding.

![Cards](docs/screenshots/cards.png)

### Dialogs

A 32% scrim, the 28dp panel, a dismiss and a confirm action — and the destructive
variant, which repaints the confirm button in the error role rather than inventing
a red.

![Dialogs](docs/screenshots/dialogs.png)

### Selection controls

The 18dp check, the 52×32 switch, a disabled control at the 38% label role, and
the `M3Select` option button with its 24dp arrow.

![Selection controls](docs/screenshots/selection-controls.png)

### Lists

`ItemList` with its 12dp panel and row radius, a selected row, a hovered row, and
one row carrying the disabled label.

![Lists](docs/screenshots/lists.png)

### Phone

The kit at 390dp: one column, the header wrapping under the title.

![The kit at phone width](docs/screenshots/phone-light.png)

## Use it

Copy `theme/` into your project (or point at this repo), then either

- set **Project Settings → GUI → Theme → Custom** to `res://theme/material_light.tres`, or
- put one theme on a subtree: `some_control.theme = load("res://theme/material_dark.tres")`

Buttons render 40dp and fields 56dp from the theme's published metrics
(`M3Metrics`), which a scene applies with `custom_minimum_size`. Android's 48dp touch
floor sits outside the visual height; wrap a 40dp button in a 48dp container if you
need the full hit area.

Switching schemes at runtime is swapping the resource — every control under it
re-resolves, because the styles read Material's colour roles rather than
hard-coded values.

## What is in the theme

| Type | What you get |
|---|---|
| `Button` | Filled — the default. Type variations: `TonalButton`, `OutlinedButton`, `TextButton` |
| `LineEdit`, `TextEdit` | Filled field: 56dp, 4dp top radius, 1dp resting underline, 2dp primary focus underline |
| `LineEdit` (`M3FieldError`) | Error field: the underline and the hint take the error role |
| `CheckBox`, `CheckButton` | Material 18dp check and the 52×32 switch, drawn per scheme |
| `OptionButton` (`M3Select`) | Outlined select with the dropdown arrow |
| `ItemList` | 12dp panel and row radius, 16dp row padding, hovered and cursor states |
| `PanelContainer` (`M3Card`, `M3CardOutlined`, `M3Dialog`, `M3Plate`) | Card, outlined card, dialog panel, section plate |
| `Label` (`M3LabelPage`, `M3LabelHeadline`, `M3LabelTitle`, `M3LabelBody`, `M3LabelMuted`, `M3LabelCaption`, `M3LabelError`) | The type scale as variations, so text follows the scheme instead of a frozen colour |
| `PopupMenu`, `PopupPanel` | Menus with the same surface language |
| `VScrollBar`, `HScrollBar` | Thin grabbers in the palette |

Two components ship as scripts, because Godot has no equivalent control:
`components/card.gd` (`MaterialCard`) and `components/dialog.gd`
(`MaterialDialog` — scrim, 28dp panel, headline, supporting copy, two actions).

Every role also lives in the theme under the `M3Roles` type and the metrics under
`M3Metrics`, so a scene can read the palette instead of repeating hexes:

```gdscript
var primary: Color = theme.get_color("primary", "M3Roles")
var radius: int = theme.get_constant("radius_card", "M3Metrics")
```

## Rebuilding the theme

The `.tres` files are generated from one token table, so the palette, the type
scale and the shapes are edited in one place:

```sh
godot --headless --import
godot --headless --script res://theme/build_theme.gd
```

The checkbox, switch and dropdown marks already ship as SVGs in `theme/icons/`;
if you recolour a scheme, edit those files before rebuilding.

`theme/build_theme.gd` holds the Material 3 baseline roles for light and dark,
the state-layer percentages, and the radii. Change a role there, rebuild, and
every control follows.

## The demo scene

Run the project and you land on `playground/playground.tscn`. It exists to be
poked: every control there is a real control, wired to a status bar that reports
what you just did, so hover, focus, pressed, disabled and the error field can be
tried by hand. It reflows from one column at phone width to two at desktop width,
and the header's Light / Dark switch re-themes the page underneath it.

## Scope

Starter set only: buttons, inputs, cards, dialogs, lists. Navigation bar, FAB,
chips, tabs, snackbars, bottom sheets, sliders and top app bars are later work,
not omissions by accident. Dynamic colour (Material You wallpaper extraction) is
out of scope; the schemes are static. Godot 4 has no radio control — a
`CheckBox` in a `ButtonGroup` gives the behaviour with a checkbox mark, and this
kit does not pretend to ship a radio dot.

## Licence

The theme and the two scripts are MIT — see [`LICENSE`](LICENSE).

Roboto is bundled under the Apache License 2.0 — see `theme/fonts/LICENSE-Roboto.txt`.
The project icon (`icon.svg`) is this repo's own drawing of Godot's robot inside a
Material squircle; Godot's logo is CC BY 4.0, Material Design is Apache 2.0.

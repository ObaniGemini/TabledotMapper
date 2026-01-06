extends VBoxContainer

signal update_visible(b: bool)
signal update_size(s: int)
signal update_width(s: int)
signal update_roughness(s: float)
signal update_negative(s: float)
signal update_color(c: Color)

@onready var VISIBLE := $CheckButton
@onready var SIZE := $VBoxContainer/Size
@onready var WIDTH := $VBoxContainer/Width
@onready var ROUGHNESS := $VBoxContainer/Roughness
@onready var NEGATIVE := $VBoxContainer/Negative
@onready var COLOR := $VBoxContainer/Color

func _ready():
	VISIBLE.button_pressed = config.GET("grid_visible")
	SIZE.update_value(config.GET("grid_size"))
	WIDTH.update_value(config.GET("grid_width"))
	ROUGHNESS.update_value(config.GET("grid_roughness"))
	NEGATIVE.update_value(config.GET("grid_negative"))
	COLOR.color = config.GET("grid_color")
	
	
	VISIBLE.toggled.connect(_update_visible)
	SIZE.value_changed.connect(_update_size)
	WIDTH.value_changed.connect(_update_width)
	ROUGHNESS.value_changed.connect(_update_roughness)
	NEGATIVE.value_changed.connect(_update_negative)
	COLOR.color_changed.connect(_update_color)


func __width_value(v: float) -> int:
	return int(WIDTH.max_value + WIDTH.min_value - v)


func get_visible() -> bool: return VISIBLE.button_pressed
func size() -> int: return int(SIZE.get_value())
func width() -> int: return __width_value(WIDTH.get_value())
func roughness() -> float: return ROUGHNESS.get_value()
func negative() -> float: return NEGATIVE.get_value()
func color() -> Color: return COLOR.color


func _update_visible(v: bool):
	config.SET("grid_visible", v)
	update_visible.emit(v)

func _update_size(v: float):
	config.SET("grid_size", v)
	update_size.emit(int(v))

func _update_width(v: float):
	config.SET("grid_width", v)
	update_width.emit(__width_value(v))

func _update_roughness(v: float):
	config.SET("grid_roughness", v)
	update_roughness.emit(v)

func _update_negative(v: float):
	config.SET("grid_negative", v)
	update_negative.emit(v)

func _update_color(c: Color):
	config.SET("grid_color", c)
	update_color.emit(c)

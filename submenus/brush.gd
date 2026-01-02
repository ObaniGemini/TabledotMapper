extends VBoxContainer

@export var TEXTURE_CHOOSER : NodePath

signal update_color(c: Color)
signal update_size(s: int)
signal update_brush(i: Image)

@onready var chooser := get_node(TEXTURE_CHOOSER)
@onready var parent := get_node("../../../")

func _ready():
	$Color.color = config.GET("brush_color")
	$Size.update_value(config.GET("brush_size"))
	
	$Color.color_changed.connect(_update_color)
	$Size.value_changed.connect(_update_size)
	$Brush.pressed.connect(show_popup)
	
	chooser.selected.connect(_update_brush)
	chooser.base_pathes = ["res://Data/brushes"]
	chooser.extensions = ["png"]
	chooser.selected_path = config.GET("brush_texture")

func show_popup():
	parent.popups.show()
	chooser.show()

func color() -> Color:
	return $Color.color

func size() -> int:
	return int($Size.get_value())

func _load_brush(path: String) -> Image:
	return TabledotImage.make_luminance_image(load(path).get_image())

func brush() -> Image:
	return _load_brush(config.GET("brush_texture"))

func _update_color(c: Color):
	config.SET("brush_color", c)
	update_color.emit(c)

func _update_size(v: float):
	config.SET("brush_size", v)
	update_size.emit(int(v))

func _update_brush(path: String, icon: ImageTexture):
	config.SET("brush_texture", path)
	
	parent.remove_popup(chooser)
	$Brush.texture_normal = icon
	$Brush.texture_pressed = icon
	$Brush.texture_hover = icon
	$Brush.texture_disabled = icon
	$Brush.texture_focused = icon
	
	update_brush.emit(_load_brush(path))

func set_color(c: Color):
	config.SET("brush_color", c)
	$Color.color = c

func _input(event: InputEvent):
	if event.is_action_pressed("exit"):
		parent.remove_popup(chooser)

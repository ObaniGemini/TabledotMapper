extends Node2D

@onready var brush := $PatternViewport/Sprite2D
@onready var full_pattern := $FullPattern/Sprite2D

var brush_size := 512.0
var color := Color()

func _ready():
	$PatternViewport/Sprite2D.scale = Vector2(30000.0, 30000.0)
	$FullPattern/Sprite2D.scale = Vector2(30000.0, 30000.0)

func set_size(x: float, y: float):
	$PatternViewport.size.x = x
	$PatternViewport.size.y = y
	$FullPattern.size.x = x
	$FullPattern.size.y = y

func set_pattern(c: CompressedTexture2D):
	brush.material.set_shader_parameter("tex", c)
	full_pattern.material.set_shader_parameter("tex", c)

func set_pattern_size(s: float):
	var size := 21.0 - s
	brush.material.set_shader_parameter("tex_size", size)
	full_pattern.material.set_shader_parameter("tex_size", size)

const FACTOR := PI/180.0
func set_pattern_rotation(r: float):
	brush.material.set_shader_parameter("tex_rotation", r * FACTOR)
	full_pattern.material.set_shader_parameter("tex_rotation", r * FACTOR)


func set_pattern_offset(offset: Vector2):
	brush.material.set_shader_parameter("tex_offset", offset)
	full_pattern.material.set_shader_parameter("tex_offset", offset)


func set_brush_pos(pos: Vector2):
	brush.material.set_shader_parameter("brush_pos", pos / Vector2($PatternViewport.size))

func set_brush_size(s: float):
	brush_size = s
	brush.material.set_shader_parameter("brush_size", brush_size)

func set_brush_roughness(r: float):
	brush.material.set_shader_parameter("brush_roughness", r)

func set_brush_color(c: Color):
	color = c
	brush.modulate = color
	full_pattern.modulate = color

func pattern_visible(b: bool):
	$Pattern2.self_modulate.a = 0.5 if b else 0.0


func get_pattern() -> Image:
	return $PatternViewport.get_texture().get_image()

func get_full_pattern() -> Image:
	return $FullPattern.get_texture().get_image()

extends Node2D

const CANVAS_CLASS := preload("res://canvas.tscn")
var canvas = null

func new_map(dim: Array):
	if canvas:
		canvas.queue_free()
	
	canvas = CANVAS_CLASS.instantiate()
	canvas.width = dim[0]
	canvas.height = dim[1]
	canvas.set_paint_mode(false)
	add_child(canvas)

func save(map_name: String):
	if map_name == "":
		$UI.error("map name is empty")
		return
	
	canvas.viewport.get_texture().get_image().save_png("user://" + map_name + ".png")


func set_paint_mode(pattern: bool):
	if canvas:
		canvas.set_paint_mode(pattern)


func can_edit() -> bool:
	return !$UI.is_hovered()



func brush_color(c: Color):
	$UI.brushparameters.set_color(c)
	if canvas: canvas.brush.update_properties(canvas.brush.size, c)

func brush_size(s: int):
	if canvas: canvas.brush.update_properties(s, canvas.brush.color)

func brush_texture(t: CompressedTexture2D):
	if canvas: canvas.brush.update_brush(t)



func pattern_texture(t: CompressedTexture2D):
	if canvas: canvas.pattern.set_pattern(t)

func pattern_size(s: float):
	if canvas: canvas.pattern.set_pattern_size(s)

func pattern_rotation(r: float):
	if canvas: canvas.pattern.set_pattern_rotation(r)

func pattern_offset(o: Vector2):
	if canvas: canvas.pattern.set_pattern_offset(o)

func pattern_brush_size(s: float):
	if canvas: canvas.pattern.set_brush_size(s)

func pattern_brush_roughness(s: float):
	if canvas: canvas.pattern.set_brush_roughness(s)

func pattern_brush_color(c: Color):
	$UI.patternparameters.set_brush_color(c)
	if canvas: canvas.pattern.set_brush_color(c)





func get_brush_color(): return $UI.brushparameters.color()
func get_brush_size(): return $UI.brushparameters.size()
func get_brush_texture(): return $UI.brushparameters.brush()

func get_pattern_texture(): return $UI.patternparameters.pattern()
func get_pattern_size(): return $UI.patternparameters.pattern_size()
func get_pattern_rotation(): return $UI.patternparameters.pattern_rotation()
func get_pattern_offset(): return $UI.patternparameters.pattern_offset()
func get_pattern_brush_size(): return $UI.patternparameters.brush_size()
func get_pattern_brush_roughness(): return $UI.patternparameters.brush_roughness()
func get_pattern_brush_color(): return $UI.patternparameters.brush_color()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN

extends Node2D

const CANVAS_CLASS := preload("res://canvas.tscn")
var canvas = null

func new_map(dim: Array):
	if canvas:
		canvas.queue_free()
	
	canvas = CANVAS_CLASS.instantiate()
	canvas.width = dim[0]
	canvas.height = dim[1]
	add_child(canvas)

func save(map_name: String):
	if map_name == "":
		$UI.error("map name is empty")
		return
	
	canvas.viewport.get_texture().get_image().save_png("user://" + map_name + ".png")


func brush_color(c: Color):
	if canvas:
		canvas.brush.update_properties(canvas.brush.size, c)

func brush_size(s: int):
	if canvas:
		canvas.brush.update_properties(s, canvas.brush.color)

func brush_texture(t: CompressedTexture2D):
	if canvas:
		canvas.brush.update_brush(t)


func get_brush_color(): return $UI.get_node("Submenus/Brushparameters").color()
func get_brush_size(): return $UI.get_node("Submenus/Brushparameters").size()
func get_brush_texture(): return $UI.get_node("Submenus/Brushparameters").brush()

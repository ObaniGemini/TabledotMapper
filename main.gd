extends Node2D

const CANVAS_CLASS := preload("res://canvas.tscn")
var canvas = null

func new_map(dim: Array):
	if canvas != null:
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

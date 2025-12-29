class_name History extends Node

signal changed(t: Type, obj)

enum Type {
	Canvas,
	Prop
}

class Log:
	var type: Type
	var previous
	var current
	
	func _init(t: Type, p, c):
		type = t
		previous = p
		current = c


class Prop:
	var obj
	var position: Vector2
	var scale: Vector2
	var rotation: float
	var color: Color
	
	func _init(o, p: Vector2, s: Vector2, r: float, c: Color):
		obj = o
		position = p
		scale = s
		rotation = r
		color = c



var current_canvas : Image
var current_props := {}






var HISTORY_SIZE := 20
var log := []
var index := -1

func init_canvas(width: int, height: int, base: Image):
	current_canvas = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	current_canvas.copy_from(base)


func make_log(type: Type, v):
	match type:
		Type.Canvas:
			var current := Image.create_empty(current_canvas.get_width(), current_canvas.get_height(), false, Image.FORMAT_RGBA8)
			current.copy_from(v)
			var previous : Image = current_canvas
			current_canvas = current
			return Log.new(type, previous, current)
		Type.Prop:
			var previous = current_props[v]
			current_props[v] = Prop.new(v, v.position, v.scale, v.rotation, v.modulate)
			return Log.new(type, previous, current_props[v])



func push(type: Type, v):
	if index != (log.size() - 1): #we went backward
		log.resize(index + 1)
	
	log.append(make_log(type, v))
	if log.size() > HISTORY_SIZE:
		log.pop_front()
	
	index = log.size() - 1


func update_to(type: Type, state):
	match type:
		Type.Canvas:
			current_canvas = state
		Type.Prop:
			current_props[state.obj] = state
	changed.emit(type, state)


func undo():
	if index == -1:
		return
	
	update_to(log[index].type, log[index].previous)
	index -= 1


func redo():
	if index == (log.size() - 1):
		return
	
	index += 1
	update_to(log[index].type, log[index].current)


func _input(event: InputEvent):
	if event.is_action_pressed("redo"):
		redo()
	elif event.is_action_pressed("undo"):
		undo()

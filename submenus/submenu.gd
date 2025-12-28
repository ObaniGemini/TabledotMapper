class_name SubMenu extends Control

@export var linked : Control
var cb := ready.connect(fake_ready)

func fake_ready():
	hide()
	
	linked.mouse_entered.connect(hover)
	linked.mouse_exited.connect(try_unhover)
	mouse_exited.connect(try_unhover)

func hover():
	global_position.y = linked.global_position.y
	show()

func try_unhover():
	if Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		return
	
	hide()

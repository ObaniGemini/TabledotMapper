extends Node2D

var width := 1
var height := 1

@onready var canvas := Image.create_empty(width, height, false, Image.Format.FORMAT_RGBA8)
@onready var texture := ImageTexture.create_from_image(canvas)
@onready var viewport := $SubViewport
@onready var brush := $Brush

func _ready():
	print("Generating map of " + str(width) + "x" + str(height))
	$SubViewport.size.x = width
	$SubViewport.size.y = height
	$SubViewport/Sprite2D.texture = texture
	
	canvas.fill(Color(1, 1, 1))
	blit()
	
	$Camera2D.zoom = Vector2(1024.0, 1024.0) / Vector2(width, height).length()
	goal_zoom = $Camera2D.zoom.x
	max_zoom = goal_zoom * 0.5
	
	brush.update_brush(get_parent().get_brush_texture())
	brush.update_properties(get_parent().get_brush_size(), get_parent().get_brush_color())
	
	$History.init_canvas(width, height, canvas)
	$History.changed.connect(history_changed)


func history_changed(type: History.Type, state):
	match type:
		History.Type.Canvas:
			canvas.copy_from(state)
			blit()
		History.Type.Prop:
			return


func blit():
	texture.update(canvas)




var canvas_updated := false
func paint(pos: Vector2):
	var p := Vector2i(mouse_to_viewport(pos))
	var off : int = brush.size / 2
	var base_rect := Rect2i(p.x - off, p.y - off, brush.size, brush.size)
	var canvas_rect := base_rect

	# clamp
	canvas_rect.size += Vector2i( mini( 0, canvas_rect.position.x ), mini( 0, canvas_rect.position.y ) )
	canvas_rect.position = Vector2i( maxi( 0, canvas_rect.position.x ), maxi( 0, canvas_rect.position.y ) )
	canvas_rect.size -= Vector2i( maxi( width, canvas_rect.position.x + canvas_rect.size.x ), maxi( height, canvas_rect.position.y + canvas_rect.size.y ) ) - Vector2i( width, height )
	canvas_rect.size = Vector2i( maxi( 0, canvas_rect.size.x ), maxi( 0, canvas_rect.size.y ) )
	
	var brush_rect := Rect2i( canvas_rect.position.x - base_rect.position.x, canvas_rect.position.y - base_rect.position.y, canvas_rect.size.x, canvas_rect.size.y )
	if canvas_rect.size.x == 0 or canvas_rect.size.y == 0:
		return
	
	
	canvas_updated = true
	canvas.blend_rect(brush.image, brush_rect, canvas_rect.position)
	blit()



func sample_color(pos: Vector2):
	var p := Vector2i(pos)
	if Rect2i(0, 0, width, height).has_point(p):
		var color := canvas.get_pixel(p.x, p.y)
		color.a = get_parent().get_brush_color().a
		get_parent().brush_color(color)


const MOUSE_OFF := Vector2(-1, -1)
var mouse_previous := MOUSE_OFF
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("sample_color"):
		sample_color(mouse_to_viewport(event.position))
	elif event is InputEventMouseMotion:
		$Brush.position = mouse_to_viewport(event.position) - Vector2(width, height) * 0.5
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if mouse_previous.x >= 0:
				$Camera2D.position -= (event.position - mouse_previous) / $Camera2D.zoom
			mouse_previous = event.position
		else:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				paint(event.position)
			
			mouse_previous = MOUSE_OFF
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom(0.95)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom(1.05)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				paint(event.position)
			else:
				if canvas_updated:
					$History.push(History.Type.Canvas, canvas)
				canvas_updated = false


func mouse_to_viewport(pos: Vector2):
	var p := pos - Vector2(640.0, 360.0)
	var offset : Vector2 = $Camera2D.position * $Camera2D.zoom
	
	return Vector2(width, height) * 0.5 + (p + offset) / $Camera2D.zoom


var camera_tween : Tween
var goal_zoom : float
var max_zoom : float
func zoom(factor: float):
	goal_zoom = clampf(goal_zoom * factor, max_zoom, 16.0)
	
	if camera_tween: camera_tween.kill()
	camera_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	camera_tween.tween_property($Camera2D, "zoom", Vector2(goal_zoom, goal_zoom), 0.25)

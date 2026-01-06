class_name Canvas extends Node2D

var width := 1
var height := 1

@onready var canvas := Image.create_empty(width, height, false, Image.Format.FORMAT_RGB8)
@onready var tmp_canvas := Image.create_empty(width, height, false, Image.Format.FORMAT_RGBA8)
@onready var texture := ImageTexture.create_from_image(canvas)
@onready var tmp_texture := ImageTexture.create_from_image(tmp_canvas)
@onready var viewport := $SubViewport
@onready var brush := $Brush
@onready var pattern := $Pattern
@onready var grid := $SubViewport/Grid/Grid

func _ready():
	Input.set_use_accumulated_input(true)
	print("Generating map of " + str(width) + "x" + str(height))
	$SubViewport.size.x = width
	$SubViewport.size.y = height
	grid.size.x = width
	grid.size.y = height
	pattern.set_size(width, height)
	
	$SubViewport/Canvas.texture = texture
	$SubViewport/PatternCanvas.texture = tmp_texture
	
	canvas.fill(Color(1, 1, 1))
	tmp_canvas.fill(Color(0, 0, 0, 0))
	blit()
	
	$Camera2D.zoom = Vector2(1024.0, 1024.0) / Vector2(width, height).length()
	goal_zoom = $Camera2D.zoom.x
	max_zoom = goal_zoom * 0.5
	
	brush.update_brush(get_parent().get_brush_texture())
	brush.update_size(get_parent().get_brush_size())
	brush.modulate = get_parent().get_brush_color()
	
	pattern.set_pattern(get_parent().get_pattern_texture())
	pattern.set_pattern_size(get_parent().get_pattern_size())
	pattern.set_pattern_rotation(get_parent().get_pattern_rotation())
	pattern.set_pattern_offset(get_parent().get_pattern_offset())
	pattern.set_brush_size(get_parent().get_pattern_brush_size())
	pattern.set_brush_roughness(get_parent().get_pattern_brush_roughness())
	pattern.set_brush_color(get_parent().get_pattern_brush_color())
	
	grid.visible = get_parent().get_grid_visible()
	grid.update_size(get_parent().get_grid_size())
	grid.update_width(get_parent().get_grid_width())
	grid.update_roughness(get_parent().get_grid_roughness())
	grid.update_color(get_parent().get_grid_color())
	
	$History.init_canvas(width, height, canvas)
	$History.changed.connect(history_changed)

enum PaintMode {
	Brush,
	Pattern,
	None
}

var paint_mode : PaintMode
func set_paint_mode(paint_mode_pattern : PaintMode):
	paint_mode = paint_mode_pattern
	$Brush.visible = paint_mode == PaintMode.Brush
	$Pattern.visible = paint_mode == PaintMode.Pattern
	

func history_changed(type: History.Type, state):
	match type:
		History.Type.Canvas:
			canvas.copy_from(state)
			blit()
		History.Type.Prop:
			return


func blit():
	texture.update(canvas)

func pattern_blit():
	tmp_texture.update(tmp_canvas)


var canvas_updated := false
func paint(pos: Vector2):
	if !get_parent().can_edit() or paint_mode == PaintMode.None:
		return
	
	var brush_size : int = int(pattern.brush_size) if paint_mode else brush.size
	
	var p := Vector2i(mouse_to_viewport(pos))
	var radius : int = brush_size / 2
	var base_rect := Rect2i(p.x - radius, p.y - radius, brush_size, brush_size)
	var canvas_rect := base_rect

	# clamp
	canvas_rect.size += Vector2i(mini(0, canvas_rect.position.x), mini(0, canvas_rect.position.y)) # reduce size when position is negative
	canvas_rect.position = Vector2i(maxi(0, canvas_rect.position.x), maxi(0, canvas_rect.position.y)) # clamp position
	canvas_rect.size -= Vector2i(maxi(width, canvas_rect.position.x + canvas_rect.size.x), maxi(height, canvas_rect.position.y + canvas_rect.size.y)) - Vector2i(width, height) # reduce size when pos + size exceeds total size
	canvas_rect.size = Vector2i(maxi(0, canvas_rect.size.x), maxi(0, canvas_rect.size.y)) #clamp size
	
	var brush_rect := Rect2i(canvas_rect.position.x - base_rect.position.x, canvas_rect.position.y - base_rect.position.y, canvas_rect.size.x, canvas_rect.size.y)
	if canvas_rect.size.x == 0 or canvas_rect.size.y == 0:
		return
	
	
	if paint_mode == PaintMode.Pattern:
		#if !canvas_updated:
			###var im : Image = pattern.get_full_pattern()
			###for x in width:
				###for y in height:
					###var c := im.get_pixel(x, y)
					###c.a = 0.0
					###pattern_canvas.set_pixel(x, y, c)
			#TabledotImage.copy_no_alpha(tmp_canvas, pattern.get_full_pattern())
		
		#var im2 : Image = pattern.get_pattern()
		#for x in canvas_rect.size.x:
			#for y in canvas_rect.size.y:
				#var canvas_pos := canvas_rect.position + Vector2i(x, y)
				#var c := pattern_canvas.get_pixelv(canvas_pos)
				#c.a = minf(pattern.color.a, c.a + im2.get_pixelv(canvas_pos).a)
				#pattern_canvas.set_pixelv(canvas_pos, c)
		
		TabledotImage.blend_circle(tmp_canvas, pattern.get_full_pattern(), canvas_rect, p, radius, pattern.roughness, pattern.color.a)
	elif paint_mode == PaintMode.Brush:
		TabledotImage.blend_luminance_rect_to_rgba8(tmp_canvas, brush.image, brush_rect, canvas_rect.position, brush.modulate)
		#canvas.blend_rect(brush.image, brush_rect, canvas_rect.position)
	pattern_blit()
	
	canvas_updated = true



func sample_color(pos: Vector2):
	var p := Vector2i(pos)
	if Rect2i(0, 0, width, height).has_point(p):
		var color := canvas.get_pixel(p.x, p.y)
		color.a = get_parent().get_brush_color().a
		get_parent().brush_color(color)


func update_mouse_pos(p: Vector2):
	var pos = mouse_to_viewport(p)
	$Brush.position = pos - Vector2(width, height) * 0.5
	pattern.set_brush_pos(pos)


const MOUSE_OFF := Vector2(-1, -1)
var mouse_previous := MOUSE_OFF
func _unhandled_input(event: InputEvent):
	if !get_parent().can_edit():
		return
	
	if event.is_action_pressed("sample_color"):
		sample_color(mouse_to_viewport(event.position))
	elif event is InputEventMouseMotion:
		update_mouse_pos(event.position)
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if mouse_previous.x >= 0:
				$Camera2D.position -= (event.position - mouse_previous) / $Camera2D.zoom
				$Camera2D.position.x = clampf($Camera2D.position.x, -width * 0.5, width * 0.5)
				$Camera2D.position.y = clampf($Camera2D.position.y, -height * 0.5, height * 0.5)
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
					TabledotImage.blend_rgba8_to_rgb8_clear(canvas, tmp_canvas)
					pattern_blit()
					blit()
					#canvas.blend_rect(pattern_canvas, Rect2i(0, 0, width, height), Vector2())
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

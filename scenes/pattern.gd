extends SubViewport

var brush_size := 512.0

func set_pattern(c: CompressedTexture2D):
	$Sprite2D.material.set_shader_parameter("tex", c)

func set_pattern_size(s: float):
	$Sprite2D.material.set_shader_parameter("tex_size", 51.0 - s)

func set_pattern_rotation(r: float):
	$Sprite2D.material.set_shader_parameter("tex_rotation", r)

func set_pattern_offset(offset: Vector2):
	$Sprite2D.material.set_shader_parameter("tex_offset", offset)


func set_brush_pos(pos: Vector2):
	$Sprite2D.material.set_shader_parameter("brush_pos", pos / Vector2(size))

func set_brush_size(s: float):
	brush_size = s
	$Sprite2D.material.set_shader_parameter("brush_size", brush_size)

func set_brush_roughness(r: float):
	$Sprite2D.material.set_shader_parameter("brush_roughness", r)

func set_brush_color(c: Color):
	$Sprite2D.material.set_shader_parameter("brush_color", c)

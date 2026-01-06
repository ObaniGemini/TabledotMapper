extends ColorRect

func update_size(s: int):
	material.set_shader_parameter("size", 32.0 * 2.0 * s)

func update_width(w: int):
	material.set_shader_parameter("width", 0.5 / pow(2.0, w))

func update_roughness(s: float):
	material.set_shader_parameter("roughness", s)

func update_negative(s: float):
	material.set_shader_parameter("negative", s)

func update_color(c: Color):
	modulate = c

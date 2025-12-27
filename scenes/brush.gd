extends Sprite2D

var base_image := load("res://brushes/sand.png")
var image : Image = Image.new()

var size := 1
var color := Color(1, 1, 1)

func _ready():
	update_properties(512, Color(0, 0, 0, 0.25))

func blit():
	texture.set_image(image)

func update_properties(s: int, c: Color):
	size = s
	color = c
	
	image.copy_from(base_image.get_image())
	image.resize(size, size)
	for x in image.get_width():
		for y in image.get_height():
			image.set_pixel(x, y, image.get_pixel(x, y) * color)
	blit()

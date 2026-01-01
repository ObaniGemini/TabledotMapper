extends Sprite2D

var base_image : Image
var image : Image = Image.new()
var size := 1

func blit():
	texture.set_image(image)


func update_brush(im: Image):
	base_image = im
	update_size(size)

func update_size(s: int):
	size = s
	
	image.copy_from(base_image)
	image.resize(size, size)
	blit()

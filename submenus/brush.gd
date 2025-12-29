extends VBoxContainer

const BRUSHES_PATHES := ["res://Data/brushes"]

signal update_color(c: Color)
signal update_size(s: int)
signal update_brush(b: CompressedTexture2D)

var brushes := []

func _ready():
	for path in BRUSHES_PATHES:
		var dir := DirAccess.open(path)
		dir.include_hidden = false
		dir.include_navigational = false
		
		for file in dir.get_files():
			if file.get_extension().ends_with("import"):
				continue
			
			# will have to fix in future
			if file.get_extension() == "png":
				print(path + "/" + file)
				brushes.append(path + "/" + file)
				var im := Image.new()
				im.copy_from(load(brushes.back()).get_image())
				im.resize(64, 64)
				$Brush.add_icon_item(ImageTexture.create_from_image(im), "")
	
	$Color.color_changed.connect(_update_color)
	$Size/Slider.value_changed.connect(_update_size)
	$Brush.item_selected.connect(_update_brush)

func color() -> Color:
	return $Color.color

func size() -> int:
	return int($Size/Slider.value)

func brush() -> CompressedTexture2D:
	return load(brushes[$Brush.get_selected_id()])

func _update_color(c: Color):
	update_color.emit(c)

func _update_size(v: float):
	update_size.emit(int(v))

func _update_brush(id: int):
	update_brush.emit(load(brushes[id]))

func set_color(c: Color):
	$Color.color = c

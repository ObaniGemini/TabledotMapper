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
	
	$Color.color = config.GET("brush_color")
	$Size.update_value(config.GET("brush_size"))
	$Brush.selected = brushes.find(config.GET("brush_texture"))
	
	$Color.color_changed.connect(_update_color)
	$Size.value_changed.connect(_update_size)
	$Brush.item_selected.connect(_update_brush)

func color() -> Color:
	return $Color.color

func size() -> int:
	return int($Size.get_value())

func _load_brush(id: int) -> Image:
	return TabledotImage.make_luminance_image(load(brushes[id]).get_image())

func brush() -> Image:
	return _load_brush($Brush.get_selected_id())

func _update_color(c: Color):
	config.SET("brush_color", c)
	update_color.emit(c)

func _update_size(v: float):
	config.SET("brush_size", v)
	update_size.emit(int(v))

func _update_brush(id: int):
	config.SET("brush_texture", brushes[id])
	update_brush.emit(_load_brush(id))

func set_color(c: Color):
	config.SET("brush_color", c)
	$Color.color = c

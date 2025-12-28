extends SubMenu

const BRUSHES_PATHES := ["res://brushes"]

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
				brushes.append(load(path + "/" + file))
				var im := Image.new()
				im.copy_from(brushes.back().get_image())
				im.resize(64, 64)
				$HBoxContainer/Brush.add_icon_item(ImageTexture.create_from_image(im), "")
	
	$HBoxContainer/Color.color_changed.connect(_update_color)
	$HBoxContainer/Size.value_changed.connect(_update_size)
	$HBoxContainer/Brush.item_selected.connect(_update_brush)

func color() -> Color:
	return $HBoxContainer/Color.color

func size() -> int:
	return int($HBoxContainer/Size.value)

func brush() -> CompressedTexture2D:
	return brushes[$HBoxContainer/Brush.get_selected_id()]

func _update_color(c: Color):
	update_color.emit(c)

func _update_size(v: float):
	update_size.emit(int(v))

func _update_brush(id: int):
	update_brush.emit(brushes[id])

func set_color(c: Color):
	$HBoxContainer/Color.color = c

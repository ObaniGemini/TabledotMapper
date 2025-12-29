extends VBoxContainer

const BRUSHES_PATHES := ["res://Data/pattern"]

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
			if file.get_extension() == "png" or file.get_extension() == "jpg":
				print(path + "/" + file)
				brushes.append(path + "/" + file)
				var im := Image.new()
				im.copy_from(load(brushes.back()).get_image())
				im.resize(64, 64)
				$Pattern.add_icon_item(ImageTexture.create_from_image(im), "")
	
	$Pattern.item_selected.connect(_update_pattern)
	$PatternSize/Slider.value_changed.connect(_update_pattern_size)
	$Rotation/Slider.value_changed.connect(_update_pattern_rotation)
	$Offset/X.value_changed.connect(_update_pattern_offset.bind(true))
	$Offset/Y.value_changed.connect(_update_pattern_offset.bind(false))
	$BrushSize/Slider.value_changed.connect(_update_brush_size)
	$BrushRoughness/Slider.value_changed.connect(_update_brush_roughness)
	$Color.color_changed.connect(_update_brush_color)

signal update_pattern(b: CompressedTexture2D)
signal update_pattern_size(s: float)
signal update_pattern_rotation(r: float)
signal update_pattern_offset(v: Vector2)
signal update_brush_size(s: float)
signal update_brush_roughness(r: float)
signal update_brush_color(c: Color)

func pattern() -> CompressedTexture2D:
	return load(brushes[$Pattern.get_selected_id()])

func pattern_size() -> float:
	return $PatternSize/Slider.value

func pattern_rotation() -> float:
	return $Rotation/Slider.value

func pattern_offset() -> Vector2:
	return Vector2($Offset/X.value, $Offset/Y.value)

func brush_size() -> float:
	return $BrushSize/Slider.value

func brush_roughness() -> float:
	return $BrushRoughness/Slider.value

func brush_color() -> Color:
	return $Color.color



func _update_pattern(id: int):
	update_pattern.emit(load(brushes[id]))

func _update_pattern_size(s: float):
	update_pattern_size.emit(s)

func _update_pattern_rotation(r: float):
	update_pattern_rotation.emit(r)

func _update_pattern_offset(v: float, x : bool):
	update_pattern_offset.emit(Vector2(v, $Offset/Y.value) if x else Vector2($Offset/X.value, v))

func _update_brush_size(s: float):
	update_brush_size.emit(s)

func _update_brush_roughness(r: float):
	update_brush_roughness.emit(r)

func _update_brush_color(c: Color):
	update_brush_color.emit(c)




func set_brush_color(c: Color):
	$Color.color = c

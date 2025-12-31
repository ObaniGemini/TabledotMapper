extends VBoxContainer

const BRUSHES_PATHES := ["res://Data/pattern"]

var brushes := []

signal show_pattern(b: bool)

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
	
	$Pattern.selected = brushes.find(config.GET("pattern_texture"))
	$PatternSize.update_value(config.GET("pattern_size"))
	$Rotation.update_value(config.GET("pattern_rotation"))
	$Offset/HBoxContainer/X.update_value(config.GET("pattern_offset").x)
	$Offset/HBoxContainer/Y.update_value(config.GET("pattern_offset").y)
	$BrushSize.update_value(config.GET("pattern_brush_size"))
	$Roughness.update_value(config.GET("pattern_brush_roughness"))
	$Color.color = config.GET("pattern_brush_color")
	
	$Pattern.item_selected.connect(_update_pattern)
	$PatternSize.value_changed.connect(_update_pattern_size)
	$Rotation.value_changed.connect(_update_pattern_rotation)
	$Offset/HBoxContainer/X.value_changed.connect(_update_pattern_offset.bind(true))
	$Offset/HBoxContainer/Y.value_changed.connect(_update_pattern_offset.bind(false))
	$BrushSize.value_changed.connect(_update_brush_size)
	$Roughness.value_changed.connect(_update_brush_roughness)
	$Color.color_changed.connect(_update_brush_color)
	
	mouse_entered.connect(show_pattern.emit.bind(true))
	mouse_exited.connect(show_pattern.emit.bind(false))

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
	return $PatternSize.get_value()

func pattern_rotation() -> float:
	return $Rotation.get_value()

func pattern_offset() -> Vector2:
	return Vector2($Offset/HBoxContainer/X.get_value(), $Offset/HBoxContainer/Y.get_value())

func brush_size() -> float:
	return $BrushSize.get_value()

func brush_roughness() -> float:
	return $Roughness.get_value()

func brush_color() -> Color:
	return $Color.color



func _update_pattern(id: int):
	config.SET("pattern_texture", brushes[id])
	update_pattern.emit(load(brushes[id]))

func _update_pattern_size(s: float):
	config.SET("pattern_size", s)
	update_pattern_size.emit(s)

func _update_pattern_rotation(r: float):
	config.SET("pattern_rotation", r)
	update_pattern_rotation.emit(r)

func _update_pattern_offset(v: float, x : bool):
	var o := Vector2(v, $Offset/HBoxContainer/Y.get_value()) if x else Vector2($Offset/HBoxContainer/X.get_value(), v)
	config.SET("pattern_offset", o)
	update_pattern_offset.emit(o)

func _update_brush_size(s: float):
	config.SET("pattern_brush_size", s)
	update_brush_size.emit(s)

func _update_brush_roughness(r: float):
	config.SET("pattern_brush_roughness", r)
	update_brush_roughness.emit(r)

func _update_brush_color(c: Color):
	config.SET("pattern_brush_color", c)
	update_brush_color.emit(c)




func set_brush_color(c: Color):
	config.SET("pattern_brush_color", c)
	$Color.color = c

extends PanelContainer

signal selected(p: String, t: ImageTexture)

const TEXTURE_CATEGORY := preload("res://scenes/ui/texture_category.tscn")

@onready var filter := $HBoxContainer/VBoxContainer/LineEdit
@onready var texture_categories := $HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer

var base_pathes := []
var extensions := []
var selected_path := ""




func _ready():
	filter.text_changed.connect(update_filters)
	init(base_pathes, extensions, selected_path)

func add_category(dir_path: String, category_name: String, ext : Array, selected_p: String):
	var dir := DirAccess.open(dir_path)
	dir.include_hidden = false
	dir.include_navigational = false
	
	var file_pathes := []
	for file in dir.get_files():
		if file.get_extension().ends_with("import"):
			continue
		
		if file.get_extension() in ext:
			file_pathes.append(dir_path + "/" + file)
	
	if file_pathes.is_empty():
		return
	
	var category := TEXTURE_CATEGORY.instantiate()
	category.name = category_name
	category.selected.connect(selected.emit)
	texture_categories.add_child(category)
	category.add_buttons(file_pathes, selected_p)


func init(pathes: Array, ext : Array, selected_p: String):
	for base_path in pathes:
		var dir := DirAccess.open(base_path)
		dir.include_hidden = false
		dir.include_navigational = false
		
		for subdir in dir.get_directories():
			add_category(base_path + "/" + subdir, subdir, ext, selected_p)
		
		add_category(base_path, "Uncategorized", ext, selected_p)

func update_filters(filter_text: String):
	for category in texture_categories.get_children():
		if category.name.contains(filter_text) or filter_text == "":
			category.show_all()
		else:
			category.filter(filter_text)

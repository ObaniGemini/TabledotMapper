extends Node

const SAVE_DIRECTORY := "user://maps"
const EXPORT_DIRECTORY := "user://exports"

class SaveData:
	var canvas: Image
	var props : Dictionary
	
	func _init(f: FileAccess):
		canvas = Image.new()
		canvas.load_png_from_buffer(f.get_var())
		props = f.get_var()


func get_saved_maps() -> Array:
	if !DirAccess.dir_exists_absolute(SAVE_DIRECTORY):
		DirAccess.make_dir_absolute(SAVE_DIRECTORY)
	
	var dir := DirAccess.open("user://saves")
	dir.include_hidden = false
	dir.include_navigational = false
	
	return Array(dir.get_files()).filter(func(e : String): e.ends_with(".map"))


func load_map(map_name: String) -> SaveData:
	var f := FileAccess.open(SAVE_DIRECTORY + "/" + map_name, FileAccess.READ)
	if !f:
		print(FileAccess.get_open_error())
		return
	
	return SaveData.new(f)

func save_map(map_name: String, canvas: Image, props : Dictionary):
	var f := FileAccess.open(SAVE_DIRECTORY + "/" + map_name, FileAccess.WRITE)
	if !f:
		print(FileAccess.get_open_error())
		return
	
	
	f.store_var(canvas.save_png_to_buffer())
	f.store_var(props)

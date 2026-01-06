extends Node

const DEFAULT_CONFIG := {
	"history": 20,
	
	"brush_texture": "",
	"brush_size": 128,
	"brush_color": Color(0, 0, 0),
	
	"pattern_texture": "",
	"pattern_size": 10.0,
	"pattern_rotation": 0.0,
	"pattern_offset": Vector2(),
	"pattern_brush_size": 128.0,
	"pattern_brush_roughness": 0.5,
	"pattern_brush_color": Color(1, 1, 1),
	
	"grid_visible": false,
	"grid_size": 4,
	"grid_width": 2,
	"grid_roughness": 0.0,
	"grid_negative": 1.0,
	"grid_color": Color(0, 0, 0),
}

const CONFIG_FILE := "user://config.save"

var data := {}


func _ready():
	load_config()


func set_dictionary(c, default: Dictionary):
	if c == null:
		c = default.duplicate(true)
	else:
		for option in default:
			if !c.has(option) or typeof(default[option]) != typeof(c[option]):
				c[option] = default[option]
	return c


func GET(k: String):
	return data[k]

func SET(k: String, v):
	data[k] = v



func load_config():
	var f := FileAccess.open(CONFIG_FILE, FileAccess.READ)
	var cfg = null
	if f != null:
		cfg = f.get_var()
	data = set_dictionary(cfg, DEFAULT_CONFIG)


func save_config():
	var f := FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	if f != null:
		f.store_var(data)
	else:
		print(FileAccess.get_open_error())


func _exit_tree() -> void:
	save_config()

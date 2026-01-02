extends VBoxContainer

const texture_button := preload("res://scenes/ui/texture_button.tscn")

signal selected(p: String, icon: ImageTexture)

@onready var buttons := $HFlowContainer

func _ready():
	$Label.text = name

func add_button(path: String):
	var button := texture_button.instantiate()
	var im := Image.new()
	im.copy_from(load(path).get_image())
	im.resize(64, 64)
	
	button.path = path
	button.texture = ImageTexture.create_from_image(im)
	buttons.add_child(button)
	return button

func show_all():
	for button in buttons.get_children():
		button.show()
	show()

func filter(filter_text: String):
	var empty := true
	for button in buttons.get_children():
		button.visible = button.name.contains(filter_text)
		empty = empty and button.visible
	visible = !empty

func add_buttons(buttons_pathes : Array, path_selected: String):
	for path in buttons_pathes:
		var button = add_button(path)
		if path == path_selected:
			button.press()

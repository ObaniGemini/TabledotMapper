extends VBoxContainer

var texture : ImageTexture
var path : String

func _ready():
	name = path.get_file()
	$Label.text = path.get_file()
	tooltip_text = $Label.text
	
	$TextureButton.texture_normal = texture
	$TextureButton.texture_pressed = texture
	$TextureButton.texture_hover = texture
	$TextureButton.texture_disabled = texture
	$TextureButton.texture_focused = texture
	
	gui_input.connect(check_press)

func check_press(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		press()

func press():
	get_node("../../").selected.emit(path, texture)

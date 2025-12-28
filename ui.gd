extends CanvasLayer

const POPUP_BOTTOM := preload("res://popups/popup_bottom.tscn")
const POPUP_NEWMAP := preload("res://popups/newmap.tscn")
const POPUP_SAVE := preload("res://popups/save.tscn")

func remove_popup(p):
	if is_instance_valid(p):
		p.queue_free()
	
	if ($Popup/HBoxContainer/VBoxContainer.get_child_count() - 1) <= 0:
		$Popup.hide()

func apply_popup(callback, p):
	if is_instance_valid(p):
		var v = p.get_values()
		remove_popup(p)
		callback.call(v)

func add_popup(callback, popup):
	var p = popup.instantiate()
	var bottom = POPUP_BOTTOM.instantiate()
	p.add_child(bottom)
	
	bottom.cancel.connect(remove_popup.bind(p))
	bottom.apply.connect(apply_popup.bind(callback, p))
	
	$Popup/HBoxContainer/VBoxContainer.add_child(p)
	$Popup.show()


var error_tween : Tween
func error(message: String):
	$Label.text = message
	
	if error_tween: error_tween.kill()
	
	error_tween = create_tween()
	error_tween.tween_property($Error, "modulate:a", 0.0, 10.0)
	
	print(message)


func _ready():
	$Popup.hide()
	
	$Panel/VBoxContainer/NewImage.pressed.connect(add_popup.bind(new_map, POPUP_NEWMAP))
	$Panel/VBoxContainer/Save.pressed.connect(add_popup.bind(get_parent().save, POPUP_SAVE))
	
	$Panel/VBoxContainer/Save.disabled = true
	
	$Submenus/Brushparameters.update_color.connect(get_parent().brush_color)
	$Submenus/Brushparameters.update_size.connect(get_parent().brush_size)
	$Submenus/Brushparameters.update_brush.connect(get_parent().brush_texture)


func new_map(dim: Array):
	get_parent().new_map(dim)
	$Panel/VBoxContainer/Save.disabled = false

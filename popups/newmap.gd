extends TabledotPopup

var values := []


func _ready():
	var p := 1
	for i in 4:
		values.append(1024 * p)
		$Button.add_item(str(values[i]) + "x" + str(values[i]))
		p *= 2
	
	_on_check_box_toggled($Button.button_pressed)
	super()



func _on_check_box_toggled(toggled_on: bool):
	$Button.visible = !toggled_on
	$HBoxContainer.visible = toggled_on

func get_values():
	if $Custom.button_pressed:
		return [int($HBoxContainer/Width.value), int($HBoxContainer/Height.value)]
	else:
		var v = values[$Button.get_selected_id()]
		return [v, v]
		

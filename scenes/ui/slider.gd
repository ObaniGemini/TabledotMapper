@tool extends HBoxContainer

signal value_changed(v: float)

@export var no_text := false
@export var custom_name := ""

@export var min_value := 0.0
@export var max_value := 100.0
@export var step := 0.0
@export var rounded := false
@export var exp_edit := false
@export var label_min_x := 0.0

@onready var slider := $VBoxContainer/HSlider
@onready var input := $VBoxContainer/SpinBox

func _ready():
	if no_text:
		$Label.queue_free()
	else:
		$Label.text = "  " + (name if custom_name == "" else custom_name)
	
	for node in [slider, input]:
		node.min_value = min_value
		node.max_value = max_value
		node.step = step
		node.rounded = rounded
	slider.exp_edit = exp_edit
	
	slider.value_changed.connect(update_value)
	input.value_changed.connect(update_value)
	$Label.custom_minimum_size.x = label_min_x

func update_value(v: float):
	slider.value = v
	input.value = v
	value_changed.emit(v)

func get_value() -> float:
	return slider.value

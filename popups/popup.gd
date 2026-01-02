class_name TabledotPopup extends VBoxContainer

const BOTTOM := preload("res://popups/popup_bottom.tscn")
@onready var bottom := BOTTOM.instantiate()

func _ready():
	add_child(bottom)

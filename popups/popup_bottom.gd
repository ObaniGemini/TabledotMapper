extends HBoxContainer

signal cancel
signal apply

func _ready():
	$Cancel.pressed.connect(cancel.emit)
	$Apply.pressed.connect(apply.emit)

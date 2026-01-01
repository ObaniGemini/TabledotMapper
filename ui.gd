extends CanvasLayer

const POPUP_BOTTOM := preload("res://popups/popup_bottom.tscn")
const POPUP_NEWMAP := preload("res://popups/newmap.tscn")
const POPUP_SAVE := preload("res://popups/save.tscn")
const POPUP_EXPORT := preload("res://popups/export.tscn")

@onready var submenus := $Submenus/ScrollContainer

func is_hovered() -> bool:
	var mouse_pos : Vector2 = $Panel.get_global_mouse_position()
	return $Panel.get_global_rect().has_point(mouse_pos) or $Submenus.get_global_rect().has_point(mouse_pos) or $Popup.visible

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

@onready var side_menu_start_pos : float = $SideMenu.position.x
var submenu_open_tween : Tween
var opening := false
func open_side():
	$SideMenu/Timer.stop()
	
	if opening:
		return
	opening = true
	
	if submenu_open_tween:
		submenu_open_tween.kill()
	
	submenu_open_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	submenu_open_tween.tween_property($SideMenu, "position:x", 1280.0, 0.5)
	submenu_open_tween.tween_property($Submenus, "position:x", 1280.0 - $Submenus.size.x * $Submenus.scale.x, 0.5)


func close_side():
	if !opening:
		return
	opening = false
	
	if submenu_open_tween:
		submenu_open_tween.kill()
	
	submenu_open_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	submenu_open_tween.tween_property($SideMenu, "position:x", side_menu_start_pos, 1.0)
	submenu_open_tween.tween_property($Submenus, "position:x", 1280.0, 1.0)


@onready var brushparameters := $Submenus/ScrollContainer/Brushparameters
@onready var patternparameters := $Submenus/ScrollContainer/Patternparameters
func _ready():
	$Popup.hide()
	
	$Panel/VBoxContainer/NewImage.pressed.connect(add_popup.bind(new_map, POPUP_NEWMAP))
	$Panel/VBoxContainer/Save.pressed.connect(add_popup.bind(get_parent().save, POPUP_SAVE))
	$Panel/VBoxContainer/Export.pressed.connect(add_popup.bind(get_parent().save, POPUP_EXPORT))
	$Panel/VBoxContainer/Brush.pressed.connect(select_brush_paint)
	$Panel/VBoxContainer/Pattern.pressed.connect(select_pattern_paint)
	
	
	$Panel/VBoxContainer/Save.disabled = true
	$Panel/VBoxContainer/Export.disabled = true
	
	$SideMenu.mouse_entered.connect(open_side)
	$Submenus.mouse_entered.connect(open_side)
	$Submenus.mouse_exited.connect($SideMenu/Timer.start)
	$SideMenu/Timer.timeout.connect(close_side)
	
	brushparameters.update_color.connect(get_parent().brush_color)
	brushparameters.update_size.connect(get_parent().brush_size)
	brushparameters.update_brush.connect(get_parent().brush_texture)
	
	patternparameters.update_pattern.connect(get_parent().pattern_texture)
	patternparameters.update_pattern_size.connect(get_parent().pattern_size)
	patternparameters.update_pattern_rotation.connect(get_parent().pattern_rotation)
	patternparameters.update_pattern_offset.connect(get_parent().pattern_offset)
	patternparameters.update_brush_size.connect(get_parent().pattern_brush_size)
	patternparameters.update_brush_roughness.connect(get_parent().pattern_brush_roughness)
	patternparameters.update_brush_color.connect(get_parent().pattern_brush_color)
	
	select_brush_paint()

func select_brush_paint():
	show_submenu($Submenus/ScrollContainer/Brushparameters)
	get_parent().set_paint_mode(false)

func select_pattern_paint():
	show_submenu($Submenus/ScrollContainer/Patternparameters)
	get_parent().set_paint_mode(true)


func show_submenu(submenu):
	for menu in submenus.get_children():
		menu.hide()
	
	submenu.show()

func new_map(dim: Array):
	get_parent().new_map(dim)
	$Panel/VBoxContainer/Save.disabled = false
	$Panel/VBoxContainer/Export.disabled = false

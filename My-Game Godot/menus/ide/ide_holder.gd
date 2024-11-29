class_name IDEHolder 
extends Control


var last_drag_position: Vector2
var is_dragging := false
var drag_offset: Vector2


func _enter_tree() -> void:
	IDE.ide_holder = self


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			is_dragging = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_dragging = true
			last_drag_position = get_global_mouse_position()


func _process(_delta: float) -> void:
	if is_dragging:
		print(last_drag_position - get_global_mouse_position() )
		for child in get_children():
			child.position -= last_drag_position - get_global_mouse_position() 
		last_drag_position = get_global_mouse_position()

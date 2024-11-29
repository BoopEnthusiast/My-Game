class_name NodeBase 
extends Control


const MAX_INPUTS: int = 1
const MAX_OUTPUTS: int = 1

var input_connections: Array[Connector]
var output_connections: Array[Connector]

var is_dragging := false
var drag_offset: Vector2


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			is_dragging = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_dragging = true
			drag_offset = event.global_position - global_position


func _process(_delta: float) -> void:
	if is_dragging:
		position = get_global_mouse_position() - drag_offset

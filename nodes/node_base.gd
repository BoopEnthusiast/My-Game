class_name NodeBase 
extends Control

const INPUT = preload("res://nodes/connector/input.tscn")
const OUTPUT = preload("res://nodes/connector/output.tscn")

@export var title: String = "TITLE YOUR NODE"
@export var max_inputs: int = 0
@export var max_outputs: int = 0
@export var has_input_name: bool = true
@export var has_output_name: bool = true

@onready var inputs_container: VBoxContainer = $Background/Inputs
@onready var outputs_container: VBoxContainer = $Background/Outputs

@onready var inputs: Array = []
@onready var outputs: Array = []

@onready var main: Control = $Background/Central/Main
@onready var documentation: Control = $Background/Central/Documentation

var is_dragging := false
var drag_offset: Vector2
var is_resizing := false


func _ready() -> void:
	for i in range(max_inputs):
		var new_input = INPUT.instantiate() as NodeInput
		inputs_container.add_child(new_input)
		if not has_input_name:
			new_input.name_field.visible = false
		inputs.append(new_input)
	for i in range(max_outputs):
		var new_output = OUTPUT.instantiate() as NodeOutput
		outputs_container.add_child(new_output)
		if not has_output_name:
			new_output.name_field.visible = false
		outputs.append(new_output)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			is_dragging = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position


func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset
	elif is_resizing:
		size.x = max(get_global_mouse_position().x - global_position.x, 150.0)
		size.y = max(get_global_mouse_position().y - global_position.y, 70.0)


func _on_resize_button_down() -> void:
	is_resizing = true


func _on_resize_button_up() -> void:
	is_resizing = false


func _on_documentation_pressed() -> void:
	main.visible = not main.visible
	documentation.visible = not main.visible

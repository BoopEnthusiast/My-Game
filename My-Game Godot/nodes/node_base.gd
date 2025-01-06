class_name NodeBase 
extends Control

const INPUT = preload("res://nodes/connector/input.tscn")
const OUTPUT = preload("res://nodes/connector/output.tscn")

@export var title: String = "TITLE YOUR NODE"
@export var max_inputs: int = 0
@export var max_outputs: int = 0

@onready var inputs_container: VBoxContainer = $Background/Inputs
@onready var outputs_container: VBoxContainer = $Background/Outputs

@onready var inputs: Array = []
@onready var outputs: Array = []

var is_dragging := false
var drag_offset: Vector2


func _ready() -> void:
	for i in range(max_inputs):
		var new_input = INPUT.instantiate()
		inputs_container.add_child(new_input)
		inputs.append(new_input)
	for i in range(max_outputs):
		var new_output = OUTPUT.instantiate()
		outputs_container.add_child(new_output)
		outputs.append(new_output)


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

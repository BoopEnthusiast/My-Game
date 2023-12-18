extends Control
class_name CodeEditor

signal started_line_connection(output_id: int, code_editor: CodeEditor)
signal connection_found(input_id: int, code_editor: CodeEditor)

var output_scene = preload("res://output.tscn")
var input_scene = preload("res://input.tscn")

@onready var inputs: Array[CodeInput] = [$LeftResize/Inputs/Input]
@onready var input_box: VBoxContainer = $LeftResize/Inputs
@onready var outputs: Array[CodeOutput] = [$LeftResize/RightResize/Outputs/Output]
@onready var output_box: VBoxContainer = $LeftResize/RightResize/Outputs
@onready var resize_timer: Timer = $ResizeTimer

var can_drag = false

func _on_connect_pressed(which_output: CodeOutput) -> void:
	emit_signal("started_line_connection", outputs.find(which_output), self)


func _on_input_mouse_entered(which_input: CodeInput) -> void:
	emit_signal("connection_found", inputs.find(which_input), self)


func _drag_area_mouse_entered() -> void:
	if not IDE.is_moving_editor and resize_timer.is_stopped():
		IDE.moving_editor = self


func _drag_area_mouse_exited() -> void:
	IDE.moving_editor = null


func _on_resize_dragged(_offset) -> void:
	resize_timer.start()


func _on_add_output_pressed() -> void:
	var new_output: CodeOutput = output_scene.instantiate()
	new_output.pressed.connect(_on_connect_pressed)
	
	outputs.append(new_output)
	output_box.add_child(new_output)
	output_box.move_child(new_output, outputs.size())


func _on_add_input_pressed() -> void:
	var new_input: CodeInput = input_scene.instantiate()
	new_input.hovered.connect(_on_input_mouse_entered)
	
	inputs.append(new_input)
	input_box.add_child(new_input)
	input_box.move_child(new_input, inputs.size())

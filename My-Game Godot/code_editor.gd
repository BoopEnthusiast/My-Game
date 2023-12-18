extends Control
class_name CodeEditor

var editor_class_name: String

signal started_line_connection(output_id: int, code_editor: CodeEditor)
signal connection_found(input_id: int, code_editor: CodeEditor)

var output_scene = preload("res://output.tscn")
var input_scene = preload("res://input.tscn")

@onready var inputs: Array[CodeInput] = [$LeftResize/Inputs/Input]
@onready var input_box: VBoxContainer = $LeftResize/Inputs
@onready var outputs: Array[CodeOutput] = [$LeftResize/RightResize/Outputs/Output]
@onready var output_box: VBoxContainer = $LeftResize/RightResize/Outputs

@onready var resize_timer: Timer = $ResizeTimer
@onready var class_name_box: LineEdit = $LeftResize/RightResize/CodeResize/PanelContainer/ClassName
@onready var code_editor: CodeEdit =  $LeftResize/RightResize/CodeResize/CodeEditor

static var can_zoom = true
static var resize_timer_is_stopped := true

func _on_connect_pressed(which_output: CodeOutput) -> void:
	emit_signal("started_line_connection", outputs.find(which_output), self)


func _on_input_mouse_entered(which_input: CodeInput) -> void:
	emit_signal("connection_found", inputs.find(which_input), self)


func _drag_area_mouse_entered() -> void:
	if not IDE.is_moving_editor and resize_timer_is_stopped:
		IDE.moving_editor = self


func _drag_area_mouse_exited() -> void:
	IDE.moving_editor = null


func _on_resize_dragged(_offset) -> void:
	resize_timer.start()
	resize_timer_is_stopped = false


func _on_resize_timer_timeout() -> void:
	resize_timer_is_stopped = true


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


func _on_code_editor_mouse_entered() -> void:
	can_zoom = false


func _on_code_editor_mouse_exited() -> void:
	can_zoom = true


func update_all_output_lines() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for output in outputs:
		output.update_all_connected_line_positions()


func _on_delete_editor_pressed() -> void:
	for output in outputs:
		output._on_delete_pressed()
	for input in inputs:
		input._on_delete_pressed()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	queue_free()


func _on_class_name_changed(text: String) -> void:
	var caret_column = class_name_box.get_caret_column()
	class_name_box.text = class_name_box.text.strip_edges().replace(" ", "")
	class_name_box.set_caret_column(caret_column)
	editor_class_name = class_name_box.text


func _on_compile_pressed():
	var code: Array[String] = code_editor.text.split(" ", false)
	

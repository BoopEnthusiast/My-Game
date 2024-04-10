extends Control
class_name CodeEditor

var editor_class_name: String

signal started_line_connection(output_id: int, code_editor: CodeEditor)
signal connection_found(input_id: int, code_editor: CodeEditor)

const INPUT_SCENE = preload("res://scenes/input.tscn")
const OUTPUT_SCENE = preload("res://scenes/output.tscn")

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
	# If the IDE isn't already moving an editor, and the editor isn't being resized, set that the IDE should move this editor
	if not IDE.is_moving_editor and resize_timer_is_stopped:
		IDE.moving_editor = self


func _drag_area_mouse_exited() -> void:
	IDE.moving_editor = null


func _on_resize_dragged(_offset) -> void:
	# Don't let the editor be moved when it's being resized
	resize_timer.start()
	resize_timer_is_stopped = false


func _on_resize_timer_timeout() -> void:
	# Let the editor be moved now that it's no longer being resized
	resize_timer_is_stopped = true


func _on_add_output_pressed() -> void:
	# Make new output
	var new_output: CodeOutput = OUTPUT_SCENE.instantiate()
	new_output.pressed.connect(_on_connect_pressed)
	# Set all the places the output needs to be registered
	outputs.append(new_output)
	output_box.add_child(new_output)
	output_box.move_child(new_output, outputs.size())


func _on_add_input_pressed() -> void:
	# Make new input
	var new_input: CodeInput = INPUT_SCENE.instantiate()
	new_input.hovered.connect(_on_input_mouse_entered)
	# Set all the places the input needs to be registered
	inputs.append(new_input)
	input_box.add_child(new_input)
	input_box.move_child(new_input, inputs.size())


func _on_code_editor_mouse_entered() -> void:
	# Don't allow the map to be zoomed since the player could be trying to scroll the code editor
	can_zoom = false


func _on_code_editor_mouse_exited() -> void:
	# Allow the map to zoom now that the player is no longer trying to scroll the editor
	can_zoom = true


func update_all_output_lines() -> void:
	# I DON'T KNOW WHY, but when the output get deleted and updates all of the other output lines, you need to wait two frames, even if it's removed as a child before this is called
	await get_tree().process_frame
	await get_tree().process_frame
	# Update the output's line positions
	for output in outputs:
		output.update_all_connected_line_positions()


func _on_delete_editor_pressed() -> void:
	# delete all the outputs and inputs
	for output in outputs:
		output._on_delete_pressed()
	for input in inputs:
		input._on_delete_pressed()
	# Wait for them to delete themselves
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	# You should kill yourself NOW
	queue_free()


func _on_class_name_changed(text: String) -> void:
	# Make sure the caret stays in the same place when all the spaces are deleted
	var caret_column = class_name_box.get_caret_column()
	class_name_box.text = class_name_box.text.strip_edges().replace(" ", "")
	class_name_box.set_caret_column(caret_column)
	# Set the editor's class name
	editor_class_name = class_name_box.text


func _on_compile_pressed() -> int:
	var code_lines: PackedStringArray = code_editor.text.split("\n", false)
	
	var code_tree: TreeArray = TreeArray.new()
	var current_parent: TreeArray = code_tree
	
	var line_index := 0
	for code_line: String in code_lines:
		code_line = code_line.strip_edges()
		print("Line: " + code_line + " Tokens: " + str(code_line.split(" ", false)))
		
		var current_token: String = ""
		var tokens: PackedStringArray = code_line.split(" ", false)
		
		# A way of doing this might be to go to functions for specific modes
		
		line_index += 1
	
	return 0
	
	code_tree.free()

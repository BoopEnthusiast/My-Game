extends Control
class_name IDE

const zoom_amount = Vector2(0.02, 0.02)
const max_zoom = Vector2(3, 3)
const min_zoom = Vector2(0.1, 0.1)

@onready var map: Control = $Map
@onready var player: CharacterBody3D = $"../.."

var code_editor_scene: PackedScene = preload("res://code_editor.tscn")

var map_initial_position: Vector2
var code_editors := []

var connecting := false
var connecting_from: CodeOutput
var connecting_from_line: Line2D
var connecting_from_editor: CodeEditor

static var moving_editor: CodeEditor
var currently_moving_editor: CodeEditor
static var is_moving_editor := false

enum VariableType {
	NULL,
	BOOL,
	INT,
	FLOAT,
	CHAR,
	STRING
}
static var VariableTypes: Array[int] = [
	VariableType.NULL,
	VariableType.BOOL,
	VariableType.INT,
	VariableType.FLOAT,
	VariableType.CHAR,
	VariableType.STRING
]


func _ready() -> void:
	map_initial_position = map.position
	code_editors = map.get_children()
	for code_editor in code_editors:
		code_editor.started_line_connection.connect(code_editor_started_line_connection)
		code_editor.connection_found.connect(code_editor_found_connection)


func _input(event) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == 4:
			map.position += event.relative / map.scale
			map.pivot_offset -= event.relative / map.scale
		if connecting:
			if connecting_from_line.get_point_count() == 1:
				connecting_from_line.add_point(event.global_position)
			connecting_from_line.set_point_position(1, connecting_from_line.to_local(event.global_position))
		if moving_editor != null and event.button_mask == 1:
			is_moving_editor = true
			currently_moving_editor = moving_editor
		if is_moving_editor and event.button_mask != 1:
			is_moving_editor = false
			currently_moving_editor = null
		if is_moving_editor:
			currently_moving_editor.position += event.relative / map.scale
			
			for output: CodeOutput in currently_moving_editor.outputs:
				output.update_all_connected_line_positions()
			for input: CodeInput in currently_moving_editor.inputs:
				for output: CodeOutput in input.connected_outputs:
					output.update_all_connected_line_positions()
		
	elif event is InputEventMouseButton:
		if event.button_index == 1 and connecting:
			if connecting and connecting_from_line and connecting_from_line.get_point_count() > 1:
				connecting_from_line.remove_point(1)
			
			connecting = false
			connecting_from = null
			connecting_from_line = null
			connecting_from_editor = null
		elif CodeEditor.can_zoom:
			if event.button_index == 4:
				map.scale += zoom_amount
			elif event.button_index == 5:
				map.scale -= zoom_amount
			map.scale = clamp(map.scale, min_zoom, max_zoom)
	
	if event.is_action_pressed("ui_cancel"):
		player.end_code_editing()


func code_editor_started_line_connection(output_id: int, code_editor: CodeEditor) -> void:
	if connecting and connecting_from_line and connecting_from_line.get_point_count() > 1:
			connecting_from_line.remove_point(1)
	
	connecting = true
	connecting_from = code_editor.outputs[output_id]
	connecting_from_line = Line2D.new()
	connecting_from_line.add_point(Vector2(18, 17))
	connecting_from.connected_inputs[connecting_from_line] = null
	connecting_from.connect_button.add_child(connecting_from_line)
	connecting_from_editor = code_editor


func code_editor_found_connection(input_id: int, code_editor: CodeEditor) -> void:
	if connecting and code_editor != connecting_from_editor:
		var connecting_to = code_editor.inputs[input_id]
		
		connecting_from.connected_inputs[connecting_from_line] = connecting_to
		connecting_to.connected_outputs.append(connecting_from)
		
		if connecting_from_line.get_point_count() > 1:
			connecting_from_line.remove_point(1)
		connecting_from_line.add_point(connecting_from_line.to_local(connecting_to.global_position) + Vector2(0, 15))
		connecting = false


func _on_add_editor_pressed():
	var new_editor = code_editor_scene.instantiate()
	new_editor.position -= map.position
	map.add_child(new_editor)

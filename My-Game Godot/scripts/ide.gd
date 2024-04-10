extends Control
class_name IDE

const ZOOM_AMOUNT = Vector2(0.02, 0.02)
const MAX_ZOOM = Vector2(3, 3)
const MIN_ZOOM = Vector2(0.1, 0.1)

@onready var map: Control = $Map
@onready var player: CharacterBody3D = $"../.."

const CODE_EDITOR_SCENE: PackedScene = preload("res://code_editor.tscn")

var map_initial_position: Vector2
var map_initial_size: Vector2
var code_editors := []

var connecting := false
var connecting_from: CodeOutput
var connecting_from_line: Line2D
var connecting_from_editor: CodeEditor

static var moving_editor: CodeEditor
var currently_moving_editor: CodeEditor
static var is_moving_editor := false

enum VARIABLE_TYPE {
	NULL,
	BOOL,
	INT,
	FLOAT,
	STRING,
	ARRAY,
	DICTIONARY,
	OBJECT,
	VECTOR3,
	NORMALVECTOR3
}
const VARIABLE_TYPES_GET_BY_INDEX: Array[VARIABLE_TYPE] = [
	VARIABLE_TYPE.NULL,
	VARIABLE_TYPE.BOOL,
	VARIABLE_TYPE.INT,
	VARIABLE_TYPE.FLOAT,
	VARIABLE_TYPE.STRING,
	VARIABLE_TYPE.ARRAY,
	VARIABLE_TYPE.DICTIONARY,
	VARIABLE_TYPE.OBJECT,
	VARIABLE_TYPE.VECTOR3,
	VARIABLE_TYPE.NORMALVECTOR3
]
const VARIABLE_TYPES_GET_BY_NAME: Dictionary = {
	"null": VARIABLE_TYPE.NULL,
	"bool": VARIABLE_TYPE.BOOL,
	"int": VARIABLE_TYPE.INT,
	"float": VARIABLE_TYPE.FLOAT,
	"String": VARIABLE_TYPE.STRING,
	"Array": VARIABLE_TYPE.ARRAY,
	"Dictionary": VARIABLE_TYPE.DICTIONARY,
	"Object": VARIABLE_TYPE.OBJECT,
	"Vector3": VARIABLE_TYPE.VECTOR3,
	"NormalVector3": VARIABLE_TYPE.NORMALVECTOR3
}

const KEY_WORDS: PackedStringArray = [
	"if",
	"for",
	"while"
]

const WHITE_SPACES: PackedStringArray = [
	" ",
	"	"
]


func _ready() -> void:
	# Get initial values
	map_initial_position = map.position
	map_initial_size = map.size
	code_editors = map.get_children()
	# Connect signals of children that may or may not be destroyed and instantiated again
	for code_editor in code_editors:
		code_editor.started_line_connection.connect(code_editor_started_line_connection)
		code_editor.connection_found.connect(code_editor_found_connection)


func _input(event) -> void:
	# Handle mouse movement
	if event is InputEventMouseMotion:
		# If middle mouse is pressed, move the map
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			map.position += event.relative / map.scale
			map.pivot_offset -= event.relative / map.scale
		# If in the process of connecting an output, move the line to follow the mouse
		if connecting:
			if connecting_from_line.get_point_count() == 1:
				connecting_from_line.add_point(event.global_position)
			connecting_from_line.set_point_position(1, connecting_from_line.to_local(event.global_position))
		## Handle moving the editor
		# When an editor is clicked, it checks if the IDE is already moving and editor
		# If the IDE isn't already moving an editor, then it sets itself as being moved
		
		# The point of most of this is to check that the mouse hasn't gone ahead of the currently moving editor
		
		# If the left mouse button is pressed and an editor has signalled themself as being moved, start moving that editor
		if moving_editor != null and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			is_moving_editor = true
			currently_moving_editor = moving_editor
		# If currently moving an editor, and the left mouse button isn't pressed, stop moving editor
		if is_moving_editor and event.button_mask != MOUSE_BUTTON_MASK_LEFT:
			is_moving_editor = false
			currently_moving_editor = null
		# If currently moving editor, move the editor
		if is_moving_editor:
			currently_moving_editor.position += event.relative / map.scale
			# Move the lines connected to outputs
			for output: CodeOutput in currently_moving_editor.outputs:
				output.update_all_connected_line_positions()
			# Move the lines connected to the outputs the inputs are connected to
			for input: CodeInput in currently_moving_editor.inputs:
				for output: CodeOutput in input.connected_outputs:
					output.update_all_connected_line_positions()
	
	# Handle mouse buttons 
	elif event is InputEventMouseButton:
		# If pressing the left mouse button and currently connecting, stop connecting
		if event.button_index == MOUSE_BUTTON_LEFT and connecting:
			if connecting and connecting_from_line and connecting_from_line.get_point_count() > 1:
				connecting_from_line.remove_point(1)
			
			connecting = false
			connecting_from = null
			connecting_from_line = null
			connecting_from_editor = null
		# If the map is able to be zoomed, zoom it
		elif CodeEditor.can_zoom:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				map.scale += ZOOM_AMOUNT
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				map.scale -= ZOOM_AMOUNT
			# Don't zoom out too far in or out
			map.scale = clamp(map.scale, MIN_ZOOM, MAX_ZOOM)
	
	# Handle quitting the editor
	if event.is_action_pressed("ui_cancel"):
		player.end_code_editing()

# Called when a code editor started connecting a line
func code_editor_started_line_connection(output_id: int, code_editor: CodeEditor) -> void:
	# If it's already connecting, stop connecting from that first
	if connecting and connecting_from_line and connecting_from_line.get_point_count() > 1:
			connecting_from_line.remove_point(1)
	# Setup the connection variables
	connecting = true
	connecting_from = code_editor.outputs[output_id]
	connecting_from_line = Line2D.new()
	connecting_from_line.add_point(Vector2(18, 17))
	connecting_from.connected_inputs[connecting_from_line] = null
	connecting_from.connect_button.add_child(connecting_from_line)
	connecting_from_editor = code_editor

# Called when a code editor found a connection with an input
func code_editor_found_connection(input_id: int, code_editor: CodeEditor) -> void:
	# Check it's connecting and it's on a different editor first, it'd be dumb to connect to yourself, you already have all of the variables yourself
	if connecting and code_editor != connecting_from_editor:
		var connecting_to = code_editor.inputs[input_id]
		# Set the input and output connections
		connecting_from.connected_inputs[connecting_from_line] = connecting_to
		connecting_to.connected_outputs.append(connecting_from)
		# Stop connecting
		if connecting_from_line.get_point_count() > 1:
			connecting_from_line.remove_point(1)
		connecting_from_line.add_point(connecting_from_line.to_local(connecting_to.global_position) + Vector2(0, 15))
		connecting = false


func _on_add_editor_pressed():
	# Make new editor
	var new_editor = CODE_EDITOR_SCENE.instantiate()
	new_editor.position -= map.position
	new_editor.started_line_connection.connect(code_editor_started_line_connection)
	new_editor.connection_found.connect(code_editor_found_connection)
	map.add_child(new_editor)

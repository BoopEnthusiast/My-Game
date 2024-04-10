extends HBoxContainer
class_name CodeOutput

signal pressed(which_output: CodeOutput)

@onready var type_selection: OptionButton = $TypeSelection
@onready var connect_button: Button = $Connect
@onready var code_editor: CodeEditor = $"../../../.."

var type: int = IDE.VARIABLE_TYPE.NULL

var connected_inputs: Dictionary # { Key: Line2D, Value: CodeInput }
#var connection_lines: Array[Line2D]

func _on_type_selection_item_selected(index) -> void:
	type = IDE.VARIABLE_TYPES_GET_BY_INDEX[index]
	print("Changed variable type: " + str(type))


func _on_connect_pressed() -> void:
	emit_signal("pressed", self)


func _on_delete_pressed() -> void:
	# Bruh I'm not commenting this too either read this or read the input delete pressed, it's the fucking same
	code_editor.outputs.erase(self)
	
	for input in connected_inputs.values():
		input.connected_outputs.erase(self)
	
	code_editor.update_all_output_lines()
	
	# You should kill yourself NOW
	get_parent().remove_child(self)
	queue_free()


func update_all_connected_line_positions() -> void:
	for line: Line2D in connected_inputs:
		var input = connected_inputs[line]
		if line.get_point_count() > 1:
			line.set_point_position(1, line.to_local(input.global_position) + Vector2(0, 15))

# So far this is unused and just kinda sitting here to be used
func update_line_position(line_to_move: Line2D, global_position_to_move_to: Vector2) -> void:
	if line_to_move.get_point_count() > 0:
		line_to_move.set_point_position(1, line_to_move.to_local(global_position_to_move_to))

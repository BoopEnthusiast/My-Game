extends HBoxContainer
class_name CodeInput

signal hovered(which_input: CodeInput)

var variable_name: StringName = "mouse_left"
var connected_outputs: Array[CodeOutput]

@onready var code_editor: CodeEditor = $"../../.."


func _on_text_changed(new_text) -> void:
	variable_name = new_text


func _on_text_field_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_delete_pressed() -> void:
	# Get rid of itself from the editor inputs
	code_editor.inputs.erase(self)
	
	# Remove all the lines of the connected outputs, delete itself from connected outputs, and then update the lines
	for output in connected_outputs:
		output.connect_button.remove_child(output.connected_inputs.find_key(self))
		output.connected_inputs.erase(output.connected_inputs.find_key(self))
		output.code_editor.update_all_output_lines()
	
	# You should kill yourself NOW
	get_parent().remove_child(self)
	queue_free()

extends HBoxContainer
class_name CodeInput

signal hovered(which_input: CodeInput)

var variable_name: StringName
var connected_outputs: Array[CodeOutput]

@onready var code_editor: CodeEditor = $"../../.."


func _on_text_changed(new_text) -> void:
	variable_name = new_text


func _on_text_field_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_delete_pressed() -> void:
	code_editor.inputs.erase(self)
	
	for output in connected_outputs:
		output.connect_button.remove_child(output.connected_inputs.find_key(self))
		output.connected_inputs.erase(output.connected_inputs.find_key(self))
		output.code_editor.update_all_output_lines()
	
	code_editor.inputs.erase(self)
	
	get_parent().remove_child(self)
	queue_free()

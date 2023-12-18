extends HBoxContainer
class_name CodeInput

signal hovered(which_input: CodeInput)

var variable_name: StringName
var connected_outputs: Array[CodeOutput]


func _on_text_changed(new_text) -> void:
	variable_name = new_text


func _on_text_field_mouse_entered():
	emit_signal("hovered", self)

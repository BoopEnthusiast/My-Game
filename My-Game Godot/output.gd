extends HBoxContainer
class_name CodeOutput

signal pressed(which_output: CodeOutput)

@onready var type_selection: OptionButton = $TypeSelection
@onready var connect_button: Button = $Connect

var type: int = IDE.VariableType.NULL

var connected_inputs: Dictionary # { Key: Line2D, Value: CodeInput }
#var connection_lines: Array[Line2D]

func _on_type_selection_item_selected(index) -> void:
	type = IDE.VariableTypes[index]
	print("Changed variable type: " + str(type))


func _on_connect_pressed():
	emit_signal("pressed", self)

class_name NodeOutput
extends NodeIOPort


var connected_input: NodeInput


func _ready() -> void:
	remove_child(button)
	add_child(button)

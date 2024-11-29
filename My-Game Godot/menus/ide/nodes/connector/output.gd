class_name NodeOutput
extends NodeIOPort


func _ready() -> void:
	remove_child(button)
	add_child(button)

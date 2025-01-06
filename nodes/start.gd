class_name StartNode
extends NodeBase


func _on_start_pressed() -> void:
	Lang.compile_spell(self)

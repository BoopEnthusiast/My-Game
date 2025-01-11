class_name StartNode
extends NodeBase


@onready var tree: Tree = $Background/Central/Tree


func _on_start_pressed() -> void:
	Lang.compile_spell(self)

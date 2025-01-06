class_name ScriptTreeObject
extends ScriptTree


func _init(parent: ScriptTree, input: NodeInput) -> void:
	type = Type.OBJECT
	_parent = parent
	value = input

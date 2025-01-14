class_name ScriptTreeObject
extends ScriptTree


func _init(new_parent: ScriptTree, input: NodeInput) -> void:
	type = Type.OBJECT
	parent = new_parent
	value = input

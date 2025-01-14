class_name ScriptTreeMethod
extends ScriptTree


func _init(new_parent: ScriptTree, method_name: String) -> void:
	type = Type.METHOD
	parent = new_parent
	value = method_name

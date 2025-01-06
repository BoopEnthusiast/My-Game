class_name ScriptTreeMethod
extends ScriptTree


func _init(parent: ScriptTree, method_name: String) -> void:
	type = Type.METHOD
	_parent = parent
	value = method_name

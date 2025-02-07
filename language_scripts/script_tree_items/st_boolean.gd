class_name ScriptTreeBoolean
extends ScriptTree


func _init(new_parent: ScriptTree, given_value: String) -> void:
	type = Type.BOOL
	parent = new_parent
	value = given_value

class_name ScriptTreeData
extends ScriptTree


func _init(new_parent: ScriptTree, given_value: Variant) -> void:
	type = Type.DATA
	parent = new_parent
	value = given_value

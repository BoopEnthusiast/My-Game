class_name ScriptTreeData
extends ScriptTree


func _init(parent: ScriptTree, given_value: Variant) -> void:
	type = Type.DATA
	_parent = parent
	value = given_value

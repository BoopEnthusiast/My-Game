class_name ScriptTreeObject
extends ScriptTree


func _init(new_parent: ScriptTree, new_value: Variant) -> void:
	type = Type.OBJECT
	parent = new_parent
	value = new_value

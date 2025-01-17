class_name ScriptTreeKeyword
extends ScriptTree


func _init(new_parent: ScriptTree, keyword: String) -> void:
	type = Type.KEYWORD
	parent = new_parent
	value = keyword

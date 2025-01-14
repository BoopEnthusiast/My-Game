class_name ScriptTreeFunction
extends ScriptTree


func _init(new_parent: ScriptTree, input_or_name: Variant) -> void:
	type = Type.FUNCTION
	parent = new_parent
	assert(input_or_name is NodeInput or input_or_name is String, "Script Tree Function input_or_name isn't a NodeInput or String")
	value = input_or_name

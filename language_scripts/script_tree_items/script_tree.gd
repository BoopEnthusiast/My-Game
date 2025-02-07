class_name ScriptTree
extends Resource


enum Type {
	ROOT,
	OBJECT,
	FUNCTION,
	METHOD,
	DATA,
	KEYWORD,
	BOOL
}

@export var type: Type
@export var children: Array[ScriptTree] 

var parent: ScriptTree

var value: Variant:
	get:
		return get_value(value)


func _init(node_type: Type, new_parent: ScriptTree, node_value: Variant = null) -> void:
	type = node_type
	value = node_value
	parent = new_parent


func add_child(child: ScriptTree) -> void:
	children.append(child)


func change_type(new_type: Type) -> void:
	assert(is_class("ScriptTree"), "This is a statically typed ScriptTree item, it is not a ScriptTree, it is of class" + get_class())
	type = new_type


func get_value(val: Variant) -> Variant:
	return val

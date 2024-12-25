class_name ScriptTree
extends Resource


enum Type {
	ROOT,
	VARIABLE,
	OBJECT,
	FUNCTION,
	METHOD,
}

@export var type: Type
@export var children: Array[ScriptTree] 

var value: Variant


func _init(node_type: Type, node_value: Variant = null) -> void:
	type = node_type
	value = node_value


func add_child(child: ScriptTree) -> void:
	children.append(child)


func change_type(new_type: Type) -> void:
	type = new_type

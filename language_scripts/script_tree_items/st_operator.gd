class_name  ScriptTreeOperator
extends ScriptTree


func _init(parent: ScriptTree, operator: String) -> void:
	type = Type.OPERATOR
	_parent = parent
	value = operator


func get_value() -> Variant:
	return "Testing hello hello!"

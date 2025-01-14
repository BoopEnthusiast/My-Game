class_name  ScriptTreeOperator
extends ScriptTree


func _init(new_parent: ScriptTree, operator: String) -> void:
	type = Type.OPERATOR
	parent = new_parent
	value = operator


func get_value(value) -> Variant:
	match value:
		"+":
			return children[0].value + children[1].value
		"-":
			return children[0].value - children[1].value
		"*":
			return children[0].value * children[1].value
		"/":
			return children[0].value / children[1].value
		"%":
			return children[0].value % children[1].value
	
	assert(false, "Operator is not a valid operator, operator is: " + value)
	return null

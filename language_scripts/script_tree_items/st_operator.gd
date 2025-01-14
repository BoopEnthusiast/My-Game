class_name  ScriptTreeOperator
extends ScriptTree


func _init(new_parent: ScriptTree, operator: String) -> void:
	type = Type.OPERATOR
	parent = new_parent
	value = operator


func get_value(operator) -> Variant:
	match operator:
		"+":
			return children[0].value + children[1].value
		"-":
			return children[0].value - children[1].value
		"*":
			return children[0].value * children[1].value
		"/":
			return children[0].value / children[1].value
		"%":
			return roundi(children[0].value) % roundi(children[1].value)
	
	assert(false, "Operator is not a valid operator, operator is: " + operator)
	return null

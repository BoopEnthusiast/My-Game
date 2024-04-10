extends Object
class_name TreeArray

var parent: TreeArray
var children: Array[TreeArray] = []
var value = null
var mode: PARSE_MODE = PARSE_MODE.ROOT
var order_of_operations: Array[PARSE_MODE] = []
enum PARSE_MODE {
	ROOT,
	INPUT,
	DEFINE,
	NAME_VARIABLE,
	SET_VARIABLE,
	GET_CLASS,
	CLASS_PROPERTY,
	CLASS_METHOD,
	FUNCTION,
	SET_PARAMETER,
	KEY_WORD,
	SET_STRING,
} 

func _notification(p_what):
	match p_what:
		NOTIFICATION_PREDELETE:
			# Destructor.
			for child in children:
				child.free()
		NOTIFICATION_POSTINITIALIZE:
			# Creator.
			pass


func get_children() -> Array[TreeArray]:
	return children


func get_parent() -> TreeArray:
	return parent


func set_value(value_to_set, mode_to_set: PARSE_MODE) -> void:
	value = value_to_set
	mode = mode_to_set


func add_child(value_to_set, mode_to_set: PARSE_MODE) -> TreeArray:
	var new_child = TreeArray.new()
	new_child.set_value(value_to_set, mode_to_set)
	children.append(new_child)
	return new_child

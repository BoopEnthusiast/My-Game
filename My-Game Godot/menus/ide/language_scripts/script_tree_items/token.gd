class_name Token
extends Resource

enum Type {
	OBJECT_NAME,
	FUNCTION_NAME,
	METHOD_NAME,
	PARAMETER,
	PROPERTY,
	FLOAT,
	STRING,
	KEYWORD,
	NONE,
	BOOLEAN,
}

var string: String
var types: Array[Type]


func _init(token_string: String, token_types: Array[Type]) -> void:
	string = token_string
	types = token_types

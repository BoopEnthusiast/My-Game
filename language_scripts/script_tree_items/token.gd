class_name Token
extends Resource

enum Type {
	OBJECT_NAME,
	FUNCTION_NAME,
	METHOD_NAME,
	PARAMETER,
	PROPERTY,
	FLOAT,
	INT,
	STRING,
	KEYWORD,
	NONE,
	BOOLEAN,
	BREAK, # New line, new commad
	OPERATOR,
}

var string: String
var types: Array[Type]


func _init(token_string: String, token_types: Array[Type]) -> void:
	string = token_string
	types = token_types

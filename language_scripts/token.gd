class_name Token
extends Resource

enum Type {
	OBJECT_NAME,
	FUNCTION_NAME,
	METHOD_NAME,
	PARAMETER,
	PROPERTY,
	EXPRESSION,
	INNER_EXPRESSION,
	STRING,
	KEYWORD,
	NONE,
	BOOLEAN,
	BREAK, # New line, new commad
}

var string: String
var types: Array[Type]
var line: int


func _init(token_string: String, line_number: int, token_types: Array[Type]) -> void:
	string = token_string
	line = line_number
	types = token_types

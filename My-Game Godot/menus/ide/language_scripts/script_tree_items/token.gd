class_name Token
extends Resource

enum Type {
	OBJECT_NAME,
	FUNCTION_NAME,
	METHOD_NAME,
	PARAMETER,
	FLOAT,
	STRING,
	KEYWORD,
	NONE,
}

var str: String
var types: Array[Type]


func _init(str: String, types: Array[Type]) -> void:
	self.str = str
	self.types = types

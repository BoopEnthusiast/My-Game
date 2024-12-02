class_name ScriptTree
extends Resource

enum Type {
	ROOT,
	VARIABLE,
	OBJECT,
	FUNCTION,
}

@export var type: Type

@tool
extends CodeEdit

@export var function_names: Color
@export var comments: Color
@export var strings: Color


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	syntax_highlighter = syntax_highlighter as CodeHighlighter
	
	syntax_highlighter.add_color_region("#", "", comments, true)
	
	syntax_highlighter.add_color_region("\"", "\"", strings)
	
	for name: String in Functions.FUNCTION_NAMES:
		syntax_highlighter.add_keyword_color(name, function_names)

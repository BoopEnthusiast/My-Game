@tool
extends CodeEdit

@export var function_name_color: Color
@export var comment_color: Color


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	syntax_highlighter = syntax_highlighter as CodeHighlighter
	
	syntax_highlighter.add_color_region("#", "", comment_color, true)
	
	for name: String in Functions.FUNCTION_NAMES:
		syntax_highlighter.add_keyword_color(name, function_name_color)

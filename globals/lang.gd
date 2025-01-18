# lang.gd
# Has no class_name as it is a singleton/global (which don't need class names in Godot)
extends Node
## Forms a list of Callables (references to functions in Godot) for a Spell to run when it's cast
## 
## Find this code at https://github.com/BoopEnthusiast/My-Game[br]
## This is in its infancy and will be extended as I work on the overall game and add more to it. But, it works and is a functional language.
## Currently there aren't many functions or methods to call, or nodes to add.[br][br]
## 
## This is the second version of it, the previous was much less extensible, but this should be the final version as I can now extend it in any way I need.[br][br]
## 
## This class does not need to be fast, it's run very infrequently and is literally the compliation of a custom language.
## For that reason, there are some inefficiencies in this code. 
## For goodness sake I'm using *recursion* directly in a video game and not just the engine, that's almost unheard of.[br][br]
##
## In the future this class may be moved to a seperate thread. 
## This will not be hard to do, especially in Godot, and it's not slow now, so I am not worried about it yet.[br][br]


enum Keywords {
	IF,
	ELIF,
	ELSE,
	WHILE,
	FOR,
	IN,
	RETURN,
}
const KEYWORDS: Array[String] = [
	"if",
	"elif",
	"else",
	"while",
	"for",
	"in",
	"return",
]

var tree_root_item: TreeItem
var form_actions_node: LangFormActions
var tokenize_code_node: LangTokenizeCode
var build_script_tree_node: LangBuildScriptTree

var _spells: Array[Spell] = []


func _enter_tree() -> void:
	tokenize_code_node = LangTokenizeCode.new()
	build_script_tree_node = LangBuildScriptTree.new()
	form_actions_node = LangFormActions.new()


## Makes a new spell and takes a start node and goes through all the connected nodes until it's done
func compile_spell(start_node: StartNode) -> void:
	# Setup new spell
	var new_spell = Spell.new()
	new_spell.start_node = start_node
	
	# Go to all connected nodes and compile each of them
	# TODO: Add more nodes that the start node can connect to
	# Maybe add more types of connections?
	var connected_node = start_node.outputs[0].get_connected_node()
	if connected_node is ProgramNode:
		var parsed_code = compile_program_node(connected_node)
		new_spell.actions.append_array(parsed_code)
	_spells.append(new_spell)
	IDE.current_spell = new_spell


## TODO: Add add_error.[br]
## Adds an error to an array of errors when one is found in the code during compilation or checking beforehand
func add_error(condition: bool, _error_text: String = "Unspecified error...", _line: int = -1) -> void:
	if condition:
		pass


## Takes a program node's text and inputs and forms a list of callables for a spell to run
func compile_program_node(program_node: ProgramNode) -> Array:
	var tokenized_code: Array[Token] = tokenize_code_node.tokenize_code(program_node.code_edit.text)
	
	var tree_root: ScriptTreeRoot = build_script_tree_node.build_script_tree(tokenized_code, program_node)
	
	tree_root_item = IDE.start_node_tree.create_item()
	return form_actions_node.form_actions(tree_root, tree_root_item)



# The piece of code that should work FOR NOW
# Input 1: "fireball" - leads to ball node
# Input 2: "start" - leads to start node
# Code for now:
# spawn(fireball)
# fireball.set_on_fire() # should setting something on fire be a global function instead of a method?
# fireball.push(5 * 3 + 2)
#
# Code for later:
# spawn(fireball)
# fireball.set_on_fire() 
# fireball.push((4 + 3) * 2)
# while fireball:
#     fireball.push(1) # moves fireball in direction player is facing, the cooldown so that the while loop isn't infinitely fast is the TTC (time to cast) for the push method on the ball

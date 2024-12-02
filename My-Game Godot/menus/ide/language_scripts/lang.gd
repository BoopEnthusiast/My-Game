# Holds all of the callables that a spell can cast and parses each spell
extends Node


enum WaitingFor {
	SPAWN,
	NAME,
	APPLY_EFFECT,
	MODIFIER,
}
enum Effects {
	PUSH
}

const BALL = preload("res://menus/ide/spawnables/ball.tscn")

var spells: Array[Spell] = []


func compile_spell(start_node: StartNode) -> void:
	var new_spell = Spell.new()
	new_spell.start_node = start_node
	var connected_node = start_node.outputs[0].get_connected_node()
	if connected_node is ProgramNode:
		var parsed_code = compile_program_node(new_spell, connected_node.code_edit.text)
		new_spell.actions.append_array(parsed_code[0])
		new_spell.action_args.append_array((parsed_code[1]))
	spells.append(new_spell)
	IDE.current_spell = new_spell


func add_error(_error_text: String = "Unspecified error...", _line: int = -1) -> void:
	pass


# Returns two arrays: the action list (callables) and the arguments for the actions (variants)
func compile_program_node(spell: Spell, text: String) -> Array[Array]:
	var action_list: Array[Callable] = []
	var action_args: Array = []
	var code: PackedStringArray = text.split(" ")
	var waiting_for_stack: Array[WaitingFor] = []
	var store_name: String
	var store_effect: Effects
	for token in code:
		token = token.strip_edges()
		if not waiting_for_stack.is_empty():
			if waiting_for_stack.front() == WaitingFor.NAME:
				store_name = token
				waiting_for_stack.pop_front()
			elif waiting_for_stack.front() == WaitingFor.SPAWN:
				if token == "ball":
					action_list.push_back(spell.spawn_ball)
					action_args.push_back(store_name)
					waiting_for_stack.pop_front()
				else:
					add_error("Unknown spawnable object")
			elif waiting_for_stack.front() == WaitingFor.APPLY_EFFECT:
				if token == "push":
					action_list.push_back(spell.apply_effect)
					waiting_for_stack.push_front(WaitingFor.MODIFIER)
					store_effect = Effects.PUSH
				else:
					add_error("Uknown effect")
			elif waiting_for_stack.front() == WaitingFor.MODIFIER:
				action_args.push_back([store_effect, float(token)])
		elif token == "spawn":
			waiting_for_stack.push_front(WaitingFor.SPAWN)
			waiting_for_stack.push_front(WaitingFor.NAME)
		else:
			action_list.push_back(spell.find_object)
			action_args.push_back(token)
			waiting_for_stack.push_front(WaitingFor.APPLY_EFFECT)
	return [action_list, action_args]


#func tokenize_code(text: String) -> String:
	#var symbols = [".","(",")"]
	#var occurance_index: int = text.find(".")
	#while occurance_index > -1:
		#text[occurance_index] = " "
		#occurance_index = text.find(".")
	#
	#return text


func compile_program_node_try_two(spell: Spell, text: String) -> Array[Array]:
	var tree_root = ScriptTreeRoot.new()
	
	return []


func tokenize_code_try_two(text: String) -> Array[Token]:
	var tokenized_code: Array[Token] = []
	var working_token: String = ""
	var next_type: Array[Token.Type]
	var is_comment := false
	
	const KEYWORDS: Array[String] = [
		"if",
		"for",
		"while",
		"elif",
	]
	
	var i = 0
	for char in text:
		if is_comment and char == "\n":
			is_comment = false
			continue
			
		elif is_comment:
			continue
			
		elif next_type.has(Token.Type.STRING):
			if char == "\\":
				pass # TODO: Implement something like newlines and tabs and whatnot
				
			elif char == "\"":
				next_type.clear()
				tokenized_code.append(Token.new(working_token, [Token.Type.STRING]))
				continue
				
		elif char == "#":
			is_comment = true
			continue
			
		elif char == " " and KEYWORDS.has(working_token):
			tokenized_code.append(Token.new(working_token, [Token.Type.KEYWORD]))
			continue
		elif char == "." and tokenized_code.back().types.has(Token.Type.OBJECT_NAME):
			tokenized_code.append(Token.new(working_token, [Token.Type.OBJECT_NAME]))
			next_type = [Token.Type.PARAMETER, Token.Type.METHOD_NAME]
			continue
			
		elif char == "(" and next_type.has(Token.Type.METHOD_NAME):
			if tokenized_code.back().types.has(Token.Type.OBJECT_NAME):
				tokenized_code.append(Token.new(working_token, [Token.Type.METHOD_NAME]))
				continue
				
			else:
				tokenized_code.append(Token.new(working_token, [Token.Type.FUNCTION_NAME]))
			
		working_token += char
	
	return tokenized_code

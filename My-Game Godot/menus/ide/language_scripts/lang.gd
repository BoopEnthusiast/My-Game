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

const WHITESPAC_CHARS: Array[String] = [
		" ",
		" ",
		" ",
		"	",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		" ",
		"　",
		"\n",
		"\t",
		"\v",
		"\f",
		"\r",
	]

const BALL = preload("res://menus/ide/spawnables/ball.tscn")

var spells: Array[Spell] = []


func compile_spell(start_node: StartNode) -> void:
	var new_spell = Spell.new()
	new_spell.start_node = start_node
	var connected_node = start_node.outputs[0].get_connected_node()
	if connected_node is ProgramNode:
		var parsed_code = compile_program_node_try_two(new_spell, connected_node.code_edit.text)
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
	var tokenized_code: Array[Token] = tokenize_code_try_two(text)
	for token in tokenized_code:
		if token.types.has(Token.Type.OBJECT_NAME):
			var new_child = ScriptTree.new(ScriptTree.Type.OBJECT)
			
			tree_root.add_child(new_child)
			
	spell.actions = []
	return []


func tokenize_code_try_two(text: String) -> Array[Token]:
	var tokenized_code: Array[Token] = []
	var working_token: String = ""
	var next_type: Array[Token.Type]
	var is_comment := false
	
	const KEYWORDS: Array[String] = [
		"if",
		"elif",
		"else",
		"while",
		"for",
	]
	
	for chr in text:
		if is_comment and chr == "\n":
			is_comment = false
			working_token = ""
			continue
			
		elif is_comment:
			continue
			
		elif next_type.has(Token.Type.STRING):
			if chr == "\\":
				pass # TODO: Implement something like newlines and tabs and whatnot
				
			elif chr == "\"":
				next_type.clear()
				tokenized_code.append(Token.new(working_token, [Token.Type.STRING]))
				continue
				
		elif chr == "#":
			is_comment = true
			continue
			
		elif chr == " " and KEYWORDS.has(working_token):
			tokenized_code.append(Token.new(working_token, [Token.Type.KEYWORD]))
			match working_token:
				KEYWORDS[0], KEYWORDS[1], KEYWORDS[3]:
					next_type = [Token.Type.BOOLEAN]
				KEYWORDS[4]:
					pass
			working_token = ""
			continue
			
		elif chr == ".":
			if not tokenized_code.is_empty() and tokenized_code.back().types.has(Token.Type.OBJECT_NAME):
				tokenized_code.append(Token.new(working_token, [Token.Type.OBJECT_NAME, Token.Type.PARAMETER]))
				
			else:
				tokenized_code.append(Token.new(working_token, [Token.Type.OBJECT_NAME]))
				
			next_type = [Token.Type.PROPERTY, Token.Type.METHOD_NAME]
			working_token = ""
			continue
			
		elif chr == "(":
			if next_type.has(Token.Type.METHOD_NAME):
				tokenized_code.append(Token.new(working_token, [Token.Type.METHOD_NAME]))
				
			else:
				tokenized_code.append(Token.new(working_token, [Token.Type.FUNCTION_NAME]))
				
			next_type = [Token.Type.PARAMETER]
			working_token = ""
			continue
			
		elif chr == ")":
			if not working_token.is_empty():
				tokenized_code.append(Token.new(working_token, [Token.Type.PARAMETER]))
			next_type = []
			continue
			
		working_token += chr
		print(working_token,"   ",tokenized_code,"   ",next_type,"    ",is_comment)
	
	print(tokenized_code)
	for token in tokenized_code:
		print(token.types,"   ",token.string)
	return tokenized_code
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
# while fireball.is_alive():
#     fireball.push(1) # moves fireball in direction player is facing, the cooldown so that the while loop isn't infinitely fast is the TTC (time to cast) for the push method on the ball

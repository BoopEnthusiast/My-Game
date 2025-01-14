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
##
## @experimental


## Tokenization's expected next token
enum WaitingFor {
	SPAWN,
	NAME,
	APPLY_EFFECT,
	MODIFIER,
}

## All possible unicode whitespace characters, there may be duplicates since it's hard to tell and better safe than sorry. This class does not need to be efficient.
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

var _spells: Array[Spell] = []

var tree_root_item: TreeItem


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
		var parsed_code = compile_program_node(new_spell, connected_node.code_edit.text, connected_node.inputs)
		new_spell.actions.append_array(parsed_code)
	_spells.append(new_spell)
	IDE.current_spell = new_spell


## TODO: Add add_error.[br]
## Adds an error to an array of errors when one is found in the code during compilation or checking beforehand
func add_error(_error_text: String = "Unspecified error...", _line: int = -1) -> void:
	pass


## Takes a program node's text and inputs and forms a list of callables for a spell to run
func compile_program_node(spell: Spell, text: String, inputs: Array) -> Array[Array]:
	var tokenized_code: Array[Token] = tokenize_code(text)
	
	var tree_root: ScriptTreeRoot = build_script_tree(tokenized_code, inputs)
	
	tree_root_item = IDE.start_node_tree.create_item()
	spell.actions = form_actions(tree_root, tree_root_item)
	return []


## Goes through each character and turns them into an array of Token objects
func tokenize_code(text: String) -> Array[Token]:
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
	const OPERATORS: Array[String] = [
		"*",
		"/",
		"+",
		"-",
		"%",
		"=",
	]
	
	# Loop through characters and turn them into tokens with types that can then be compiled into a Script Tree
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
			
		elif chr == "\n":
			tokenized_code.append(Token.new(working_token, [Token.Type.BREAK]))
			working_token = ""
			continue
			
		elif WHITESPAC_CHARS.has(chr):
			if KEYWORDS.has(working_token):
				tokenized_code.append(Token.new(working_token, [Token.Type.KEYWORD]))
				match working_token:
					KEYWORDS[0], KEYWORDS[1], KEYWORDS[3]:
						next_type = [Token.Type.BOOLEAN]
					KEYWORDS[4]:
						pass
				
			elif OPERATORS.has(working_token):
				tokenized_code.append(Token.new(working_token, [Token.Type.OPERATOR]))
				next_type = [Token.Type.FLOAT, Token.Type.INT]
				
			elif working_token.is_valid_int():
				if next_type.has(Token.Type.PARAMETER):
					tokenized_code.append(Token.new(working_token, [Token.Type.INT, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.INT]))
				next_type = [Token.Type.INT, Token.Type.FLOAT]
				
			elif working_token.is_valid_float():
				if next_type.has(Token.Type.PARAMETER):
					tokenized_code.append(Token.new(working_token, [Token.Type.FLOAT, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.FLOAT]))
				next_type = [Token.Type.INT, Token.Type.FLOAT]
				
			
			working_token = ""
			continue
			
		elif chr == ".":
			if not working_token.is_valid_int():
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
			
		elif chr == ",":
			tokenized_code.append(_number_parameter(working_token))
			
			next_type = [Token.Type.PARAMETER]
			working_token = ""
			continue
			
		elif chr == ")":
			if not working_token.is_empty():
				tokenized_code.append(_number_parameter(working_token))
			next_type = []
			working_token = ""
			continue
			
		elif OPERATORS.has(chr):
			if working_token.is_valid_int():
				if next_type.has(Token.Type.PARAMETER):
					tokenized_code.append(Token.new(working_token, [Token.Type.INT, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.INT]))
				
			elif working_token.is_valid_float():
				if next_type.has(Token.Type.PARAMETER):
					tokenized_code.append(Token.new(working_token, [Token.Type.FLOAT, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.FLOAT]))
			
			tokenized_code.append(Token.new(chr, [Token.Type.OPERATOR]))
			
			next_type = [Token.Type.INT, Token.Type.FLOAT]
			working_token = ""
			continue
		
		working_token += chr
		print(working_token,"   ",tokenized_code,"   ",next_type,"    ",is_comment)
	
	tokenized_code.append(Token.new(working_token, [Token.Type.BREAK]))
	
	print(tokenized_code)
	for token in tokenized_code:
		print(token.types,"   ",token.string)
	return tokenized_code


## Loop through tokens and build out the Script Tree, returning the root node
func build_script_tree(tokenized_code: Array[Token], inputs: Array) -> ScriptTreeRoot:
	const FUNCTION_NAMES: Array[String] = [
		"spawn",
		"print"
	]
	
	var tree_root = ScriptTreeRoot.new()
	var working_st: ScriptTree = tree_root
	
	for token in tokenized_code:
		if token.types.has(Token.Type.BREAK):
			working_st = tree_root
			print("SETTING TO TREE ROOT")
			
		elif token.types.has(Token.Type.OBJECT_NAME):
			# The inputs are the objects
			var input = _get_input(token.string, inputs)
			assert(is_instance_valid(input), "Can't find input with name: " + token.string)
			
			var new_child = ScriptTreeObject.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.INT) or token.types.has(Token.Type.FLOAT):
			assert(working_st.type == ScriptTree.Type.OPERATOR or working_st.type == ScriptTree.Type.FUNCTION, "Parent of Script Tree Int or Float isn't an object, parent is: " + str(working_st.type))
			
			var new_child = ScriptTreeData.new(working_st, float(token.string))
			working_st.add_child(new_child)
			working_st = new_child
			
		elif token.types.has(Token.Type.FUNCTION_NAME):
			# Has to either be a built-in function or a function from another node
			var input
			input = _get_input(token.string, inputs)
			input = FUNCTION_NAMES[FUNCTION_NAMES.find(token.string)]
			assert(is_instance_valid(input) or typeof(input) == TYPE_STRING, "Can't find input with name: " + token.string)
			
			var new_child = ScriptTreeFunction.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.METHOD_NAME):
			assert(working_st.type == ScriptTree.Type.OBJECT, "Parent of Script Tree Method isn't an object, parent is: " + str(working_st.type))
			var new_child = ScriptTreeMethod.new(working_st, token.string.strip_edges())
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.OPERATOR):
			#if token.string == "=":
				assert(working_st.type == ScriptTree.Type.OBJECT or working_st.type == ScriptTree.Type.DATA, "Parent of operator is not an object, parent is: " + str(working_st.type))
				var new_child = _replace_working_st(working_st, token.string)
				working_st = new_child
				
			#elif token.string == "*" or token.string == "/":
				#assert(working_st.type == ScriptTree.Type.OBJECT or working_st.type == ScriptTree.Type.DATA, "Parent of operator is not an object, parent is: " + str(working_st.type))
				#var new_child = _replace_working_st(working_st)
				#working_st = new_child
				#if working_st.parent.value == "+" or working_st.parent.value == "-" or working_st.parent.value == "%":
					#
				
		elif token.types.has(Token.Type.PARAMETER):
			assert(working_st.type == ScriptTree.Type.FUNCTION or working_st.type == ScriptTree.Type.METHOD, "Parent of Script Tree Parameter isn't a function or method, parent is: " + str(working_st.type) + " with value: " + str(working_st.value))
			# Parameters are always objects
			
			var input = _get_input(token.string, inputs)
			assert(is_instance_valid(input), "Can't find input with name: " + token.string)
			
			var new_child = ScriptTreeObject.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
	
	
	return tree_root


## Go down the built up ScriptTree with recursion and form the array of callable
func form_actions(working_st: ScriptTree, tree_item: TreeItem) -> Array[Callable]:
	
	var callable_list: Array[Callable] = []
	
	# Debugging
	print(working_st.type,"  ",working_st.value,"    HAS ",working_st.children.size()," CHILDREN: ")
	for child in working_st.children:
		print(child.type,"  ",child.value)
	print("END OF CHILDREN")
	
	# Go through each child and run this function on them, then get their array of callables and add it to the current one
	for child in working_st.children:
		print("STARTING WORK ON: ",child.type,"  ",child.value,"    PARENTS TYPE IS: ",working_st.type)
		var new_tree_item = tree_item.create_child()
		new_tree_item.set_text(0, str(working_st.type)+" | "+str(working_st.value))
		callable_list.append_array(form_actions(child, new_tree_item))
	
	## See if the current object and its parent match to a known function/method, if so, add it to the callable list
	# Built-in functions
	if working_st.type == ScriptTree.Type.OBJECT or working_st.type == ScriptTree.Type.DATA or working_st.type == ScriptTree.Type.OPERATOR:
		if working_st.parent.type == ScriptTree.Type.FUNCTION:
			# Functions
			match working_st.parent.value:
				"spawn":
					callable_list.append(Callable(Functions, "spawn").bind(working_st.value))
				"print":
					callable_list.append(Callable(Functions, "pprint").bind(working_st.value))
				
	# Method on an object
	elif working_st.type == ScriptTree.Type.METHOD:
		if working_st.parent.type == ScriptTree.Type.OBJECT:
			var has_parameters := false
			for child in working_st.children:
				if child.type == ScriptTree.Type.OBJECT:
					has_parameters = true
			if not has_parameters:
				callable_list.append(Callable(working_st.parent.value.get_output_node(), working_st.value))
			else:
				var new_callable := Callable(working_st.parent.value.get_output_node(), working_st.value)
				for child in working_st.children:
					new_callable = new_callable.bind(child.value)
				callable_list.append(new_callable)
				
	
	print("Callable list: " + str(callable_list))
	# Pass the callable list back up the tree
	return callable_list

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

func _get_input(find_name: String, inputs: Array) -> NodeInput:
	for input in inputs:
		if input.name_field.text.strip_edges() == find_name.strip_edges():
			return input
	return null


func _number_parameter(working_token: String) -> Token:
	if working_token.is_valid_int():
		return Token.new(working_token, [Token.Type.PARAMETER, Token.Type.INT])
		
	elif working_token.is_valid_float():
		return Token.new(working_token, [Token.Type.PARAMETER, Token.Type.FLOAT])
		
	else:
		return Token.new(working_token, [Token.Type.PARAMETER])


func _replace_working_st(working_st: ScriptTree, token_string: String) -> ScriptTree:
	working_st.parent.children.erase(working_st)
	var new_child = ScriptTreeOperator.new(working_st.parent, token_string)
	working_st.parent.add_child(new_child)
	new_child.add_child(working_st)
	working_st.parent = new_child
	return new_child

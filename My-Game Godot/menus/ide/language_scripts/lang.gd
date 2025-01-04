extends Node
## Holds all of the callables that a spell can cast and parses each spell


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
		var parsed_code = compile_program_node(new_spell, connected_node.code_edit.text, connected_node.inputs, connected_node.outputs)
		new_spell.actions.append_array(parsed_code)
	spells.append(new_spell)
	IDE.current_spell = new_spell


func add_error(_error_text: String = "Unspecified error...", _line: int = -1) -> void:
	pass


func compile_program_node(spell: Spell, text: String, inputs: Array, _outputs: Array) -> Array[Array]:
	var tree_root = ScriptTreeRoot.new()
	var tokenized_code: Array[Token] = tokenize_code(text)
	var working_st: ScriptTree = tree_root
	
	const FUNCTION_NAMES: Array[String] = [
		"spawn"
	]
	
	# Loop through tokens and build out the Script Tree
	for token in tokenized_code:
		if token.types.has(Token.Type.BREAK):
			working_st = tree_root
			print("SETTING TO TREE ROOT")
		elif token.types.has(Token.Type.OBJECT_NAME):
			# The inputs are the objects
			var input = get_input(token.string, inputs)
			assert(is_instance_valid(input), "Can't find input with name: " + token.string)
			
			var new_child = ScriptTreeObject.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.FUNCTION_NAME):
			# Has to either be a built-in function or a function from another node
			var input
			input = get_input(token.string, inputs)
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
			
		elif token.types.has(Token.Type.PARAMETER):
			assert(working_st.type == ScriptTree.Type.FUNCTION or working_st.type == ScriptTree.Type.METHOD, "Parent of Script Tree Parameter isn't a function or method, parent is: " + str(working_st.type) + " with value: " + str(working_st.value))
			# Parameters are always objects
			
			var input = get_input(token.string, inputs)
			assert(is_instance_valid(input), "Can't find input with name: " + token.string)
			
			var new_child = ScriptTreeObject.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
	
	var tree_node_root: Tree = Tree.new()
	var tree_item_root: TreeItem = tree_node_root.create_item()
	add_child(tree_node_root)
	spell.actions = form_actions(tree_root, tree_item_root)
	return []


# Go down the built up ScriptTree with recursion and form the array of callable
func form_actions(working_st: ScriptTree, tree_item: TreeItem) -> Array[Callable]:
	var callable_list: Array[Callable] = []
	
	# Debugging
	print(working_st.type,"  ",working_st.value,"    HAS ",working_st.children.size()," CHILDREN: ")
	for child in working_st.children:
		print(child.type,"  ",child.value)
	print("END OF CHILDREN")
	
	# Go through each child and run this function on them, then get their array of callables and add it to the current one
	for child in working_st.children:
		print("STARTING WORK ON: ",child.type,"  ",child.value)
		var new_tree_item = tree_item.create_child()
		new_tree_item.set_text(0, str(working_st.type)+" | "+str(working_st.value))
		callable_list.append_array(form_actions(child, new_tree_item))
	
	## See if the current object and its parent match to a known function/method, if so, add it to the callable list
	# Spawn built-in function
	if working_st.type == ScriptTree.Type.OBJECT:
		if working_st.get_parent().type == ScriptTree.Type.FUNCTION:
			if working_st.get_parent().value == "spawn":
				callable_list.append(Callable(Functions, "spawn").bind(working_st.value))
				
	# Method on an object
	elif working_st.type == ScriptTree.Type.METHOD:
		if working_st.get_parent().type == ScriptTree.Type.OBJECT:
			callable_list.append(Callable(working_st.get_parent().value.get_output_node(), working_st.value))
			
	
	print("Callable list: " + str(callable_list))
	# Pass the callable list back up the tree
	return callable_list


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
			working_token = ""
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

func get_input(find_name: String, inputs: Array) -> NodeInput:
	for input in inputs:
		if input.get_name_field().strip_edges() == find_name.strip_edges():
			return input
	return null

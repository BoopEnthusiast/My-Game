class_name LangBuildScriptTree
extends Node
## External code for the Lang Singleton


## Loop through tokens and build out the Script Tree, returning the root node
func build_script_tree(tokenized_code: Array[Token], program_node: ProgramNode) -> ScriptTreeRoot:
	var inputs = program_node.inputs
	
	var tree_root = ScriptTreeRoot.new()
	var working_st: ScriptTree = tree_root # The current parent of the next token
	
	# Main loop
	# Almost all of the conditions ends with making a new ScriptTree object and adding it as a child of the working_st
	for token in tokenized_code:
		# Reset working_st back to the tree root, it's a new command
		if token.types.has(Token.Type.BREAK):
			working_st = tree_root
			
		# Keywords
		elif token.types.has(Token.Type.KEYWORD):
			match token.string: # TODO: Implement other keywords
				Lang.KEYWORDS[Lang.Keywords.RETURN]:
					var new_child = ScriptTreeFunction.new(working_st, "return")
					working_st.add_child(new_child)
					working_st = new_child
					
		# Objects
		# The inputs are the objects
		elif token.types.has(Token.Type.OBJECT_NAME):
			var input = _get_input(token.string, inputs)
			if not is_instance_valid(input):
				Lang.add_error("Can't find input with name: " + token.string, program_node, token.line)
				continue
			
			var new_child = ScriptTreeObject.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		# Function
		# Has to either be a built-in function or a function from another node
		elif token.types.has(Token.Type.FUNCTION_NAME):
			
			var function_name = _get_input(token.string, inputs)
			
			var function_names_index = Functions.FUNCTION_NAMES.find(token.string)
			if function_names_index < 0:
				Lang.add_error("Could not find function: " + token.string, program_node, token.line)
				continue
			
			function_name = Functions.FUNCTION_NAMES[function_names_index]
			if not typeof(function_name) == TYPE_STRING:
				Lang.add_error("Can't find function: " + token.string, program_node, token.line)
				continue
			
			var new_child = ScriptTreeFunction.new(working_st, function_name)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.METHOD_NAME):
			# Initial check
			if not working_st.type == ScriptTree.Type.OBJECT:
				Lang.add_error("Parent of Script Tree Method isn't an object, parent is: " + str(working_st.type), program_node, token.line)
				continue
			
			var new_child = ScriptTreeMethod.new(working_st, token.string.strip_edges())
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.PARAMETER):
			# Initial check
			if not working_st.type == ScriptTree.Type.FUNCTION or working_st.type == ScriptTree.Type.METHOD:
				Lang.add_error("Parent of Script Tree Parameter isn't a function or method, parent is: " + str(working_st.type) + " with value: " + str(working_st.value), program_node, token.line)
				continue
			
			var value
			if token.types.has(Token.Type.OBJECT_NAME):
				value = _get_input(token.string, inputs)
				if not is_instance_valid(value):
					Lang.add_error("Can't find input with name: " + token.string, program_node, token.line)
					continue
					
			elif token.types.has(Token.Type.EXPRESSION):
				# Execute the expression
				var expression = Expression.new()
				var error = expression.parse(token.string)
				if error != OK:
					Lang.add_error(expression.get_error_text(), program_node, token.line)
					continue
				value = expression.execute()
				
			elif token.types.has(Token.Type.STRING):
				value = token.string
			
			var new_child = ScriptTreeObject.new(working_st, value)
			working_st.add_child(new_child)
			
			working_st = new_child
			
	
	tree_root.parent = null
	return tree_root


## Checks all of the NodeInputs and checks against them for the name
func _get_input(find_name: String, inputs: Array) -> NodeInput:
	for input in inputs:
		if input.name_field.text.strip_edges() == find_name.strip_edges():
			return input
	return null

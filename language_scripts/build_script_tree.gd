class_name LangBuildScriptTree
extends Node
## External code for the Lang Singleton


## Loop through tokens and build out the Script Tree, returning the root node
func build_script_tree(tokenized_code: Array[Token], program_node: ProgramNode) -> ScriptTreeRoot:
	var inputs = program_node.inputs
	var tree_root = ScriptTreeRoot.new()
	var working_st: ScriptTree = tree_root
	
	for token in tokenized_code:
		if token.types.has(Token.Type.BREAK):
			working_st = tree_root
			print("SETTING TO TREE ROOT")
			
		elif token.types.has(Token.Type.KEYWORD):
			match token.string:
				Lang.KEYWORDS[Lang.Keywords.RETURN]:
					var new_child = ScriptTreeFunction.new(working_st, "return")
					working_st.add_child(new_child)
					working_st = new_child
			
		elif token.types.has(Token.Type.OBJECT_NAME):
			# The inputs are the objects
			var input = _get_input(token.string, inputs)
			if not is_instance_valid(input):
				Lang.add_error("Can't find input with name: " + token.string, program_node, token.line)
				continue
			
			var new_child = ScriptTreeObject.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.FUNCTION_NAME):
			# Has to either be a built-in function or a function from another node
			var input = _get_input(token.string, inputs)
			var function_names_index = Functions.FUNCTION_NAMES.find(token.string)
			if function_names_index < 0:
				Lang.add_error("Could not find function: " + token.string, program_node, token.line)
				continue
			input = Functions.FUNCTION_NAMES[function_names_index]
			if not is_instance_valid(input) and not typeof(input) == TYPE_STRING:
				Lang.add_error("Can't find input with name: " + token.string, program_node, token.line)
				continue
			
			var new_child = ScriptTreeFunction.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.METHOD_NAME):
			if not working_st.type == ScriptTree.Type.OBJECT:
				Lang.add_error("Parent of Script Tree Method isn't an object, parent is: " + str(working_st.type), program_node, token.line)
				continue
			var new_child = ScriptTreeMethod.new(working_st, token.string.strip_edges())
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.PARAMETER):
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


func _get_input(find_name: String, inputs: Array) -> NodeInput:
	for input in inputs:
		if input.name_field.text.strip_edges() == find_name.strip_edges():
			return input
	return null

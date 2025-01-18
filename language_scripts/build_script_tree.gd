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
			Lang.add_error(is_instance_valid(input), "Can't find input with name: " + token.string, program_node, token.line)
			
			var new_child = ScriptTreeObject.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.INT) or token.types.has(Token.Type.FLOAT):
			Lang.add_error(working_st.type == ScriptTree.Type.OPERATOR or working_st.type == ScriptTree.Type.FUNCTION, "Parent of Script Tree Int or Float isn't an object, parent is: " + str(working_st.type), program_node, token.line)
			
			var new_child = ScriptTreeData.new(working_st, float(token.string))
			working_st.add_child(new_child)
			working_st = new_child
			
		elif token.types.has(Token.Type.FUNCTION_NAME):
			# Has to either be a built-in function or a function from another node
			var input = _get_input(token.string, inputs)
			var function_names_index = Functions.FUNCTION_NAMES.find(token.string)
			Lang.add_error(function_names_index < 0, "Could not find function: " + token.string, program_node, token.line)
			if function_names_index < 0:
				continue
			input = Functions.FUNCTION_NAMES[function_names_index]
			Lang.add_error(is_instance_valid(input) or typeof(input) == TYPE_STRING, "Can't find input with name: " + token.string, program_node, token.line)
			
			var new_child = ScriptTreeFunction.new(working_st, input)
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.METHOD_NAME):
			Lang.add_error(working_st.type == ScriptTree.Type.OBJECT, "Parent of Script Tree Method isn't an object, parent is: " + str(working_st.type), program_node, token.line)
			var new_child = ScriptTreeMethod.new(working_st, token.string.strip_edges())
			working_st.add_child(new_child)
			
			working_st = new_child
			
		elif token.types.has(Token.Type.OPERATOR):
			# TODO: Implement BEDMAS
			Lang.add_error(working_st.type == ScriptTree.Type.OBJECT or working_st.type == ScriptTree.Type.DATA, "Parent of operator is not an object, parent is: " + str(working_st.type), program_node, token.line)
			var new_child = _replace_working_st(working_st, token.string)
			working_st = new_child
			
		elif token.types.has(Token.Type.PARAMETER):
			Lang.add_error(working_st.type == ScriptTree.Type.FUNCTION or working_st.type == ScriptTree.Type.METHOD, "Parent of Script Tree Parameter isn't a function or method, parent is: " + str(working_st.type) + " with value: " + str(working_st.value), program_node, token.line)
			
			var value
			if token.types.has(Token.Type.OBJECT_NAME):
				value = _get_input(token.string, inputs)
				Lang.add_error(is_instance_valid(value), "Can't find input with name: " + token.string, program_node, token.line)
			elif token.types.has(Token.Type.INT) or token.types.has(Token.Type.FLOAT):
				value = float(token.string)
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


func _replace_working_st(working_st: ScriptTree, token_string: String) -> ScriptTree:
	working_st.parent.children.erase(working_st)
	var new_child = ScriptTreeOperator.new(working_st.parent, token_string)
	working_st.parent.add_child(new_child)
	new_child.add_child(working_st)
	working_st.parent = new_child
	return new_child

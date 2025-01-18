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
			input = Functions.FUNCTION_NAMES[Functions.FUNCTION_NAMES.find(token.string)]
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
			# TODO: Implement BEDMAS
			assert(working_st.type == ScriptTree.Type.OBJECT or working_st.type == ScriptTree.Type.DATA, "Parent of operator is not an object, parent is: " + str(working_st.type))
			var new_child = _replace_working_st(working_st, token.string)
			working_st = new_child
			
		elif token.types.has(Token.Type.PARAMETER):
			assert(working_st.type == ScriptTree.Type.FUNCTION or working_st.type == ScriptTree.Type.METHOD, "Parent of Script Tree Parameter isn't a function or method, parent is: " + str(working_st.type) + " with value: " + str(working_st.value))
			# Parameters are always objects
			
			var value
			print("PARAMETER TOKEN TYPE: ", token.types)
			if token.types.has(Token.Type.OBJECT_NAME):
				value = _get_input(token.string, inputs)
				assert(is_instance_valid(value), "Can't find input with name: " + token.string)
			elif token.types.has(Token.Type.INT) or token.types.has(Token.Type.FLOAT):
				value = float(token.string)
			elif token.types.has(Token.Type.STRING):
				value = token.string
			
			var new_child = ScriptTreeObject.new(working_st, value)
			working_st.add_child(new_child)
			
			working_st = new_child
			
	
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

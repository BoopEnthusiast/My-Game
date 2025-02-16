class_name LangFormActions
extends Node
## External code for the Lang Singleton

## Go down the built up ScriptTree with recursion and form the array of callables
func form_actions(working_st: ScriptTree, tree_item: TreeItem) -> Array[Callable]:
	if not is_instance_valid(working_st):
		return []
	
	var callable_list: Array[Callable] = []
	
	# Debugging
	print(working_st.type,"  ",working_st.value,"    HAS ",working_st.children.size()," CHILDREN: ")
	for child in working_st.children:
		print(child.type,"  ",child.value)
	print("END OF CHILDREN")
	
	# Go through each child and run this function on them, then get their array of callables and add it to the current one
	for child in working_st.children:
		print("STARTING WORK ON: ",child.type,"  ",child.value,"    PARENTS TYPE IS: ",working_st.type) # Debug
		var new_tree_item = tree_item.create_child()
		new_tree_item.set_text(0, str(working_st.type)+" | "+str(working_st.value))
		callable_list.append_array(form_actions(child, new_tree_item))
	
	
	## Set current value for parents
	if working_st.type == ScriptTree.Type.OBJECT and working_st.children.size() > 0:
		if working_st.children[0].type == ScriptTree.Type.OBJECT and working_st.children[0].value is String:
			working_st.value = Functions.get_property(working_st.value, working_st.children[0].value)
	
	## See if the current object and its parent match to a known function/method, if so, add it to the callable list
	# Built-in functions and keywords
	if working_st.type == ScriptTree.Type.OBJECT or working_st.type == ScriptTree.Type.DATA or working_st.type == ScriptTree.Type.BOOL:
		# Keywords
		if working_st.parent.type == ScriptTree.Type.KEYWORD:
			match working_st.parent.value: # TODO: Implement more keywords
				Lang.KEYWORDS[Lang.Keywords.RETURN]:
					return working_st.value
		
		# Functions
		elif working_st.parent.type == ScriptTree.Type.FUNCTION:
			match working_st.parent.value:
				"spawn":
					callable_list.append(Callable(Functions, "spawn").bind(working_st.value))
				"print":
					callable_list.append(Callable(Functions, "pprint").bind(working_st.value))
				"wait":
					callable_list.append(Callable(Functions, "wait").bind(working_st.value))
				"call":
					callable_list.append_array(Lang.compile_program_node(working_st.value.get_connected_node()))
				
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
				
	
	print("Callable list: " + str(callable_list)) # Debug
	# Pass the callable list back up the tree
	return callable_list

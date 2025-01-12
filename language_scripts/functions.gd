extends Node


## Spawn a primitive object
func spawn(input: NodeInput) -> void:
	var node = input.get_output_node()
	if node is PrimitiveNode:
		node.spawn()


## Prints to the console in the Godot editor
func pprint(to_print: Variant) -> void:
	print(to_print)

class_name NodeInput
extends NodeIOPort


func get_output_node() -> NodeBase:
	return get_connected_node()

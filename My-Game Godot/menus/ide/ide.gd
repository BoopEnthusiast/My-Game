extends Control


var ide_holder: IDEHolder

var connecting_from: NodeIOPort


func connect_nodes(connecting_to: NodeIOPort) -> void:
	assert(not connecting_from.is_class(connecting_to.get_class()), "Input is connecting to input or output is connecting to output")

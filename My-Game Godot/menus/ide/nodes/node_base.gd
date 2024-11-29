class_name NodeBase 
extends Control


const MAX_INPUTS: int = 1
const MAX_OUTPUTS: int = 1


var input_connections: Array[Connector]
var output_connections: Array[Connector]


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("I've been clicked D:")

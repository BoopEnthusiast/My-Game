# This class holds all of the information for a given spell for when it'll be cast
class_name Spell
extends Resource


var start_node: StartNode
var object_dict: Dictionary = {}
var actions: Array[Callable] = []

var _working_objects: Array = []


func cast() -> void:
	for action in actions:
		action.call()

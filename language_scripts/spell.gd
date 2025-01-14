# This class holds all of the information for a given spell for when it'll be cast
class_name Spell
extends Resource


var start_node: StartNode
var object_dict: Dictionary = {}
var actions: Array[Callable] = []


func cast() -> void:
	for action in actions:
		await action.call()

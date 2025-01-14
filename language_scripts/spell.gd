# This class holds all of the information for a given spell for when it'll be cast
class_name Spell
extends Resource


var start_node: StartNode
var object_dict: Dictionary = {}
var actions: Array[Callable] = []
var threads: Array[Thread] = []


func cast() -> void:
	var new_thread = Thread.new()
	threads.append(new_thread)
	new_thread.start(Callable(loop_through_actions).bind(new_thread))


func loop_through_actions(thread: Thread) -> void:
	for action in actions:
		if action.get_method() == "wait":
			OS.delay_msec(action.call())
		else:
			action.call_deferred()

# This class holds all of the information for a given spell for when it'll be cast
class_name Spell
extends Object


var start_node: StartNode
var object_dict: Dictionary = {}
var actions: Array[Callable] = []
var action_args: Array = []
var working_objects: Array = []


func cast() -> void:
	print(actions,"\n",action_args)
	for i in range(actions.size()):
		actions[i].call(action_args[i])


func spawn_ball(name: String) -> void:
	var new_ball = Lang.BALL.instantiate()
	print("making fireball: ",name)
	object_dict[name] = new_ball
	print(object_dict)
	new_ball.ball_name = name
	Singleton.world_root.add_child(new_ball)


func find_object(name: String) -> void:
	print(object_dict)
	working_objects.push_front(object_dict[name])


func apply_effect(effect: Lang.Effects) -> void:
	var object = working_objects.pop_front()
	if effect == Lang.Effects.PUSH:
		if object is Ball:
			object.push()

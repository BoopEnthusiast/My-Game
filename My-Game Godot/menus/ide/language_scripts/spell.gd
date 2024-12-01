# This class holds all of the information for a given spell for when it'll be cast
class_name Spell
extends Object


var start_node: StartNode
var object_dict: Dictionary = {}
var actions: Array[Callable] = []
var action_args: Array = []
var working_objects: Array = []


func cast() -> void:
	for i in range(actions.size()):
		actions[i].call(action_args[i])


func spawn_ball(name: String) -> void:
	var new_ball = Lang.BALL.instantiate()
	object_dict[name] = new_ball
	new_ball.ball_name = name
	new_ball.global_position = Singleton.player.main_camera.global_position + -Singleton.player.main_camera.global_transform.basis.z * 3.0
	Singleton.world_root.add_child(new_ball)


func find_object(name: String) -> void:
	working_objects.push_front(object_dict[name])


# Pass in two values to the array: the effect from Lang.Effects and the modifier of that effect which should be a float
func apply_effect(effect_and_strength: Array) -> void:
	var effect: Lang.Effects = effect_and_strength[0]
	var strength: float = effect_and_strength[1]
	var object = working_objects.pop_front()
	if effect == Lang.Effects.PUSH:
		if object is Ball:
			object.push()

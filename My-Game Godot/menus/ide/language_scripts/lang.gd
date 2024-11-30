# Holds all of the callables that a spell can cast and parses each spell
extends Node


const BALL = preload("res://menus/ide/spawnables/ball.tscn")

enum WaitingFor {
	SPAWN,
	NAME,
	APPLY_EFFECT,
}
enum Effects {
	PUSH
}

var spells: Array[Spell] = []


func compile_spell(start_node: StartNode) -> void:
	var new_spell = Spell.new()
	new_spell.start_node = start_node
	var connected_node = start_node.outputs[0].get_connected_node()
	if connected_node is ProgramNode:
		var parsed_code = compile_program_node(new_spell, connected_node.code_edit.text)
		parsed_code[0].reverse()
		parsed_code[1].reverse()
		new_spell.actions.append_array(parsed_code[0])
		new_spell.action_args.append_array((parsed_code[1]))
	spells.append(new_spell)
	IDE.current_spell = new_spell


func add_error(error_text: String = "Unspecified error...", line: int = -1) -> void:
	pass


# Returns two arrays: the action list (callables) and the arguments for the actions (variants)
func compile_program_node(spell: Spell, text: String) -> Array[Array]:
	var action_list: Array[Callable] = []
	var action_args: Array = []
	var code = text.split(" ")
	var waiting_for_stack: Array[WaitingFor] = []
	var store_name: String
	var i = 0
	for token in code:
		token = token.strip_edges()
		if not waiting_for_stack.is_empty():
			if waiting_for_stack.front() == WaitingFor.NAME:
				store_name = token
				waiting_for_stack.pop_front()
			elif waiting_for_stack.front() == WaitingFor.SPAWN:
				if token == "ball":
					action_list.push_front(spell.spawn_ball)
					action_args.push_front(store_name)
					waiting_for_stack.pop_front()
				else:
					add_error("Unknown spawnable object")
			elif waiting_for_stack.front() == WaitingFor.APPLY_EFFECT:
				if token == "push":
					action_list.push_front(spell.apply_effect)
					action_args.push_front(Effects.PUSH)
				else:
					add_error("Uknown effect")
		elif token == "spawn":
			waiting_for_stack.push_front(WaitingFor.SPAWN)
			waiting_for_stack.push_front(WaitingFor.NAME)
		else:
			action_list.push_front(spell.find_object)
			action_args.push_front(token)
			waiting_for_stack.push_front(WaitingFor.APPLY_EFFECT)
		i += 1
	return [action_list, action_args]

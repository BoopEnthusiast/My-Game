extends Node
## Library of functions for spells to call, these are not methods


## Spawn a primitive object
func spawn(input: NodeInput) -> void:
	var node = input.get_output_node()
	if node is PrimitiveNode:
		Singleton.book_hands.book_display.spell_name_label.text = "Spawn"
		Singleton.book_hands.spell_animations.play("spawn")
		await Singleton.book_hands.spell_animations.animation_finished
		node.spawn()


## Prints to the console in the Godot editor
func pprint(to_print: Variant) -> void:
	Singleton.book_hands.book_display.spell_name_label.text = "Print"
	Singleton.book_hands.spell_animations.play("print")
	await Singleton.book_hands.spell_animations.animation_finished
	print(str(to_print))
	Singleton.print_label.text = to_print


func wait(time_to_wait: float) -> void:
	Singleton.book_hands.book_display.spell_name_label.text = "Wait"
	Singleton.book_hands.set_wait_time(time_to_wait)
	Singleton.book_hands.spell_animations.play("wait")
	await Singleton.book_hands.spell_animations.animation_finished

extends Node
## Library of functions for spells to call, these are not methods
const FUNCTION_NAMES: Array[String] = [
	"spawn",
	"print",
	"wait",
	"call",
]
const FUNCTION_INFO: Dictionary = {
	"spawn": "spawn(input_name) takes the name of the input connected to a Primitive node and spawns the selected primitive"
}


## Not a global function, internal to the language. Gets the value of a property from the connected node of the input
func get_property(input: NodeInput, property: String) -> Variant:
	var node: NodeBase = input.get_output_node()
	if not is_instance_valid(node):
		Lang.add_error("Could not find node connected to: " + input.name_field.text)
		return null
	
	var found_property: bool = false
	for node_property: Dictionary in node.get_property_list():
		if node_property["name"] == "properties":
			found_property = true
			break
	if not found_property:
		print(node.get_property_list())
		Lang.add_error("Could not get any properties on node connected to input: " + input.name_field.text)
		return null
	
	node.update_properties()
	return node.properties[property]


## Spawn a primitive object
func spawn(input: NodeInput) -> void:
	var node = input.get_output_node()
	if node is PrimitiveNode:
		Singleton.book_hands.play_spell("Spawn", "spawn")
		await Singleton.book_hands.spell_animations.animation_finished
		node.spawn()
	elif node is ProgramNode:
		var returned_value = Lang.compile_program_node(node)
		Singleton.book_hands.play_spell("Spawn", "spawn")
		await Singleton.book_hands.spell_animations.animation_finished
		returned_value.spawn()
	else:
		Lang.add_error("Could not find Program node or Primitive when spawning")


## Prints to the console in the Godot editor # has to be called pprint behind the scenes because print already exists in gdscript
func pprint(to_print: Variant) -> void:
	Singleton.book_hands.play_spell("Print", "print")
	await Singleton.book_hands.spell_animations.animation_finished
	print(str(to_print))
	Singleton.print_label.text = str(to_print)


## Waits for the given times, like sleep(number) in other languages # might rename to sleep... 
func wait(time_to_wait: float) -> void:
	Singleton.book_hands.play_spell("Wait", "wait")
	Singleton.book_hands.set_wait_time(time_to_wait)
	await Singleton.book_hands.spell_animations.animation_finished

class_name PrimitiveNode
extends NodeBase


enum Primitives {
	BALL,
	CUBE
}

const PRIMITIVES = [
	preload("res://spawnables/primitive_ball.tscn"),
	preload("res://spawnables/primitive_cube.tscn")
]

var selected_primitive: Primitives = Primitives.BALL
var spawned_object: PrimitiveSpawnable

var properties: Dictionary = {
	"distance": 0.0
}


func _on_option_button_item_selected(index: int) -> void:
	selected_primitive = index as Primitives


func spawn() -> void:
	var new_primitive: PrimitiveSpawnable = PRIMITIVES[int(selected_primitive)].instantiate()
	Singleton.world_root.add_child(new_primitive)
	new_primitive.global_position = Singleton.player.main_camera.global_position - Singleton.player.camera_rotation_node.global_basis.z * 2.0
	spawned_object = new_primitive


func transmute(transmute_node: NodeInput) -> void:
	Singleton.book_hands.book_display.spell_name_label.text = "Transmute"
	Singleton.book_hands.spell_animations.play("transmute")
	await Singleton.book_hands.spell_animations.animation_finished
	
	if is_instance_valid(spawned_object):
		match transmute_node.get_output_node().selected_transmutation:
			TransmuteNode.Transmutations.FIRE:
				spawned_object.mesh.set_surface_override_material(0, spawned_object.fire_material)
			TransmuteNode.Transmutations.WATER:
				spawned_object.mesh.set_surface_override_material(0, spawned_object.water_material)


func push() -> void:
	Singleton.book_hands.book_display.spell_name_label.text = "Push"
	Singleton.book_hands.spell_animations.play("print")
	await Singleton.book_hands.spell_animations.animation_finished
	
	if is_instance_valid(spawned_object):
		spawned_object.velocity += -spawned_object.global_position.direction_to(Singleton.player.main_camera.global_position)


func update_properties() -> void:
	if is_instance_valid(spawned_object):
		properties["distance"] = Singleton.player.global_position.distance_to(spawned_object.global_position)

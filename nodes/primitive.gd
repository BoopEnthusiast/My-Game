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


func _on_option_button_item_selected(index: int) -> void:
	selected_primitive = index as Primitives


func spawn() -> void:
	var new_primitive: PrimitiveSpawnable
	match selected_primitive:
		Primitives.BALL:
			new_primitive = PRIMITIVES[0].instantiate()
		Primitives.CUBE:
			new_primitive = PRIMITIVES[1].instantiate()
	
	Singleton.world_root.add_child(new_primitive)
	new_primitive.global_position = Singleton.player.main_camera.global_position - Singleton.player.camera_rotation_node.global_basis.z * 2.0
	spawned_object = new_primitive


func set_on_fire() -> void:
	spawned_object.mesh.set_surface_override_material(0, spawned_object.fire_material)


func transmute(transmute_node: NodeInput) -> void:
	
	var type = transmute_node.get_output_node().selected_transmutation
	
	match type:
		TransmuteNode.Transmutations.FIRE:
			spawned_object.mesh.set_surface_override_material(0, spawned_object.fire_material)
		TransmuteNode.Transmutations.WATER:
			spawned_object.mesh.set_surface_override_material(0, spawned_object.water_material)


func push() -> void:
	spawned_object.velocity += -spawned_object.global_position.direction_to(Singleton.player.main_camera.global_position)

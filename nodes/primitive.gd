class_name PrimitiveNode
extends NodeBase


enum Primitives {
	BALL
}
enum Transmutations {
	FIRE,
	WATER
}

const PRIMITIVES = [
	preload("res://spawnables/primitive_ball.tscn")
]

var selected_primitive: Primitives = Primitives.BALL
var is_on_fire: bool = false
var spawned_object: PrimitiveSpawnable


func _on_option_button_item_selected(index: int) -> void:
	selected_primitive = index as Primitives


func spawn() -> void:
	match selected_primitive:
		Primitives.BALL:
			var new_ball = PRIMITIVES[0].instantiate()
			Singleton.world_root.add_child(new_ball)
			new_ball.global_position = Singleton.player.main_camera.global_position - Singleton.player.camera_rotation_node.global_basis.z * 2.0
			spawned_object = new_ball


func set_on_fire() -> void:
	spawned_object.mesh.set_surface_override_material(0, spawned_object.fire_material)


func transmute(type: Transmutations) -> void:
	match type:
		Transmutations.FIRE:
			spawned_object.mesh.set_surface_override_material(0, spawned_object.fire_material)
		Transmutations.WATER:
			spawned_object.mesh.set_surface_override_material(0, spawned_object.water_material)


func push() -> void:
	spawned_object.velocity += -spawned_object.global_position.direction_to(Singleton.player.main_camera.global_position)

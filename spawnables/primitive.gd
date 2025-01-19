class_name PrimitiveSpawnable
extends Node3D


@export var body: PhysicsBody3D
@export var mesh: MeshInstance3D
@export var fire_material: ShaderMaterial
@export var water_material: ShaderMaterial

var velocity: Vector3


func _physics_process(delta: float) -> void:
	body.move_and_collide(velocity * delta)


func _on_lifetime_timeout() -> void:
	queue_free()

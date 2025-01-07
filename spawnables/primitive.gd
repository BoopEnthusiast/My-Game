class_name PrimitiveSpawnable
extends Node3D


@export var body: CollisionObject3D
@export var mesh: MeshInstance3D
@export var fire_material: ShaderMaterial

var velocity: Vector3
var is_on_fire := false


func _physics_process(delta: float) -> void:
	position += velocity * delta

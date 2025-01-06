class_name PrimitiveSpawnable
extends Node3D


@export var body: CollisionObject3D
@export var mesh: MeshInstance3D
@export var mat: ShaderMaterial

var velocity: Vector3
var is_on_fire := false


func _ready() -> void:
	mesh.set_surface_override_material(0, mat)


func _physics_process(delta: float) -> void:
	position += velocity * delta

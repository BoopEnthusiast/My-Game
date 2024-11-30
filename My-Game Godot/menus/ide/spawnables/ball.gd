class_name Ball
extends AnimatableBody3D


var ball_name: String
var velocity: Vector3


func push() -> void:
	velocity = global_position.direction_to(Singleton.player.global_position) * 30.0


func _physics_process(delta: float) -> void:
	position += velocity * delta

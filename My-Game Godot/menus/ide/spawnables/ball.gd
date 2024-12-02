class_name Ball
extends AnimatableBody3D


var ball_name: String
var velocity := Vector3.ZERO


func push(strength: float) -> void:
	velocity += -global_position.direction_to(Singleton.player.main_camera.global_position) * strength


func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_lifetime_timeout() -> void:
	queue_free()

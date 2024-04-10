extends AnimatableBody3D

const INHERITS_FROM: StringName = "TObject"
const CLASS_NAME: StringName = "Fireball"

func _physics_process(_delta):
	if move_and_collide(basis.z) is KinematicCollision3D:
		queue_free()


func _on_timeout():
	queue_free()


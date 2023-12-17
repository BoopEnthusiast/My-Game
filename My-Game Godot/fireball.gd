extends AnimatableBody3D
class_name Fireball

func _physics_process(_delta):
	if move_and_collide(basis.z) is KinematicCollision3D:
		queue_free()


func _on_timeout():
	queue_free()

class_name Player 
extends CharacterBody3D


const SPEED = 5.0
const _JUMP_VELOCITY = 4.5

# Get relevant nodes
@onready var main_camera: Camera3D = $Camera
@onready var camera_rotation_node: Node3D = $Camera/CameraRotation

# The camera's basis.z 
var camera_rotation: Vector3

var _camera_rotation := Vector2(0, 0)
var _mouse_sensitivity := 0.003

var stop_movement := false


func _enter_tree() -> void:
	Singleton.player = self


func _ready() -> void:
	main_camera.rotation = Basis().y
	
	MenuHandler.unpause_game()
	MenuHandler.stop_code_editing()


func _input(event) -> void:
	# Get the mouse movement
	if event is InputEventMouseMotion and not stop_movement:
		# Get how much the mouse has moved and pass it onto the camera_look function
		var relative_position = event.relative * _mouse_sensitivity
		camera_look(relative_position)


# Rotate the camera
func camera_look(movement: Vector2) -> void:
	# Add how much the camera has moved to the camera rotation
	_camera_rotation += movement 
	# Stop the player from making the camera go upside down by looking too far up and down
	_camera_rotation.y = clamp(_camera_rotation.y, deg_to_rad(-90), deg_to_rad(90)) 
	
	# Reset the transform basis
	transform.basis = Basis()
	main_camera.transform.basis = Basis()
	
	# Finally rotate the object, the player and camera needs to rotate on the x and only the camera should rotate on the y
	rotate_object_local(Vector3.UP, -_camera_rotation.x)
	main_camera.rotate_object_local(Vector3.RIGHT, -_camera_rotation.y)
	
	camera_rotation = -main_camera.global_transform.basis.z


func _physics_process(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not stop_movement:
		velocity.y = _JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and not stop_movement:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("fire") and not stop_movement:
		if is_instance_valid(IDE.current_spell):
			IDE.current_spell.cast()

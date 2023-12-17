extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Get relevant nodes
@onready var main_camera := $Camera
@onready var base_menu := $Menu

var camera_rotation = Vector2(0, 0)
var mouse_sensitivity := 0.005

var fireball = preload("res://fireball.tscn")

func _ready() -> void:
	# Remove the mouse from the screen and just capture its movement
	unpause_game()


func _input(event) -> void:
	# If escape is pressed pause the game
	if event.is_action_pressed("ui_cancel"):
		pause_game()
	
	# Get the mouse movement
	if event is InputEventMouseMotion:
		# Get how much the mouse has moved and pass it onto the camera_look function
		var relative_position = event.relative * mouse_sensitivity
		camera_look(relative_position)
	
	if event.is_action_pressed("fire"):
		var new_fireball: Fireball = fireball.instantiate()
		get_parent().add_child(new_fireball)
		new_fireball.global_position = main_camera.global_position
		new_fireball.position.y -= 0.5
		new_fireball.rotation.x = -main_camera.rotation.x
		new_fireball.rotation.y = rotation.y - PI

# Rotate the camera
func camera_look(movement: Vector2) -> void:
	# Add how much the camera has moved to the camera rotation
	camera_rotation += movement 
	# Stop the player from making the camera go upside down by looking too far up and down
	camera_rotation.y = clamp(camera_rotation.y, deg_to_rad(-90), deg_to_rad(90)) 
	
	# Reset the transform basis
	transform.basis = Basis()
	main_camera.transform.basis = Basis()
	
	# Finally rotate the object, the player and camera needs to rotate on the x and only the camera should rotate on the y
	rotate_object_local(Vector3.UP, -camera_rotation.x)
	main_camera.rotate_object_local(Vector3.RIGHT, -camera_rotation.y)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func pause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	base_menu.visible = true
	base_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true


func unpause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	base_menu.visible = false
	base_menu.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false


func quit_game():
	get_tree().quit()

extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Get relevant nodes
@onready var main_camera: Camera3D = $Camera
@onready var pause_menu: VBoxContainer = $Menu/PauseMenu
@onready var ide: Control = $Menu/IDE

var camera_rotation := Vector2(0, 0)
var mouse_sensitivity := 0.003

var in_menu := false

#var fireball: PackedScene = preload("res://fireball.tscn")

func _ready() -> void:
	main_camera.rotation = Basis().y
	
	unpause_game()
	end_code_editing()


func _input(event) -> void:
	# If escape is pressed pause the game
	if event.is_action_pressed("ui_cancel"):
		pause_game()
	
	if event.is_action_pressed("start_coding"):
		start_code_editing()
	
	# Get the mouse movement
	if event is InputEventMouseMotion:
		# Get how much the mouse has moved and pass it onto the camera_look function
		var relative_position = event.relative * mouse_sensitivity
		camera_look(relative_position)
	
	#if event.is_action_pressed("fire"):
		#var new_fireball: Fireball = fireball.instantiate()
		#get_object_parent().add_child(new_fireball)
		#new_fireball.global_position = main_camera.global_position
		#new_fireball.position.y -= 0.5
		#new_fireball.rotation.x = -main_camera.rotation.x
		#new_fireball.rotation.y = rotation.y - PI

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


func _physics_process(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not in_menu:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and not in_menu:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func pause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_menu.visible = true
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true


func unpause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false


func start_code_editing() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_process_input(false)
	ide.visible = true
	ide.process_mode = Node.PROCESS_MODE_ALWAYS
	in_menu = true


func end_code_editing() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	ide.visible = false
	ide.process_mode = Node.PROCESS_MODE_DISABLED
	in_menu = false


func quit_game() -> void:
	get_tree().quit()

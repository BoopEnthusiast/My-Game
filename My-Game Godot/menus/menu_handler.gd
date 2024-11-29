extends Node


var pause_menu: PauseMenu


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		MenuHandler.pause_game()
	
	elif event.is_action_pressed("start_coding") and not IDE.ide_holder.visible:
		MenuHandler.start_code_editing()
		print("start")
		IDE.code_start_input_released = false
	
	if event.is_action_released("start_coding"):
		print("released")
		IDE.code_start_input_released = true


func pause_game() -> void:
	assert(pause_menu, "Could not find pause menu")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_menu.visible = true
	get_tree().paused = true


func unpause_game() -> void:
	assert(pause_menu, "Could not find pause menu")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.visible = false
	get_tree().paused = false


func start_code_editing() -> void:
	assert(IDE.ide_holder, "Could not find IDE holder")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_process_input(false)
	IDE.ide_holder.visible = true


func end_code_editing() -> void:
	assert(IDE.ide_holder, "Could not find IDE holder")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	IDE.ide_holder.visible = false

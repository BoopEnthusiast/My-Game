extends Node


var ide_holder: IDEHolder
var code_start_input_released := false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("start_coding") and code_start_input_released:
		print("stop")
		MenuHandler.end_code_editing()

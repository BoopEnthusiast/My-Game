class_name PauseMenu 
extends VBoxContainer


func _enter_tree() -> void:
	MenuHandler.pause_menu = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		MenuHandler.unpause_game()


func _on_resume_pressed() -> void:
	MenuHandler.unpause_game()


func _on_quit_pressed() -> void:
	get_tree().quit()

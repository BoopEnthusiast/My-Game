extends Control

const TEST_LEVEL = preload("res://world/test_level.tscn")

func _on_start():
	get_tree().change_scene_to_packed(TEST_LEVEL)

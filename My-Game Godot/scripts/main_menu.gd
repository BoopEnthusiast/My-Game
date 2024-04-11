extends Control

var start_scene: PackedScene = "res://scenes/test_level.tscn"

func _on_start():
	get_tree().change_scene_to_packed(start_scene)

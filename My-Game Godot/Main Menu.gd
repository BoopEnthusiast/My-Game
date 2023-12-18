extends Control

var start_scene: PackedScene = preload("res://Test Level.tscn")

func _on_start():
	get_tree().change_scene_to_packed(start_scene)

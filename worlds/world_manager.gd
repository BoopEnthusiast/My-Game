class_name WorldManager
extends Node


var mouse_captured: bool = false

@onready var node_graph: Control = $NodeGraph


func _enter_tree() -> void:
	Nodes.world_manager = self


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		if mouse_captured:
			release_mouse()
		else:
			capture_mouse()
	
	if Input.is_action_just_pressed(&"open_code"):
		if get_tree().paused:
			get_tree().paused = false
			node_graph.visible = false
		else:
			get_tree().paused = true
			node_graph.visible = true


func _ready() -> void:
	capture_mouse()


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

class_name BookHands
extends Node3D


@onready var directional_light: DirectionalLight3D = $DirectionalLight
@onready var book_display: BookDisplay = $SubViewport/BookDisplay
@onready var spell_animations: AnimationPlayer = $SpellAnimations


func _enter_tree() -> void:
	Singleton.book_hands = self


func _process(_delta: float) -> void:
	var directional_light_rotation = directional_light.global_rotation
	global_rotation = Vector3(-Singleton.player.camera_rotation_node.global_rotation.x, Singleton.player.camera_rotation_node.global_rotation.y, Singleton.player.camera_rotation_node.global_rotation.z)
	directional_light.global_rotation = directional_light_rotation

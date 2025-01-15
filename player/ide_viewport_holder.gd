class_name IDEViewportHolder
extends Control


var is_dragging := false
var camera_offset := Vector2.ZERO
var last_mouse_position := Vector2.ZERO
var zoom_level := 1.0

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var ide: Control = $SubViewportContainer/IDEViewport/IDE


func _enter_tree() -> void:
	IDE.ide_holder = self


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_dragging:
		camera_offset += event.position - last_mouse_position
		last_mouse_position = event.position
		_update_view()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
			is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var old_zoom = zoom_level
			zoom_level = min(zoom_level * 1.1, 2.0)
			camera_offset -= event.position / old_zoom - event.position / zoom_level
			_update_view()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var old_zoom = zoom_level
			zoom_level = max(zoom_level * 0.9, 0.5)
			camera_offset -= event.position / old_zoom - event.position / zoom_level
			_update_view()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
		is_dragging = true
		last_mouse_position = event.position
		IDE.stop_connecting()


func _update_view() -> void:
	sub_viewport_container.scale = Vector2.ONE * zoom_level
	sub_viewport_container.position = camera_offset

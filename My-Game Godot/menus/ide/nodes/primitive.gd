extends NodeBase


enum Primitives {
	BALL
}

var selected_primitive: Primitives = Primitives.BALL
var is_on_fire: bool = false


func _on_option_button_item_selected(index: int) -> void:
	selected_primitive = index


func set_on_fire() -> void:
	pass

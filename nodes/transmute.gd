class_name TransmuteNode
extends NodeBase


enum Transmutations {
	FIRE,
	WATER
}

var selected_transmutation: Transmutations = Transmutations.FIRE


func _on_select_transmutation_item_selected(index: int) -> void:
	selected_transmutation = index as Transmutations

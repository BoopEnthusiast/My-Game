class_name PrintLabel
extends Label


func _enter_tree() -> void:
	Singleton.print_label = self

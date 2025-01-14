class_name BookDisplay
extends Control


@onready var spell_name_label: Label = $SpellName
@onready var progress_bar: ProgressBar = $ProgressBar

@export_range(0.0, 1.0) var progress: float = 0.0


func _process(_delta: float) -> void:
	progress_bar.value = progress

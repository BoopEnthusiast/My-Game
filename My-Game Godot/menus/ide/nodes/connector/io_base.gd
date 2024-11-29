class_name NodeIOPort 
extends HBoxContainer


@onready var name_field: TextEdit = $NameField
@onready var button: Button = $Button

var variable_name: String


func _on_button_pressed() -> void:
	if not IDE.connecting_from is NodeOutput:
		IDE.start_connecting(self)
	else:
		IDE.connect_nodes(self)


func _on_name_field_text_changed() -> void:
	if name_field.text.length() > 50:
		name_field.text = variable_name
	while name_field.text.find("\n") >= 0:
		name_field.text[name_field.text.find("\n")] = ""
	variable_name = name_field.text

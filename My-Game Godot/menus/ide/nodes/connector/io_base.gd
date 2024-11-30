class_name NodeIOPort 
extends HBoxContainer


@onready var name_field: TextEdit = $NameField
@onready var button: Button = $Button
@onready var parent_node: NodeBase = $"../../../"

var connector: Connector

var variable_name: String


func _on_button_down() -> void:
	if is_instance_valid(connector):
		connector.queue_free()
		IDE.stop_connecting()
	elif not is_instance_valid(IDE.connecting_from):
		IDE.start_connecting(self)
	elif parent_node != IDE.connecting_from.parent_node and _check_class():
		IDE.connect_nodes(self)


func _on_name_field_text_changed() -> void:
	if name_field.text.length() > 50:
		name_field.text = variable_name
	while name_field.text.find("\n") >= 0:
		name_field.text[name_field.text.find("\n")] = ""
	variable_name = name_field.text


func _check_class() -> bool:
	if self is NodeInput:
		if IDE.connecting_from is NodeOutput:
			return true
		else:
			return false
	else:
		if IDE.connecting_from is NodeInput:
			return true
		else:
			return false


func get_connected_node() -> NodeBase:
	if self is NodeInput:
		return connector.output.parent_node
	else:
		return connector.input.parent_node

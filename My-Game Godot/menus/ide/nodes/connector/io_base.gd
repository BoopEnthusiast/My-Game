class_name NodeIOPort 
extends HBoxContainer


@onready var button: Button = $Button
@onready var parent_node: NodeBase = $"../../../"

@onready var _name_field: TextEdit = $NameField

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


func _on__name_field_text_changed() -> void:
	var text = _name_field.text
	if text.length() > 50:
		text = variable_name
	while text.find("\n") >= 0:
		text[text.find("\n")] = ""
	variable_name = text
	_name_field.text = text


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


func get_name_field() -> String:
	return _name_field.text

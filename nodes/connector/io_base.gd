class_name NodeIOPort 
extends HBoxContainer


@onready var button: Button = $Button
@onready var parent_node: NodeBase = $"../../../"

@onready var name_field: LineEdit = $NameField

var connector: Connector

var variable_name: String


func _on_button_down() -> void:
	if is_instance_valid(connector) and not IDE.is_connecting:
		connector.queue_free()
		IDE.stop_connecting()
	elif not is_instance_valid(IDE.connecting_from) and not IDE.is_connecting:
		print("IO Start connection")
		IDE.start_connecting(self)
	elif parent_node != IDE.connecting_from.parent_node and _check_class() and not is_instance_valid(connector):
		IDE.connect_nodes(self)


func _on_name_field_text_changed() -> void:
	var caret_col = name_field.get_caret_column()
	var text = name_field.text
	if text.length() > 50:
		text = variable_name
	while text.find("\n") >= 0:
		text[text.find("\n")] = ""
	variable_name = text
	name_field.text = text
	name_field.set_caret_column(caret_col)


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

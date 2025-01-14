extends Control


const CONNECTOR = preload("res://nodes/connector/connector.tscn")

var ide_holder: IDEHolder
var start_node_tree: Tree

var connecting_from: NodeIOPort
var connector: Connector
var is_connecting: bool = false

var current_spell: Spell


func start_connecting(connect_from: NodeIOPort) -> void:
	is_connecting = true
	var new_connector = CONNECTOR.instantiate()
	connecting_from = connect_from
	if connect_from is NodeInput:
		new_connector.input = connect_from
	else:
		new_connector.output = connect_from
	ide_holder.add_child(new_connector, true)
	connect_from.connector = new_connector
	connector = new_connector


func stop_connecting() -> void:
	is_connecting = false
	connecting_from = null
	if is_instance_valid(connector):
		connector.queue_free()


func connect_nodes(connecting_to: NodeIOPort) -> void:
	assert(connecting_from.is_class(connecting_to.get_class()), "Input is connecting to input or output is connecting to output")
	if connecting_from is NodeInput:
		connector.output = connecting_to
	else:
		connector.input = connecting_to
	connecting_to.connector = connector
	connecting_from = null
	connector = null
	is_connecting = false

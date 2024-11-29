extends Control


const CONNECTOR = preload("res://menus/ide/nodes/connector/connector.tscn")

var ide_holder: IDEHolder

var connecting_from: NodeIOPort
var connector: Connector


func start_connecting(connect_from: NodeIOPort) -> void:
	connecting_from = connect_from
	connector = CONNECTOR.instantiate()
	if connecting_from is NodeInput:
		connector.input = connecting_from
	else:
		connector.output = connecting_from
	ide_holder.add_child(connector)
	connecting_from.connector = connector


func stop_connecting() -> void:
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

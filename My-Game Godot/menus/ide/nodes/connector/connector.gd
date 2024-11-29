class_name Connector 
extends Path2D


var input: NodeBase
var output: NodeBase


func _draw() -> void:
	draw_polyline(curve.get_baked_points(), Color.HONEYDEW, 3.0, true)


func _process(_delta: float) -> void:
	if is_visible_in_tree():
		queue_redraw()

class_name Connector 
extends Path2D


var input: NodeInput
var output: NodeOutput


func _ready() -> void:
	curve = curve.duplicate()
	while curve.point_count < 2:
		curve.add_point(Vector2.ZERO)


func _draw() -> void:
	if curve.get_baked_points().size() > 1:
		draw_polyline(curve.get_baked_points(), Color.HONEYDEW, 3.0, true)


func _process(_delta: float) -> void:
	if not output or not input:
		var first: NodeIOPort = input
		if output and not input:
			first = output
		curve.set_point_position(0, first.button.global_position + first.button.size / 2)
		curve.set_point_position(1, get_global_mouse_position())
		set_mid_points()
	else:
		curve.set_point_position(0, input.button.global_position + input.button.size / 2)
		curve.set_point_position(1, output.button.global_position + output.button.size / 2)
		set_mid_points()
	
	if is_visible_in_tree():
		queue_redraw()


func set_mid_points() -> void:
	var mid_x_pos =  Vector2((curve.get_point_position(1).x - curve.get_point_position(0).x) / 2, 0)
	curve.set_point_out(0, mid_x_pos)
	curve.set_point_in(1, -mid_x_pos)

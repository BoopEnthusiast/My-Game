extends VSplitContainer

var active_tab: int = 0

func _on_tab_selected(tab):
	get_child(active_tab + 1).visible = false
	get_child(tab + 1).visible = true
	active_tab = tab

extends Node
class_name FocusParentOnReady

var parent : Control

func _ready() -> void:
	parent = get_parent() as Control
	if parent == null:
		return
	
	if parent.is_visible_in_tree() == true:
		grab_focus()
	else:
		parent.visibility_changed.connect(grab_focus)


func grab_focus():
	parent.call_deferred("grab_focus")

extends ProgressBar
class_name HealthBar

@export var progress_bar_under : ProgressBar = null
@export var timer : Timer = null

var last_value : float = 0.0

var is_init : bool = false

func _on_value_update(value : float):
	if value < self.value:
		timer.start()
	
	self.value = value
	last_value = value
	
	if is_init == false:
		is_init = true
		progress_bar_under.value = value


func _on_timer_timeout():
	progress_bar_under.value = last_value


func _on_health_become_not_full():
	var parent : ProgressBar = get_parent() as ProgressBar
	
	if parent != null:
		parent.show()


func _on_health_become_full():
	var parent : ProgressBar = get_parent() as ProgressBar
	
	if parent != null:
		parent.hide()

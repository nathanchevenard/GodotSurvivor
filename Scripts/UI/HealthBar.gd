extends ProgressBar
class_name HealthBar

@export var progress_bar_under : ProgressBar = null
@export var timer : Timer = null
@export var value_label : Label

var last_value : float = 0.0

var is_init : bool = false

func _on_value_update(new_value : float, new_max_value : float):
	if new_max_value == 0:
		value = 0
		progress_bar_under.value = 0
		
		if value_label != null:
			value_label.text = "0 / 0"
		
		return
	
	var percentage : float = float(100 * new_value) / new_max_value
	
	if percentage < value:
		timer.start()
	
	value = percentage
	last_value = value
	
	if is_init == false:
		is_init = true
		progress_bar_under.value = value
	
	if value_label != null:
		value_label.text = str(roundi(new_value)) + " / " + str(roundi(new_max_value))


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

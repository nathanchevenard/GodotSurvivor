extends ProgressBar
class_name HealthBar

@export var progress_bar_under : ProgressBar = null
@export var timer : Timer = null

var last_value : float = 0.0

#func _process(delta):
	#rotation = 0.0

func _on_value_update(value : float):
	self.value = value
	timer.start()
	last_value = value

func _on_timer_timeout():
	progress_bar_under.value = last_value

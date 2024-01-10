extends Projectile
class_name Beam

@export var duration : float

var current_time : float = 0.0

func _process(delta):
	current_time += delta
	
	if current_time >= duration:
		queue_free()

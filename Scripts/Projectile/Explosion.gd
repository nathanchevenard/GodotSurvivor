extends Projectile
class_name Explosion

@export var lifetime_duration : float
@export var hitbox_duration : float

var current_time : float = 0.0

func _process(delta):
	current_time += delta
	
	if current_time >= lifetime_duration:
		queue_free()

func _on_body_entered(body : Node2D):
	if current_time < hitbox_duration:
		super(body)

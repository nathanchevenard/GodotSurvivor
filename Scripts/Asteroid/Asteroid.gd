extends Area2D
class_name Asteroid

@export var direction : Vector2 = Vector2.RIGHT
@export var speed : float = 200.0
@export var torque : float = 50.0

func _physics_process(delta):
	var velocity : Vector2 = speed * direction * delta
	global_position += velocity
	
	rotation_degrees += torque * delta

func _on_body_entered(body: Player):
	body.destroy()

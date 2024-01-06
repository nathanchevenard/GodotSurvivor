extends Node2D
class_name Projectile

@export var max_speed : float = 400.0

@onready var current_direction : Vector2 = Vector2.RIGHT.rotated(rotation)

var target_group : String

func _physics_process(delta):
	var velocity : Vector2 = current_direction * max_speed * delta
	global_position += velocity


func _on_body_entered(body : Node2D):
	if body.is_in_group(target_group) == true:
		body.destroy()
	
	queue_free()

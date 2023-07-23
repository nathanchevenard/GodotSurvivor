extends Node2D

@export var max_speed : float = 400.0

@onready var current_direction : Vector2 = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	var velocity : Vector2 = current_direction * max_speed * delta
	global_position += velocity

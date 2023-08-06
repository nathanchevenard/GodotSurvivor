extends Node2D
class_name Level

@onready var border_rect : ReferenceRect = %BorderRect
@onready var asteroid_handler : Node2D = %AsteroidHandler

@onready var screen_width : float = ProjectSettings.get_setting("display/window/size/viewport_width") 
@onready var screen_height : float = ProjectSettings.get_setting("display/window/size/viewport_height") 
@onready var screen_size : Vector2 = Vector2(screen_width, screen_height)

@export var asteroid_scene : PackedScene
@export var spawn_circle_radius : float  = 350.0
@export_range(0.0, 180.0) var direction_random_variation : float = 40.0


func spawn_asteroid() -> void:
	var screen_center = screen_size / 2.0
	
	var angle : float = deg_to_rad(randf_range(0.0, 360.0))
	var direction : Vector2 = Vector2.RIGHT.rotated(angle)
	var point : Vector2 = screen_center + spawn_circle_radius * direction
	
	var asteroid : Asteroid = asteroid_scene.instantiate()
	asteroid_handler.add_child(asteroid)
	
	var direction_center = point.direction_to(screen_center)
	
	var rotation_variance_rad = deg_to_rad(direction_random_variation)
	var direction_rotation = randf_range(-rotation_variance_rad, rotation_variance_rad)
	var asteroid_dir = direction_center.rotated(direction_rotation)
	
	asteroid.direction = asteroid_dir
	asteroid.position = point

func _input(event):
	if event.is_action_pressed("ui_accept"):
		spawn_asteroid()

extends Node2D
class_name Level

@onready var border_rect : ReferenceRect = %BorderRect
@onready var asteroid_handler : Node2D = %AsteroidHandler
@onready var game_over = %GameOver

@onready var screen_width : float = ProjectSettings.get_setting("display/window/size/viewport_width") 
@onready var screen_height : float = ProjectSettings.get_setting("display/window/size/viewport_height") 
@onready var screen_size : Vector2 = Vector2(screen_width, screen_height)

@export var asteroid_scene : PackedScene
@export var spawn_circle_radius : float  = 350.0
@export_range(0.0, 180.0) var direction_random_variation : float = 40.0

var asteroids : Array[Asteroid]

func spawn_asteroid_on_border() -> void:
	var screen_center = screen_size / 2.0
	
	var angle : float = deg_to_rad(randf_range(0.0, 360.0))
	var direction : Vector2 = Vector2.RIGHT.rotated(angle)
	var point : Vector2 = screen_center + spawn_circle_radius * direction
	
	var direction_center = point.direction_to(screen_center)
	
	var rotation_variance_rad = deg_to_rad(direction_random_variation)
	var direction_rotation = randf_range(-rotation_variance_rad, rotation_variance_rad)
	var asteroid_dir = direction_center.rotated(direction_rotation)
	var asteroid_size = randi_range(0, Asteroid.ASTEROID_SIZE.size() - 1)
	
	spawn_asteroid(point, asteroid_dir, asteroid_size)


func spawn_asteroid(pos: Vector2, dir: Vector2, size: Asteroid.ASTEROID_SIZE) -> void:
	var asteroid : Asteroid = asteroid_scene.instantiate()
	asteroid_handler.add_child.call_deferred((asteroid))
	
	asteroid.position = pos
	asteroid.direction = dir
	asteroid.size = size
	asteroids.append(asteroid)
	
	asteroid.destroyed.connect(on_asteroid_destroy.bind(asteroid))


func _on_spawn_timer_timeout():
	spawn_asteroid_on_border()


func on_asteroid_destroy(asteroid: Asteroid) -> void:
	if asteroid.size > 0:
		var nb_spawn = randi_range(0, 3)
		
		for i in range(nb_spawn):
			var rotation_variance_rad = deg_to_rad(direction_random_variation)
			var direction_rotation = 2 * randf_range(-rotation_variance_rad, rotation_variance_rad)
			var dir = asteroid.direction.rotated(direction_rotation)
			
			spawn_asteroid(asteroid.global_position, dir, asteroid.size - 1)
	
	if asteroids.has(asteroid):
		asteroids.erase(asteroid)


func _on_retry_button_pressed():
	get_tree().reload_current_scene()


func _on_player_destroyed():
	game_over.show()

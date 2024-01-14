extends Node2D
class_name Level

@onready var border_rect : ReferenceRect = %BorderRect
@onready var enemy_handler : Node2D = %EnemyHandler
@onready var obstacle_handler : Node2D = %ObstacleHandler
@onready var projectile_handler : Node2D = %ProjectileHandler
@onready var game_over = %GameOver

@onready var screen_width : float = ProjectSettings.get_setting("display/window/size/viewport_width") 
@onready var screen_height : float = ProjectSettings.get_setting("display/window/size/viewport_height") 
@onready var screen_size : Vector2 = Vector2(screen_width, screen_height)

@export var enemy_spawn_range_min : float = 30
@export var enemy_spawn_range_max : float = 40

@export var asteroid_scene : PackedScene
@export var enemy_scene : PackedScene
@export var spawn_circle_radius : float  = 350.0
@export_range(0.0, 180.0) var direction_random_variation : float = 40.0

@export var enemy_incrementation_threshold : int = 10
@export var current_enemy_incrementation : int = 0
@export var enemy_spawn_number : int = 1
@export var enemy_max_number : int = 300

var asteroids : Array[Asteroid]
var enemies : Array[Enemy]

var toggle_asteroids : bool = true
var toggle_enemies : bool = true

static var instance : Level = null

signal game_end

func _init():
	if instance != null:
		push_warning("Multiple instances of Level tried to instantiate.")
		return
	
	instance = self


func _process(delta):
	print("enemies: " + str(enemies.size()))
	print("asteroids: " + str(asteroids.size()))


func _on_obstacle_spawn_timer_timeout():
	if toggle_asteroids == false:
		return
	
	spawn_asteroid_on_border()


func spawn_asteroid_on_border() -> void:
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for player : Player in players:
		spawn_scene_around_position(asteroid_scene, player.global_position)


func _on_enemy_spawn_timer_timeout():
	if toggle_enemies == false:
		return
	
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for i in range(enemy_spawn_number):
		for player : Player in players:
			if enemies.size() >= enemy_max_number:
				return
			spawn_scene_around_position(enemy_scene, player.global_position)
	
	current_enemy_incrementation += 1
	if current_enemy_incrementation >= enemy_incrementation_threshold:
		current_enemy_incrementation -= enemy_incrementation_threshold
		enemy_spawn_number += 1


func spawn_scene_around_position(scene: PackedScene, position: Vector2):
	var instance : Node2D = scene.instantiate() as Node2D
	enemy_handler.add_child.call_deferred((instance))
	
	var random_angle : float = randf_range(0.0, 2 * PI)
	var random_range : float = randf_range(enemy_spawn_range_min, enemy_spawn_range_max)
	var offset = Vector2.RIGHT.rotated(random_angle) * random_range
	
	instance.global_position = position + offset
	#enemy.destroyed.connect(on_asteroid_destroy.bind(enemy))


func _on_retry_button_pressed():
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Settings/Settings.tscn")

func _on_player_destroyed():
	game_over.show()
	game_end.emit()

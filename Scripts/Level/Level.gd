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

@export var asteroid_scene : PackedScene
@export var enemy_spawn_infos : Array[EnemySpawnInfo]
@export var spawn_circle_radius : float  = 350.0
@export_range(0.0, 180.0) var direction_random_variation : float = 40.0

@export var enemy_spawn_timer : float = 0.5
@export var enemy_incrementation_threshold : int = 10
@export var current_enemy_incrementation : int = 0
@export var enemy_spawn_number : int = 1
@export var enemy_max_number : int = 300

var asteroids : Array[Asteroid]
var enemies : Array[Enemy]

var current_enemy_spawn_timer : float = 0.0
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
	#print("enemies: " + str(enemies.size()))
	#print("asteroids: " + str(asteroids.size()))
	
	current_enemy_spawn_timer += delta
	if current_enemy_spawn_timer >= enemy_spawn_timer:
		current_enemy_spawn_timer = 0.0
		spawn_enemy()


func _on_obstacle_spawn_timer_timeout():
	if toggle_asteroids == false:
		return
	
	spawn_asteroid_on_border()


func spawn_asteroid_on_border() -> void:
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for player : Player in players:
		spawn_scene_around_position(asteroid_scene, player.global_position)


func spawn_enemy():
	if toggle_enemies == false:
		return
	
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for i in range(enemy_spawn_number):
		for player : Player in players:
			if enemies.size() >= enemy_max_number:
				var removed_enemy = enemies.pop_at(0)
				removed_enemy.queue_free()
			
			var enemy_scene : PackedScene = get_random_enemy()
			spawn_scene_around_position(enemy_scene, player.global_position)
	
	current_enemy_incrementation += 1
	if current_enemy_incrementation >= enemy_incrementation_threshold:
		current_enemy_incrementation -= enemy_incrementation_threshold
		enemy_spawn_number += 1


func get_random_enemy() -> PackedScene:
	var weight_sum : float = 0.0
	
	for enemy_spawn_info : EnemySpawnInfo in enemy_spawn_infos:
		weight_sum += enemy_spawn_info.weight
	
	var random_number : float = randf_range(0.0, weight_sum)
	var current_weight : float = 0.0
	
	for enemy_spawn_info : EnemySpawnInfo in enemy_spawn_infos:
		current_weight += enemy_spawn_info.weight
		if random_number <= current_weight:
			return enemy_spawn_info.enemy_scene
	
	return null


func spawn_scene_around_position(scene: PackedScene, position: Vector2):
	var instance : Node2D = scene.instantiate() as Node2D
	enemy_handler.add_child.call_deferred((instance))
	
	var random_angle : float = randf_range(0.0, 2 * PI)
	var offset = Vector2.RIGHT.rotated(random_angle) * spawn_circle_radius
	
	instance.global_position = position + offset
	#enemy.destroyed.connect(on_asteroid_destroy.bind(enemy))


func _on_player_destroyed():
	game_over.show()
	PauseSystem.instance.start_pause()
	game_end.emit()

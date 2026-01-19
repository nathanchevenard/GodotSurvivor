extends Node2D
class_name Level

@onready var enemy_handler : Node2D = %EnemyHandler
@onready var obstacle_handler : Node2D = %ObstacleHandler
@onready var projectile_handler : Node2D = %ProjectileHandler
@onready var game_over = %GameOver
@onready var arena : Arena = %Arena

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

var init_enemy_spawn_number : int
var current_enemy_spawn_timer : float = 0.0
var toggle_asteroids : bool = true
var toggle_enemies : bool = true
var timer_seconds : float = 0

static var instance : Level = null

signal game_end


func _init():
	if instance != null:
		push_warning("Multiple instances of Level tried to instantiate.")
		return
	
	instance = self
	
	SignalsManager.timer_seconds_update.connect(on_timer_seconds_update)


func _process(delta):
	#print("enemies: " + str(enemies.size()))
	#print("asteroids: " + str(asteroids.size()))
	
	current_enemy_spawn_timer += delta
	if current_enemy_spawn_timer >= enemy_spawn_timer:
		current_enemy_spawn_timer = 0.0
		spawn_enemy()


func _ready() -> void:
	for enemy in enemy_spawn_infos:
		enemy.already_spawned = 0
	
	init_enemy_spawn_number = enemy_spawn_number


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
			
			# If no enemy found, there are none available now so we return
			if enemy_scene == null:
				return
			
			spawn_scene_around_position(enemy_scene, player.global_position, true)
	
	current_enemy_incrementation += 1
	if current_enemy_incrementation >= enemy_incrementation_threshold:
		current_enemy_incrementation -= enemy_incrementation_threshold
		enemy_spawn_number += 1


func get_random_enemy() -> PackedScene:
	var weight_sum : float = 0.0
	var enemies : Array[EnemySpawnInfo] = enemy_spawn_infos.duplicate()
	
	for enemy in enemy_spawn_infos:
		# Enemies with spawn_only_on_timer as true are spawned by function on_timer_seconds_update
		if enemy.spawn_only_on_timer == true || timer_seconds < enemy.spawn_timer \
		|| (enemy.spawn_timer_stop > 0 && timer_seconds > enemy.spawn_timer_stop):
			enemies.erase(enemy)
	
	for enemy_spawn_info : EnemySpawnInfo in enemies:
		weight_sum += enemy_spawn_info.weight
	
	var random_number : float = randf_range(0.0, weight_sum)
	var current_weight : float = 0.0
	
	for enemy_spawn_info : EnemySpawnInfo in enemies:
		current_weight += enemy_spawn_info.weight
		if random_number <= current_weight:
			enemy_spawn_info.already_spawned += 1
			return enemy_spawn_info.enemy_scene
	
	return null


func spawn_scene_around_position(scene: PackedScene, target_position: Vector2,\
must_be_in_arena: bool = false) -> Node2D:
	var node : Node2D = scene.instantiate() as Node2D
	enemy_handler.add_child.call_deferred((node))
	
	var random_angle : float = randf_range(0.0, 2 * PI)
	var offset : Vector2 = Vector2.RIGHT.rotated(random_angle) * spawn_circle_radius
	
	if must_be_in_arena == true && SettingsController.is_arena_mode == true:
		# Pick a random position around player that is in arena radius
		# Try random a few times, and if it does not find a right spot, force one inside radius
		if (target_position + offset).length() >= arena.arena_radius:
			for i in range(0, 10):
				random_angle = randf_range(0.0, 2 * PI)
				offset = Vector2.RIGHT.rotated(random_angle) * spawn_circle_radius
				if (target_position + offset).length() < arena.arena_radius:
					break
				if i == 9:
					offset = -target_position + (arena.arena_radius / 2) * target_position.normalized()
	
	node.global_position = target_position + offset
	return node


func _on_player_destroyed():
	SignalsManager.emit_game_over()
	PauseSystem.instance.start_pause(true)
	game_end.emit()


func on_timer_seconds_update(seconds : int):
	timer_seconds = seconds
	
	for enemy in enemy_spawn_infos:
		if enemy.spawn_only_on_timer == true && enemy.spawn_timer == seconds:
			var players : Array[Node] = get_tree().get_nodes_in_group("Player")
			
			for player : Player in players:
				for i in enemy.spawn_number:
					spawn_scene_around_position(enemy.enemy_scene, player.global_position, true)
					enemy.already_spawned += 1
			
			if enemy.reset_enemy_spawn_number == true:
				enemy_spawn_number = init_enemy_spawn_number
				current_enemy_incrementation = 0

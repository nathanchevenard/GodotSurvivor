extends Resource
class_name EnemySpawnInfo

@export var enemy_scene : PackedScene
@export var weight : float
@export var spawn_timer : float = 0
@export var spawn_timer_stop : float = 0
@export var spawn_only_on_timer : bool = false
@export var spawn_number : int = 1
@export var reset_enemy_spawn_number : bool = false

var already_spawned : int = 0

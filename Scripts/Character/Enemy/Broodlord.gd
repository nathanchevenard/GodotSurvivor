extends Enemy
class_name Broodlord

@export var spawned_enemy_scene : PackedScene
@export var spawn_number : int = 1
@export var spawn_delay : float = 1
@export var spawn_volley_delay : float = 0.5
@export var spawn_forward_distance : float = 10
@export var spawn_side_distance : float = 10

var spawn_timer : float = 0
var is_spawning_enemies : bool = false
var is_spawning_left : int = 1


func _physics_process(delta):
	super(delta)
	
	if is_spawning_enemies == true:
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_delay:
		spawn_timer -= spawn_delay
		
		spawn_enemies()


func spawn_enemies():
	is_spawning_enemies = true
	
	for i in spawn_number:
		var enemy : Node2D = spawned_enemy_scene.instantiate()
		Level.instance.enemy_handler.call_deferred("add_child", enemy)
		enemy.global_position = global_position + spawn_forward_distance * transform.x
		enemy.global_position += spawn_side_distance * is_spawning_left * transform.y
		is_spawning_left *= -1
		await get_tree().create_timer(spawn_volley_delay).timeout
	
	is_spawning_enemies = false

extends Node
class_name CollectablesManager

@export var xp_collectable_scene : PackedScene
@export var heal_collectable_scene : PackedScene
@export var heal_collectable_drop_rate : float = 0.02
@export var magnet_collectable_scene : PackedScene
@export var magnet_collectable_drop_rate : float = 0.01

var xp_collectables : Array[Collectable]


func _init() -> void:
	SignalsManager.enemy_die.connect(_on_enemy_die)
	SignalsManager.player_collect_all_xp.connect(_on_player_collect_all_xp)


func _on_enemy_die(enemy : Enemy):
	var xp : XpCollectable = xp_collectable_scene.instantiate()
	xp.xp_value = enemy.xp_value
	Level.instance.obstacle_handler.call_deferred("add_child", xp)
	xp.global_position = enemy.global_position
	xp.rotation_degrees = randf_range(-180, 180)
	xp.sprite.scale *= enemy.xp_scene_scale
	xp.modulate = enemy.xp_modulate_color
	xp_collectables.append(xp)
	xp.destroy.connect(on_xp_destroyed)
	
	var drop : Node2D = null
	
	if randf_range(0, 1) < heal_collectable_drop_rate:
		drop = heal_collectable_scene.instantiate()
	elif randf_range(0, 1) < magnet_collectable_drop_rate:
		drop = magnet_collectable_scene.instantiate()
	
	if drop != null:
		Level.instance.obstacle_handler.call_deferred("add_child", drop)
		drop.global_position = enemy.global_position


func on_xp_destroyed(xp : Collectable):
	xp_collectables.erase(xp)


func _on_player_collect_all_xp(player : Player):
	for xp in xp_collectables:
		xp.is_collecting = true
		xp.collecting_player = player

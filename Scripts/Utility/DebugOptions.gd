extends Node
class_name DebugOptions

@export var player_immortal : bool = false
@export var player_toggle_weapons : bool = true
@export var toggle_asteroids : bool = true
@export var toggle_enemies : bool = true
@export var enemies_spawn_number : int = -1
@export var enemies_spawn_timer : float = -1

var players : Array[Player]


func _ready():
	var nodes : Array[Node] = get_tree().get_nodes_in_group("Player")
	players.assign(nodes)
	
	if player_immortal == true:
		for player in players:
			player.is_immortal = true
	
	if player_toggle_weapons == false:
		for player in players:
			player.init_weapons()
			
			for weapon in player.weapons:
				weapon.queue_free()
	
	if toggle_asteroids == false:
		Level.instance.toggle_asteroids = false
	
	if toggle_enemies == false:
		Level.instance.toggle_enemies = false
	
	if enemies_spawn_number > 0:
		Level.instance.enemy_spawn_number = enemies_spawn_number
	
	if enemies_spawn_timer > 0:
		Level.instance.enemy_spawn_timer = enemies_spawn_timer
		Level.instance.current_enemy_spawn_timer = enemies_spawn_timer


func _process(delta):
	#print("FPS: " + str(Engine.get_frames_per_second()))
	pass

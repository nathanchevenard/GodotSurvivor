extends Node
class_name DebugOptions

@export var player_immortal : bool = false
@export var player_toggle_weapons : bool = true
@export var toggle_asteroids : bool = true
@export var toggle_enemies : bool = true

var players : Array[Player]


func _ready():
	var nodes : Array[Node] = get_tree().get_nodes_in_group("Player")
	players.assign(nodes)
	
	if player_immortal == true:
		for player in players:
			player.is_immortal = true
	
	print(Level.instance)
	
	if toggle_asteroids == false:
		Level.instance.toggle_asteroids = false
	
	if toggle_enemies == false:
		Level.instance.toggle_enemies = false

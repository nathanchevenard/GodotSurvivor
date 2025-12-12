extends Collectable

@export var heal_value : int = 15


func on_player_collect(player : Player):
	player.heal(heal_value)
	super(player)

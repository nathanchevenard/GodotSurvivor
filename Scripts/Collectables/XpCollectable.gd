extends Collectable
class_name XpCollectable

@export var xp_value : float = 1


func on_player_collect(player : Player):
	player.add_xp(xp_value)
	super(player)

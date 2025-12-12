extends Collectable


func on_player_collect(player : Player):
	SignalsManager.emit_player_collect_all_xp(player)
	super(player)

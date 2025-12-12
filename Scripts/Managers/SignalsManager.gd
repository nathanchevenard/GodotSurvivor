extends Node

signal enemy_die(enemy : Enemy)
func emit_enemy_died(enemy : Enemy):
	enemy_die.emit(enemy)


signal player_level_up(player : Player)
func emit_player_level_up(player : Player):
	player_level_up.emit(player)


signal player_xp_update(current_xp : int, max_xp : int)
func emit_player_xp_update(current_xp, max_xp):
	player_xp_update.emit(current_xp, max_xp)


signal player_collect_all_xp(player : Player)
func emit_player_collect_all_xp(player : Player):
	player_collect_all_xp.emit(player)

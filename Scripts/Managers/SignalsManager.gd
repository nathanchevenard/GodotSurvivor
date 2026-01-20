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


signal timer_seconds_update(seconds : int)
func emit_timer_seconds_update(seconds : int):
	timer_seconds_update.emit(seconds)


signal weapon_pivot_button_pressed(button : WeaponPivotButton)
func emit_weapon_pivot_button_pressed(button : WeaponPivotButton):
	weapon_pivot_button_pressed.emit(button)


signal game_pause
func emit_game_paused():
	game_pause.emit()


signal game_unpause
func emit_game_unpaused():
	game_unpause.emit()


signal game_freeze
func emit_game_freeze():
	game_freeze.emit()


signal game_unfreeze
func emit_game_unfreeze():
	game_unfreeze.emit()


signal game_unpause_delay_start
func emit_game_unpause_delay_start():
	game_unpause_delay_start.emit()


signal game_over
func emit_game_over():
	game_over.emit()


signal pivot_button_hover(pivot : Node2D)
func emit_pivot_button_hover(pivot : Node2D):
	pivot_button_hover.emit(pivot)


signal pivot_button_unhover(pivot : Node2D)
func emit_pivot_button_unhover(pivot : Node2D):
	pivot_button_unhover.emit(pivot)


signal player_ready(player : Player)
func emit_player_ready(player : Player):
	player_ready.emit(player)


signal ship_select(ship_data : ShipData)
func emit_ship_select(ship_data : ShipData):
	ship_select.emit(ship_data)


signal upgrade_add(upgrade : Upgrade, weapon_pivot : Node2D)
func emit_upgrade_add(upgrade : Upgrade, weapon_pivot : Node2D):
	upgrade_add.emit(upgrade, weapon_pivot)


signal dialogue_start(type : DialogueManager.DialogueType, data : DialogueData, planet : Planet, quest : Quest)
func emit_dialogue_start(type : DialogueManager.DialogueType, data : DialogueData, planet : Planet, quest : Quest):
	dialogue_start.emit(type, data, planet, quest)


signal quest_accept(quest : Quest)
func emit_quest_accept(quest : Quest):
	quest_accept.emit(quest)


signal quest_end(quest : Quest)
func emit_quest_end(quest : Quest):
	quest_end.emit(quest)

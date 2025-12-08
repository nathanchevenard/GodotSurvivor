extends Node

signal enemy_die
func emit_enemy_died():
	enemy_die.emit()

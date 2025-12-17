extends Control
class_name PauseHandler


func _init() -> void:
	SignalsManager.game_pause.connect(_on_game_paused)
	SignalsManager.game_unpause.connect(_on_game_unpaused)


func _ready() -> void:
	hide()


func _on_game_paused():
	show()


func _on_game_unpaused():
	hide()

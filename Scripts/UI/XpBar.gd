extends ProgressBar
class_name XpBar

@export var level_label : Label


func _init() -> void:
	SignalsManager.player_xp_update.connect(_on_player_xp_update)
	SignalsManager.player_level_up.connect(_on_player_level_up)


func _ready() -> void:
	value = 0
	level_label.text = "Lv 1"


func _on_player_xp_update(current_xp : int, max_xp : int):
	max_value = max_xp
	value = current_xp


func _on_player_level_up(player : Player):
	level_label.text = "Lv " + str(player.current_level)

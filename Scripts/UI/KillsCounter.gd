extends Label
class_name KillsCounter

static var count : int = 0


func _init() -> void:
	SignalsManager.enemy_die.connect(_on_enemy_die)
	count = 0


func _on_enemy_die(_enemy : Enemy):
	count += 1
	text = str(count)

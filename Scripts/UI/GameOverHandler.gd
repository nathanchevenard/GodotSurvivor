extends Control
class_name GameOverHandler

@export var kills_label : Label
@export var timer_label : Label
@export var level_label : Label
@export var weapon_stats_pivot : Control
@export var weapon_stat_scene : PackedScene
@export var border_layer : CanvasLayer


func _init() -> void:
	SignalsManager.game_over.connect(_on_game_over)


func _ready() -> void:
	hide()


func _on_game_over():
	update_infos()
	show()
	border_layer.hide()


func update_infos():
	var player : Player = get_tree().get_nodes_in_group("Player")[0]
	
	kills_label.text = str(KillsCounter.count)
	timer_label.text = GameStatistic.time_convert(floori(GameStatistic.timer))
	level_label.text = str(player.current_level)
	
	display_weapon_stats(player)


func display_weapon_stats(player : Player):
	for weapon in player.weapons:
		var stat : WeaponStatButton = weapon_stat_scene.instantiate() as WeaponStatButton
		stat.icon.texture = weapon.upgrades[0].icon
		stat.weapon_name_label.text = weapon.upgrades[0].name
		stat.weapon_name_level.text = "Lv" + str(weapon.upgrades.size())
		stat.weapon_name_damage.text = str(roundi(weapon.damage_dealt))
		weapon_stats_pivot.add_child(stat)

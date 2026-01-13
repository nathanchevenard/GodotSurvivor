extends Node
class_name ShipUpgradeSlot

@export var icon : TextureRect
@export var number_label : Label

var current_upgrade : Upgrade
var number : int = 0


func _init() -> void:
	SignalsManager.upgrade_add.connect(_on_upgrade_added)


func set_upgrade(upgrade : Upgrade):
	current_upgrade = upgrade
	icon.texture = upgrade.icon
	number_label.show()


func _on_upgrade_added(upgrade : Upgrade, _weapon_pivot : Node2D):
	if upgrade == current_upgrade:
		number += 1
		number_label.text = "Lv" + str(number)

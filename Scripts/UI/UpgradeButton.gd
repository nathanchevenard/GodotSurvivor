extends Control
class_name UpgradeButton

var upgrade : Upgrade

signal upgrade_pressed(upgrade)


func init(upgrade : Upgrade):
	self.upgrade = upgrade
	%Icon.texture = upgrade.icon
	%Title.text = upgrade.name
	%Description.text = upgrade.description


func _on_button_pressed():
	upgrade_pressed.emit(upgrade)

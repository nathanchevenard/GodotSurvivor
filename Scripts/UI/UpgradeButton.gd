extends Control
class_name UpgradeButton

@export var button : Button
@export var selected_control : Control

var upgrade : Upgrade

signal upgrade_pressed(upgrade_button)


func init(upgrade : Upgrade):
	self.upgrade = upgrade
	%Icon.texture = upgrade.icon
	%Title.text = upgrade.name
	%Description.text = upgrade.description


func select():
	selected_control.show()


func unselect():
	selected_control.hide()


func _on_button_pressed():
	upgrade_pressed.emit(self)

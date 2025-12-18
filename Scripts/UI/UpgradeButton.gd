extends Control
class_name UpgradeButton

@export var button : Button
@export var selected_control : Control

var upgrade : Upgrade
var weapon_pivot : Node2D

signal upgrade_pressed(upgrade_button)


func init(upgrade : Upgrade, weapon_pivot : Node2D = null):
	self.upgrade = upgrade
	self.weapon_pivot = weapon_pivot
	%Icon.texture = upgrade.icon
	%Title.text = upgrade.name
	%Description.text = upgrade.description


func select():
	selected_control.show()


func unselect():
	selected_control.hide()


func _on_button_pressed():
	upgrade_pressed.emit(self)


func _on_button_mouse_entered() -> void:
	if weapon_pivot != null:
		SignalsManager.emit_pivot_button_hover(weapon_pivot)


func _on_button_mouse_exited() -> void:
	if weapon_pivot != null:
		SignalsManager.emit_pivot_button_unhover(weapon_pivot)

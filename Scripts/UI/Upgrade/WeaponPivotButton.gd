extends Button
class_name WeaponPivotButton

@export var weapon_pivot : Node2D
@export var weapon_texture : TextureRect
@export var hovered_panel : Control
@export var number_label : Label


func _init() -> void:
	SignalsManager.pivot_button_hover.connect(_on_pivot_button_hovered)
	SignalsManager.pivot_button_unhover.connect(_on_pivot_button_unhovered)
	SignalsManager.upgrade_add.connect(_on_upgrade_added)


func _pressed() -> void:
	SignalsManager.emit_weapon_pivot_button_pressed(self)


func set_weapon(weapon : Upgrade):
	weapon_texture.texture = weapon.icon
	number_label.show()


func _on_pivot_button_hovered(pivot : Node2D):
	if pivot == weapon_pivot:
		hovered_panel.show()


func _on_pivot_button_unhovered(pivot : Node2D):
	if pivot == weapon_pivot:
		hovered_panel.hide()


func _on_upgrade_added(upgrade : Upgrade, pivot : Node2D):
	if pivot == weapon_pivot:
		var player : Player = get_tree().get_nodes_in_group("Player")[0]
		number_label.text = "Lv" + str(player.weapon_pivots_dico[pivot].upgrades.size())

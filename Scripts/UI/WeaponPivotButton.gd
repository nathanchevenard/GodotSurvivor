extends Button
class_name WeaponPivotButton

@export var weapon_pivot : Node2D
@export var weapon_texture : TextureRect
@export var hovered_panel : Control


func _init() -> void:
	SignalsManager.pivot_button_hover.connect(_on_pivot_button_hovered)
	SignalsManager.pivot_button_unhover.connect(_on_pivot_button_unhovered)


func _pressed() -> void:
	SignalsManager.emit_weapon_pivot_button_pressed(self)


func _on_pivot_button_hovered(pivot : Node2D):
	if pivot == weapon_pivot:
		hovered_panel.show()


func _on_pivot_button_unhovered(pivot : Node2D):
	if pivot == weapon_pivot:
		hovered_panel.hide()

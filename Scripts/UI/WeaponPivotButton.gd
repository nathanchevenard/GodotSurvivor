extends Button
class_name WeaponPivotButton

@export var weapon_pivot : Node2D
@export var weapon_texture : TextureRect


func _pressed() -> void:
	SignalsManager.emit_weapon_pivot_button_pressed(self)

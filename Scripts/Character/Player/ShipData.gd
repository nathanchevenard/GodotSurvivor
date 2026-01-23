extends Resource
class_name ShipData

@export var name : String
@export var sprite : Texture2D
@export_multiline var description : String

@export_group("Stats")
@export var ship_upgrades_number : int
@export var health : int = 100
@export var health_regen : float = 0
@export var shield : int = 0
@export var speed : float = 100

@export_group("Weapon pivots")
@export var weapon_pivot_positions : Array[Vector2]
@export var weapon_pivot_rotations : Array[float]
@export var ship_upgrade_layout_scene : PackedScene
@export var ship_selection_layout_scene : PackedScene


func get_stats_text() -> String:
	var text : String = ""
	text += "Weapon slots : " + str(weapon_pivot_positions.size()) + "\n"
	text += "Ship upgrade slots : " + str(ship_upgrades_number) + "\n"
	text += "Health : " + str(health) + "\n"
	text += "Health regen : " + str(health_regen) + "\n"
	text += "Shield : " + str(shield) + "\n"
	text += "Speed : " + str(speed) + "\n"
	
	return text

@tool
extends Control
class_name ShipUpgradeLayout

@export var weapon_pivot_buttons : Array[WeaponPivotButton]
@export var ship_data_path : String
@export var ship_sprite : TextureRect
@export var ship_upgrades_line : Line2D
@export var ship_selection_upgrades_pivot : Control

@export_group("Weapon angle indicators")
@export var indicators : Array[Polygon2D]
@export var indicators_pivot : Node2D
@export var indicator_points_number : int = 16
@export var indicator_angle : float = 90
@export var indicator_range : float = 100
@export var indicator_color : Color

@export_tool_button("Generate angle indicators") 
var gen_angle_action = generate_angle_indicators

func generate_angle_indicators():
	for indicator in indicators:
		indicator.queue_free()
	indicators.clear()
	
	if ship_data_path.is_empty():
		printerr("No ShipData path")
		return
	
	var ship_data : ShipData = load(ship_data_path)
	var pos_offset : Vector2 = ship_sprite.get_rect().position + Vector2(-ship_sprite.get_rect().size.x / 2, ship_sprite.get_rect().size.y / 2)
	
	for i in ship_data.weapon_pivot_positions.size():
		var indicator : Polygon2D = generate_points()
		indicators_pivot.add_child(indicator)
		indicator.owner = get_tree().edited_scene_root
		indicator.global_position = 2 * ship_data.weapon_pivot_positions[i] + pos_offset
		indicator.rotation_degrees = ship_data.weapon_pivot_rotations[i]
		indicators.append(indicator)


func generate_points() -> Polygon2D:
	var polygon : Polygon2D = Polygon2D.new()
	
	var points : PackedVector2Array
	points.append(Vector2(0,0))
	
	for i in indicator_points_number + 1:
		var angle = -deg_to_rad(indicator_angle) / 2 + i * (deg_to_rad(indicator_angle) / indicator_points_number)
		var pos : Vector2 = indicator_range * Vector2(1, 0).rotated(angle)
		points.append(pos)
	
	polygon.polygon = points
	polygon.color = indicator_color
	
	return polygon

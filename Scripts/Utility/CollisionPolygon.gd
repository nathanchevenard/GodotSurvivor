@tool
extends Node2D
class_name CollisionPolygon

@export var collision_polygon : CollisionPolygon2D
@export var polygon : Polygon2D
@export var points_number : int = 64
@export var angle : float = 360
@export var radius : float = 50
@export var color : Color

@export_tool_button("Generate Hitbox") var generate_hitbox_action = generate_hitbox

func generate_hitbox():
	if collision_polygon == null || polygon == null:
		printerr("No Collision Shape or no Polygon")
		return
	
	var points : PackedVector2Array
	
	for i in points_number:
		var point_angle = -deg_to_rad(angle) / 2 + i * (deg_to_rad(angle) / points_number)
		var pos : Vector2 = radius * Vector2(1, 0).rotated(point_angle)
		points.append(pos)
	
	collision_polygon.polygon = points
	polygon.polygon = points
	polygon.color = color

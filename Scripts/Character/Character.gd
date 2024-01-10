extends CharacterBody2D
class_name Character

@export var max_speed : float = 100.0
@export_range(0.0, 1.0) var position_acceleration : float = 0.1
@export_range(0.0, 1.0) var rotation_acceleration : float = 0.1
@export var target_groups : Array[String]

var current_direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.ZERO
var current_speed : float = 0.0

signal destroyed

func _physics_process(delta):
	if current_direction != Vector2.ZERO:
		last_direction = current_direction.normalized()
		rotate_toward_direction()
	
	move()


func rotate_toward_direction() -> void:
	var angle : float = global_position.angle_to_point(global_position + current_direction)
	rotation = lerp_angle(rotation, angle, rotation_acceleration)


func move() -> void:
	if current_direction == Vector2.ZERO:
		current_speed = lerp(current_speed, 0.0, position_acceleration)
	else:
		current_speed = lerp(current_speed, max_speed, position_acceleration)
	
	velocity = last_direction * current_speed
	move_and_slide()


func get_closest_entity(group_names : Array[String]) -> Node2D:
	var closest_entity : Node2D = null
	var entities = get_sorted_closest_entities(group_names)
	
	for entity in entities:
		closest_entity = entity
		break
	
	return closest_entity


func get_sorted_closest_entities(group_names : Array[String]) -> Array[Node]:
	var entities : Array[Node] = []
	
	for group_name in group_names:
		entities.append_array(get_tree().get_nodes_in_group(group_name))
		
	entities.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))	
	
	return entities


func destroy() -> void:
	destroyed.emit()
	queue_free()

extends CharacterBody2D
class_name Character

@export var speed_max : float = 70.0
@export_range(0.0, 1.0) var position_acceleration : float = 0.1
@export_range(0.0, 1.0) var rotation_acceleration : float = 0.1
@export var target_groups : Array[String]

@export var health_max : int = 10
@export var health_regen : float = 0
@export var health_regen_delay : float = 1
@export var shield_max : int = 0
@export var shield_regen : float = 0
@export var shield_regen_delay : float = 0.5

var is_being_destroyed : bool = false

var health : int = 0
var health_regen_timer : float = 0.0
var shield : int = 0
var current_shield_regen : float = 0.0
var is_regenerating_shield : bool = false
var shield_regen_timer : float = 0.0
var damage_mult : float = 1
var cooldown_mult : float = 1

var init_health_max : int
var init_health_regen : float
var init_shield_max : int
var init_speed_max : float
var init_damage_mult : float = 1
var init_cooldown_mult : float = 1

var current_direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.ZERO
var current_speed : float = 0.0

signal destroyed
signal health_changed(value : float)
signal shield_changed(value : float)

signal on_health_become_full
signal on_health_become_not_full


func _ready():
	health = health_max
	emit_health_changed()
	
	shield = shield_max
	emit_shield_changed()
	
	init_health_max = health_max
	init_health_regen = health_regen
	init_shield_max = shield_max
	init_speed_max = speed_max


func _physics_process(delta):
	if current_direction != Vector2.ZERO:
		last_direction = current_direction.normalized()
		rotate_toward_direction()
	
	move(delta)
	update_health(delta)
	update_shield(delta)


func rotate_toward_direction() -> void:
	var angle : float = global_position.angle_to_point(global_position + current_direction)
	rotation = lerp_angle(rotation, angle, rotation_acceleration)


func move(delta : float) -> void:
	if current_direction == Vector2.ZERO:
		current_speed = lerp(current_speed, 0.0, position_acceleration)
	else:
		current_speed = lerp(current_speed, speed_max, position_acceleration)
	
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


func take_damage(damage : int) -> float:
	var damage_dealt : int = damage
	is_regenerating_shield = false
	shield_regen_timer = 0
	
	if shield == shield_max && health == health_max && damage > 0:
		on_health_become_not_full.emit()
	
	if shield > 0:
		shield -= damage
		
		if shield < 0:
			damage = -shield
			shield = 0
		else:
			damage = 0
		
		emit_shield_changed()
	
	health -= damage
	
	if health < 0:
		damage_dealt += health
		health = 0
	
	emit_health_changed()
	
	if health <= 0:
		destroy()
	
	return damage_dealt


func heal(amount: int):
	if health == health_max:
		return
	
	health = clampi(health + amount, 0, health_max)
	emit_health_changed()
	
	if health == health_max && shield == shield_max:
		on_health_become_full.emit()


func update_health(delta: float):
	if health_regen <= 0 || health == health_max:
		return
	
	health_regen_timer += delta
	
	if health_regen_timer >= health_regen_delay:
		heal(roundi(health_regen))
		health_regen_timer = 0


func update_shield(delta: float):
	# If no shield regen or shield already full, do nothing
	if shield_regen == 0 || shield >= shield_max:
		return
	
	# If shield is not regenerating, wait for regen start delay
	if is_regenerating_shield == false:
		shield_regen_timer += delta
		if shield_regen_timer >= shield_regen_delay:
			is_regenerating_shield = true
			shield_regen_timer = 0
		# If delay is not reached yet, do nothing
		else:
			return
	
	current_shield_regen += delta
	
	if current_shield_regen >= shield_regen:
		current_shield_regen -= shield_regen
		shield += 1
		emit_shield_changed()
	
	if shield == shield_max && health == health_max:
		on_health_become_full.emit()


func emit_health_changed():
	if health_max != 0:
		health_changed.emit(health, health_max)
	else:
		health_changed.emit(0.0, health_max)


func emit_shield_changed():
	if shield_max != 0:
		shield_changed.emit(shield, shield_max)
	else:
		shield_changed.emit(0.0, health_max)


func destroy() -> void:
	if is_being_destroyed == true:
		return
	
	is_being_destroyed = true
	destroyed.emit()
	queue_free()

extends CharacterBody2D
class_name Player

@export var max_speed : float = 100.0
@export_range(0.0, 1.0) var position_acceleration : float = 0.1
@export_range(0.0, 1.0) var rotation_acceleration : float = 0.1

@export var attack_speed : float = 1

@export var projectile_scene : PackedScene
@onready var joystick : JoystickController = $"../BorderLayer/Joystick"

var current_direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.ZERO
var current_speed : float = 0.0

var attack_cooldown : float = 0.0

signal projectile_fired(projectile)
signal destroyed

func _ready():
	pass


func _physics_process(_delta):
	update_autoattack(_delta)
	
	if DeviceDetection.is_mobile():
		current_direction = joystick.posVector.normalized()
		
	if current_direction != Vector2.ZERO:
		last_direction = current_direction
		rotate_toward_direction()
	
	move()


func _input(event):
	if event.is_action_pressed("left_click") && DeviceDetection.is_mobile():
		joystick.global_position = get_global_mouse_position()		
		
	if DeviceDetection.is_computer():
		current_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func update_autoattack(_delta : float):
	attack_cooldown += _delta
	if attack_cooldown >= attack_speed:
		attack_cooldown = 0.0
		var closest_target : Node2D = get_closest_target()
		
		if closest_target != null:
			var angle : float = global_position.angle_to_point(closest_target.global_position)
			fire(angle)


func move() -> void:
	if current_direction == Vector2.ZERO:
		current_speed = lerp(current_speed, 0.0, position_acceleration)
	else:
		current_speed = lerp(current_speed, max_speed, position_acceleration)		
	
	velocity = last_direction * current_speed
	move_and_slide()


func rotate_toward_mouse() -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var angle : float = global_position.angle_to_point(mouse_pos)
	rotation = lerp_angle(rotation, angle, rotation_acceleration)
	


func rotate_toward_direction() -> void:
	var angle : float = global_position.angle_to_point(global_position + current_direction)
	rotation = lerp_angle(rotation, angle, rotation_acceleration)


func fire(angle : float) -> void:
	var projectile : Projectile = projectile_scene.instantiate() as Projectile
	
	projectile.global_position = global_position
	projectile.rotation = angle
	
	projectile_fired.emit(projectile)


func get_closest_target() -> Node2D:
	var closest_target : Node2D = null
	var targets : Array[Node] = get_tree().get_nodes_in_group("Adversary")
	
	targets.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	for target in targets:
		closest_target = target
		break
	
	return closest_target


func destroy() -> void:
	destroyed.emit()
	queue_free()

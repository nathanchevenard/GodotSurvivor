extends CharacterBody2D

@export var max_speed : float = 100.0
@export_range(0.0, 1.0) var position_acceleration : float = 0.1
@export_range(0.0, 1.0) var rotation_acceleration : float = 0.1

@export var projectile_scene : PackedScene

var current_direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.ZERO
var current_speed : float = 0.0

signal projectile_fired(projectile)

func _ready():
	pass


func _physics_process(delta):
	move()
	rotate_toward_mouse()


func _input(event):
	current_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if current_direction != Vector2.ZERO:
		last_direction = current_direction
		
	if event.is_action_pressed("fire"):
		fire()


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


func fire() -> void:
	var projectile : Node = projectile_scene.instantiate()
	projectile.transform = global_transform
	
	projectile_fired.emit(projectile)


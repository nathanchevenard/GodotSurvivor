extends CharacterBody2D

var speed : float = 200.0
var direction : Vector2 = Vector2.ZERO


func _ready():
	pass


func _physics_process(delta):
	# Move
	velocity = direction * speed	
	move_and_slide()
	
	# Rotate towards mouse
	var mouse_pos : Vector2 = get_global_mouse_position()
	var angle : float = global_position.angle_to_point(mouse_pos)
	rotation = angle


func _input(event):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

extends Node2D
class_name Projectile

var speed : float
var current_direction : Vector2

var weapon : Weapon

func initialize(weapon : Weapon, starting_position : Vector2, target: Node2D, speed : float):
	global_position = starting_position
	self.weapon = weapon
	
	if (target != null):
		current_direction = (target.global_position - global_position).normalized()
		rotation = global_position.angle_to_point(target.global_position)
	
	self.speed = speed


func _physics_process(delta):
	var velocity : Vector2 = current_direction * speed * delta
	global_position += velocity


func _on_body_entered(body : Node2D):
	if weapon != null:
		for target_group in weapon.target_groups:
			if body.is_in_group(target_group) == true && weapon != null:
				var character : Character = body as Character
				character.take_damage(weapon.damage)

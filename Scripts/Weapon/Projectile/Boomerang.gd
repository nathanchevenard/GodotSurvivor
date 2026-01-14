extends Projectile
class_name Boomerang

@export var decrease_value : float = 100
@export var destroyed_range : float = 10
@export var torque : float = 500

var is_returning : bool = false


func _physics_process(delta):
	super(delta)
	
	rotation_degrees += torque * delta
	
	if is_returning == false:
		speed -= decrease_value * delta
		if speed <= 0:
			is_returning = true
	else:
		speed += decrease_value * delta
		set_target_pos(weapon.character.global_position)
		
		if (weapon.character.global_position - global_position).length() < destroyed_range:
			queue_free()

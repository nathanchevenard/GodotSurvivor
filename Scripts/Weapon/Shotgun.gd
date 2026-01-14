extends Weapon
class_name Shotgun

@export var dispersion_angle : float = 30


func fire():
	if acquired_targets.size() > 0:
		var target : Node2D = null
		target = acquired_targets[0]
		
		for i in projectile_number:
			var projectile_instance : Projectile = projectile.instantiate() as Projectile
			projectile_instance.initialize(self, global_position, target, projectile_speed)
			Level.instance.projectile_handler.add_child(projectile_instance)
			
			var pos_randomized : Vector2 = target.global_position - global_position
			var random_angle : float = randf_range(-dispersion_angle, dispersion_angle)
			pos_randomized = pos_randomized.rotated(deg_to_rad(random_angle))
			projectile_instance.set_target_pos(pos_randomized + global_position)

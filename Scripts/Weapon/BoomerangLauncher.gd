@tool
extends Weapon
class_name BoomerangLauncher


func initialize_projectile(projectile_instance : Projectile, target : Node2D):
	super(projectile_instance, target)
	
	# If boomerang is faster, it should not go further but come back faster instead
	(projectile_instance as Boomerang).decrease_value *= pow((projectile_speed / init_projectile_speed), 2)

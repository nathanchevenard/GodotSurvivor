@tool
extends Weapon
class_name ForceField

@export var projectile_instance : Projectile


func _ready():
	super()
	
	projectile_instance.initialize(self, global_position, null, 0)
	global_position = character.global_position


func on_upgrade_added(upgrade : Upgrade, weapon : Weapon):
	super(upgrade, weapon)
	
	projectile_instance.scale = projectile_size * character.projectile_size_mult * Vector2.ONE
	range = init_range * projectile_size

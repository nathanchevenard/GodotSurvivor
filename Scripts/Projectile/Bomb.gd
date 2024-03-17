extends Projectile
class_name Bomb

@export var lifetime_max : float = 3.0
@export var torque : float = 50.0

@export var explosion_scene : PackedScene

var estimated_lifetime : float
var current_bomb_lifetime : float = 0.0

func initialize(weapon : Weapon, starting_position : Vector2, target: Node2D, speed : float):
	super(weapon, starting_position, target, speed)
	
	if self.speed > 0:
		estimated_lifetime = target.global_position.distance_to(global_position) / self.speed
		torque /= estimated_lifetime
	else:
		estimated_lifetime = lifetime_max


func _physics_process(delta):
	super(delta)
	
	rotation_degrees += torque * delta
	current_bomb_lifetime += delta
	
	if current_bomb_lifetime >= lifetime_max || current_bomb_lifetime >= estimated_lifetime:
		if weapon != null:
			var explosion : Explosion = explosion_scene.instantiate() as Explosion
			explosion.initialize(weapon, global_position, null, 0.0)
			explosion.set_coef_area_of_effect(weapon.projectile_coef_area_of_effect)
			Level.instance.projectile_handler.add_child(explosion)
		
		queue_free()

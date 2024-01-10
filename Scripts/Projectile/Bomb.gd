extends Projectile
class_name Bomb

@export var lifetime_max : float = 3.0
@export var torque : float = 50.0

@export var explosion_scene : PackedScene

var estimated_lifetime : float
var current_lifetime : float = 0.0

func initialize(weapon : Weapon, starting_position : Vector2, target: Node2D, speed : float):
	super(weapon, starting_position, target, speed)
	
	estimated_lifetime = target.global_position.distance_to(global_position) / self.speed
	
	torque /= estimated_lifetime


func _physics_process(delta):	
	super(delta)
	
	rotation_degrees += torque * delta
	current_lifetime += delta
	
	if current_lifetime >= lifetime_max || current_lifetime >= estimated_lifetime:
		if weapon != null:
			var explosion : Projectile = explosion_scene.instantiate() as Projectile
			explosion.initialize(weapon, global_position, null, 0.0)
			Level.instance.projectile_handler.add_child(explosion)
		
		queue_free()

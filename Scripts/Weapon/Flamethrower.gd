extends Weapon
class_name Flamethrower

@export var rotation_speed : float = 0.1
@export var projectile_instance : Projectile

var is_firing : bool = false
var previous_rotation : float


func _ready():
	super()
	
	previous_rotation = 0
	projectile_instance.initialize(self, global_position, null, 0)


func _process(delta):
	super(delta)
	
	var new_rot = previous_rotation
	var targets : Array[Node2D] = acquire_targets(1)
	
	if targets.size() > 0:
		var target : Node2D = targets[0]
		var angle = get_angle_to(target.global_position)
		if angle > 0:
			angle = 1
		else:
			angle = -1
		new_rot += angle * rotation_speed
		
		if (target.global_position - global_position).length() < range:
			fire_start()
		else:
			fire_stop()
			
	else:
		fire_stop()
	
	global_rotation = new_rot
	previous_rotation = global_rotation


func fire_start():
	if is_firing == true:
		return
	
	is_firing = true
	projectile_instance.sprite.play("start")
	projectile_instance.sprite.animation_finished.connect(_anim_start_finished)
	
	if projectile_instance.sprite.animation_finished.is_connected(_anim_stop_finished):
		projectile_instance.sprite.animation_finished.disconnect(_anim_stop_finished)


func _anim_start_finished():
	projectile_instance.sprite.animation_finished.disconnect(_anim_start_finished)
	projectile_instance.sprite.play("idle")


func fire_stop():
	if is_firing == false:
		return
	
	is_firing = false
	projectile_instance.sprite.play("stop")
	projectile_instance.sprite.animation_finished.connect(_anim_stop_finished)
	
	if projectile_instance.sprite.animation_finished.is_connected(_anim_start_finished):
		projectile_instance.sprite.animation_finished.disconnect(_anim_start_finished)


func _anim_stop_finished():
	projectile_instance.sprite.animation_finished.disconnect(_anim_stop_finished)
	projectile_instance.sprite.play("hidden")


func on_upgrade_added(upgrade : Upgrade, weapon : Weapon):
	super(upgrade, weapon)
	
	projectile_instance.scale = Vector2(projectile_size, projectile_size)
	range = init_range * projectile_size

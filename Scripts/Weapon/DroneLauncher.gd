extends Weapon
class_name DroneLauncher

@export var position_radius : float = 20

var drones : Array[Drone]
var current_angle : float = 0


func _ready():
	super()
	
	spawn_drone()


func _process(delta):
	current_angle += delta * projectile_speed
	
	for i in drones.size():
		var offset : Vector2 = Vector2(position_radius, 0)
		offset = offset.rotated(current_angle + 2 * PI * i / drones.size())
		drones[i].global_position = character.global_position + offset
		drones[i].global_rotation = 0


func spawn_drone():
	var drone : Drone = projectile.instantiate() as Drone
	drone.initialize(self, global_position, null, 0)
	drones.append(drone)
	add_child(drone)


func on_upgrade_added(upgrade : Upgrade, weapon : Weapon):
	super(upgrade, weapon)
	
	while projectile_number > drones.size():
		spawn_drone()

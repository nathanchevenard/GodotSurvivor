extends Character
class_name Player

@export var is_immortal : bool = false
@export var attack_speed : float = 1

@export var projectile_scene : PackedScene
@onready var joystick : JoystickController = $"../BorderLayer/Joystick"

var attack_cooldown : float = 0.0
var weapons : Array[Weapon]
@export var upgrades : Array[Upgrade]

signal projectile_fired(projectile)
signal upgrade_added(upgrade)

func _ready():
	super()
	
	init_weapons()
	init_upgrades()


func _physics_process(_delta):
	#update_autoattack(_delta)
	
	if DeviceDetection.is_mobile():
		current_direction = joystick.posVector
	
	super(_delta)


func _input(event):
	if DeviceDetection.is_computer():
		current_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func init_weapons():
	if weapons != null && weapons.size() > 0:
		return
	
	for child in get_children():
		if child is Weapon:
			weapons.append(child)
			upgrade_added.connect(child.on_upgrade_added)


func init_upgrades():
	for upgrade in upgrades:
		upgrade_added.emit(upgrade)


func add_upgrade(upgrade : Upgrade):
	upgrade_added.emit(upgrade)


func update_autoattack(_delta : float):
	attack_cooldown += _delta
	if attack_cooldown >= attack_speed:
		attack_cooldown = 0.0
		var closest_target : Node2D = get_closest_entity(target_groups)
		
		if closest_target != null:
			var angle : float = global_position.angle_to_point(closest_target.global_position)
			fire(angle)


func rotate_toward_mouse() -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var angle : float = global_position.angle_to_point(mouse_pos)
	rotation = lerp_angle(rotation, angle, rotation_acceleration)
	


func fire(angle : float) -> void:
	var projectile : Projectile = projectile_scene.instantiate() as Projectile
	
	projectile.global_position = global_position
	projectile.rotation = angle
	projectile.target_groups = target_groups
	
	projectile_fired.emit(projectile)


func destroy() -> void:
	if is_immortal == true:
		return
	
	super()

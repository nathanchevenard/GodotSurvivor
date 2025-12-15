extends Character
class_name Player

@export var is_immortal : bool = false
@export var attack_speed : float = 1

@export var projectile_scene : PackedScene

@export var level_cap_base : int = 5
@export var level_cap_increase : int = 4
@export var level_cap_acceleration : int = 3

@onready var joystick : JoystickController = $"../BorderLayer/Joystick"

var attack_cooldown : float = 0.0
var weapons : Array[Weapon]
var upgrades : Array[Upgrade]

var current_xp : float = 0
var current_level : int = 1
var current_level_cap : int = 1

signal projectile_fired(projectile)
signal upgrade_added(upgrade)

func _ready():
	super()
	
	init_weapons()
	init_upgrades()
	
	current_level_cap = level_cap_base


func _physics_process(_delta):
	#update_autoattack(_delta)
	
	if DeviceDetection.is_mobile():
		current_direction = joystick.posVector
	
	super(_delta)


func _input(event):
	if DeviceDetection.is_computer():
		var x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
		var y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		current_direction = Vector2(x, y).normalized()


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
	upgrades.append(upgrade)
	
	if upgrade is PlayerUpgrade:
		upgrade.apply_upgrade(self)


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
	
	hide()
	destroyed.emit()


func has_weapon_type(weapon_type) -> bool:
	for weapon in weapons:
		if weapon_type != weapon.weapon_type:
			continue
		
		return weapon.projectile_number > 0
	
	return false


func add_xp(xp_value : float):
	current_xp += xp_value
	
	while current_xp >= current_level_cap:
		current_xp -= current_level_cap
		current_level += 1
		SignalsManager.emit_player_level_up(self)
		
		current_level_cap = level_cap_base + level_cap_increase * (current_level - 1) + level_cap_acceleration * (current_level - 2)
	
	SignalsManager.emit_player_xp_update(current_xp, current_level_cap)

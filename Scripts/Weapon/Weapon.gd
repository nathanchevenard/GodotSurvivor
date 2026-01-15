extends Node2D
class_name Weapon

enum WeaponEnum
{
	Blaster,
	Laser,
	BombLauncher,
	MineLauncher,
	Flamethrower,
	DroneLauncher,
	Shotgun,
	Boomerang,
	LightningChain,
}

@export var weapon_type : WeaponEnum
@export var target_groups : Array[String] = ["Enemy"]
@export var projectile : PackedScene
@export var damage : float
@export var range : float = 0.0
@export var cooldown : float
@export var projectile_speed : float
@export var projectile_number : float
@export var projectile_lifetime : float = 5.0
@export var projectile_coef_area_of_effect : float = 1.0
@export var projectile_size : float = 1.0
@export var is_volley : bool = false
@export var volley_duration : float = 0.5
@export var damage_delay : float = 0.0

var character : Character
var cooldown_timer : float = 0.0
var acquired_targets : Array[Node2D]

var init_cooldown : float
var init_damage : float
var init_projectile_speed : float
var init_projectile_coef_area_of_effect : float
var init_projectile_size : float
var init_range : float
var init_projectile_lifetime : float

var upgrades : Array[Upgrade]
var damage_dealt : float = 0


func _ready():
	if character == null:
		character = get_parent() as Character
	
	init_cooldown = cooldown
	init_damage = damage
	init_projectile_speed = projectile_speed
	init_projectile_coef_area_of_effect = projectile_coef_area_of_effect
	init_projectile_size = projectile_size
	init_range = range
	init_projectile_lifetime = projectile_lifetime


func _process(delta):
	if cooldown_timer < 1 / (cooldown * character.cooldown_mult):
		cooldown_timer += delta
	
	if cooldown_timer >= 1 / (cooldown * character.cooldown_mult) && check_targets():
		fire()
		cooldown_timer -= 1 / (cooldown * character.cooldown_mult)


func acquire_targets(target_number : int) -> Array[Node2D]:
	var targets : Array[Node] = character.get_sorted_closest_entities(target_groups)
	var ret : Array[Node2D] = []
	ret.assign(targets.slice(0, target_number))
	
	return ret


func check_targets() -> bool:
	acquired_targets.clear()
	
	for target in acquire_targets(get_projectile_number()):
		if range > 0 && global_position.distance_to(target.global_position) > range:
			continue
		
		acquired_targets.append(target)
	
	return acquired_targets.size() > 0


func get_projectile_number() -> int:
	var additional_chance : float = fmod(projectile_number, 1)
	if randf_range(0, 1) < additional_chance:
		return floori(projectile_number) + 1
	else:
		return floori(projectile_number)


func fire():
	if is_volley == false:
		for target in acquired_targets:
			var projectile_instance : Projectile = projectile.instantiate() as Projectile
			initialize_projectile(projectile_instance, target)
			Level.instance.projectile_handler.add_child(projectile_instance)
	else:
		var current_projectile_nb = get_projectile_number()
		for i in current_projectile_nb:
			var projectile_instance : Projectile = projectile.instantiate() as Projectile
			var target : Node2D = null
			if acquired_targets.size() > 0:
				target = acquired_targets[0]
			initialize_projectile(projectile_instance, target)
			Level.instance.projectile_handler.add_child(projectile_instance)
			
			if i < current_projectile_nb - 1:
				await get_tree().create_timer(volley_duration / current_projectile_nb).timeout
				check_targets()


func initialize_projectile(projectile_instance : Projectile, target : Node2D):
	projectile_instance.initialize(self, global_position, target, projectile_speed)


func on_upgrade_added(upgrade : Upgrade, weapon : Weapon):
	if upgrade == null || upgrade is not WeaponUpgrade || weapon == null || weapon != self:
		return
	
	upgrades.append(upgrade)
	upgrade.apply_upgrade(self)

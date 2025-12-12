extends Node
class_name Weapon

enum WeaponEnum
{
	Blaster,
	Laser,
	BombLauncher,
	MineLauncher,
}

@export var weapon_type : WeaponEnum
@export var target_groups : Array[String] = ["Enemy"]
@export var projectile : PackedScene
@export var damage : float
@export var range : float = 0.0
@export var cooldown : float
@export var projectile_speed : float
@export var projectile_number : int
@export var projectile_lifetime : float = 5.0
@export var projectile_coef_area_of_effect : float = 1.0
@export var projectile_size : float = 1.0
@export var is_volley : bool = false
@export var volley_duration : float = 0.5

var character : Character
var cooldown_timer : float = 0.0
var acquired_targets : Array[Node2D]

var init_cooldown : float
var init_damage : float
var init_projectile_speed : float
var init_projectile_coef_area_of_effect : float
var init_projectile_size : float

var upgrades : Array[Upgrade]

# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent() as Character
	
	init_cooldown = cooldown
	init_damage = damage
	init_projectile_speed = projectile_speed
	init_projectile_coef_area_of_effect = projectile_coef_area_of_effect
	init_projectile_size = projectile_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cooldown_timer < cooldown * character.cooldown_mult:
		cooldown_timer += delta
	
	if cooldown_timer >= cooldown * character.cooldown_mult && check_targets():
		fire()
		cooldown_timer = 0


func acquire_targets() -> Array[Node2D]:
	var targets : Array[Node] = character.get_sorted_closest_entities(target_groups)
	var ret : Array[Node2D] = []
	ret.assign(targets.slice(0, projectile_number))
	
	return ret


func check_targets() -> bool:
	acquired_targets.clear()
	
	for target in acquire_targets():
		if range > 0 && character.global_position.distance_to(target.global_position) > range:
			continue
		
		acquired_targets.append(target)
	
	return acquired_targets.size() > 0


func fire():
	if is_volley == false:
		for target in acquired_targets:
			var projectile_instance : Projectile = projectile.instantiate() as Projectile
			projectile_instance.initialize(self, character.global_position, target, projectile_speed)
			Level.instance.projectile_handler.add_child(projectile_instance)
	else:
		for i in projectile_number:
			var projectile_instance : Projectile = projectile.instantiate() as Projectile
			projectile_instance.initialize(self, character.global_position, null, projectile_speed)
			Level.instance.projectile_handler.add_child(projectile_instance)
			await get_tree().create_timer(volley_duration / projectile_number).timeout


func on_upgrade_added(upgrade : Upgrade):
	if upgrade == null || upgrade is not WeaponUpgrade:
		return
	
	if weapon_type == upgrade.impacted_weapon:
		upgrades.append(upgrade)
		upgrade.apply_upgrade(self)

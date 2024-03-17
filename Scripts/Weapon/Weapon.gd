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

var character : Character
var current_cooldown : float = 0.0
var acquired_targets : Array[Node2D]

var upgrades : Array[Upgrade]

# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent() as Character


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_cooldown < cooldown:
		current_cooldown += delta
	
	if current_cooldown >= cooldown && check_targets():
		fire()
		current_cooldown = 0


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
	for target in acquired_targets:
		var projectile_instance : Projectile = projectile.instantiate() as Projectile
		projectile_instance.initialize(self, character.global_position, target, projectile_speed)
		Level.instance.projectile_handler.add_child(projectile_instance)


func on_upgrade_added(upgrade : WeaponUpgrade):
	if weapon_type == upgrade.impacted_weapon:
		upgrades.append(upgrade)
		upgrade.apply_upgrade(self)

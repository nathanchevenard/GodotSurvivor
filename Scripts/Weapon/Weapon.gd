@tool
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
@export var is_enemy_weapon : bool = false
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
@export var always_fire : bool = false

@export_category("Hitbox")
@export var hitbox_collision : CollisionPolygon2D
@export var hitbox_polygon : Polygon2D
@export var hitbox_points_number : int = 16
@export var hitbox_angle : float = 90

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

var colliding_bodies : Array[Node2D]

#region Generate Hitbox
@export_tool_button("Generate Hitbox") var generate_hitbox_action = generate_hitbox

func generate_hitbox():
	if hitbox_collision == null:
		return
	
	var points : PackedVector2Array
	points.append(Vector2(0,0))
	
	for i in hitbox_points_number + 1:
		var angle = -deg_to_rad(hitbox_angle) / 2 + i * (deg_to_rad(hitbox_angle) / hitbox_points_number)
		var pos : Vector2 = range * Vector2(1, 0).rotated(angle)
		points.append(pos)
		print(pos)
	
	hitbox_collision.polygon = points
	
	if hitbox_polygon != null:
		hitbox_polygon.polygon = points

#endregion


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
	
	generate_hitbox()


func _process(delta):
	if Engine.is_editor_hint():
		return
	
	if cooldown_timer < 1 / (cooldown * character.cooldown_mult):
		cooldown_timer += delta
	
	if cooldown_timer >= 1 / (cooldown * character.cooldown_mult) && check_targets():
		fire()
		cooldown_timer -= 1 / (cooldown * character.cooldown_mult)


func acquire_targets(target_number : int) -> Array[Node2D]:
	if is_enemy_weapon == true:
		return [get_tree().get_nodes_in_group("Player")[0] as Node2D]
	
	var targets : Array[Node2D] = colliding_bodies.duplicate()
	targets.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	var valid_targets : Array[Node2D] = []
	
	for target in targets:
		var is_valid : bool = false
		
		# Target is valid if in at least one of the target_groups
		for group in target_groups:
			if target.is_in_group(group):
				is_valid = true
				break
		
		if is_valid == true:
			valid_targets.append(target)
			
			# Stop checking when we reached desired target number
			if valid_targets.size() >= target_number:
				break
	
	return valid_targets


func check_targets() -> bool:
	if always_fire == true:
		return true
	
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



func _on_hitbox_body_entered(body: Node2D) -> void:
	if colliding_bodies.has(body) == false:
		colliding_bodies.append(body)


func _on_hitbox_body_exited(body: Node2D) -> void:
	if colliding_bodies.has(body) == true:
		colliding_bodies.erase(body)

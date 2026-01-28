extends Character
class_name Player

static var instance : Player = null

@export var is_immortal : bool = false

@export var level_cap_base : int = 5
@export var level_cap_increase : int = 4
@export var level_cap_acceleration : int = 3

@export var ship_data : ShipData

@export var explosion_sprites : Array[AnimatedSprite2D]
@export var weapon_pivots_node : Node2D

@export_group("Dialogue")
@export var dialogue_start : Control
@export var dialogue_start_progress_bar : ProgressBar

@onready var joystick : JoystickController = $"../BorderLayer/Joystick"

var weapon_pivots : Array[Node2D]
var attack_cooldown : float = 0.0
var weapons : Array[Weapon]
var upgrades : Array[Upgrade]
var slot_upgrades : Array[Upgrade]

var current_xp : float = 0
var current_level : int = 1
var current_level_cap : int = 1

var weapon_pivots_dico : Dictionary[Node2D, Weapon]
var ship_upgrades : Array[ShipUpgrade]

signal upgrade_added(upgrade, weapon)


func _init():
	instance = self


func _ready():
	super()
	
	ship_data = SettingsController.selected_ship_data
	init_data()
	
	current_level_cap = level_cap_base
	init_weapon_pivots()
	
	SignalsManager.emit_player_ready(self)


func _physics_process(_delta):
	#update_autoattack(_delta)
	
	if DeviceDetection.is_mobile():
		current_direction = joystick.posVector
	
	super(_delta)


func _input(event):
	if DeviceDetection.is_computer():
		var x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		var y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		current_direction = Vector2(x, y).normalized()


func init_data():
	sprite_2d.texture = ship_data.sprite
	health_max = ship_data.health
	health = ship_data.health
	health_regen = ship_data.health_regen
	shield_max = ship_data.shield
	shield = ship_data.shield
	speed_max = ship_data.speed
	
	init_health_max = health_max
	init_health_regen = health_regen
	init_shield_max = shield_max
	init_speed_max = speed_max
	
	emit_health_changed()
	emit_shield_changed()


func init_weapon_pivots():
	for i in ship_data.weapon_pivot_positions.size():
		var pivot : Node2D = Node2D.new()
		weapon_pivots_node.add_child(pivot)
		pivot.position = ship_data.weapon_pivot_positions[i]
		pivot.rotation_degrees = ship_data.weapon_pivot_rotations[i]
		weapon_pivots.append(pivot)


func has_available_weapon_pivot():
	return weapon_pivots_dico.size() != weapon_pivots.size()


func create_weapon(weapon_scene : PackedScene, pivot : Node2D):
	var weapon : Weapon = weapon_scene.instantiate() as Weapon
	weapon.character = self
	weapons.append(weapon)
	upgrade_added.connect(weapon.on_upgrade_added)
	weapon_pivots_dico[pivot] = weapon
	pivot.add_child(weapon)


func add_upgrade(upgrade : Upgrade, pivot : Node2D):
	if upgrade is WeaponUpgrade && upgrade.upgrade_type == WeaponUpgrade.WeaponUpgradeEnum.AddWeapon:
		create_weapon(upgrade.weapon_scene, pivot)
	
	var weapon : Weapon = null
	if pivot != null:
		weapon = weapon_pivots_dico[pivot]
	
	upgrade_added.emit(upgrade, weapon)
	upgrades.append(upgrade)
	
	if slot_upgrades.has(upgrade) == false:
		if upgrade is ShipUpgrade || upgrade is WeaponUpgrade \
		&& upgrade.upgrade_type == WeaponUpgrade.WeaponUpgradeEnum.AddWeapon:
			slot_upgrades.append(upgrade)
	
	if upgrade is ShipUpgrade:
		upgrade.apply_upgrade(self)
		if ship_upgrades.has(upgrade) == false:
			ship_upgrades.append(upgrade)


func rotate_toward_mouse() -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var angle : float = global_position.angle_to_point(mouse_pos)
	rotation = lerp_angle(rotation, angle, rotation_acceleration)
	


func destroy() -> void:
	if is_immortal == true:
		return
	
	get_tree().paused = true
	
	for explosion in explosion_sprites:
		explosion.play("explode")
		await get_tree().create_timer(0.5).timeout
	
	hide()
	destroyed.emit(self)


func has_weapon_type(weapon_type) -> bool:
	for weapon in weapons:
		if weapon_type != weapon.weapon_type:
			continue
		
		return true
	
	return false


func add_xp(xp_value : float):
	current_xp += xp_value
	
	while current_xp >= current_level_cap:
		current_xp -= current_level_cap
		current_level += 1
		SignalsManager.emit_player_level_up(self)
		
		current_level_cap = level_cap_base + level_cap_increase * (current_level - 1) + level_cap_acceleration * (current_level - 2)
	
	SignalsManager.emit_player_xp_update(current_xp, current_level_cap)


func dialogue_area_enter(duration : float):
	dialogue_start.show()
	dialogue_start_progress_bar.max_value = duration


func dialogue_area_exit():
	dialogue_start.hide()

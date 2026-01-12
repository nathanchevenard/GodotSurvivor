extends Node
class_name UpgradeSystem

@export var canvas_layer : CanvasLayer
@export var container : Container
@export var button_scene : PackedScene
@export var upgrades : Array[Upgrade]

@export var ship_upgrade_layout_pivot : Control
@export var ship_upgrades_pivot : Control
@export var ship_upgrade_slot_scene : PackedScene

var cooldown : float = 0
var timer : float = 9
var upgrades_count : int = 0

var upgrades_number : int = 3
var button_instances : Array[UpgradeButton]
var weapon_pivot_buttons : Array[WeaponPivotButton]
var ship_upgrade_slots : Array[ShipUpgradeSlot]
var selected_upgrade : Upgrade
var selected_upgrade_button : UpgradeButton
var new_upgrade_probability : float = 0.5
var stacked_upgrade_count : int = 0


func _init() -> void:
	SignalsManager.player_level_up.connect(_on_player_level_up)
	SignalsManager.weapon_pivot_button_pressed.connect(_on_weapon_pivot_button_pressed)
	SignalsManager.game_pause.connect(_on_game_paused)
	SignalsManager.game_unpause.connect(_on_game_unpaused)
	SignalsManager.player_ready.connect(_on_player_ready)


func _process(delta):
	if cooldown <= 0:
		return
	
	if PauseSystem.instance.is_paused == true:
		return
	
	timer += delta
	
	if timer >= cooldown:
		start_upgrade()
		timer = 0.0


func _on_player_ready(player : Player):
	init_buttons(player)
	set_weapon_pivot_buttons_visible(false)
	start_upgrade()


func init_buttons(player : Player):
	var upgrade_layout : ShipUpgradeLayout = player.ship_data.ship_upgrade_layout_scene.instantiate() as ShipUpgradeLayout
	ship_upgrade_layout_pivot.add_child(upgrade_layout)
	ship_upgrade_layout_pivot.move_child(upgrade_layout, 0)
	weapon_pivot_buttons = upgrade_layout.weapon_pivot_buttons
	
	for i in player.weapon_pivots.size():
		weapon_pivot_buttons[i].weapon_pivot = player.weapon_pivots[i]
	
	for i in player.ship_data.ship_upgrades_number:
		var ship_upgrade_slot : ShipUpgradeSlot = ship_upgrade_slot_scene.instantiate() as ShipUpgradeSlot
		ship_upgrades_pivot.add_child(ship_upgrade_slot)
		ship_upgrade_slots.append(ship_upgrade_slot)


func start_upgrade():
	PauseSystem.instance.start_pause(true)
	display_upgrades()


func display_upgrades():
	var player : Player = get_tree().get_nodes_in_group("Player")[0] as Player
	# Stores the upgrades the player does not have yet and that they can unlock
	var available_new_upgrades : Array[Upgrade] = get_available_new_upgrades(player)
	# Stores the upgrades the player already has and that have not been picked yet
	var slot_upgrades : Array[Upgrade] = player.slot_upgrades.duplicate()
	
	# TEMP: On first upgrade, have only weapon upgrades to start with one
	if upgrades_count == 0:
		var weapon_upgrades : Array[Upgrade] = upgrades.duplicate()
		for upgrade in upgrades:
			if upgrade is not WeaponUpgrade:
				weapon_upgrades.erase(upgrade)
		for i in upgrades_number:
			var upgrade : Upgrade = weapon_upgrades.pick_random()
			create_upgrade_button(upgrade)
			weapon_upgrades.erase(upgrade)
	else:
		for i in upgrades_number:
			var upgrade_data : Array = pick_random_upgrade(i, player, available_new_upgrades, slot_upgrades)
			var upgrade : Upgrade = upgrade_data[0]
			var weapon_pivot : Node2D = upgrade_data[1]
			create_upgrade_button(upgrade, weapon_pivot)
			available_new_upgrades.erase(upgrade)
			
			# If upgrade is not a new one, prevent next choices from having the chosen upgrade
			if upgrade_data[2] == false:
				if weapon_pivot != null:
					slot_upgrades.erase(player.weapon_pivots_dico[weapon_pivot].upgrades[0])
				else:
					slot_upgrades.erase(upgrade)
	
	set_weapon_pivot_buttons_visible(false)
	canvas_layer.show()
	button_instances[0].button.call_deferred("grab_focus")


func get_available_new_upgrades(player : Player) -> Array[Upgrade]:
	var available_new_upgrades : Array[Upgrade] = upgrades.duplicate()
	
	for upgrade in upgrades:
		# Remove add weapon upgrades if ship does not have remaining slots
		if upgrade is WeaponUpgrade:
			if upgrade.upgrade_type == WeaponUpgrade.WeaponUpgradeEnum.AddWeapon && player.has_available_weapon_pivot() == false:
				available_new_upgrades.erase(upgrade)
		
		# Remove ship upgrades if ship does not have remaining slots, or if ship already has the upgrade
		if upgrade is ShipUpgrade:
			if player.ship_upgrades.size() >= player.ship_data.ship_upgrades_number || player.ship_upgrades.has(upgrade) == true:
				available_new_upgrades.erase(upgrade)
	
	return available_new_upgrades


func pick_random_upgrade(i : int, player : Player, possible_upgrades : Array[Upgrade], \
slot_upgrades : Array[Upgrade]) -> Array:
	var upgrade : Upgrade = null
	var weapon_pivot : Node2D = null
	var is_new_upgrade : bool = false
	var possible_weapons : Array[Weapon] = player.weapons.duplicate()
	var data : Array
	
	# First choice is always a new upgrade (if ship can have one)
	if i == 0:
		if possible_upgrades.size() > 0:
			upgrade = possible_upgrades.pick_random()
			possible_upgrades.erase(upgrade)
			is_new_upgrade = true
		else:
			data = pick_random_possessed_upgrade(player, slot_upgrades, possible_weapons)
			possible_weapons = data[2]
	# Other choices that are not the last one can be either new upgrades or upgrade improvements
	elif i < upgrades_number - 1:
		if i < upgrades_number - player.slot_upgrades.size() \
		|| possible_upgrades.size() > 0 && randf_range(0, 1) > 1:
			upgrade = possible_upgrades.pick_random()
			possible_upgrades.erase(upgrade)
			is_new_upgrade = true
		else:
			data = pick_random_possessed_upgrade(player, slot_upgrades, possible_weapons)
			possible_weapons = data[2]
	# Last choice is always a possessed upgrade improvement
	else:
		data = pick_random_possessed_upgrade(player, slot_upgrades, possible_weapons)
		possible_weapons = data[2]
	
	if data.size() > 0:
		upgrade = data[0]
		weapon_pivot = data[1]
	
	return [upgrade, weapon_pivot, is_new_upgrade]


func pick_random_possessed_upgrade(player : Player, slot_upgrades : Array[Upgrade], \
possible_weapons : Array[Weapon]) -> Array:
	var upgrade : Upgrade = slot_upgrades.pick_random()
	var weapon_pivot : Node2D
	
	while upgrade is WeaponUpgrade && possible_weapons.size() == 0:
		upgrade = slot_upgrades.pick_random()
	if upgrade is WeaponUpgrade:
		var weapon : Weapon = possible_weapons.pick_random()
		possible_weapons.erase(weapon)
		upgrade = weapon.upgrades[0].weapon_upgrades.pick_random()
		weapon_pivot = player.weapon_pivots_dico.find_key(weapon)
	
	return [upgrade, weapon_pivot, possible_weapons]


func create_upgrade_button(upgrade : Upgrade, weapon_pivot : Node2D = null):
	var button = button_scene.instantiate() as UpgradeButton
	button.init(upgrade, weapon_pivot)
	button.upgrade_pressed.connect(_on_upgrade_pressed) 
	button_instances.append(button)
	container.add_child.call_deferred(button)


func _on_upgrade_pressed(upgrade_button : UpgradeButton):
	var upgrade : Upgrade = upgrade_button.upgrade
	if upgrade is WeaponUpgrade \
	&& (upgrade as WeaponUpgrade).upgrade_type == WeaponUpgrade.WeaponUpgradeEnum.AddWeapon:
		set_weapon_pivot_buttons_visible(true)
		
		if selected_upgrade_button != null:
			selected_upgrade_button.unselect()
		
		selected_upgrade = upgrade
		selected_upgrade_button = upgrade_button
		upgrade_button.select()
		
		return
	
	apply_upgrade(upgrade, upgrade_button.weapon_pivot)


func apply_upgrade(upgrade : Upgrade, pivot : Node2D = null):
	upgrades_count += 1
	stacked_upgrade_count = clampi(stacked_upgrade_count - 1, 0, 100000)
	
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for player : Player in players:
		if upgrade is ShipUpgrade && player.ship_upgrades.has(upgrade) == false:
			ship_upgrade_slots[player.ship_upgrades.size()].icon.texture = upgrade.icon
		
		player.add_upgrade(upgrade, pivot)
		
		if upgrade.pick_max_number > 0 && player.upgrades.count(upgrade) >= upgrade.pick_max_number:
			upgrades.erase(upgrade)
	
	for button in button_instances:
		button.queue_free()
	
	button_instances.clear()
	canvas_layer.hide()
	
	if stacked_upgrade_count == 0:
		PauseSystem.instance.stop_pause_with_delay(PauseSystem.instance.pause_delay)
	else:
		display_upgrades()


func set_weapon_pivot_buttons_visible(value : bool):
	var player : Player = get_tree().get_nodes_in_group("Player")[0] as Player
	
	for button in weapon_pivot_buttons:
		if value == true && player.weapon_pivots_dico.has(button.weapon_pivot) == false:
			button.show()
		else:
			button.hide()


func _on_weapon_pivot_button_pressed(button : WeaponPivotButton):
	apply_upgrade(selected_upgrade, button.weapon_pivot)
	button.weapon_texture.texture = selected_upgrade.icon
	set_weapon_pivot_buttons_visible(false)
	selected_upgrade = null


func _on_player_level_up(_player : Player):
	stacked_upgrade_count += 1
	start_upgrade()


func _on_game_paused():
	canvas_layer.show()


func _on_game_unpaused():
	canvas_layer.hide()

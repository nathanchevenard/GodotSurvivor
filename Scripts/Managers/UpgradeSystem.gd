extends Node
class_name UpgradeSystem

@export var canvas_layer : CanvasLayer
@export var container : Container
@export var button_scene : PackedScene
@export var upgrades : Array[Upgrade]

@export var weapon_pivot_buttons : Array[WeaponPivotButton]
@export var ship_upgrade_texture_rects : Array[TextureRect]

var cooldown : float = 0
var timer : float = 9
var upgrades_count : int = 0

var upgrades_number : int = 3
var button_instances : Array[UpgradeButton]
var selected_upgrade : Upgrade
var selected_upgrade_button : UpgradeButton

var stacked_upgrade_count : int = 0


func _init() -> void:
	SignalsManager.player_level_up.connect(_on_player_level_up)
	SignalsManager.weapon_pivot_button_pressed.connect(_on_weapon_pivot_button_pressed)
	SignalsManager.game_pause.connect(_on_game_paused)
	SignalsManager.game_unpause.connect(_on_game_unpaused)


func _ready() -> void:
	start_upgrade()
	
	set_weapon_pivot_buttons_visible(false)


func _process(delta):
	if cooldown <= 0:
		return
	
	if PauseSystem.instance.is_paused == true:
		return
	
	timer += delta
	
	if timer >= cooldown:
		start_upgrade()
		timer = 0.0


func start_upgrade():
	PauseSystem.instance.start_pause(true)
	display_upgrades()


func display_upgrades():
	var available_upgrades : Array[Upgrade] = upgrades.duplicate()
	
	var player : Player = get_tree().get_nodes_in_group("Player")[0] as Player
	
	for upgrade in upgrades:
		if upgrade is WeaponUpgrade:
			if upgrade.must_have_weapon && player.has_weapon_type(upgrade.impacted_weapon) == false\
			|| upgrade.upgrade_type == WeaponUpgrade.WeaponUpgradeEnum.AddWeapon && player.has_available_weapon_pivot() == false:
				available_upgrades.erase(upgrade)
		
		if upgrade is PlayerUpgrade:
			if player.ship_upgrades.size() >= player.ship_upgrades_number && player.ship_upgrades.has(upgrade) == false:
				available_upgrades.erase(upgrade)
		
		# TEMP: On first upgrade, have only weapon upgrades to start with one
		if upgrades_count == 0 && upgrade is not WeaponUpgrade:
			available_upgrades.erase(upgrade)
	
	for i in upgrades_number:
		var button = button_scene.instantiate() as UpgradeButton
		var upgrade : Upgrade = available_upgrades.pick_random()
		available_upgrades.erase(upgrade)
		button.init(upgrade)
		button.upgrade_pressed.connect(_on_upgrade_pressed) 
		button_instances.append(button)
		
		container.add_child.call_deferred(button)
	
	set_weapon_pivot_buttons_visible(false)
	canvas_layer.show()
	button_instances[0].button.call_deferred("grab_focus")


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
	
	apply_upgrade(upgrade)


func apply_upgrade(upgrade : Upgrade, pivot : Node2D = null):
	upgrades_count += 1
	stacked_upgrade_count = clampi(stacked_upgrade_count - 1, 0, 100000)
	
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for player : Player in players:
		if upgrade is PlayerUpgrade && player.ship_upgrades.has(upgrade) == false:
			ship_upgrade_texture_rects[player.ship_upgrades.size()].texture = upgrade.icon
		
		player.add_upgrade(upgrade, pivot)
		
		if upgrade.pick_max_number > 0 && player.upgrades.count(upgrade) >= upgrade.pick_max_number:
			upgrades.erase(upgrade)
	
	for button in button_instances:
		button.queue_free()
	
	button_instances.clear()
	canvas_layer.hide()
	
	if stacked_upgrade_count == 0:
		PauseSystem.instance.stop_pause(true)
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

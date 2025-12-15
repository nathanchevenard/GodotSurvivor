extends Node
class_name UpgradeSystem

@export var container : Container
@export var button_scene : PackedScene
@export var upgrades : Array[Upgrade]

var cooldown : float = 0
var timer : float = 9
var upgrades_count : int = 0

var upgrades_number : int = 3
var button_instances : Array[UpgradeButton]

var stacked_upgrade_count : int = 0


func _init() -> void:
	SignalsManager.player_level_up.connect(_on_player_level_up)


func _ready() -> void:
	start_upgrade()


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
		if upgrade is WeaponUpgrade && upgrade.must_have_weapon && player.has_weapon_type(upgrade.impacted_weapon) == false:
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
	
	button_instances[0].button.call_deferred("grab_focus")


func _on_upgrade_pressed(upgrade : Upgrade):
	upgrades_count += 1
	stacked_upgrade_count = clampi(stacked_upgrade_count - 1, 0, 100000)
	
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for player : Player in players:
		player.add_upgrade(upgrade)
		
		if upgrade.pick_max_number > 0 && player.upgrades.count(upgrade) >= upgrade.pick_max_number:
			upgrades.erase(upgrade)
	
	for button in button_instances:
		button.queue_free()
	
	button_instances.clear()
	
	if stacked_upgrade_count == 0:
		PauseSystem.instance.stop_pause(true)
	else:
		display_upgrades()


func _on_player_level_up(_player : Player):
	stacked_upgrade_count += 1
	start_upgrade()

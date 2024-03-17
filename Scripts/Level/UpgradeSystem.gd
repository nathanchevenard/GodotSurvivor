extends Node
class_name UpgradeSystem

@export var container : Container
@export var button_scene : PackedScene
@export var upgrades : Array[Upgrade]

var cooldown : float = 10
var timer : float = 9

var upgrades_number : int = 3
var button_instances : Array[UpgradeButton]

func _process(delta):
	if PauseSystem.instance.is_paused == true:
		return
	
	timer += delta
	
	if timer >= cooldown:
		upgrade()
		timer = 0.0


func upgrade():
	PauseSystem.instance.start_pause()
	display_upgrades()


func display_upgrades():
	for i in upgrades_number:
		var button = button_scene.instantiate() as UpgradeButton
		button.init(upgrades.pick_random())
		button.upgrade_pressed.connect(_on_upgrade_pressed) 
		button_instances.append(button)
		
		container.add_child.call_deferred(button)


func _on_upgrade_pressed(upgrade : Upgrade):
	var players : Array[Node] = get_tree().get_nodes_in_group("Player")
	
	for player : Player in players:
		player.add_upgrade(upgrade)
	
	for button in button_instances:
		button.queue_free()
	
	button_instances.clear()
	
	PauseSystem.instance.stop_pause()

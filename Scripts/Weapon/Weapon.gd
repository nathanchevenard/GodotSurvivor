extends Node
class_name Weapon

@export var target_groups : Array[String]
@export var projectile : PackedScene
@export var damage : float
@export var range : float
@export var projectile_speed : float
@export var cooldown : float
@export var projectile_number : int

var character : Character

var current_cooldown : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent() as Character


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_cooldown < cooldown:
		current_cooldown += delta
	
	if current_cooldown >= cooldown:
		fire()
		current_cooldown = 0


func acquire_targets() -> Array[Node2D]:
	var targets : Array[Node] = character.get_sorted_closest_entities(target_groups)
	var ret : Array[Node2D] = []
	ret.assign(targets.slice(0, projectile_number))
	
	return ret


func fire():
	for target in acquire_targets():
		var projectile_instance : Projectile = projectile.instantiate() as Projectile
		projectile_instance.initialize(self, character.global_position, target, projectile_speed)
		Level.instance.projectile_handler.add_child(projectile_instance)

@tool
extends Weapon
class_name LightningChain

@export var rebound_number : int = 2
@export var rebound_range : float = 100

var init_rebound_number : int
var init_rebound_range : float


func _ready():
	super()
	
	init_rebound_number = rebound_number
	init_rebound_range = rebound_range


func initialize_projectile(projectile_instance : Projectile, target : Node2D):
	super(projectile_instance, target)
	if projectile_instance is Lightning:
		projectile_instance.rebound_number = rebound_number
		projectile_instance.rebound_range = rebound_range

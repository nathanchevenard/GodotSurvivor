extends Enemy
class_name Ravager

@export var charge_cooldown : float = 10.0
@export var charge_channelling_duration : float = 1.0
@export var charge_duration : float = 1.0
@export var charge_speed : float = 1
@export var charge_range_coefficient : float = 0.9

var current_charge_cooldown : float = 0.0
var current_charge_time : float = 0.0
var current_charge_channelling_time : float = 0.0

var is_channelling : bool = false
var is_charging : bool = false

var direction : Vector2 = Vector2.ZERO
var charge_direction : Vector2 = Vector2.ZERO

func _ready():
	super()
	
	current_charge_cooldown = charge_cooldown


func _physics_process(delta):
	if is_charging == false:
		super(delta)
		current_charge_cooldown += delta
		
		if current_charge_cooldown >= charge_cooldown && can_charge():
			current_charge_cooldown = 0.0
			start_charge()
	else:
		update_shield(delta)
		
		global_position = global_position + direction * charge_speed * delta
		
		if is_channelling:
			current_charge_channelling_time += delta
			if current_charge_channelling_time >= charge_channelling_duration:
				is_channelling = false
				start_charge_execution()
		else:
			current_charge_time += delta
			if current_charge_time >= charge_duration:
				stop_charge()


func start_charge():
	is_charging = true
	is_channelling = true
	look_at(closest_player.global_position)
	direction = Vector2.ZERO
	charge_direction = (closest_player.global_position - global_position).normalized()
	current_charge_channelling_time = 0.0
	current_charge_time = 0.0


func start_charge_execution():
	direction = charge_direction


func stop_charge():
	is_charging = false


func can_charge() -> bool:
	if closest_player != null && (closest_player.global_position - global_position).length() < charge_duration * charge_speed * charge_range_coefficient:
		return true
	else:
		return false

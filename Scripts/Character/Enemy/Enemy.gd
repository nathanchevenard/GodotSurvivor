extends Character
class_name Enemy

@export var attack : int = 10
@export var attack_cooldown : float = 1.0
@export var xp_value : int = 1
@export var xp_modulate_color : Color = Color.WHITE
@export var xp_scene_scale : float = 1

var characters_in_range : Array[Character] = []
var current_attack_cooldown : float = 0.0

var update_closest_player_cooldown : float = 3.0
var current_update_closest_player_cooldown : float = 0.0
var closest_player : Player

func _init():
	Level.instance.enemies.append(self)
	
	current_update_closest_player_cooldown = update_closest_player_cooldown


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	current_update_closest_player_cooldown += delta
	
	if current_update_closest_player_cooldown >= update_closest_player_cooldown:
		current_update_closest_player_cooldown = 0.0
		closest_player = get_closest_entity(target_groups) as Player
	
	if closest_player == null:
		push_warning("No player found for Enemy.")
		return
	
	current_direction = closest_player.global_position - global_position
	
	super(delta)
	
	update_attack(delta)


func update_attack(delta: float):
	if current_attack_cooldown < attack_cooldown:
		current_attack_cooldown += delta
	
	if current_attack_cooldown >= attack_cooldown && characters_in_range.size() > 0:
		trigger_attack()
		current_attack_cooldown = 0


func trigger_attack():
	characters_in_range[0].take_damage(attack)


func _on_area_2d_body_entered(body: Node2D):
	for target_group in target_groups:
		if body.is_in_group(target_group):
			var character : Character = body as Character
			if character != null:
				characters_in_range.append(character)
				update_attack(0)


func _on_area_2d_body_exited(body: Node2D):
	var character : Character = body as Character
	if character != null && characters_in_range.has(character):
		characters_in_range.erase(character)


func destroy():
	Level.instance.enemies.erase(self)
	SignalsManager.emit_enemy_died(self)
	
	super()

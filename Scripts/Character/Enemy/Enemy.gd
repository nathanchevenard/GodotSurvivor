extends Character
class_name Enemy

@export var attack : int = 10
@export var cooldown : float = 1.0

var characters_in_range : Array[Character] = []
var current_cooldown : float = 0.0

func _init():
	Level.instance.enemies.append(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var player = get_closest_entity(target_groups)
	
	if player == null:
		push_warning("No player found for Enemy.")
		return
	
	current_direction = player.global_position - global_position
	
	super(delta)
	
	update_attack(delta)


func update_attack(delta: float):
	if current_cooldown < cooldown:
		current_cooldown += delta
	
	if current_cooldown >= cooldown && characters_in_range.size() > 0:
		current_cooldown = 0
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
	super()

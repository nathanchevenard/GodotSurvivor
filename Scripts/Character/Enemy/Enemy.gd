extends Character
class_name Enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var player = get_closest_entity(target_groups)
	
	if player == null:
		push_warning("No player found for Enemy.")
		return
	
	current_direction = player.global_position - global_position
	
	super(delta)


func _on_area_2d_body_entered(body: Node2D):
	for target_group in target_groups:
		if body.is_in_group(target_group):
			var player : Player = body as Player
			player.destroy()

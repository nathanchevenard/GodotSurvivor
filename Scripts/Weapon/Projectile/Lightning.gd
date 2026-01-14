extends Projectile
class_name Lightning

var rebound_number : int = 2
var rebound_range : float = 100
var current_target : Character


func initialize(weapon : Weapon, starting_position : Vector2, target: Node2D, speed : float):
	super(weapon, starting_position, target, speed)
	current_target = target


func _process(delta):
	super(delta)
	
	if current_target == null || current_target.health == 0:
		find_new_target()


func damage_character(character : Character):
	super(character)
	find_new_target()


func find_new_target():
	if damaged_characters.size() > rebound_number:
		queue_free()
	else:
		var new_target : Character = get_untouched_enemy_around()
		if new_target == null:
			queue_free()
			return
		
		set_target_pos(new_target.global_position)
		current_target = new_target


func get_untouched_enemy_around() -> Character:
	var closest_enemies : Array[Node] = get_sorted_closest_entities(weapon.target_groups)
	if closest_enemies.size() == 0:
		return null
	
	for enemy : Character in closest_enemies:
		if damaged_characters.has(enemy):
			continue
		if (enemy.global_position - global_position).length() > rebound_range:
			return null
		
		return enemy
	
	return null


func get_sorted_closest_entities(group_names : Array[String]) -> Array[Node]:
	var entities : Array[Node] = []
	
	for group_name in group_names:
		entities.append_array(get_tree().get_nodes_in_group(group_name))
	
	entities.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	return entities

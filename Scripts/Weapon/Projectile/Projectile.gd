extends Node2D
class_name Projectile

@export var sprite : AnimatedSprite2D

var speed : float
var current_direction : Vector2
var lifetime : float

var current_lifetime : float = 0.0
var weapon : Weapon
var init_damage : float
var target_groups : Array[String]

var damage_delay : float
var current_damage_timer : float = 0
var colliding_characters : Array[Character]

var has_damaged_character : bool = false
var damaged_characters : Array[Character]


func initialize(weapon : Weapon, starting_position : Vector2, target: Node2D, speed : float):
	global_position = starting_position
	scale *= Vector2(weapon.projectile_size, weapon.projectile_size)
	self.weapon = weapon
	self.speed = speed
	target_groups = weapon.target_groups
	damage_delay = weapon.damage_delay
	
	if weapon != null:
		lifetime = weapon.projectile_lifetime
		init_damage = weapon.damage * weapon.character.damage_mult
	
	if target != null:
		set_target_pos(target.global_position)


func set_target_pos(pos : Vector2):
	current_direction = (pos - global_position).normalized()
	rotation = global_position.angle_to_point(pos)


func _physics_process(delta):
	var velocity : Vector2 = current_direction * speed * delta
	global_position += velocity


func _process(delta):
	if lifetime > 0:
		current_lifetime += delta
		if current_lifetime >= lifetime:
			queue_free()
	
	if damage_delay > 0:
		current_damage_timer += delta
		if current_damage_timer >= damage_delay:
			current_damage_timer -= damage_delay
			damage_colliding_characters()


func damage_colliding_characters():
	for character in colliding_characters:
		damage_character(character)


func damage_character(character : Character):
	if character.health <= 0:
		return
	
	if damaged_characters.has(character) == false:
		damaged_characters.append(character)
	has_damaged_character = true
	
	if weapon != null:
		character.take_damage(roundi(weapon.damage * weapon.character.damage_mult))
	else:
		character.take_damage(roundi(init_damage))


func _on_body_entered(body : Node2D):
	for target_group in target_groups:
		if body.is_in_group(target_group) == true:
			on_enemy_collision(body)


func _on_body_exited(body : Node2D):
	var character : Character = body as Character
	colliding_characters.erase(character)


func on_enemy_collision(body : Node2D):
	var character : Character = body as Character
	
	if damage_delay > 0:
		colliding_characters.append(character)
	
	damage_character(character)

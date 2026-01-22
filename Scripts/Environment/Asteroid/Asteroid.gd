@tool
extends CharacterBody2D
class_name Asteroid

enum ASTEROID_SIZE
{
	SMALL,
	MEDIUM,
	BIG
}

@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

@export var size : ASTEROID_SIZE = ASTEROID_SIZE.MEDIUM:
	set(value):
		if value != size:
			size = value
			size_changed.emit()

@export var direction : Vector2 = Vector2.RIGHT
@export var speed_min : float = 50.0
@export var speed_max : float = 150.0
@export var torque : float = 50.0
@export var size_min : float = 0.3
@export var size_max : float = 2.5
@export var attack : int = 10
@export var cooldown : float = 1.0
@export var player_distance_destroyed : float = 1000

@export var asteroid_size_array : Array[AsteroidSize]

var characters_in_range : Array[Character] = []
var current_cooldown : float = 0.0
var players : Array[Node]

var speed : float

signal size_changed
signal destroyed

func _ready():
	if Engine.is_editor_hint():
		set_physics_process(false)
	
	size_changed.connect(update_size)
	update_size()
	
	var random_angle : float = randf_range(0.0, 2 * PI)
	direction = Vector2.RIGHT.rotated(random_angle) 
	
	var random_size : float = randf_range(size_min, size_max)
	global_scale = Vector2(random_size, random_size)
	
	speed = randf_range(speed_min, speed_max)
	
	Level.instance.asteroids.append(self)
	
	players = get_tree().get_nodes_in_group("Player")


func _physics_process(delta):
	var velocity : Vector2 = speed * direction * delta
	global_position += velocity
	
	rotation_degrees += torque * delta
	
	if current_cooldown < cooldown:
		current_cooldown += delta
	
	if current_cooldown >= cooldown && characters_in_range.size() > 0:
		current_cooldown = 0
		characters_in_range[0].take_damage(attack)
	
	var is_far_from_all_players : bool = true
	for player : Player in players:
		if (player.global_position - global_position).length() <= player_distance_destroyed:
			is_far_from_all_players = false
			break
	
	if is_far_from_all_players == true:
		destroy()


func destroy() -> void:
	Level.instance.asteroids.erase(self)
	destroyed.emit()
	queue_free()


func update_size() -> void:
	assert(size in range(asteroid_size_array.size()), "The given size" + str(size) + "is not a valid asteroid size index")
	
	var asteroid_size = asteroid_size_array[size]
	
	sprite_2d.texture = asteroid_size.texture
	collision_shape_2d.shape = asteroid_size.shape


func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		var character : Character = body as Character
		if character != null:
			character.take_damage(attack)
			characters_in_range.append(character)
			current_cooldown = 0.0


func _on_area_2d_body_exited(body: Node2D):
	var character : Character = body as Character
	if character != null && characters_in_range.has(character):
		characters_in_range.erase(character)

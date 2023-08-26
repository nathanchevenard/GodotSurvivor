@tool
extends Area2D
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
@export var speed : float = 200.0
@export var torque : float = 50.0

@export var asteroid_size_array : Array[AsteroidSize]

signal size_changed
signal destroyed

func _ready():
	if Engine.is_editor_hint():
		set_physics_process(false)
	
	size_changed.connect(update_size)
	update_size()


func _physics_process(delta):
	var velocity : Vector2 = speed * direction * delta
	global_position += velocity
	
	rotation_degrees += torque * delta


func _on_body_entered(body: Player):
	body.destroy()


func destroy() -> void:
	destroyed.emit()
	queue_free()


func update_size() -> void:
	assert(size in range(asteroid_size_array.size()), "The given size" + str(size) + "is not a valid asteroid size index")
	
	var asteroid_size = asteroid_size_array[size]
	
	sprite_2d.texture = asteroid_size.texture
	collision_shape_2d.shape = asteroid_size.shape

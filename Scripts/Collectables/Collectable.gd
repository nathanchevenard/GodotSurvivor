extends Node2D
class_name Collectable

@export var sprite : Sprite2D

var is_collecting : bool = false
var collecting_player : Player
var speed_increment : float = 0.5
var current_speed : float = 0

signal destroy(Collectable)


func _physics_process(delta: float) -> void:
	if is_collecting == false:
		return
	
	current_speed += speed_increment
	
	if (collecting_player.global_position - global_position).length() <= 2 * current_speed:
		on_player_collect(collecting_player)
	
	global_position += (collecting_player.global_position - global_position).normalized() * current_speed


func on_player_collect(player : Player):
	destroy.emit(self)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_collecting = true
		collecting_player = body

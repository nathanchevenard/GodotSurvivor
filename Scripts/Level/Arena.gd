@tool
extends Node2D
class_name Arena

@export var wall_scene : PackedScene
@export var wall_size : Vector2 = Vector2(200, 50)
@export var arena_definition : int = 8
@export var arena_radius : float = 50

var walls : Array[Node]

@export_tool_button("Generate Arena") var generate_arena_action = generate_arena

func generate_arena():
	for wall in walls:
		wall.queue_free()
	walls.clear()
	
	for i in arena_definition:
		var wall : Node2D = wall_scene.instantiate()
		walls.append(wall)
		
		wall.scale = wall_size
		var angle = i * 2 * PI / arena_definition
		wall.position = (arena_radius + wall_size.y / 2) * Vector2(cos(angle), sin(angle))
		wall.rotation = (PI / 2) + angle
		
		add_child(wall)
		wall.owner = get_tree().edited_scene_root


func _ready() -> void:
	if SettingsController.is_arena_mode == false:
		process_mode = Node.PROCESS_MODE_DISABLED
		hide()
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
		show()

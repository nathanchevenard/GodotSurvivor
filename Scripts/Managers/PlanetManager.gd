extends Node2D
class_name PlanetManager

static var instance : PlanetManager

@export var planet_scene : PackedScene
@export var planet_number : int = 3
@export var spawn_radius_min : float = 00
@export var spawn_radius_max : float = 700
@export var planet_names : Array[String]
@export_multiline var planet_descs : Array[String]
@export var planet_icons : Array[Texture2D]
@export var planet_sprite_frames : Array[SpriteFrames]

var planets : Array[Planet]
var available_names : Array[String]
var available_descs : Array[String]
var available_icons : Array[Texture2D]
var available_sprite_frames : Array[SpriteFrames]


func _init() -> void:
	instance = self


func _ready() -> void:
	available_names = planet_names.duplicate()
	available_descs = planet_descs.duplicate()
	available_icons = planet_icons.duplicate()
	available_sprite_frames = planet_sprite_frames.duplicate()
	generate_planets()


func generate_planets():
	var angle : float = randf_range(0, 2 * PI)
	var pos : Vector2 = Vector2(1, 0)
	
	for i in planet_number:
		pos = randf_range(spawn_radius_min, spawn_radius_max) * Vector2(1, 0).rotated(angle)
		angle += 2 * PI / planet_number
		
		var planet : Planet = planet_scene.instantiate() as Planet
		planets.append(planet)
		add_child(planet)
		
		var planet_name : String = available_names.pick_random()
		planet.planet_name = planet_name
		available_names.erase(planet_name)
		
		var planet_desc : String = available_descs.pick_random()
		planet.planet_desc = planet_desc
		available_descs.erase(planet_desc)
		
		var planet_icon : Texture2D = available_icons.pick_random()
		planet.planet_icon = planet_icon
		available_icons.erase(planet_icon)
		
		var sprite_frames : SpriteFrames = available_sprite_frames.pick_random()
		planet.animated_sprite.sprite_frames = sprite_frames
		planet.animated_sprite.play("default")
		available_sprite_frames.erase(sprite_frames)
		
		planet.global_position = pos

extends Node
class_name SettingsController

static var is_joystick_floating : bool = true

@onready var settings = $Settings
@onready var player = $"../Player"
@onready var projectile_factory = $"../ProjectileFactory"
@onready var asteroid_handler = %AsteroidHandler
@onready var joystick = $"../BorderLayer/Joystick"


func _on_floating_joystick_toggled(toggled_on):
	is_joystick_floating = toggled_on


func _on_display_mode_item_selected(index):
	match index:
		0:
			index = 0
		1:
			index = 1
		_:
			index = 6
	
	DisplayServer.screen_set_orientation(index)


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level/Level.tscn")

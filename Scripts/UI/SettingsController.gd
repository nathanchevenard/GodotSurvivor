extends Node
class_name SettingsController

static var is_arena_mode : bool = true
static var is_joystick_floating : bool = true

@export var arena_mode_button : CheckButton
@export var joystick_floating_button : CheckButton


func _ready() -> void:
	arena_mode_button.button_pressed = is_arena_mode
	joystick_floating_button.button_pressed = is_joystick_floating


func _on_arena_mode_toggled(toggled_on: bool) -> void:
	is_arena_mode = toggled_on


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


func _on_quit_button_pressed() -> void:
	get_tree().quit()

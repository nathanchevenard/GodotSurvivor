extends Node2D
class_name JoystickController

var posVector: Vector2


func _init() -> void:
	if DeviceDetection.is_mobile() == true:
		SignalsManager.game_freeze.connect(_on_game_froze)
		SignalsManager.game_unfreeze.connect(_on_game_unfroze)
		SignalsManager.game_unpause_delay_start.connect(_on_game_unfroze)


func _input(event):
	if SettingsController.is_joystick_floating && event.is_action_pressed("left_click") \
	&& DeviceDetection.is_mobile() && visible == true:
		global_position = get_global_mouse_position()


func _on_game_froze():
	hide()


func _on_game_unfroze():
	show()

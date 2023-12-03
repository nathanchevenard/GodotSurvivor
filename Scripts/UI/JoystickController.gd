extends Node2D
class_name JoystickController

var posVector: Vector2

func _input(event):
	if SettingsController.is_joystick_floating && event.is_action_pressed("left_click") && DeviceDetection.is_mobile():
		global_position = get_global_mouse_position()

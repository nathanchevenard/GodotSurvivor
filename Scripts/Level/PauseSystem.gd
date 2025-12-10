extends Node
class_name PauseSystem

static var instance : PauseSystem = null

var is_paused : bool = false
var is_pause_allowed : bool = true

func _init():
	if instance != null:
		push_warning("Multiple instances of PauseSystem tried to instantiate.")
		return
	
	instance = self

func _input(event):
	if event.is_action_pressed("toggle_pause") && is_pause_allowed == true:
		toggle_pause()


func toggle_pause():
	if is_paused == true:
		stop_pause()
	else:
		start_pause()


func start_pause(disallow_pause : bool = false):
	get_tree().paused = true
	is_paused = true
	
	if disallow_pause == true:
		is_pause_allowed = false


func stop_pause(reallow_pause : bool = false):
	get_tree().paused = false
	is_paused = false
	
	if reallow_pause == true:
		is_pause_allowed = true


func _on_retry_button_pressed():
	PauseSystem.instance.stop_pause()
	get_tree().change_scene_to_file("res://Scenes/Settings/Settings.tscn")


func _on_menu_button_pressed():
	PauseSystem.instance.stop_pause()
	get_tree().change_scene_to_file("res://Scenes/Settings/Settings.tscn")

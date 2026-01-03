extends Node
class_name ShipSelectionController

@export var ships_container : Container
@export var ship_datas : Array[ShipData]
@export var ship_select_button_scene : PackedScene

@export var selected_ship_name : Label
@export var selected_ship_icon : TextureRect
@export var selected_ship_desc : Label


func _init() -> void:
	SignalsManager.ship_select.connect(_on_ship_selected)


func _ready() -> void:
	for i in ship_datas.size():
		var select_button : ShipSelectionButton = ship_select_button_scene.instantiate() as ShipSelectionButton
		select_button.set_ship_data(ship_datas[i])
		ships_container.add_child(select_button)
		
		if i == 0:
			select_button.button.pressed.emit()


func _on_ship_selected(ship_data : ShipData):
	SettingsController.selected_ship_data = ship_data
	
	selected_ship_name.text = ship_data.name
	selected_ship_icon.texture = ship_data.sprite
	selected_ship_desc.text = ship_data.description


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level/Level.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings/Settings.tscn")

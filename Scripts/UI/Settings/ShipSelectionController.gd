extends Node
class_name ShipSelectionController

@export var ships_container : Container
@export var ship_datas : Array[ShipData]
@export var ship_select_button_scene : PackedScene

@export var selected_ship_name : Label
@export var selected_ship_icon : TextureRect
@export var selected_ship_desc : Label
@export var selected_ship_stats : Label
@export var selected_ship_layout : ShipUpgradeLayout
@export var ship_upgrade_scene : PackedScene

@export var desc : Control
@export var stats : Control
@export var layout : Control

@export var desc_button : Button
@export var stats_button : Button
@export var layout_button : Button
@export var selected_button_stylebox : StyleBox

@export var layout_pivot : Control
@export var layout_offset : Vector2
@export var layout_scale : float

var button_init_style : StyleBox


func _init() -> void:
	SignalsManager.ship_select.connect(_on_ship_selected)


func _ready() -> void:
	for i in ship_datas.size():
		var select_button : ShipSelectionButton = ship_select_button_scene.instantiate() as ShipSelectionButton
		select_button.set_ship_data(ship_datas[i])
		ships_container.add_child(select_button)
		
		if i == 0:
			select_button.button.pressed.emit()
			select_button.button.grab_focus()
	
	button_init_style = desc_button.get_theme_stylebox("normal")
	_on_desc_button_pressed()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_tab"):
		if desc.is_visible_in_tree() == true:
			_on_stats_button_pressed()
		elif stats.is_visible_in_tree() == true:
			_on_layout_button_pressed()
		elif layout.is_visible_in_tree() == true:
			_on_desc_button_pressed()
	elif event.is_action_pressed("previous_tab"):
		if desc.is_visible_in_tree() == true:
			_on_layout_button_pressed()
		elif stats.is_visible_in_tree() == true:
			_on_desc_button_pressed()
		elif layout.is_visible_in_tree() == true:
			_on_stats_button_pressed()
	elif event.is_action_pressed("back"):
		_on_back_button_pressed()


func _on_ship_selected(ship_data : ShipData):
	SettingsController.selected_ship_data = ship_data
	
	selected_ship_name.text = ship_data.name
	selected_ship_icon.texture = ship_data.sprite
	selected_ship_desc.text = ship_data.description
	selected_ship_stats.text = ship_data.get_stats_text()
	
	if selected_ship_layout != null:
		selected_ship_layout.queue_free()
		selected_ship_layout = null
	
	selected_ship_layout = ship_data.ship_selection_layout_scene.instantiate() as ShipUpgradeLayout
	layout_pivot.add_child(selected_ship_layout)
	selected_ship_layout.global_position = layout_pivot.global_position + layout_offset
	selected_ship_layout.scale *= layout_scale
	selected_ship_layout.ship_upgrades_line.hide()
	
	# Prevent weapon buttons interactions
	for button in selected_ship_layout.weapon_pivot_buttons:
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
	
	for i in ship_data.ship_upgrades_number:
		var ship_upgrade : Control = ship_upgrade_scene.instantiate() as Control
		selected_ship_layout.ship_selection_upgrades_pivot.add_child(ship_upgrade)


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level/Level.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings/Settings.tscn")


func _on_desc_button_pressed() -> void:
	desc.show()
	stats.hide()
	layout.hide()
	
	desc_button.add_theme_stylebox_override("normal", selected_button_stylebox)
	stats_button.remove_theme_stylebox_override("normal")
	layout_button.remove_theme_stylebox_override("normal")


func _on_stats_button_pressed() -> void:
	stats.show()
	desc.hide()
	layout.hide()
	
	stats_button.add_theme_stylebox_override("normal", selected_button_stylebox)
	desc_button.remove_theme_stylebox_override("normal")
	layout_button.remove_theme_stylebox_override("normal")


func _on_layout_button_pressed() -> void:
	layout.show()
	desc.hide()
	stats.hide()
	
	layout_button.add_theme_stylebox_override("normal", selected_button_stylebox)
	desc_button.remove_theme_stylebox_override("normal")
	stats_button.remove_theme_stylebox_override("normal")

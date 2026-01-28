extends Control
class_name ShipSelectionButton

@export var button : Button
@export var icon : TextureRect
@export var name_label : Label

@export var selected_button_stylebox : StyleBox
var init_button_stylebox : StyleBox

var ship_data : ShipData
var focus_on_ready : bool = false

signal pressed_owner(button : ShipSelectionButton)


func _ready() -> void:
	button.pressed.connect(_on_pressed)
	init_button_stylebox = button.get_theme_stylebox("normal")


func _on_pressed():
	SignalsManager.emit_ship_select(ship_data)
	pressed_owner.emit(self)
	button.add_theme_stylebox_override("normal", selected_button_stylebox)


func set_ship_data(data : ShipData):
	ship_data = data
	icon.texture = data.sprite
	name_label.text = data.name


func on_deselect():
	button.add_theme_stylebox_override("normal", init_button_stylebox)

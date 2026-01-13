extends Control
class_name ShipSelectionButton

@export var button : Button
@export var icon : TextureRect
@export var name_label : Label

var ship_data : ShipData
var focus_on_ready : bool = false


func _ready() -> void:
	button.pressed.connect(_on_pressed)


func _on_pressed():
	SignalsManager.emit_ship_select(ship_data)


func set_ship_data(data : ShipData):
	ship_data = data
	icon.texture = data.sprite
	name_label.text = data.name

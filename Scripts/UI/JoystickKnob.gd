extends Sprite2D
class_name JoystickKnob

@onready var parent : JoystickController = $".."
@onready var ring : Sprite2D = $"../Ring"

var pressing: bool = false

@export var maxLength : int = 50
@export var deadZone : float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	maxLength *= parent.scale.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pressing:
		if get_global_mouse_position().distance_to(parent.global_position) <= maxLength:
			global_position = get_global_mouse_position()
		else:
			var angle : float = parent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = parent.global_position.x + cos(angle) * maxLength
			global_position.y = parent.global_position.y + sin(angle) * maxLength
		calculateVector()
	else:
		global_position = lerp(global_position, parent.global_position, delta * 20)
		parent.posVector = Vector2.ZERO

func calculateVector():
	parent.posVector.x = (global_position.x - parent.global_position.x) / maxLength
	parent.posVector.y = (global_position.y - parent.global_position.y) / maxLength
	
	if parent.posVector.length() < deadZone:
		parent.posVector = Vector2.ZERO

func _on_button_button_down():
	pressing = true


func _on_button_button_up():
	pressing = false

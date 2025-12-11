extends Resource
class_name Upgrade

@export var name : String
@export var description : String
@export var icon : Texture2D
@export var is_percentage : bool = true
@export var value : float

func apply_value_to_variable(variable : Variant, init_variable : Variant = null) -> Variant:
	if is_percentage == false:
		return variable + value
	else:
		return variable + value * init_variable

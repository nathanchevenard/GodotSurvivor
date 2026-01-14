extends Projectile
class_name Blast

func _on_body_entered(body : Node2D):
	super(body)
	
	if has_damaged_character == true:
		queue_free()

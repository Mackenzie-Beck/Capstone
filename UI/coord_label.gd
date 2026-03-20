extends Label

@export var offset: Vector2 = Vector2(10,10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_position = get_global_mouse_position() + offset

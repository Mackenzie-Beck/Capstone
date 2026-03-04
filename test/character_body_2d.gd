extends CharacterBody2D


const SPEED = 300.0



func _physics_process(delta: float) -> void:


	# 
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction:
		velocity = input_direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()



func on_save_game(saved_data:Array[SavedData]):

	var my_data = SavedData.new()
	my_data.scene_path = scene_file_path
	my_data.position = global_position
	saved_data.append(my_data)

	
func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()
	
func on_load_game(save_data:SavedData):
	global_position = save_data.position

extends Control


# Called when the node enters the scene tree for the first time.


func _on_button_pressed() -> void:
	Utils.save()


func _on_button_2_pressed() -> void:
	Utils.load_game()

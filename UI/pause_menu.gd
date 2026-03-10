extends PanelContainer





func _on_main_button_pressed() -> void:
	pass # Replace with function body.


func _on_save_button_pressed() -> void:
	Utils.save()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_exit_button_mouse_entered() -> void:
	print("test")

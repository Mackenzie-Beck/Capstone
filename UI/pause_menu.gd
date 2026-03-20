extends PanelContainer





func _on_main_button_pressed() -> void:
	UIcontrol.switch_view(UIcontrol.VIEWS.MAIN)


func _on_save_button_pressed() -> void:
	Utils.save()


func _on_exit_button_pressed() -> void:
	get_tree().quit()

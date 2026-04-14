extends PanelContainer





func _on_main_button_pressed() -> void:
	UIcontrol.switch_view(UIcontrol.VIEWS.MAIN)


func _on_save_button_pressed() -> void:
	Utils.save()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	UIcontrol.switch_view(UIcontrol.VIEWS.PLAYER)


func _on_button_pressed() -> void:
	SB.game_win.emit()

extends PanelContainer


func _on_main_menu_pressed() -> void:
	UIcontrol.switch_view(UIcontrol.VIEWS.MAIN)


func _on_exit_pressed() -> void:
	get_tree().quit()

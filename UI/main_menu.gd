extends PanelContainer



func _on_start_game_pressed() -> void:
	SB.start_game.emit()



func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_multiplayer_game_pressed() -> void:
	PlayerManager.multiplayer_check = true
	SB.start_game.emit()

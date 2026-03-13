extends PanelContainer

signal start_game()



func _on_start_game_pressed() -> void:
	emit_signal("start_game")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()

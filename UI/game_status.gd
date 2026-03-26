extends PanelContainer

@onready var current_player_label = $MarginContainer/VBoxContainer/CurrentPlayerLabel
@onready var previous_label = $MarginContainer/VBoxContainer/PreviousLabel
@onready var combat_log = $MarginContainer/VBoxContainer/CombatLog


func _ready() -> void:
	update_player_label()

func update_player_label() -> void:
	var current = PlayerManager.current_player
	var text = "CURRENT PLAYER: "
	if current == 0:
		text += "Player 1"
		current_player_label.add_theme_color_override("font_color", Color.GREEN)
	elif current == 1:
		text += "Player 2"
		current_player_label.add_theme_color_override("font_color", Color.RED)
	
	current_player_label.text = text
	
func update_log(text: String, prev: int) -> void:
	#Any integer above player count, 1, will set previous turn text to enemy
	#Does not do any string parsing, can add if we need
	
	combat_log.text = text
	
	if prev == 0:
		previous_label = "Previous turn: Player 1"
	elif prev == 1:
		previous_label = "Previous turn: Player 2"
	else:
		previous_label = "Previous turn: Enemy Ships"

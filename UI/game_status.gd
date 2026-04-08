extends PanelContainer

@onready var current_player_label = $MarginContainer/VBoxContainer/CurrentPlayerLabel
@onready var previous_label = $MarginContainer/VBoxContainer/PreviousLabel
@onready var combat_log = $MarginContainer/VBoxContainer/CombatLog


func _ready() -> void:
	#update_player_label()
	current_player_label.text = "CURRENT PLAYER: "
	current_player_label.text += "Player 1"
	current_player_label.add_theme_color_override("font_color", Color.GREEN)
	
	SB.turn_change.connect(update_player_label)
	SB.player_turn_end.connect(update_player_log)

func update_player_label(log_text:String) -> void:
	var current = PlayerManager.current_player
	var text = "CURRENT PLAYER: "
	if current == 1:
		text += "Player 1"
		current_player_label.add_theme_color_override("font_color", Color.GREEN)
		#update_log("Hello 1", 99)
		update_log(log_text, 1)
	elif current == 0:
		text += "Player 2"
		current_player_label.add_theme_color_override("font_color", Color.SKY_BLUE)
		#update_log("Hello 2", 0)
		update_log(log_text, 0)
	'''else: #this is meant to allow the enemy ships a turn in the display, but there is no point in time where it is the enemies turn, so it doesnt really work
		text += "Enemy Ships"
		current_player_label.add_theme_color_override("font_color",Color.RED)
		update_log(log_text,1)'''
	
	current_player_label.text = text
	

func update_log(text: String, prev: int) -> void:
	#Any integer above player count, 1, will set previous turn text to enemy
	#Does not do any string parsing, can add if we need
	
	combat_log.text = text
	
	if prev == 0:
		previous_label.text = "Previous turn: Player 1"
	elif prev == 1:
		previous_label.text = "Previous turn: Player 2"
	else:
		previous_label.text = "Previous turn: Enemy Ships"
	

func update_player_log(data:Dictionary, player=true) -> void:
	if player:
		var type = "Laser" if data.attack_is_laser else "Bomb"
		var text = "Shot a " + type + " at " + str(data.attack) + "\nMoved to " + str(data.move)
		update_player_label(text)
	
	

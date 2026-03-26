extends Node


# All player state will be stored and accessed here.



@export var player1_save_data:PlayerSavedData
@export var player2_save_data:PlayerSavedData
@export var player_array: Array[PlayerSavedData]
@export var current_player: int = 0

func _ready() -> void:
	player1_save_data = PlayerSavedData.new()
	player2_save_data = PlayerSavedData.new()
	player_array.append(player1_save_data)
	player_array.append(player2_save_data)

func swap_player() -> void:
	# Toggle between player 0 and 1
	if current_player == 0:
		current_player = 1
	elif current_player == 1:
		current_player = 0

#getters and setters
func get_health() -> int:
	return player_array[current_player].health
	
func get_fuel() -> int:
	return player_array[current_player].fuel
	
func get_position() -> Vector2:
	return player_array[current_player].position
	

func set_health(health:int) -> void:
	player_array[current_player].health = health
	
func set_fuel(fuel:int) -> void:
	player_array[current_player].fuel = fuel



#NOTE, this function could be used to actually move the player node, right now it just tracks 
# player pos for saving 
func set_position(pos:Vector2) -> void:
	player_array[current_player].position = pos



func on_save_game(saved_data:Array[SavedData]) -> void:
	saved_data.append(player_array[current_player])
	
	
func on_before_load_game() -> void:
	pass
	
func on_load_game(saved_data:SavedData) -> void:
	player_array[current_player] = saved_data

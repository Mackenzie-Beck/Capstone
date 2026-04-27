extends Node


# All player state will be stored and accessed here.


@export var multiplayer_check: bool = false
@export var player1_save_data:PlayerSavedData
@export var player2_save_data:PlayerSavedData
@export var player_array: Array[PlayerSavedData]
@export var current_player: int = 0
var player1_coords : Vector2i
var player2_coords : Vector2i

signal pre_load

func _ready() -> void:
	player1_save_data = PlayerSavedData.new()
	player1_save_data.player_index = 0
	player_array.append(player1_save_data)
	
	player2_save_data = PlayerSavedData.new()
	player2_save_data.player_index = 1
	player_array.append(player2_save_data)
	
	SB.turn_change.connect(swap_player)
	SB.player_moved.connect(_on_player_moved)


func swap_player() -> void:
	# Toggle between player 0 and 1
	if current_player == 0:
		current_player = 1
	elif current_player == 1:
		current_player = 0

func reset_players():
	player_array.clear()
	player1_save_data = PlayerSavedData.new()
	player_array.append(player1_save_data)
	
	player2_save_data = PlayerSavedData.new()
	player_array.append(player2_save_data)
	
	
#getters and setters
func get_health() -> int:
	return player_array[current_player].health

func get_fuel() -> int:
	return player_array[current_player].fuel

func get_position() -> Vector2:
	return player_array[current_player].position


func set_health(health:int) -> void:
	player_array[current_player].health = health
	if player_array[current_player].health <=0:
		SB.game_over.emit()

func set_fuel(fuel:int) -> void:
	player_array[current_player].fuel = fuel
	if player_array[current_player].fuel <=0:
		SB.game_over.emit()



func _on_player_moved(new_player_coords: Vector2i):
	set_position(new_player_coords)



func set_position(pos:Vector2) -> void:
	player_array[current_player].position = pos


func on_save_game(saved_data:Array[SavedData]) -> void:
	if multiplayer_check:
		for player_save_data in player_array:
			#print("player saved data: ", player_save_data)
			saved_data.append(player_save_data)
	else:
		#print("player saved data: ", player_array[current_player])
		saved_data.append(player_array[current_player])
			

	
func on_before_load_game() -> void:
	player_array.clear()
	pre_load.emit()
	
func on_load_game(saved_data:SavedData) -> void:
	#print("on load game")
	#print("player array before append: ", player_array)
	player_array.append(saved_data)
	#print("player array after append: ", player_array)
	current_player = saved_data.player_index
	
	set_fuel(saved_data.fuel)
	UIcontrol.player_control_ui.update_fuel(saved_data.fuel)
	
	#print("saved_data.health: ", saved_data.health)
	#print("playermanager health: ", get_health())
	set_health(saved_data.health)
	#print("playermanager health after set_health: ", get_health())
	SB.player_health_update.emit(saved_data.health)
	
	set_position(saved_data.position)
	Utils.main_scene.object_layer.set_player_coords(saved_data.position)

	

extends Node


# All player state will be stored and accessed here.


@export var multiplayer_check: bool = false
@export var player1_save_data:PlayerSavedData
@export var player2_save_data:PlayerSavedData
@export var player_array: Array[PlayerSavedData]
@export var current_player: int = 0
var player1_coords : Vector2i
var player2_coords : Vector2i

func _ready() -> void:
	player1_save_data = PlayerSavedData.new()
	player_array.append(player1_save_data)
	
	player2_save_data = PlayerSavedData.new()
	player_array.append(player2_save_data)
	
	SB.turn_change.connect(swap_player)
	SB.player_moved.connect(_on_player_moved)

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
	if player_array[current_player].health <=0:
		SB.game_over.emit()

func set_fuel(fuel:int) -> void:
	player_array[current_player].fuel = fuel



func _on_player_moved(new_player_coords: Vector2i):
	set_position(new_player_coords)



func set_position(pos:Vector2) -> void:
	player_array[current_player].position = pos


func on_save_game(saved_data:Array[SavedData]) -> void:
	saved_data.append(player_array[current_player])
	
func on_before_load_game() -> void:
	pass
	
func on_load_game(saved_data:SavedData) -> void:
	player_array[current_player] = saved_data

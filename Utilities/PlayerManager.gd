extends Node


# All player state will be stored and accessed here.



@export var player_save_data:PlayerSavedData
var player_coords : Vector2i

func _ready() -> void:
	player_save_data = PlayerSavedData.new()
	SB.player_moved.connect(_on_player_moved)

#getters and setters
func get_health() -> int:
	return player_save_data.health
	
func get_fuel() -> int:
	return player_save_data.fuel
	


func set_health(health:int) -> void:
	player_save_data.health = health
	
func set_fuel(fuel:int) -> void:
	player_save_data.fuel = fuel


func _on_player_moved(new_player_coords: Vector2i):
	player_coords = new_player_coords
	
func get_player_coords():
	return player_coords

func on_save_game(saved_data:Array[SavedData]) -> void:
	saved_data.append(player_save_data)
	
	
func on_before_load_game() -> void:
	pass
	
func on_load_game(saved_data:SavedData) -> void:
	player_save_data = saved_data

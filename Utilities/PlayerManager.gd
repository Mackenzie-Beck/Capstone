extends Node


# All player state will be stored and accessed here.



@export var player_save_data:PlayerSavedData
	

func _ready() -> void:
	player_save_data = PlayerSavedData.new()

#getters and setters
func get_health() -> int:
	return player_save_data.health
	
func get_fuel() -> int:
	return player_save_data.fuel
	
func get_position() -> Vector2:
	return player_save_data.position
	

func set_health(health:int) -> void:
	player_save_data.health = health
	
func set_fuel(fuel:int) -> void:
	player_save_data.fuel = fuel



#NOTE, this function could be used to actually move the player node, right now it just tracks 
# player pos for saving 
func set_position(pos:Vector2) -> void:
	player_save_data.position = pos



func on_save_game(saved_data:Array[SavedData]) -> void:
	saved_data.append(player_save_data)
	
	
func on_before_load_game() -> void:
	pass
	
func on_load_game(saved_data:SavedData) -> void:
	player_save_data = saved_data

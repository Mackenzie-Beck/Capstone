extends Node


signal start_game()
signal expression_changed(expression_data) #used to update playerActionDisplay=======
signal fuel_used(value:int)
signal turn_change() #handles update log during multiplayer
signal player_turn_end(data:Dictionary) #handles update log during singleplayer
signal enemy_attack(equation:String)
signal player_moved(new_player_coords)
signal enemy_laser()
signal enemy_move(movement_vector: Vector2)
signal enemy_takes_damage()
signal player_health_update(value : int)
signal game_over()

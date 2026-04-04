extends Node


signal start_game()
signal expression_changed(expression_data) #used to update playerActionDisplay=======
signal fuel_used(value:int)
signal turn_change()
signal enemy_attack(equation:String)
signal player_moved(new_player_coords)
signal enemy_laser()
signal enemy_move(movement_vector: Vector2)
signal enemy_takes_damage()

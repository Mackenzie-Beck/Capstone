extends Node

#rng service, can use random nummber generation anywhere without needing to create a new RandimNumberGenerator
var rng = RandomNumberGenerator.new()


# constants and enums
# global consts or enums can go here



# can store a reference to the 'main' scene here, this would basically just be the parent node of the world grid and environment etc.
# right now I have a direct path reference, so when we merge everything and decide where main goes this will have to be moved
var main_scene = preload("uid://5klo3y5bav62")

#flags
# put global flags here, global flags are generally bad practice but they can be useful in a pinch, so if we must use them its good to have a central location to store them. 


func set_main_scene(scene:Node2D):
	main_scene = scene


# Create a timer anywhere in the game tree and connect it to a funciton anywhere in teh game tree.
func create_timer(client_func : Callable, delay :float) -> void:
	var new_timer = Timer.new()
	new_timer.autostart = false
	new_timer.one_shot = true
	new_timer.timeout.connect(client_func)
	add_child(new_timer)
	new_timer.start(delay)





func save() -> void:
	var saved_game:SavedGame = SavedGame.new()
	
	var saved_data:Array[SavedData] = []
	
	get_tree().call_group("persist", "on_save_game", saved_data)
	# this walks over all the nodes in the game tree to be saved, and then calls teh on_save_game function (which a savable node MUST have). 
	# And stores the data in the saved_data array
	saved_game.saved_data = saved_data	
	
	ResourceSaver.save(saved_game, "user://savegame.tres") # only one save file for now, in the future I can change this so that the user is prompted to enter a save name for multiple saves

func load() -> void:
	var saved_game:SavedGame = load("user://savegame.tres") as SavedGame
	
	get_tree().call_group("persist", "on_before_load_game") 
	# call this function on every persistent node to do any prep work before loading game, ie. clearing enemies from a scene or resetting UI components
	
	for item in saved_game.saved_data:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
	
	
	#at this point I think I need to discuss with the team, the way our archietcture is set up all of the saved data should be collected and loaded by the combat_grid and player_manager
	# however I think it may be better to have individual nodes in the combat_grid implement the sav/load contract instead, that should make it much easier to add new dynamic
	# saved objects	

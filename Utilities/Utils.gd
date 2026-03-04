extends Node

#rng service, can use random nummber generation anywhere without needing to create a new RandimNumberGenerator
var rng = RandomNumberGenerator.new()


# constants and enums
# global consts or enums can go here


#var save_nodes = get_tree().get_nodes_in_group("persist")
# "persist is the group that any state object must be added to to be saved"

# can store a reference to the 'main' scene here, this would basically just be the parent node of the world grid and environment etc.
# In the main scenes ready function it can just assign itself to this variable
var main_scene :Node2D



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
	print("saved data after call", saved_data)
	# this walks over all the nodes in the game tree to be saved, and then calls the on_save_game function (which a savable node MUST have). 
	# And stores the data in the saved_data array
	saved_game.saved_data = saved_data	

	DirAccess.make_dir_recursive_absolute("user://saves")
	#this should be user:// but for some reason I cant actually find the save file, for now this will do
	ResourceSaver.save(saved_game, "user://saves/savegame.tres") # only one save file for now, in the future I can change this so that the user is prompted to enter a save name for multiple saves


func load_game() -> void:
	var saved_game:SavedGame = load("user://saves/savegame.tres") as SavedGame
	get_tree().call_group("persist", "on_before_load_game") 
	# call this function on every persistent node to do any prep work before loading game, ie. clearing enemies from a scene or resetting UI components
	
	for item in saved_game.saved_data:
		if item is PlayerSavedData:
			PlayerManager.on_load_game(item)
		else:
			var scene = load(item.scene_path) as PackedScene
			var restored_node = scene.instantiate()
			main_scene.add_child(restored_node)
			if restored_node.has_method("on_load_game"):
				restored_node.on_load_game(item)
	
	

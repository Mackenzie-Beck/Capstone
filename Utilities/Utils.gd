extends Node

#rng service, can use random nummber generation anywhere without needing to create a new RandimNumberGenerator
var rng = RandomNumberGenerator.new()


# constants and enums
# global consts or enums can go here


#var save_nodes = get_tree().get_nodes_in_group("persist")
# "persist is the group that any state object must be added to to be saved"


#flags
# put global flags here, global flags are generally bad practice but they can be useful in a pinch, so if we must use them its good to have a central location to store them. 


# Create a timer anywhere in the game tree and connect it to a funciton anywhere in teh game tree.
func create_timer(client_func : Callable, delay :float) -> void:
	var new_timer = Timer.new()
	new_timer.autostart = false
	new_timer.one_shot = true
	new_timer.timeout.connect(client_func)
	add_child(new_timer)
	new_timer.start(delay)




# Save function TODO

#store var function -> useful for storing any variable
#JSON.stringify for converting godot data into JSON
#file.get_as_text to turn json file into a string, use JSON.parse_string to convert that string into a dictionary
func save() -> void:
	pass

func load() -> void:
	pass

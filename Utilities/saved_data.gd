class_name SavedData
extends Resource 

# Data resource to store any data meant to be saved.


# any variables to be stored in a saved data class must be exports or they wont be accessible by the ResourceSaver
@export var position:Vector2
@export var scene_path:String #the file path to the scene to be instantiated

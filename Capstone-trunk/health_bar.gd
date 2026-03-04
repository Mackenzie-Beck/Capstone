extends ProgressBar

@export var player_health = 100 #in %


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if value != player_health:
		value = player_health
	
func hit(damage):
	player_health -= damage

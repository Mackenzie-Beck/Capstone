extends Area2D

@export var health = 100 #health is in %
@export var fuel = 50 #in whole units
@export var location = Vector2(0,0)
var tile_size = 22.620689655172413793103448275862

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#delete this after replicating function elsewhere
func turnStart(pos):
#	move(pos)
	$"/root/PlayerManager".set_position(pos)
	return pos
	
func playerHealth(damage = null):
	if damage == null: #getter
		return health
	else: #setter
		health -= damage
		$HealthBar.value = health




	
	

	
	

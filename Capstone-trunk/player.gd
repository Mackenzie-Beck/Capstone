extends Area2D

@export var health = 100 #health is in %
@export var location = Vector2(0,0)
var tile_size = 22.620689655172413793103448275862

var screen_size
var rng = RandomNumberGenerator.new() #temp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func makeLocation():
	screen_size = get_viewport_rect().size
	var locX = rng.randi_range(0,screen_size[0])
	var locY = rng.randi_range(0,screen_size[1])
	locX = floor(locX/tile_size)*tile_size
	locY = floor(locY/tile_size)*tile_size
	return Vector2(locX, locY)

func move(pos):
	position = pos

func turnStart(pos):
	move(pos)
	return pos
	pass
	
	

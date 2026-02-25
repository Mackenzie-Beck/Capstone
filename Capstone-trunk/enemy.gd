extends Area2D

@export var health = 100 #health is in %

var screen_size
var rng = RandomNumberGenerator.new() #temp
var tile_size = 22.620689655172413793103448275862
var localLoc

var attack = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	localLoc = Vector2(screen_size[0]/4,screen_size[1]/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start():
	move(localLoc)
	return localLoc
	
func turnStart():
	var attack = newAttack()
	var move = move(makeLocation())
	return [attack,move]
	pass
	
func newAttack():
	var type = rng.randi() % 2
	if type == 0: #line attack
		#create 1+ lines towards the player, append to attack
		pass
	else: #area attack
		pass 
		#create 1+ areas near the player, append to attack
	#return attack
	return [1]

func makeLocation():
	screen_size = get_viewport_rect().size
	var loc = position
	var locX = rng.randi_range(loc[0]-5*tile_size,loc[0]+5*tile_size)
	var locY = rng.randi_range(loc[1]-5*tile_size,loc[1]+5*tile_size)
	locX = clamp(floor(locX/tile_size)*tile_size,0,screen_size[0])
	locY = clamp(floor(locY/tile_size)*tile_size,0,screen_size[1])
	return Vector2(locX, locY)

func move(pos):
	position = pos
	return pos
	pass
	

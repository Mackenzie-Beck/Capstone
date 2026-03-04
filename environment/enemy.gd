extends Area2D

@export var health = 100 #health is in %
@export var damage = 25 #damage is in % of player health

var screen_size
var rng = RandomNumberGenerator.new() #temp
var tile_size = 22.620689655172413793103448275862 #this is a near-arbitrary value based on the size of the grid png's tiles
var startLoc


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	startLoc = Vector2(screen_size[0]/4,screen_size[1]/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start(player_location):
	move(startLoc)
	var attack = newAttack(player_location)
	return [startLoc, attack]
	
func turnEnd(player_location):
	var attack = newAttack(player_location)
	var move = makeLocation()
	return [move, attack]
	
func newAttack(player_location):
	var attacks = []
	var type = rng.randi() % 2
	type = 0
	if type == 0: #line attack
		var line = Line2D.new()
		line.add_point(position)
		line.add_point(player_location)
		line.default_color = Color(1,0,0)
		var angle = player_location - position
		line.add_point(angle*100)
		attacks.append(line)
	else: #area attack
		pass 
		#create 1+ areas near the player, append to attack
	#return attack
	return attacks

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
	

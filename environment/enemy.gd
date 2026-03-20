extends Area2D

@export var health = 100 #health is in %
@export var damage = 25 #damage is in % of player health

var screen_size
var rng = RandomNumberGenerator.new() #temp
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
		var xOffset = to_global($"../ObjectLayer".map_to_local(Vector2i(0.5,0)))
		line.default_color = Color(1,0,0)
		var angle = player_location - position + xOffset
		var xLength = to_global($"../ObjectLayer".map_to_local(Vector2i(40,0)))
		for x in range(-xLength[0],xLength[0],xLength[0]/80):
			var result = x*angle
			line.add_point(result)
		attacks.append(line)
	else: #area attack
		pass 
		#create 1+ areas near the player, append to attack
	#return attack
	return attacks

func makeLocation():
	var tile_size = $"../ObjectLayer".global_tile_size
	var upperLimit = $"../ObjectLayer".tile_map_bounds
	var grid_size = to_global($"../ObjectLayer".map_to_local(upperLimit))
	var offset = to_global($"../ObjectLayer".map_to_local(Vector2(0.5,0.5)))
	var locX = rng.randi_range(position[0]-tile_size[0]*5,position[0]+tile_size[0]*5)
	var locY = rng.randi_range(position[1]-tile_size[1]*5,position[1]+tile_size[1]*5)
	locX = clamp(floor(locX/tile_size[0])*tile_size[0],-grid_size[0],grid_size[0])
	locY = clamp(floor(locY/tile_size[1])*tile_size[1],-grid_size[1],grid_size[1])
	return Vector2(locX, locY)+offset

func move(pos):
	position = pos
	return pos
	

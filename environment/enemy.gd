extends Area2D

@export var health: int #health is in #
@export var damage = 1 #damage is in # of player health

var rng = Utils.rng
@onready var object_layer: TileMapLayer = $"../ObjectLayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = rng.randi_range(10,25)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start(player_location):
	#object_layer.set_enemy_coords(object_layer.enemy_coords)
	var attack = newAttack(player_location)
	return [object_layer.enemy_coords, attack]
	
func turnEnd(player_location:Vector2i):
	var move = makeLocation()
	var attack = newAttack(player_location)
	return [move, attack]
	
func newAttack(player_location:Vector2i):
	var attacks = []
	var types = []
	var count = rng.randi_range(1,5)
	#for j in range(0,count): #this is for the idea of having multiple attacks
	var type = rng.randi() % 2
	#type = 0 #this is for testing the weapon types specifically, remove when done
	types.append(type) #this is part of multi-attacks
	if type == 0: #line attack
		var line = Line2D.new()
		line.default_color = Color(1,0,0)
		var angle = (object_layer.player_coords - object_layer.enemy_coords)
		var variance = rng.randi_range(-4,4)
		angle[0] -= variance
		var xLength = object_layer.tile_map_bounds[0]
		for i in range(0,xLength*2):
			line.add_point(object_layer.map_to_local(object_layer.enemy_coords + angle*i))
		attacks.append(line)
	else: #area attack
		var bombCount = rng.randi_range(1,2)
		for i in range(bombCount,0,-1):
			var bombCenter = Vector2i(rng.randi_range(player_location[0]-1-i,player_location[0]+1+i),
									  rng.randi_range(player_location[1]-1-i,player_location[1]+1+i))
			attacks.append(bombCenter)
	return [attacks,type]
	
func makeLocation():
	var upperLimit = object_layer.tile_map_bounds
	var location = object_layer.enemy_coords
	var newLocation = object_layer.player_coords
	while newLocation == object_layer.player_coords or newLocation in object_layer.all_bomb_coords:
		newLocation[0] = clamp(rng.randi_range(location[0]-5,location[0]+5),-upperLimit[0],upperLimit[0])
		newLocation[1] = clamp(rng.randi_range(location[1]-5,location[1]+5),-upperLimit[1],upperLimit[1])
	return newLocation
	
	
	

	

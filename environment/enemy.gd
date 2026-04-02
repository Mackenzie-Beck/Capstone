extends Node2D

@export var health: int #health is in #
@export var damage = 1 #damage is in # of player health

var rng = Utils.rng

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = rng.randi_range(10,25)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start(player_location):
	#get_parent().object_layer.set_enemy_coords(get_parent().object_layer.enemy_coords)
	var attack = newAttack(player_location)
	return [get_parent().object_layer.enemy_coords, attack]

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
		var angle = (get_parent().object_layer.player_coords - get_parent().object_layer.enemy_coords)
		var variance = rng.randi_range(-4,4)
		angle[0] -= variance
		var xLength = get_parent().object_layer.tile_map_bounds[0]
		for i in range(0,xLength*2):
			line.add_point(get_parent().object_layer.map_to_local(get_parent().object_layer.enemy_coords + angle*i))
			var equation = str(get_parent().object_layer.enemy_coords)+str(angle)+"*x" 
			SB.enemy_attack.emit(equation)

		attacks.append(line)
	else: #area attack
		var bombCount = rng.randi_range(1,2)
		var bombCenter: Vector2i
		var d = 1 #max distance from player that a bomb can generate
		for i in range(bombCount,0,-1):
			while bombCenter in get_parent().object_layer.all_bomb_coords:
				bombCenter = Vector2i(rng.randi_range(player_location[0]-d-i,player_location[0]+d+i),
									  rng.randi_range(player_location[1]-d-i,player_location[1]+d+i))
				d += 1 #to prevent infinte loops in very edge cases
			attacks.append(bombCenter)
	return [attacks,type]
	
func makeLocation():
	var upperLimit = get_parent().object_layer.tile_map_bounds
	var location = get_parent().object_layer.enemy_coords
	var newLocation = get_parent().object_layer.player_coords
	while newLocation == get_parent().object_layer.player_coords or newLocation in get_parent().object_layer.all_bomb_coords:
		newLocation[0] = clamp(rng.randi_range(location[0]-5,location[0]+5),-upperLimit[0],upperLimit[0])
		newLocation[1] = clamp(rng.randi_range(location[1]-5,location[1]+5),-upperLimit[1],upperLimit[1])
	return newLocation
	
	
	

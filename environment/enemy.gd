extends Area2D

@export var health = 100 #health is in %
@export var damage = 25 #damage is in % of player health

var rng = Utils.rng

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start(player_location):
	#$"../ObjectLayer".set_enemy_coords($"../ObjectLayer".enemy_coords)
	var attack = newAttack(player_location)
	return [$"../ObjectLayer".enemy_coords, attack]
	
func turnEnd(player_location:Vector2i):
	var move = makeLocation()
	var attack = newAttack(player_location)
	return [move, attack]
	
func newAttack(player_location:Vector2i):
	var attacks = []
	var type = rng.randi() % 2
	type = 0 #this line is for testing only, remove when done
	#var count = rng.randi_range(1,5)
	#for i in range(0,count): #this is for the idea of having multiple attacks
	if type == 0: #line attack
		var line = Line2D.new()
		line.default_color = Color(1,0,0)
		var angle = (player_location - $"../ObjectLayer".enemy_coords)
		var variance = rng.randi_range(-2,2)
		angle[0] -= variance
		var xLength = $"../ObjectLayer".tile_map_bounds[0]
		for i in range(0,xLength*2,xLength/40):
			line.add_point($"../ObjectLayer".map_to_local($"../ObjectLayer".enemy_coords + angle*i))
		attacks.append(line)
	else: #area attack
		#create 1+ areas near the player, append to attack
		var count = rng.randi_range(1,2)
		for i in range(count,0,-1):
			var bombCenter = Vector2i(rng.randi_range(player_location[0]-1-i,player_location[0]+1+i),
									  rng.randi_range(player_location[1]-1-i,player_location[1]+1+i))
			attacks.append(bombCenter)
	return [attacks,type]
	


func makeLocation():
	var upperLimit = $"../ObjectLayer".tile_map_bounds
	var location = $"../ObjectLayer".enemy_coords
	var newLocation = $"../ObjectLayer".player_coords
	while newLocation == $"../ObjectLayer".player_coords:
		newLocation[0] = clamp(rng.randi_range(location[0]-5,location[0]+5),-upperLimit[0],upperLimit[0])
		newLocation[1] = clamp(rng.randi_range(location[1]-5,location[1]+5),-upperLimit[1],upperLimit[1])
	return newLocation

	

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
		var xOffset = to_global($"../ObjectLayer".map_to_local(Vector2(0.5,0)))
		line.default_color = Color(1,0,0)
		var angle = $"../ObjectLayer".enemy_coords - player_location
		print("attack angle ="+str(angle))
		var xLength = to_global($"../ObjectLayer".map_to_local(Vector2i(40,0)))
		for x in range(0,xLength[0],xLength[0]/40):
			var result = x*angle
			line.add_point(result+xOffset)
		print($"../ObjectLayer".local_to_map(line.get_point_position(0)))
		attacks.append(line)
	else: #area attack
		pass 
		#create 1+ areas near the player, append to attack
	#print("att="+str(attacks[0].points))
	return attacks

func makeLocation():
	var upperLimit = $"../ObjectLayer".tile_map_bounds
	var location = $"../ObjectLayer".enemy_coords
	var locX = rng.randi_range(location[0]-5,location[0]+5)
	var locY = rng.randi_range(location[1]-5,location[1]+5)
	#locX = clamp(locX,-upperLimit[0],upperLimit[0])
	#locY = clamp(locY,-upperLimit[1],upperLimit[1])
	print("mov="+str(Vector2(locX,locY)))
	return Vector2(locX, locY)

	

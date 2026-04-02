extends Node2D

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
	#get_parent().object_layer.set_enemy_coords(get_parent().object_layer.enemy_coords)
	var attack = newAttack(player_location)
	return [get_parent().object_layer.enemy_coords, attack]
	
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
		line.default_color = Color(1,0,0)
		var angle = (get_parent().object_layer.player_coords - get_parent().object_layer.enemy_coords)
		var xLength = get_parent().object_layer.tile_map_bounds[0]
		for i in range(0,xLength*2,xLength/40):
			line.add_point(get_parent().object_layer.map_to_local(get_parent().object_layer.enemy_coords + angle*i))
			var equation = str(get_parent().object_layer.enemy_coords)+str(angle)+"*x" 
			SB.enemy_attack.emit(equation)
		attacks.append(line)
	else: #area attack
		pass 
		#create 1+ areas near the player, append to attack
	return attacks

func makeLocation():
	var upperLimit = get_parent().object_layer.tile_map_bounds
	var location = get_parent().object_layer.enemy_coords
	var locX = rng.randi_range(location[0]-5,location[0]+5)
	var locY = rng.randi_range(location[1]-5,location[1]+5)
	locX = clamp(locX,-upperLimit[0],upperLimit[0])
	locY = clamp(locY,-upperLimit[1],upperLimit[1])
	#print("mov="+str(Vector2(locX,locY)))
	return Vector2(locX, locY)

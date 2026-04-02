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
		get_enemy_attack_expression()
		
		for i in range(0,xLength*2,xLength/40):
			line.add_point(get_parent().object_layer.map_to_local(get_parent().object_layer.enemy_coords + angle*i))
		
		
		attacks.append(line)
	else: #area attack
		pass 
		#create 1+ areas near the player, append to attack
	return attacks

func get_enemy_attack_expression():
		#calculate slope and feed to point-slope form function
		# Calculate slope
		var dx = float(get_parent().object_layer.player_coords[0] - get_parent().object_layer.enemy_coords[0])
		var dy = float(get_parent().object_layer.player_coords[1] - get_parent().object_layer.enemy_coords[1])
		var m = (dy / dx)  # rise over run

		# Calculate y-intercept using point-slope: b = y1 - m*x1
		var x1 = float(get_parent().object_layer.enemy_coords[0])
		var y1 = float(get_parent().object_layer.enemy_coords[1])
		var b = y1 - m * x1

		# Build equation string
		var equation
		if -b > 0:
			equation = str(-m) + "*x+" + str(-b)
		elif -b == 0:
			equation = str(-m) + "*x"
		else:
			equation = str(-m) + "*x" + str(-b)  # b is already negative, so no extra minus needed

		SB.enemy_attack.emit(equation)

func makeLocation():
	var upperLimit = get_parent().object_layer.tile_map_bounds
	var location = get_parent().object_layer.enemy_coords
	var locX = rng.randi_range(location[0]-5,location[0]+5)
	var locY = rng.randi_range(location[1]-5,location[1]+5)
	locX = clamp(locX,-upperLimit[0],upperLimit[0])
	locY = clamp(locY,-upperLimit[1],upperLimit[1])
	#print("mov="+str(Vector2(locX,locY)))
	return Vector2(locX, locY)

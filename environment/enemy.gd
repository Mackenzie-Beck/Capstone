extends Node2D

@export var health: int #health is in #
@export var damage = 1 #damage is in # of player health

var rng = Utils.rng

var last_coords : Vector2


var current_coords : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = rng.randi_range(10,25)
	SB.enemy_takes_damage.connect(_on_enemy_takes_damage)
	SB.reset_game.connect(_on_reset_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start(player_location):
	var attack = newAttack(player_location)
	return [get_parent().object_layer.enemy_coords, attack]

func turnEnd(player_location:Vector2i):
	var move = makeLocation()
	var attack = newAttack(player_location)
	if get_parent().object_layer.is_coord_in_bomb(move):
		print("enemy is in bomb (turnend on enemy.gd)")
		SB.enemy_takes_damage.emit()
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
		var angle = (PlayerManager.get_position() - get_parent().object_layer.enemy_coords)
		var variance = rng.randi_range(-4,4)
		angle[0] -= variance
		var xLength = get_parent().object_layer.tile_map_bounds[0]
		get_enemy_attack_expression(angle)
		
		for i in range(0,xLength*2):
			line.add_point(get_parent().object_layer.map_to_local(get_parent().object_layer.enemy_coords + (angle)*i))
		
		SB.enemy_laser.emit()
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
		SB.enemy_bomb.emit()
	return [attacks,type]

func get_enemy_attack_expression(angle : Vector2i):
		#calculate slope and feed to point-slope form function
		# Calculate slope
		#var dx = float(get_parent().object_layer.player_coords[0] - get_parent().object_layer.enemy_coords[0])
		#var dy = float(get_parent().object_layer.player_coords[1] - get_parent().object_layer.enemy_coords[1])
		var dx = float(angle[0])
		var dy = float(angle[1])
	# Guard against vertical line (undefined slope)
		if dx == 0:
			SB.enemy_attack.emit("x=" + str(get_parent().object_layer.enemy_coords[0]))
			return
		
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
		#print("enemy equation: ", equation)
		SB.enemy_attack.emit(equation)


func makeLocation():
	var upperLimit = get_parent().object_layer.tile_map_bounds
	var location = get_parent().object_layer.enemy_coords
	var newLocation = PlayerManager.get_position() #this is only to set up the while loop
	var iterations = 0
	while newLocation == PlayerManager.get_position() or Vector2i(newLocation) in get_parent().object_layer.all_bomb_coords:
		if iterations <= 50: #this and the 2nd while loop are to prevent infinite loops where the enemy is surrounded by bomb tiles
			newLocation[0] = clamp(rng.randi_range(location[0]-5,location[0]+5),-upperLimit[0],upperLimit[0])
			newLocation[1] = clamp(rng.randi_range(location[1]-5,location[1]+5),-upperLimit[1],upperLimit[1])
			iterations+=1
		else:
			break
	while newLocation == PlayerManager.get_position(): 
		newLocation[0] = clamp(rng.randi_range(location[0]-5,location[0]+5),-upperLimit[0],upperLimit[0])
		newLocation[1] = clamp(rng.randi_range(location[1]-5,location[1]+5),-upperLimit[1],upperLimit[1])
	return newLocation
	
	

func _on_enemy_takes_damage():
	#print("_on_enemy_takes_damage")
	health -=1
	if health <=0:
		SB.game_win.emit()

func _on_reset_game():
	current_coords = Vector2i(5,5)

func on_save_game(saved_data:Array[SavedData]) -> void:
	var enemy_save_data = EnemySavedData.new()
	enemy_save_data.position = current_coords
	enemy_save_data.health = health
	saved_data.append(enemy_save_data)

func on_load_game(saved_data:SavedData) -> void:
	current_coords = Vector2(saved_data.position)
	get_parent().move_enemy(current_coords)
	get_parent().enemy_action = [Vector2i(0,0), -1]
	#print("curretn coords: ", current_coords)
	health = saved_data.health
	UIcontrol.health_display.update_enemy_hbar(saved_data.health)

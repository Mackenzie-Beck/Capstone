extends Node2D

# Declare the variable at class level
var control_ui



#@export var enemy_scene: PackedScene
var expression = Expression.new()
var enemy_action = [Vector2(0,0),1] #[move,attack]
var player_location


signal hit




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instantiate and add the UI inside _ready()
	Utils.main_scene = self # this is needed so utils can load scenes as children of main, then if the node needs to be added anywhere in particular, it can access mains tree and move itself on its load funciton
	
	
	
	# Connect to signals
	UIcontrol.player_control_ui.movement_expression_applied.connect(_on_movement_applied)
	UIcontrol.player_control_ui.shooting_expression_applied.connect(_on_shooting_applied)
	UIcontrol.player_control_ui.weapon_type_changed.connect(_on_weapon_changed)
	
	newgame()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("NextTurn"):
		turnEnd()
		turnStart()
	

# Signal handler functions
func _on_movement_applied(expression: String) -> void:
	print("Movement expression applied: ", expression)

func _on_shooting_applied(expression: String) -> void:
	print("Shooting expression applied: ", expression)

func _on_weapon_changed(is_laser: bool) -> void:
	print("Weapon changed to: ", "Laser" if is_laser else "Bomb")
	# Update weapon system here



# Environment functions

func newgame():
	player_location = $Player.makeLocation()
	$Player.move(player_location)
	enemy_action = $Enemy.start($Player.position)
	#todo: clamp movement to screen -1 tile rather than screen
	turnStart()
	
func gameEnd():
	$DeathPopup.show()
	#todo: disable play features after loss, signal to menus that game is over
	
func turnStart():
	enemyDisplayAttack(enemy_action[1])
	enemyDisplayMove(enemy_action[0])
	
func turnEnd():
	playerHitReg()
	$Enemy.move(enemy_action[0])
	enemy_action = $Enemy.turnEnd($Player.position)
	enemyHitReg()
	
	
func enemyDisplayAttack(attacks):
	#remove previous attack indicator
	var main_children = self.get_children()
	for child in main_children:
		if child is Line2D:
			child.queue_free()
	#add new attack indicator
	for attack in attacks:
		add_child(attack)
	pass
	
func enemyDisplayMove(move):
	var line = Line2D.new()
	line.add_point($Enemy.position)
	line.add_point(move)
	line.default_color = Color(0,1,0)
	add_child(line)
	pass

func enemyHitReg():
	for i in enemy_action[1]:
		for j in range(0,3):
			if i.get_point_position(j) == player_location:
				var alive = $Player.playerHealth($Enemy.damage)
	if not $Player.isAlive():
		gameEnd()
		
func playerHitReg(expression_string = "-5x+1"): #inputs are placeholders for signal send
	var line = Line2D.new()
	for i in range(0,20): #for each x value
		var formula = expression_string
		#these ifs are to convert the x in the formula into the x-value
		if formula.contains("*x"):
			#print("star mult")
			formula = expression_string.replace("*x","*"+str(i))
		if formula.contains("+x"):
			#print("add")
			formula = expression_string.replace("+x","+"+str(i))
		if formula.contains("-x"):
			#print("subtract")
			formula = expression_string.replace("-x","-"+str(i))
		if formula.begins_with("x"):
			#print("start")
			formula = expression_string.replace("x",str(i))
		if formula.contains("x"):
			#print("base mult")
			formula = expression_string.replace("x","*"+str(i))
		var error = expression.parse(formula)
		if error != OK:
			print(expression.get_error_text())
			return
		var result = expression.execute()
		print(result)
		line.add_point(Vector2(i*22,result))
		line.default_color = Color(1,0.8,0)
	self.add_child(line)
	
	
	
	
	
	
	

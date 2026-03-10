extends Node2D

# Declare the variable at class level
var control_ui



#@export var enemy_scene: PackedScene
var expression
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
	enemy_action = $Enemy.start($Player.position)
	player_location = $Player.makeLocation()
	$Player.move(player_location)
	#todo: clamp movement to screen -1 tile rather than screen
	turnStart()
	
func gameEnd():
	$DeathPopup.show()
	pass
	
func turnStart():
	enemyDisplayAttack(enemy_action[1])
	enemyDisplayMove(enemy_action[0])
	
func turnEnd():
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
		
func playerHitReg(formula = "5x+1"): #inputs are placeholders for signal send
	var x = $Player.position[0]
	var error = expression.parse(formula, PackedStringArray(['x']))
	if error != OK:
		print(expression.get_error_text())
		return
	var result = expression.execute(PackedStringArray([x]))
	print(result)
	var line = Line2D.new()
	line.add_point($Player.position)
	line.add_point(Vector2($Player.position[0], result)*100)
	line.default_color = Color(0,5,1)
	pass


	

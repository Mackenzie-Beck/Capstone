extends Node2D

# Declare the variable at class level
var control_ui
@onready var object_layer: TileMapLayer = $ObjectLayer
@onready var enemy: Node2D = $Enemy

#@export var enemy_scene: PackedScene
var enemy_action = [Vector2(0,0),1] #[move,attack]
#var player_action = [Vector2(0,0),1] #[move,attack]
var player_location


signal hit

signal fuel_updated(amount: int)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instantiate and add the UI inside _ready()
	Utils.main_scene = self # this is needed so utils can load scenes as children of main, then if the node needs to be added anywhere in particular, it can access mains tree and move itself on its load funciton
	SB.start_game.connect(_on_start_game)
	SB.expression_changed.connect(_on_new_player_expression)
	UIcontrol.player_control_ui.movement_expression_applied.connect(_on_movement_expression_applied)

	
	
	# Connect to signals
	UIcontrol.player_control_ui.movement_expression_applied.connect(_on_movement_applied)
	UIcontrol.player_control_ui.shooting_expression_applied.connect(_on_shooting_applied)
	UIcontrol.player_control_ui.weapon_type_changed.connect(_on_weapon_changed)
	fuel_updated.connect(UIcontrol.player_control_ui.update_fuel)
	
	
	visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("NextTurn"):
		turnEnd()
		turnStart()
	elif Input.is_action_just_pressed("pause"):
		UIcontrol.switch_view(UIcontrol.VIEWS.PAUSE)
	

# Signal handler functions
func _on_movement_applied(expression: String) -> void:
	#print("Movement expression applied: ", expression)
	pass

func _on_shooting_applied(expression: String) -> void:
	#print("Shooting expression applied: ", expression)
	pass

func _on_weapon_changed(is_laser: bool) -> void:
	#print("Weapon changed to: ", "Laser" if is_laser else "Bomb")
	pass
	# Update weapon system here

func _on_start_game() -> void:
	visible=true
	newgame()
	
func _on_new_player_expression(expression_data) -> void:
	playerActionDisplay(expression_data)

# Environment functions

func newgame():
	player_location = to_global(object_layer.map_to_local(object_layer.player_coords))
	#enemy_action = $Enemy.start(player_location)
	turnStart()
	
func gameEnd():
	#$DeathPopup.show()
	pass
	
func turnStart():
	#remove previous enemy attack and movement indicator
	for child in self.get_children():
		if child is Line2D:
			if child.default_color == Color(0,1,0) or child.default_color == Color(1,0,0):
				child.queue_free()
	#generate new actions
	enemyDisplayAttack(enemy_action[1])
	enemyDisplayMove(enemy_action[0])
	
func turnEnd():
	move_enemy(enemy_action[0])
	enemy_action = enemy.turnEnd(PlayerManager.get_player_coords())
	enemyHitReg()


func move_enemy(new_coords):
	object_layer.erase_cell(object_layer.enemy_coords)
	object_layer.set_enemy_coords(new_coords)

func enemyDisplayAttack(attacks):
	#add new attack indicator
	for attack in attacks:
		if attack:
			add_child(attack)
	pass
	
func enemyDisplayMove(move):
	var line = Line2D.new()
	line.add_point(object_layer.map_to_local(object_layer.enemy_coords))
	line.add_point(object_layer.map_to_local(move))
	line.default_color = Color(0,1,0)
	add_child(line)
	pass

#todo: change this to have where the attack generates an attack oneach tile on its line
func enemyHitReg():
	for i in enemy_action[1]:
		for j in range(0,3):
			if i.get_point_position(j) == player_location:
				PlayerManager.set_health(PlayerManager.get_health())#-enemy.damage)
	if not PlayerManager.get_health() <= 0:
		gameEnd()

func playerActionDisplay(expression_data) -> void:
	for child in self.get_children():
		if child is Line2D && expression_data.slot_name == "Movement" && child.default_color == Color(0,0.8,1):
			child.queue_free()
		elif child is Line2D && expression_data.slot_name == "Shooting" && child.default_color == Color(1,0.8,0):
			child.queue_free()
	var expression = Expression.new()
	var line = Line2D.new()
	var xLength = object_layer.tile_map_bounds
	var xOffset = Vector2i(0.5,0)
	for x in range(-(xLength[0]),xLength[0]):
		var formula = expression_data.expression
		var error = expression.parse(formula, ["x"])
		if error != OK:
			print(expression.get_error_text())
			return
		var result = expression.execute([x])
		if expression.has_execute_failed():
			print(expression.get_error_text())
			return
		var point = Vector2i(x,-result)+xOffset
		point = to_global(object_layer.map_to_local(point))
		line.add_point(point)
	if expression_data.slot_name == "Shooting":
		line.default_color = Color(1,0.8,0)
	elif expression_data.slot_name == "Movement":
		line.default_color = Color(0,0.8,1)
	add_child(line)
		
		
		
		
func _on_movement_expression_applied(movement_expression : String):
	turnEnd()
	turnStart()

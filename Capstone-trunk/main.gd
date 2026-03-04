extends Node
signal hit

#@export var enemy_scene: PackedScene
var expression
var enemy_action = [Vector2(0,0),1] #[move,attack]
var player_location


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	newgame()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("NextTurn"):
		turnEnd()
		turnStart()
	
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
		
func playerHitReg():
	pass


	
	
	

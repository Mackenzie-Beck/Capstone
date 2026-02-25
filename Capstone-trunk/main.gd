extends Node

@export var enemy_scene: PackedScene
var expression
var enemy_location
var player_location


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	newgame()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("NextTurn"):
		turnStart()
	
func newgame():
	enemy_location = $Enemy.start()
	player_location = $Player.makeLocation()
	$Player.move(player_location)
	#todo: clamp movement to screen -1 tile rather than screen
	
func turnStart():
	var enemy_actions = $Enemy.turnStart()
	enemy_location = enemy_actions[1]
	displayAttack(enemy_actions[0])
	
func displayAttack(attacks):
	for attack in attacks:
		var line = Line2D.new()
		line.add_point(enemy_location)
		line.add_point(player_location)
		add_child(line)
	pass
	
func displayMove(move):
	pass
	
	
	

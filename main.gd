extends Node2D

# Declare the variable at class level
var control_ui

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instantiate and add the UI inside _ready()
	Utils.main_scene = self # this is needed so utils can load scenes as children of main, then if the node needs to be added anywhere in particular, it can access mains tree and move itself on its load funciton
	
	# Connect to signals
	UIcontrol.player_control_ui.movement_expression_applied.connect(_on_movement_applied)
	UIcontrol.player_control_ui.shooting_expression_applied.connect(_on_shooting_applied)
	UIcontrol.player_control_ui.weapon_type_changed.connect(_on_weapon_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Signal handler functions
func _on_movement_applied(expression: String) -> void:
	print("Movement expression applied: ", expression)

func _on_shooting_applied(expression: String) -> void:
	print("Shooting expression applied: ", expression)

func _on_weapon_changed(is_laser: bool) -> void:
	print("Weapon changed to: ", "Laser" if is_laser else "Bomb")
	# Update weapon system here

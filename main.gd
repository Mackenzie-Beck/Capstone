extends Node

# Declare the variable at class level
var control_ui

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instantiate and add the UI inside _ready()
	control_ui = load("res://UI/player_control_UI.tscn").instantiate()
	add_child(control_ui)
	
	# Connect to signals
	control_ui.movement_expression_applied.connect(_on_movement_applied)
	control_ui.shooting_expression_applied.connect(_on_shooting_applied)
	control_ui.weapon_type_changed.connect(_on_weapon_changed)

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

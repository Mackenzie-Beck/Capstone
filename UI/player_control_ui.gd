extends Control
class_name PlayerControlUI

signal movement_expression_applied(expression: String)
signal shooting_expression_applied(expression: String)
signal weapon_type_changed(is_laser: bool)

@onready var movement_slot: ExpressionSlot = $MarginContainer/VBoxContainer/HSplitContainer/RightPanel/MovementSlot
@onready var shooting_slot: ExpressionSlot = $MarginContainer/VBoxContainer/HSplitContainer/RightPanel/ShootingSlot
@onready var weapon_toggle: Button = $MarginContainer/VBoxContainer/HSplitContainer/RightPanel/ExtraControls/WeaponToggle
@onready var execute_button: Button = $MarginContainer/VBoxContainer/ExtraControls/ExecuteButton
@onready var clear_button: Button = $MarginContainer/VBoxContainer/ExtraControls/ClearButton
@onready var fuel_counter: Label = $MarginContainer/VBoxContainer/HSplitContainer/RightPanel/ExtraControls/FuelCounter/Label
@onready var background: Panel = $Background

var is_laser_mode: bool = true
var is_hovered: bool 


func _ready() -> void:
	# Connect signals
	movement_slot.expression_changed.connect(_on_movement_expression_changed)
	shooting_slot.expression_changed.connect(_on_shooting_expression_changed)
	weapon_toggle.toggled.connect(_on_weapon_toggle_toggled)
	execute_button.pressed.connect(_on_execute_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	
	# Initialize weapon toggle
	_update_weapon_toggle_display()


func _process(_delta: float) -> void:
	is_hovered = background.get_global_rect().has_point(get_global_mouse_position())

func _on_movement_expression_changed(expression_data: Dictionary) -> void:
	print("Movement expression changed: ", expression_data)

func _on_shooting_expression_changed(expression_data: Dictionary) -> void:
	print("Shooting expression changed: ", expression_data)

func _on_weapon_toggle_toggled(toggled_on: bool) -> void:
	is_laser_mode = not toggled_on
	_update_weapon_toggle_display()
	weapon_type_changed.emit(is_laser_mode)
	AudioControl.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CPU4)

func _update_weapon_toggle_display() -> void:
	if is_laser_mode:
		weapon_toggle.text = "Laser"
	else:
		weapon_toggle.text = "Bomb"

func _on_execute_pressed() -> void:
	var movement_expr = movement_slot.get_expression()
	var shooting_expr = shooting_slot.get_expression()
	
	# Validate before applying
	if movement_expr.is_empty():
		push_warning("Movement expression is empty!")
		return
	
	if shooting_expr.is_empty():
		push_warning("Shooting expression is empty!")
		return
	
	# Emit signals for the game to handle
	movement_expression_applied.emit(movement_expr)
	shooting_expression_applied.emit(shooting_expr)
	
	print("Applied expressions:")
	print("  Movement: ", movement_expr)
	print("  Shooting: ", shooting_expr)
	print("  Weapon: ", "Laser" if is_laser_mode else "Bomb")
	
	_apply_to_ship(movement_expr, shooting_expr, is_laser_mode)
	AudioControl.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UIBUTTON4)
	#PlayerManager.swap_player()
	if PlayerManager.multiplayer_check:
		SB.turn_change.emit()
	

func _on_clear_pressed() -> void:
	movement_slot.clear_expression()
	shooting_slot.clear_expression()
	AudioControl.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CPU1)

func _apply_to_ship(movement_expr: String, shooting_expr: String, is_laser: bool) -> void:
	"""Apply the expression just for testing"""
	pass

func get_movement_expression() -> String:
	return movement_slot.get_expression()

func get_shooting_expression() -> String:
	return shooting_slot.get_expression()

func is_laser_weapon() -> bool:
	return is_laser_mode

func set_read_only(read_only: bool) -> void:
	"""Disable/enable the UI"""
	execute_button.disabled = read_only
	clear_button.disabled = read_only
	weapon_toggle.disabled = read_only

func show_ui() -> void:
	show()
	var tween = create_tween()
	modulate.a = 0
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func hide_ui() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hide)

func update_fuel(value: int) -> void:
	fuel_counter.text = str(value)

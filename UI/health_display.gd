extends Control

@onready var Player1Health: ProgressBar = $MarginContainer/VBoxContainer/Player1Health
@onready var Player1HealthMulti: ProgressBar = $MarginContainer2/VBoxContainer/Player1Health
@onready var Player2Health: ProgressBar = $MarginContainer2/VBoxContainer/Player2Health
@onready var EnemyHealth: ProgressBar = $MarginContainer/VBoxContainer/EnemyHealth
@onready var EnemyHealthMulti: ProgressBar = $MarginContainer2/VBoxContainer/EnemyHealth

func _ready() -> void:
	Player1Health.value = 10
	EnemyHealth.value = 10
	Player1HealthMulti.value = 10
	EnemyHealthMulti.value = 10
	Player2Health.value = 10

func update_player_hbar(val: int) -> void:
	if PlayerManager.multiplayer_check:
		Player1HealthMulti.value = val
	else:
		Player1Health.value = val
	
func update_player2_hbar(val: int) -> void:
	Player2Health.value = val
	
func update_enemy_hbar(val: int) -> void:
	if PlayerManager.multiplayer_check:
		EnemyHealthMulti.value = val
	else:
		EnemyHealth.value = val

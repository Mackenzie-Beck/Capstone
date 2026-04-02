extends Control

@onready var Player1Health: ProgressBar = $MarginContainer/VBoxContainer/Player1Health
@onready var EnemyHealth: ProgressBar = $MarginContainer/VBoxContainer/EnemyHealth

func _ready() -> void:
	Player1Health.value = 10
	EnemyHealth.value = 10


func update_player_hbar(val: int) -> void:
	Player1Health.value = val
	
func update_enemyd_hbar(val: int) -> void:
	EnemyHealth.value = val

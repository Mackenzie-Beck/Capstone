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
	SB.player_health_update.connect(_on_player_health_update)
	SB.enemy_takes_damage.connect(_on_enemy_health_update)
	SB.reset_game.connect(reset_health)
	SB.game_loaded.connect(_on_game_loaded)


func reset_health():
	Player1Health.value = 10
	EnemyHealth.value = 10
	Player1HealthMulti.value = 10
	EnemyHealthMulti.value = 10
	Player2Health.value = 10
	if PlayerManager.multiplayer_check:
		if PlayerManager.current_player == 0:
			update_player_hbar(Player1HealthMulti.value)
		elif PlayerManager.current_player == 1:
			update_player2_hbar(Player2Health.value)
		update_enemy_hbar(EnemyHealthMulti.value)
	else:
		update_player_hbar(Player1Health.value)
		update_enemy_hbar(EnemyHealth.value)

func _on_player_health_update(value):
	#print("_on_player_health_update in health_display")
	AudioControl.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ROBO1)
	if PlayerManager.multiplayer_check:
		if PlayerManager.current_player == 0:
			update_player_hbar(Player1HealthMulti.value+value)
		elif PlayerManager.current_player == 1:
			update_player2_hbar(Player2Health.value+value)
	else:
		update_player_hbar(Player1Health.value+value)

func update_player_hbar(val: int) -> void:
	#print("update_player_hbar in health_display")
	if PlayerManager.multiplayer_check:
		Player1HealthMulti.value = val
	else:
		Player1Health.value = val
	
func update_player2_hbar(val: int) -> void:
	Player2Health.value = val
	
	
func _on_enemy_health_update():
	AudioControl.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ROBO4)
	if PlayerManager.multiplayer_check:
		update_enemy_hbar(EnemyHealthMulti.value -1)
	else:
		update_enemy_hbar(EnemyHealth.value -1)
	
func update_enemy_hbar(val: int) -> void:
	if PlayerManager.multiplayer_check:
		EnemyHealthMulti.value = val
	else:
		EnemyHealth.value = val

func _on_game_loaded():
	if PlayerManager.multiplayer_check:
		update_player_hbar(PlayerManager.get_health())
		update_enemy_hbar(Utils.main_scene.enemy.health)
	else:
		update_player_hbar(PlayerManager.get_health())
		update_enemy_hbar(Utils.main_scene.enemy.health)

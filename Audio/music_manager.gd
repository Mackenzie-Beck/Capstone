extends Node2D
# MusicManager.gd

@export var tracks: Array[AudioStream] = []

var _player: AudioStreamPlayer
var _last_index: int = -1

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Music"  # use a dedicated audio bus
	add_child(_player)
	_player.finished.connect(_play_next)
	_play_next()

func _play_next() -> void:
	if tracks.is_empty():
		return

	var index: int = _last_index
	while index == _last_index and tracks.size() > 1:
		index = randi() % tracks.size()

	_last_index = index
	_player.stream = tracks[index]
	_player.play()

func stop() -> void:
	_player.stop()

func resume() -> void:
	if not _player.playing:
		_player.play()

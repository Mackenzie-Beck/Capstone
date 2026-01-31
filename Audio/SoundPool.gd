class_name SoundPool extends Node2D

#component added to scenes where you want one of several sounds to play after an event.
# stores a list of SOUND_EFFECT_TYPEs and then picks one at random to play,
# has a timer so that sounds do not overlap




@onready var timer = $Timer
var timedout: bool = true

@export var sound_effects : Array[SoundEffect.SOUND_EFFECT_TYPE]
@export var delay: float = 1

#for making sure a sound does not play twice in a row
var lastindex: int = -1


func play_random_sound() -> void:
	
	# only run the code if the delay timer is not running 
	if timer.is_stopped():
		
		var index: int = -1
		while index == lastindex:
			index = Utils.rng.randf_range(0, sound_effects.size()-1)
		
		AudioControl.create_2d_audio_at_location(get_parent().position, sound_effects[index])

		lastindex = index
		timer.start(delay)


func _get_configuration_warnings():
	var number_of_sound_effects: int = 0
	
	for SOUND_EFFECT in sound_effects:
		if SOUND_EFFECT is SoundEffect.SOUND_EFFECT_TYPE:
			number_of_sound_effects += 1
			
	if number_of_sound_effects < 2:
		return ["Expect at least two children of SoundQueue"]

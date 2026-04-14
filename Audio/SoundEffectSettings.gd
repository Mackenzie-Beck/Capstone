class_name SoundEffect 
extends Resource
## Sound effect resource, used to configure unique sound effects for use with the AudioControl. Passed to [method AudioControl.create_2d_audio_at_location()] and [method AudioControl.create_audio()] to play sound effects.

## Stores the different types of sounds effects available to be played to distinguish them from another. Each new SoundEffect resource created should add to this enum, to allow them to be easily instantiated via [method AudioControl.create_2d_audio_at_location()] and [method AudioControl.create_audio()].
enum SOUND_EFFECT_TYPE {
	CONSOLE1,
	CONSOLE2,
	CPU1,
	CPU2,
	CPU3,
	CPU4,
	CPU5,
	ROBO1,
	ROBO2,
	ROBO3,
	ROBO4,
	ROBO5,
	ROBO6,
	ROBO7,
	ROBO8,
	UIACTIVATE1,
	UIACTIVATE2,
	UIACTIVATE3,
	UIBUTTON1,
	UIBUTTON2,
	UIBUTTON3,
	UIBUTTON4,
	UICONSOLE1,
	UICONSOLE2,
	UICONSOLE3,
	UICONSOLE4,
	UICONSOLE5,
	EVILLASER,
	GOODLASER,
	BOMB,
}

@export_range(0, 10) var limit: int = 5 ## Maximum number of this SoundEffect to play simultaneously before culled.
@export var type: SOUND_EFFECT_TYPE ## The unique sound effect in the [enum SOUND_EFFECT_TYPE] to associate with this effect. Each SoundEffect resource should have it's own unique [enum SOUND_EFFECT_TYPE] setting.
@export var sound_effect: AudioStreamOggVorbis ## The [AudioStreamOggVorbis] audio resource to play.
@export_range(-40, 20) var volume: float = 0 ## The volume of the [member sound_effect].
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0 ## The pitch scale of the [member sound_effect].
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.0 ## The pitch randomness setting of the [member sound_effect].

var audio_count: int = 0 ## The instances of this [AudioStreamOggVorbis] currently playing.


## Takes [param amount] to change the [member audio_count]. 
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


## Checks whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return audio_count < limit


## Connected to the [member sound_effect]'s finished signal to decrement the [member audio_count].
func on_audio_finished() -> void:
	change_audio_count(-1)

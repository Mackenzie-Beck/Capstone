extends Camera2D


#WASD var's
@export var move_speed: float = 1200
#zoom var's
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.4
@export var max_zoom: float = 2.0
@export var zoom_smoothness: float = 8.0
#world-border var's
@export var world_min: Vector2 = Vector2(-2000, -2000)
@export var world_max: Vector2 = Vector2(2000, 2000)

@onready var cam: Camera2D = $"."

#zoom we want to reach
var target_zoom: float = 1.0
#zoom from previous frame
var previous_zoom: float = 1.0
#world-position on pointer at the time of scrolling
var zoom_focus_world: Vector2 = Vector2.ZERO


func _ready() -> void:
	cam.make_current()
	target_zoom = cam.zoom.x
	previous_zoom = cam.zoom.x
	

func _process(delta: float) -> void:
	
	#WASD-Movement
	var direction := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))
	if direction.length() > 0:
		direction = direction.normalized()
	global_position += direction * move_speed * cam.zoom * delta
	
		
	#Zoom
	var current_zoom: float = cam.zoom.x
	var smooth_zoom: float = lerp(current_zoom, target_zoom, zoom_smoothness * delta)
	cam.zoom = Vector2(smooth_zoom, smooth_zoom)
	
	var zoom_ratio: float = previous_zoom / smooth_zoom
	if abs(zoom_ratio - 1.0) > 0.00001:
		global_position = zoom_focus_world + (global_position - zoom_focus_world) * zoom_ratio

	previous_zoom = smooth_zoom

	#border limit function
	_clamp_to_world()	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		zoom_focus_world = cam.get_global_mouse_position()
		# need to assig these names to mouse wheel down and mouse wheel up respectivley 
		if event.is_action("zoom_out"):
			target_zoom -= zoom_step
		elif event.is_action("zoom_in"):
			target_zoom += zoom_step
		else:
			return

		target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	
#world-border function
func _clamp_to_world() -> void:
	var half_viewport: Vector2 = get_viewport_rect().size / 2 / cam.zoom
	
	if half_viewport.x < (world_max.x - world_min.x) / 2:
		global_position.x = clamp(
			global_position.x,
			world_min.x + half_viewport.x,
			world_max.x - half_viewport.x
			)
	else:
		global_position.x = (world_min.x + world_max.x) / 2  # center it

	if half_viewport.y < (world_max.y - world_min.y) / 2:
		global_position.y = clamp(
		global_position.y,
		world_min.y + half_viewport.y,
		world_max.y - half_viewport.y
		)
	else:
		global_position.y = (world_min.y + world_max.y) / 2  # center it

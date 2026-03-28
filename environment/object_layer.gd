extends TileMapLayer


@export var player_sprite_atlas_coords : Vector2 
@export var player2_sprite_atlas_coords : Vector2i
@export var enemy_sprite_atlas_coords : Vector2 # set default values for these when assets are decided

@export var player_coords : Vector2 = Vector2i(0,0)
@export var player2_coords : Vector2i = Vector2i(0,1)
@export var enemy_coords : Vector2 = Vector2i(10,-10)

@export var tile_map_bounds : Vector2 = Vector2i(40,40)

@export var highlight_layer: TileMapLayer
@export var highlight_atlas_coords: Vector2i = Vector2i.ZERO
@export var highlight_bomb_coords: Vector2i = Vector2i(1,0)
@export var highlight_move_coords: Vector2i = Vector2i(2,0)
@export var highlight_shoot_coords: Vector2i = Vector2i(3,0)

var last_hovered_tile: Vector2i = Vector2i(-1, -1)


var movement_tile : Vector2i
var shoot_tile : Vector2i



func _ready() -> void:
	#connect signals from UI
	UIcontrol.player_control_ui.movement_expression_applied.connect(_on_movement_expression_applied)
	UIcontrol.player_control_ui.shooting_expression_applied.connect(_on_shooting_expression_applied)
	
	
	
	set_player_coords(Vector2i(0,0))
	set_enemy_coords(Vector2i(5,5))
	

# Will need to change the second arg of set_cell when the tilemap resource is created
func set_player_coords(coords : Vector2i):
	#TODO: change logic so that player tile is set depending on the current player
	player_coords = coords
	set_cell(player_coords, 2, player_sprite_atlas_coords)
	
	
func set_enemy_coords(coords : Vector2i):
	enemy_coords = coords
	set_cell(enemy_coords,0,  enemy_sprite_atlas_coords)



func _process(_delta: float) -> void:
	var hovered_tile: Vector2i = local_to_map(to_local(get_global_mouse_position()))


	if Input.is_action_just_pressed("LMB") and UIcontrol.player_control_ui.visible and not UIcontrol.player_control_ui.is_hovered:
		# get movement and shoot expressions
		var move = UIcontrol.player_control_ui.get_movement_expression()

		# include gaurd for empty expressions 
		if not move.is_empty():
			# check if the mouse coord is on move
			if is_coord_on_line(move, hovered_tile):
				movement_tile = hovered_tile
				highlight_layer.set_cell(hovered_tile, 0, Vector2i(2,0))
				print("move: ", movement_tile)
				

			
	elif Input.is_action_just_pressed("RMB") and UIcontrol.player_control_ui.visible and not UIcontrol.player_control_ui.is_hovered:
		var shoot = UIcontrol.player_control_ui.get_shooting_expression()
		if not shoot.is_empty():
			if is_coord_on_line(shoot, hovered_tile):
				shoot_tile = hovered_tile
				print("shoot: ", shoot_tile)
	
		
	if hovered_tile == last_hovered_tile:
		return
		
	if highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_bomb_coords and \
	 highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_move_coords and \
	highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_shoot_coords:

		highlight_layer.erase_cell(last_hovered_tile)



	if hovered_tile.x >= -tile_map_bounds.x and hovered_tile.x < tile_map_bounds.x and \
	hovered_tile.y >= -tile_map_bounds.y and hovered_tile.y < tile_map_bounds.y and highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_bomb_coords and \
	highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_move_coords and highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_shoot_coords:
		highlight_layer.set_cell(hovered_tile, 0, highlight_atlas_coords)
		last_hovered_tile = hovered_tile
	else:
		last_hovered_tile = Vector2i(-1, -1)

	# Set the text of the coord_label
	UIcontrol.coord_label.text = str(hovered_tile.x) + "," +str(-hovered_tile.y)  

	




# a little annoying but the center_coord will be flipped on the grid
#ie if you enter (3,3) the rendered point will be (-3,-3)
func bomb(center_coord: Vector2i) ->void:
	# Create highlight at coord, just start with a 3x3 area
	for x in range(-1,2):
		for y in range(-1,2):
			highlight_layer.set_cell(Vector2i(center_coord.x+x, center_coord.y+y), 0, highlight_bomb_coords)


func _on_movement_expression_applied(movement_expr:String) -> void:
	#print(movement_expr)
	# clear current player tile
	erase_cell(player_coords)
	# calculate movement distance and emit fuel use 
	#SB.fuel_used.emit(cartesian_distance(player_coords, movement_tile))
	var new_fuel = PlayerManager.get_fuel() - cartesian_distance(player_coords, movement_tile)
	#print(PlayerManager.get_fuel())
	#print("new_fuel: ", new_fuel)
	
	PlayerManager.set_fuel(new_fuel)
	get_parent().fuel_updated.emit(new_fuel)
	
	
	
	# set_player_tile
	set_player_coords(movement_tile)
	
	# check if player is in bomb area
	print("player health before bomb: ", PlayerManager.get_health())
	if is_coord_in_bomb(movement_tile):
		PlayerManager.set_health(PlayerManager.get_health()-1)
	print("Player health after bomb: ", PlayerManager.get_health())
	#did player cross a laser
	
func _on_shooting_expression_applied(shooting_expr:String) -> void:
	if UIcontrol.player_control_ui.is_laser_mode:
		pass
	else:
		bomb(shoot_tile)


func is_coord_on_line(expression_string:String, coord: Vector2i) -> bool:
	# make expression object 
	var expression = Expression.new()
	#print("expression string: ", expression_string)
	#print("coord: ", -coord)
	# parse expression with variables
	var error = expression.parse(expression_string, ['x'])
	# loop through coords on line to see if the given coord belongs to this line
	for x in range(-tile_map_bounds.x, tile_map_bounds.x+1):
		var result = expression.execute([x])
		#print(Vector2i(x, result))
		if Vector2i(x, -result) == coord:
			print("Coord is on line")
			return true
	return false
	# debug
	#return true

func cartesian_distance(point1: Vector2i, point2: Vector2i) -> int:
	var dx: int = point2.x - point1.x
	var dy: int = point2.y - point1.y
	return int(sqrt(dx * dx + dy * dy))

func is_coord_in_bomb(coord: Vector2i):
	if highlight_layer.get_cell_atlas_coords(coord) == highlight_bomb_coords:
		return true
	else:
		false

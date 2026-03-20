extends TileMapLayer


@export var player_sprite_atlas_coords : Vector2 
@export var enemy_sprite_atlas_coords : Vector2 # set default values for these when assets are decided

@export var player_coords : Vector2 = Vector2i(0,0)
@export var enemy_coords : Vector2 = Vector2i(10,-10)

@export var tile_map_bounds : Vector2 = Vector2i(40,40)

@export var highlight_layer: TileMapLayer
@export var highlight_atlas_coords: Vector2i = Vector2i.ZERO
@export var highlight_bomb_coords: Vector2i = Vector2i(1,0)
var last_hovered_tile: Vector2i = Vector2i(-1, -1)


var movement_tile : Vector2i
var shoot_tile : Vector2i



func _ready() -> void:
	#connect signals from UI
	UIcontrol.player_control_ui.movement_expression_applied.connect(_on_movement_expression_applied)
	UIcontrol.player_control_ui.shooting_expression_applied.connect(_on_shooting_expression_applied)
	
	
	
	set_player_coords(Vector2i(0,0))
	set_enemy_coords(Vector2i(5,5))
	bomb(Vector2i(3,3))
	

# Will need to change the second arg of set_cell when the tilemap resource is created
func set_player_coords(coords : Vector2i):
	player_coords = coords
	set_cell(player_coords, 2, player_sprite_atlas_coords)
	
	
func set_enemy_coords(coords : Vector2i):
	enemy_coords = coords
	set_cell(enemy_coords,0,  enemy_sprite_atlas_coords)



func _process(_delta: float) -> void:
	var hovered_tile: Vector2i = local_to_map(to_local(get_global_mouse_position()))


	if Input.is_action_just_pressed("mouse_click") and UIcontrol.player_control_ui.visible and not UIcontrol.player_control_ui.is_hovered:
		# get movement and shoot expressions
		var move = UIcontrol.player_control_ui.get_movement_expression()
		var shoot = UIcontrol.player_control_ui.get_shooting_expression()
		print(move)
		print(shoot)
		print(hovered_tile)
		# include gaurd for empty expressions 
		if not move.is_empty():
			# check if the mouse coord is on move
			is_coord_on_line(move, hovered_tile)
		elif not shoot.is_empty():
			is_coord_on_line(shoot, hovered_tile)
		

		
		
		
		
	if hovered_tile == last_hovered_tile:
		return
		
	if highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_bomb_coords:
			highlight_layer.erase_cell(last_hovered_tile)



	if hovered_tile.x >= -tile_map_bounds.x and hovered_tile.x < tile_map_bounds.x and \
	hovered_tile.y >= -tile_map_bounds.y and hovered_tile.y < tile_map_bounds.y and highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_bomb_coords:
		highlight_layer.set_cell(hovered_tile, 0, highlight_atlas_coords)
		last_hovered_tile = hovered_tile
	else:
		last_hovered_tile = Vector2i(-1, -1)

	# Set the text of the coord_label
	UIcontrol.coord_label.text = str(hovered_tile.x) + "," +str(abs(hovered_tile.y))  
	




# a little annoying but the center_coord will be flipped on the grid
#ie if you enter (3,3) the rendered point will be (-3,-3)
func bomb(center_coord: Vector2i) ->void:
	# Create highlight at coord, just start with a 3x3 area
	for x in range(-1,2):
		for y in range(-1,2):
			highlight_layer.set_cell(Vector2i(center_coord.x+x, center_coord.y+y), 0, highlight_bomb_coords)


func _on_movement_expression_applied(movement_expr:String) -> void:
	pass
	
func _on_shooting_expression_applied(shooting_expr:String) -> void:
	if UIcontrol.player_control_ui.is_laser_mode:
		pass
	else:
		pass


func is_coord_on_line(expression_string:String, coord: Vector2i):
	# make expression object 
	var expression = Expression.new()
	# parse expression with variables
	var error = expression.parse(expression_string, ['x'])
	
	# loop through coords on line to see if the given coord belongs to this line
	for x in range(-tile_map_bounds.x, tile_map_bounds.x+1):
		var result = expression.execute([x])
		print(Vector2i(x, result))
		if Vector2i(x, result) == coord:
			print("Coord is on line")

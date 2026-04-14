extends TileMapLayer


@export var player_sprite_atlas_coords : Vector2 
@export var player2_sprite_atlas_coords : Vector2i = Vector2i.ZERO
@export var enemy_sprite_atlas_coords : Vector2 = Vector2.ZERO # set default values for these when assets are decided



@export var enemy_coords : Vector2 = Vector2i(10,-10)
@export var tile_map_bounds : Vector2 = Vector2(40,40)
@export var global_tile_size : Vector2 = to_global(map_to_local(Vector2i(1,1)))


@export var highlight_layer: TileMapLayer
@export var highlight_atlas_coords: Vector2i = Vector2i.ZERO
@export var highlight_bomb_coords: Vector2i = Vector2i(1,0)
@export var all_bomb_coords: Array[Vector2i]


@export var highlight_move_coords: Vector2i = Vector2i(2,0)
@export var highlight_shoot_coords: Vector2i = Vector2i(3,0)
@export var highlight_purple_coords: Vector2i = Vector2i(4,0)

var last_hovered_tile: Vector2i = Vector2i(-1, -1)


var movement_tile : Vector2i
var shoot_tile : Vector2i
var prev_bomb_tile1 : Variant = null  # tracks LMB's stolen bomb tile
var prev_bomb_tile2 : Variant = null  # tracks RMB's stolen bomb tile

var check_laser: bool = false
var prev_enemy_attack_expression : String
var enemy_attack_expression: String
var enemy_move_vector : Vector2
var active_laser_expression : String
var last_side: float = 0.0


func _ready() -> void:
	#connect signals from UI
	UIcontrol.player_control_ui.movement_expression_applied.connect(_on_movement_expression_applied)
	UIcontrol.player_control_ui.shooting_expression_applied.connect(_on_shooting_expression_applied)
	
	SB.enemy_attack.connect(_on_enemy_attack)
	SB.enemy_laser.connect(_on_enemy_laser)
	SB.enemy_move.connect(_on_enemy_move)
	set_player_coords(Vector2i(0,0))
	set_enemy_coords(Vector2i(5,5))
	

func reset_grid():
	print("reset grid")
	highlight_layer.clear()
	clear()
	for cell in highlight_layer.get_used_cells():
		highlight_layer.set_cell(cell, -1)
	highlight_layer.update_internals()
	for cell in get_used_cells():
		set_cell(cell,-1)
	update_internals()
	if PlayerManager.multiplayer_check:
		set_player_coords(Vector2i(0,0))
		set_enemy_coords(Vector2i(5,5))
	else:
		set_cell(PlayerManager.get_position(), 2, player_sprite_atlas_coords)
		set_cell(PlayerManager.get_position(), 0, player2_sprite_atlas_coords)
		set_enemy_coords(Vector2i(5,5))
#	for tile in self.til


# Will need to change the second arg of set_cell when the tilemap resource is created
func set_player_coords(coords : Vector2i):
	#TODO: change logic so that player tile is set depending on the current player
	PlayerManager.set_position(coords)
	#player_coords = coords #technically not necessary
	
	if PlayerManager.current_player == 0:
		set_cell(PlayerManager.get_position(), 2, player_sprite_atlas_coords)
	elif PlayerManager.current_player == 1:
		set_cell(PlayerManager.get_position(), 0, player2_sprite_atlas_coords)
	SB.player_moved.emit(PlayerManager.get_position())
	#print("player coords: ", player_coords)
	
	

func set_enemy_coords(coords : Vector2i):
	enemy_coords = coords
	set_cell(enemy_coords,1,  enemy_sprite_atlas_coords)
	#print("enemy at: ", enemy_coords)



func _process(_delta: float) -> void:
	var hovered_tile: Vector2i = local_to_map(to_local(get_global_mouse_position()))


	if Input.is_action_just_pressed("LMB") and UIcontrol.player_control_ui.visible and not UIcontrol.player_control_ui.is_hovered:
		# get movement and shoot expressions
		var move = UIcontrol.player_control_ui.get_movement_expression()

		# include gaurd for empty expressions 
		if not move.is_empty():
			# check if the mouse coord is on move
			if is_coord_on_line(move, hovered_tile):
				if prev_bomb_tile1 != null:
					highlight_layer.set_cell(prev_bomb_tile1, 0, highlight_bomb_coords)
					prev_bomb_tile1 = null
				else:
					if movement_tile != null:
						if movement_tile in all_bomb_coords:
							#highlight_layer.erase_cell(movement_tile)
							highlight_layer.set_cell(movement_tile,0,highlight_bomb_coords)
						else:
							highlight_layer.erase_cell(movement_tile)
					
				movement_tile = hovered_tile
				if hovered_tile in all_bomb_coords:
					prev_bomb_tile1 = hovered_tile
				
				if hovered_tile in all_bomb_coords:
					prev_bomb_tile1 = hovered_tile
					highlight_layer.set_cell(hovered_tile, 0, highlight_purple_coords)
				else:
					highlight_layer.set_cell(hovered_tile, 0, highlight_move_coords)
				#print("move: ", movement_tile)

			
	elif Input.is_action_just_pressed("RMB") and UIcontrol.player_control_ui.visible and not UIcontrol.player_control_ui.is_hovered:
		var shoot = UIcontrol.player_control_ui.get_shooting_expression()
		if not shoot.is_empty():
			if is_coord_on_line(shoot, hovered_tile):
				if prev_bomb_tile2 != null:
					highlight_layer.set_cell(prev_bomb_tile2, 0 , highlight_bomb_coords)
					prev_bomb_tile2 = null
				else:
					if shoot_tile != null and shoot_tile not in all_bomb_coords:
						highlight_layer.erase_cell(shoot_tile)
					elif shoot_tile in all_bomb_coords:
						highlight_layer.set_cell(shoot_tile,0, highlight_bomb_coords)
				
				shoot_tile = hovered_tile
				
				if hovered_tile in all_bomb_coords:
					prev_bomb_tile2 = hovered_tile
					highlight_layer.set_cell(hovered_tile, 0, highlight_purple_coords)
				else:
					highlight_layer.set_cell(hovered_tile, 0, highlight_shoot_coords)
				#print("shoot: ", shoot_tile)

		
	if hovered_tile == last_hovered_tile:
		return
		
	if highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_bomb_coords and \
	 highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_move_coords and \
	highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_shoot_coords and \
	highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_shoot_coords and \
	highlight_layer.get_cell_atlas_coords(last_hovered_tile) != highlight_purple_coords:

		highlight_layer.erase_cell(last_hovered_tile)



	if hovered_tile.x >= -tile_map_bounds.x and hovered_tile.x < tile_map_bounds.x and \
	hovered_tile.y >= -tile_map_bounds.y and hovered_tile.y < tile_map_bounds.y and highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_bomb_coords and \
	highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_move_coords and highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_shoot_coords and \
	highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_shoot_coords and \
	highlight_layer.get_cell_atlas_coords(hovered_tile) != highlight_purple_coords:
		
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
			all_bomb_coords.append(Vector2i(center_coord.x+x, center_coord.y+y))

func laser(shooting_expr:String) -> void:
	#var enemy_move_expression = UIcontrol.player_control_ui.get_movement_expression()
	#get enemies move expression
	#var intersection : Variant = get_intersect_point(enemy_move_vector, shooting_expr)
	#print("intersection at: ", intersection)
	pass


func _on_movement_expression_applied(movement_expr:String) -> void:
	#print(movement_expr)
	# clear current player tile
	erase_cell(PlayerManager.get_position())
	# calculate movement distance and emit fuel use 
	#SB.fuel_used.emit(cartesian_distance(PlayerManager.get_position(), movement_tile))
	var new_fuel = PlayerManager.get_fuel() - cartesian_distance(PlayerManager.get_position(), movement_tile)
	#print(PlayerManager.get_fuel())
	#print("new_fuel: ", new_fuel)
	
	PlayerManager.set_fuel(new_fuel)
	get_parent().fuel_updated.emit(new_fuel)
	
	
	
	# set_player_tile
	var prev_player_coords = PlayerManager.get_position()
	set_player_coords(movement_tile)
	
	
	# check if player is in bomb area
	#print("player health before bomb: ", PlayerManager.get_health())
	if is_coord_in_bomb(movement_tile):
		SB.player_health_update.emit(-1)
	#print("Player shealth after bomb: ", PlayerManager.get_health())
	#did player cross a laser
	#if check_laser:
		#print("check laser")
	if did_player_cross_laser(prev_player_coords,PlayerManager.get_position()):
		SB.player_health_update.emit(-1)
		#print("player crossed laser")
	

func _on_shooting_expression_applied(shooting_expr:String) -> void:
	if UIcontrol.player_control_ui.is_laser_mode:
		laser(shooting_expr)
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
			#print("Coord is on line")
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

func did_player_cross_laser(prev_coords, coords):
	#print("prev coords: ", prev_coords)
	#print("current coords", coords)
	var movement_expression = UIcontrol.player_control_ui.get_movement_expression()
	#print("active laser attack expression: ", active_laser_expression)
	#print("Enemy attack expression: ", enemy_attack_expression)
	var intersection : Variant = get_intersect_point(active_laser_expression, movement_expression)
	#print("intersection at: ", intersection)
	if intersection == null:
		return false
	else:
		var intersection_tile = Vector2i(intersection.x, -intersection.y) # have to negate the y coordinate because prev_cord and coords are in tile space while the intersection is in math spacewda 
		return has_crossed_intersection(prev_coords, coords, intersection_tile)


func has_crossed_intersection(prev: Vector2, curr: Vector2, intersect: Vector2) -> bool:
	var movement = curr - prev
	var to_intersect = intersect - prev

	# Project the intersection onto the movement vector (gives a 0.0 - 1.0 value)
	var t = to_intersect.dot(movement) / movement.length_squared()

	# t in [0,1] means the intersect point falls between prev and curr
	print(t >= 0.0 and t <= 1.0)
	return t >= 0.0 and t <= 1.0


func parse_linear_exp_string(expression : String) -> Dictionary:
	var m : float
	var b : float
	
	if 'x' in expression:
		var parts = expression.split('x')
		#print("parts ", parts)
		
		# parse slope
		var m_str = parts[0]
		var b_str = parts[1]
		
		m_str = m_str.replace("*", "")
		b_str = b_str.replace("*", "")
		
		
		#print("mstr: " ,m_str)
		if m_str =="" and b_str != "":
			var b_parts = b_str.split("+") if "+" in b_str else b_str.split("-")
			m = float(b_parts[0])
			b = float(b_str.substr(b_parts[0].length())) if b_parts.size() > 1 else 0
			# re add the - sign if split was on -
			if "+" not in b_str and b_parts.size() > 1:
				b = -b
		else:
			if m_str == "" or m_str == "+":
				m = 1
			elif m_str == "-":
				m= -1
			else:
				m = float(m_str)
				
			# parse intercept
			
			if b_str =="":
				b = 0
			else:
				b = float(b_str)
			
	else:
		m = 0
		b = float(expression)
			
	return {'m':m,'b':b}
		
func get_intersect_point(expression1: String, expression2 : String) -> Variant:
	var eq1 = parse_linear_exp_string(expression1)
	print("eq1: ", eq1)
	var eq2 = parse_linear_exp_string(expression2)
	print("eq2: ", eq2)
	var m1 = eq1["m"]
	var m2 = eq2["m"]
	var b1 = eq1["b"]
	var b2 = eq2["b"]
	
	if m1 == m2:
		return null
		
	var x = (b2-b1) /(m1-m2)
	var y = m1 * x + b1
	return Vector2(x,y)
	
func _on_enemy_laser():
	check_laser = true
	active_laser_expression = enemy_attack_expression

func _on_enemy_attack(equation: String):
	#print("on enemy attack")
	prev_enemy_attack_expression = enemy_attack_expression
	enemy_attack_expression = equation
	check_laser = false 
	#print("enemy attack expression: ", enemy_attack_expression)

func _on_enemy_move(movement_vector: Vector2):
	enemy_move_vector = movement_vector



func did_enemy_cross_laser(start_coords: Vector2i, end_coords: Vector2i, laser_expression: String) -> bool:
	var eq = parse_linear_exp_string(laser_expression)
	var m = eq["m"]
	var b = eq["b"]

	var dx = float(end_coords.x - start_coords.x)
	var dy = float(end_coords.y - start_coords.y)
	var sx = float(start_coords.x)
	var sy = float(start_coords.y)

	# Denominator is zero when the enemy's path is parallel to the laser
	var denom = -m * dx - dy
	if abs(denom) < 0.0001:
		return false

	var t = (sy + m * sx + b) / denom
	return t >= 0.0 and t <= 1.0

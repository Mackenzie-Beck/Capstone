extends TileMapLayer


@export var player_sprite_atlas_coords : Vector2 
@export var goal_sprite_atlas_coords : Vector2 # set default values for these when assets are decided

@export var player_coords : Vector2 = Vector2(0,0)
@export var goal_coords : Vector2 = Vector2(10,-10)

@export var tile_map_bounds : Vector2 = Vector2(17,10)




# Will need to change the second arg of set_cell when the tilemap resource is created
func set_player_coords(coords : Vector2):
	player_coords = coords
	set_cell(player_coords, 1, player_sprite_atlas_coords)
	
	
func set_goal_coords(coords : Vector2):
	goal_coords = coords
	set_cell(goal_coords,1,  goal_sprite_atlas_coords)

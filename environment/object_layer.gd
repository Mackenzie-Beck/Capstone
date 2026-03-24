extends TileMapLayer


@export var player_sprite_atlas_coords : Vector2 
@export var enemy_sprite_atlas_coords : Vector2 # set default values for these when assets are decided

@export var player_coords : Vector2 = Vector2(0,0)
@export var enemy_coords : Vector2 = Vector2(10,-10)

@export var tile_map_bounds : Vector2 = Vector2(40,40)
@export var global_tile_size : Vector2 = to_global(map_to_local(Vector2i(1,1)))

@export var highlight_layer: TileMapLayer
@export var highlight_atlas_coords: Vector2i = Vector2.ZERO
var last_hovered_tile: Vector2i = Vector2i(-1, -1)



func _ready() -> void:
	set_player_coords(Vector2(0,0))
	set_enemy_coords(Vector2(5,5))

# Will need to change the second arg of set_cell when the tilemap resource is created
func set_player_coords(coords : Vector2):
	player_coords = coords
	set_cell(player_coords, 2, player_sprite_atlas_coords)
	
	
func set_enemy_coords(coords : Vector2):
	#print("got to set_enemey_coords, coords="+str(coords))
	enemy_coords = coords
	set_cell(enemy_coords,0,  enemy_sprite_atlas_coords)



func _process(_delta: float) -> void:
	var hovered_tile: Vector2i = local_to_map(to_local(get_global_mouse_position()))
	
	if hovered_tile == last_hovered_tile:
		return

	highlight_layer.clear()  # removes the single highlight cell

	if hovered_tile.x >= -tile_map_bounds.x and hovered_tile.x < tile_map_bounds.x and \
	hovered_tile.y >= -tile_map_bounds.y and hovered_tile.y < tile_map_bounds.y:
		highlight_layer.set_cell(hovered_tile, 0, highlight_atlas_coords)
		last_hovered_tile = hovered_tile
	else:
		last_hovered_tile = Vector2i(-1, -1)

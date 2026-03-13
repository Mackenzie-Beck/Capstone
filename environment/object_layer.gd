extends TileMapLayer


@export var player_sprite_atlas_coords : Vector2 
@export var enemy_sprite_atlas_coords : Vector2 # set default values for these when assets are decided

@export var player_coords : Vector2 = Vector2(0,0)
@export var enemy_coords : Vector2 = Vector2(10,-10)

@export var tile_map_bounds : Vector2 = Vector2(40,40)


func _ready() -> void:
	set_player_coords(Vector2(0,0))
	set_enemy_coords(Vector2(5,5))

# Will need to change the second arg of set_cell when the tilemap resource is created
func set_player_coords(coords : Vector2):
	player_coords = coords
	set_cell(player_coords, 2, player_sprite_atlas_coords)
	
	
func set_enemy_coords(coords : Vector2):
	enemy_coords = coords
	set_cell(enemy_coords,0,  enemy_sprite_atlas_coords)

extends Upgrade

class_name ColorSplash

@export_range(0, 1) var splash_frac = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func trigger_internal(tilemap: TileMap, recipe: Recipe):
	var filtered_neighbors: Array[Vector2i] = []
	var neighbors = {}
	for n in tilemap.pattern_to_clear:
		var temp = tilemap.get_surrounding_cells(n)
		for ti in temp:
			neighbors[ti] = null
	var neighbor_list = neighbors.keys()
	for n in neighbor_list:
		var temp_coord = tilemap.get_cell_atlas_coords(0, n)
		var valid_tile_ids = []
		for i in tilemap.piece_spawner.valid_color_indices:
			valid_tile_ids.append(Vector2i(i, 0))
		if temp_coord in valid_tile_ids and temp_coord != Vector2i(recipe.color_index, 0):
			filtered_neighbors.append(n)
	for fn in filtered_neighbors:
		var chance = randf_range(0, 1)
		if chance < splash_frac:
			tilemap.erase_cell(0, fn)
			tilemap.set_cell(0, fn, 0, Vector2i(recipe.color_index, 0))



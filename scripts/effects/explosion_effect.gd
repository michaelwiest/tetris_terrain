extends Effect

class_name ExplosionEffect
@export var flame_scene: PackedScene
var flame

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	flame = flame_scene.instantiate()
	flame.z_index = 2
	flame.restart()
	add_child(flame)
#	print("adding flame")


# Gross hack to draw flame animation.
func _process(delta):
	if flame:
		flame.position = global_location


func trigger_internal(tilemap: TileMap):
	var filtered_neighbors: Array[Vector2i] = find_neighboring_cells(tilemap)
	var unique_matched := {}
	# Clean this up.
	for mp in tilemap.pattern_to_clear:
		unique_matched[mp] = null
	for fn in filtered_neighbors:
		unique_matched[fn] = null
	tilemap.pattern_to_clear = unique_matched.keys()
	

func find_neighboring_cells(tilemap: TileMap) -> Array[Vector2i]:
	var filtered_neighbors: Array[Vector2i] = []
	var neighbors = tilemap.get_surrounding_cells(location)
	neighbors.append(neighbors[0] + Vector2i.UP)
	neighbors.append(neighbors[1] + Vector2i.RIGHT)
	neighbors.append(neighbors[2] + Vector2i.DOWN)
	neighbors.append(neighbors[3] + Vector2i.LEFT)
	for n in neighbors:
		var temp_coord = tilemap.get_cell_atlas_coords(0, n)
		var valid_tile_ids = []
		for i in tilemap.piece_spawner.valid_color_indices:
			valid_tile_ids.append(Vector2i(i, 0))
		if temp_coord in valid_tile_ids:
			filtered_neighbors.append(n)
	return filtered_neighbors

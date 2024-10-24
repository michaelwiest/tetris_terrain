extends Node2D

class_name Effect

enum Type {BOARD_ALTER, MATCH_ALTER, UPGRADE}
@onready var active: bool = false
@export var location: Vector2i = Vector2i(-1, -1)
@onready var animation = $animation
@export var type: Type = Type.MATCH_ALTER

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func find_neighboring_cells(tilemap: TileMap) -> Array[Vector2i]:
	if not active:
		return []
	var filtered_neighbors: Array[Vector2i] = []
	var neighbors = tilemap.get_surrounding_cells(location)
	neighbors.append(neighbors[0] + Vector2i.UP)
	neighbors.append(neighbors[1] + Vector2i.RIGHT)
	neighbors.append(neighbors[2] + Vector2i.DOWN)
	neighbors.append(neighbors[3] + Vector2i.LEFT)
	for n in neighbors:
		var temp_coord = tilemap.get_cell_atlas_coords(0, n)
		if temp_coord in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), ]:
			filtered_neighbors.append(n)
	return filtered_neighbors
	

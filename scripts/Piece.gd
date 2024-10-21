extends Node2D
class_name Piece

# array of Array of vector2i
var all_pieces: Array
# array of vector2i
var tilemap_ids: Array

var has_upgrade: bool = false
var rotation_mod: int
var active_piece: Array

@onready var is_ready: bool = false
@onready var rotation_index: int = 0

# TODO: implement a way to figure out the shape type of the current piece. 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func instance(new_positions: Array, new_tmap_ids: Array): 
	assert(len(new_positions[0]) == len(new_tmap_ids), "Must be same length.")
	rotation_mod = len(new_positions)
	for np in new_positions:
		for npi in np:
			assert(typeof(npi) == 6, "All positions must be vector2i")
	for nti in new_tmap_ids:
		assert(typeof(nti) == 6, "All positions must be vector2i")
	all_pieces = new_positions
	tilemap_ids = new_tmap_ids
	active_piece = all_pieces[rotation_index]
	is_ready = true

func rotated_positions():
	var temp_rotation_index = (rotation_index + 1) % 4
	return all_pieces[temp_rotation_index]

func rotate_piece():
	rotation_index = (rotation_index + 1) % 4
	active_piece = all_pieces[rotation_index]

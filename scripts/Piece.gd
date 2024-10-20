extends Node2D
class_name Piece
# array of vector2i
var positions: Array

# array of vector2i
var tilemap_ids: Array
var has_upgrade: bool = false

@onready var is_ready: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func instance(new_positions: Array, new_tmap_ids: Array): 
	assert(len(new_positions) == len(new_tmap_ids), "Must be same length.")
	for np in new_positions:
		assert(typeof(np) == 6, "All positions must be vector2i")
	for nti in new_tmap_ids:
		assert(typeof(nti) == 6, "All positions must be vector2i")
	positions = new_positions
	tilemap_ids = new_tmap_ids
	is_ready = true

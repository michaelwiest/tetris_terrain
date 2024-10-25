extends Node2D
class_name Piece

# array of Array of vector2i
var all_pieces: Array
# array of vector2i
var tilemap_ids: Array

var effect_indices: PackedInt32Array = []
var effects: Array[Effect] = []
var rotation_mod: int
var active_piece: Array
var anims = []

@onready var is_ready: bool = false
@onready var rotation_index: int = 0
var flame = preload("res://scenes/Flame.tscn")
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


func draw(tilemap: TileMap, tilemap_layer: int, pos: Vector2i, tile_id: int):
	for i in range(len(active_piece)):
		var piece_i = active_piece[i]
		tilemap.set_cell(tilemap_layer, pos + piece_i, tile_id, tilemap_ids[i])
		# Gross hack to draw an effect.
		if i in effect_indices:
			anims[i].position = tilemap.map_to_local(pos + piece_i)
			anims[i].z_index = 2


func clear(tilemap: TileMap, active_layer: int, pos: Vector2i):
	for i in active_piece:
		tilemap.erase_cell(active_layer, pos + i)
		# Gross hack to draw an effect.
		tilemap.erase_cell(2, pos + i)

func set_matched_effects(matched_pattern: Array):
	for index in effect_indices:
		if effects[index].location in matched_pattern:
			effects[index].active = true

func land(cur_pos: Vector2i):
	# Set the final location for the piece's potential effects for downstream operations
	for index in effect_indices:
		effects[index].location = active_piece[index] + cur_pos

func set_effects(effects_temp: Array, locs: PackedInt32Array):
	assert(len(effects_temp) == len(locs), "Effects and locations must match.")
	for effect in effects_temp:
		effects.append(effect)
		var flame_anim = flame.instantiate()
		add_child(flame_anim)
		anims.append(flame_anim)
	for loci in locs:	
		effect_indices.append(loci)

func has_effect():
	return len(effects) > 0

func effect_locations():
	var all_locations: Array[Vector2i] = []
	for e in effects:
		all_locations.append(e.location)
	return all_locations
		

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
var has_upgrade: bool = false

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


func draw(
	tilemap: TileMap, tilemap_layer: int, pos: Vector2i, tile_id: int,
	additional_offset: Vector2 = Vector2(0, 0)):
	for i in range(len(active_piece)):
		var piece_i = active_piece[i]
		tilemap.set_cell(tilemap_layer, pos + piece_i, tile_id, tilemap_ids[i])
		
		if i in range(len(effect_indices)):
			var index = effect_indices[i]
			effects[i].move(
				pos + active_piece[index], 
				tilemap.map_to_local(pos + active_piece[index]) + additional_offset)

			
func trigger_effects(tilemap: TileMap):
	for e in effects:
		e.trigger(tilemap)

func clear(tilemap: TileMap, active_layer: int, pos: Vector2i):
	for i in active_piece:
		tilemap.erase_cell(active_layer, pos + i)

func set_matched_effects(matched_pattern: Array):
	for index in range(len(effect_indices)):
		var effect_index = effect_indices[index]
		if effects[index].location in matched_pattern:
			effects[index].active = true

func land(cur_pos: Vector2i):
	# Set the final location for the piece's potential effects for downstream operations
	for index in range(len(effect_indices)):
		var effect_index = effect_indices[index]
		effects[index].location = active_piece[effect_index] + cur_pos


func add_effects_at_locations(effects_temp: Array[Effect], locs: PackedInt32Array):
	assert(len(effects_temp) == len(locs), "Effects and locations must match.")
	
	for effect in effects_temp:
		if effect.type == Effect.Type.UPGRADE:
			has_upgrade = true
		effects.append(effect)
		add_child(effect)
	for loci in locs:	
		effect_indices.append(loci)

func add_effect(effect_temp: Effect):
	var piece_arr = [0, 1, 2, 3]
	piece_arr.shuffle()
	if len(effect_indices) < 4:
		for i in piece_arr:
			if i not in effect_indices:
				add_effects_at_locations([effect_temp], [i])
				break
				

func has_effect():
	return len(effects) > 0

func effect_locations():
	var all_locations: Array[Vector2i] = []
	for e in effects:
		all_locations.append(e.location)
	return all_locations
		

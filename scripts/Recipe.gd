extends Node2D
class_name Recipe

@export var display_name: String
@export var display_color: Color
@export var piece: Piece
@export var check_from_bottom: bool = true
var animation = preload("res://scenes/flash.tscn")
var particle = preload("res://scenes/explosion.tscn")
var _is_animating: bool = false
var animation_objects: Array = []
var particle_objects: Array = []
@export var has_match: bool = false

@onready var clear_sound = $SfxrStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
func instantiate(temp_piece: Piece):
	piece = temp_piece
	
func print_patterns():
	print(piece.active_piece)

func set_animation_finished():
	_is_animating = false
	for anim in animation_objects:
		anim.queue_free()
#	for parti in particle_objects:
#		parti.queue_free()
	animation_objects = []
	particle_objects = []

func is_animating():
	return _is_animating

func animate(locs):
	clear_sound.play()
	for i in range(len(locs)):
		var loc = locs[i]
		var anim = animation.instantiate()
		var parti = particle.instantiate()
		parti.color = display_color
		animation_objects.append(anim)
		particle_objects.append(parti)
		add_child(anim)
		add_child(parti)
		anim.position = loc
		parti.position = loc
		anim.play()
		parti.restart()
		if i == 0:
			_is_animating = true
			anim.animation_finished.connect(set_animation_finished)

# This code is pretty brittle and needs some checking	
func has_piece(query_piece: Piece):
	for pi in piece.all_pieces:
		var has_match = true
		for p in query_piece.active_piece:
			if p not in pi:
				has_match = false
			
		if has_match and piece.tilemap_ids == query_piece.tilemap_ids:
			return true
			
	return false
		

func find_patterns_in_tilemap(
	tilemap: TileMap, 
	board_layer: int, 
	row_max: int, 
	col_max: int, 
	active_piece: Piece,
	row_min: int = 0, 
	col_min: int = 0
	):
	"""Find a version of this recipe's pattern within the supplied tilemap. 
	
	This will also take an active_piece to find any effects on it such that the code will 
	try and preferentially match the tile with an effect on it.
	"""
	var has_match_temp: bool
	has_match = false
	var matching_locations: Array[Vector2i] = []
	# In the case where we have an active_piece with effects on it we want to preferentially
	# trigger those. In which case we have to track all matches. 
	var all_matching_locations: Array = []
	
	var row_to_check = range(row_min, row_max)
	if check_from_bottom:
		row_to_check = range(row_max -1 , row_min -1, -1)
	
	for p in piece.tilemap_ids:
		matching_locations.append(Vector2i(-1, -1))
	var cols_to_check = range(col_min, col_max)
	for row in row_to_check:
		for col in cols_to_check:
			for j in len(piece.all_pieces):
				var piece_to_check = piece.all_pieces[j]
				# Reset the match
				matching_locations = []
				for p in piece.tilemap_ids:
					matching_locations.append(Vector2i(-1, -1))
				has_match_temp = true
				for i in len(piece_to_check):
					var p: Vector2i = piece_to_check[i]
					var atlas_to_match = piece.tilemap_ids[i]

					var rc = row + p[0]
					var cc = col + p[1]
					if (rc > row_max):
						has_match_temp = false
						continue
					if (cc > col_max):
						has_match_temp = false
						continue
					if (tilemap.get_cell_atlas_coords(board_layer, Vector2i(cc, rc)) != atlas_to_match):
						has_match_temp = false
					else:
						matching_locations[i] = Vector2i(cc, rc)

				if has_match_temp:
					all_matching_locations.append(matching_locations)
	
	if len(all_matching_locations) == 0:
		has_match = false
		return matching_locations
	has_match = true	
	print("Has effect ", active_piece.has_effect())
	print(all_matching_locations)
	if not active_piece.has_effect():
		return all_matching_locations[0]
	else:
		var max_count: int = 0
		var to_return_index: int = 0
		for i in range(len(all_matching_locations)):
			var temp_count: int = 0
			for e in active_piece.effect_locations():
				if e in all_matching_locations[i]:
					temp_count += 1
			if temp_count > max_count:
				to_return_index = i
		
		return all_matching_locations[to_return_index]
	

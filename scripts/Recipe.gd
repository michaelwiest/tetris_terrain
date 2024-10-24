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
	row_min: int = 0, 
	col_min: int = 0
	):
	var has_match
	var matching_locations = []
	
	var row_to_check = range(row_min, row_max)
	# Need to shift indices if going from bottom
	if check_from_bottom:
		row_to_check = range(row_max -1 , row_min -1, -1)
	
	for p in piece.tilemap_ids:
		matching_locations.append(Vector2i(-1, -1))
	var cols_to_check = range(col_min, col_max)
	for row in row_to_check:
		for col in cols_to_check:
			for j in len(piece.all_pieces):
				var piece_to_check = piece.all_pieces[j]
				has_match = true
				for i in len(piece_to_check):
					var p: Vector2i = piece_to_check[i]
					var atlas_to_match = piece.tilemap_ids[i]

					var rc = row + p[0]
					var cc = col + p[1]
					if (rc > row_max):
						has_match = false
						continue
					if (cc > col_max):
						has_match = false
						continue
					if (tilemap.get_cell_atlas_coords(board_layer, Vector2i(cc, rc)) != atlas_to_match):
						has_match = false
					else:
						matching_locations[i] = Vector2i(cc, rc)

				if has_match:
					return [true, matching_locations]
			#		
	return [has_match, matching_locations]

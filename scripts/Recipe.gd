extends Node2D
class_name Recipe

@export var shape_type: ShapeAutoload.Shape
@export var color_index: int
@export var display_name: String
@export var display_color: Color
@export var check_from_bottom: bool = true
var animation = preload("res://scenes/animations/flash.tscn")
var particle = preload("res://scenes/animations/explosion.tscn")
var _is_animating: bool = false
var animation_objects: Array[AnimatedSprite2D] = []
var particle_objects: Array[CPUParticles2D] = []
@export var has_match: bool = false

@export var score_per_tile: int = 25

@onready var clear_sound = $SfxrStreamPlayer
@onready var piece: Piece = $Piece

@onready var upgrades: Array[Upgrade] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var temp_shape = ShapeAutoload.get_shapes(shape_type)
	var colors_temp = []
	for ts in temp_shape:
		colors_temp.append(Vector2i(color_index, 0))
	piece.instance(ShapeAutoload.get_shapes(shape_type), colors_temp)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func trigger_upgrades(tilemap: TileMap):
	for u in upgrades:
		u.trigger(tilemap, self)

func find_upgrades_in_tree() -> Array[Upgrade]:
	var to_return: Array[Upgrade] = []
	for child in get_children():
		if child is Upgrade:
			to_return.append(child)
	return to_return

func set_upgrades(upgrade: Upgrade):
	add_child(upgrade)
	upgrade.hide_icon()
	upgrades = find_upgrades_in_tree()

func reset():
	for upgrade in upgrades:
		upgrade.queue_free()
	upgrades = []

func instantiate(temp_piece: Piece):
	piece = temp_piece
	
func print_patterns():
	print(piece.active_piece)


func is_animating():
	return _is_animating

func set_animations(tilemap: TileMap, locs):
#	clear_sound.play()
	animation_objects = []
	particle_objects = []
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
		anim.visible = false
		parti.position = loc

	tilemap.animation_queue.add_animations_and_sound(animation_objects, [clear_sound] as Array[AudioStreamPlayer], particle_objects as Array[CPUParticles2D])
			

# This code is pretty brittle and needs some checking	
func has_piece(query_piece: Piece):
	var query_piece_type: ShapeAutoload.Shape = ShapeAutoload.determine_shape(query_piece.active_piece)
	var piece_type_match: bool = true
	for i in range(len(query_piece.tilemap_ids)):
		if query_piece.tilemap_ids[i][0] != color_index:
			piece_type_match = false
	return query_piece_type == piece.piece_type and piece_type_match

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
					var rc = row + p[1]
					var cc = col + p[0]
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
	

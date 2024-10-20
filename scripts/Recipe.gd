extends Node2D
class_name Recipe

@export var patterns: Array
@export var target_atlas_locations: Array
@export var tilemap: TileMap
@export var check_from_bottom: bool = true
var animation = preload("res://scenes/flash.tscn")
var particle = preload("res://scenes/explosion.tscn")
var _is_animating: bool = false
var animation_objects: Array = []
var particle_objects: Array = []
@onready var clear_sound = $SfxrStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if len(patterns) != len(target_atlas_locations):
		push_error("Recipe pattern length and target_atlas_location must be the same.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_patterns(p):
	if len(patterns) > 0:
		push_warning("Overwriting pattern to match.")
	patterns = []
	for pi in p:
		patterns.append(pi)

func set_target_atlas_locations(l):
	if len(target_atlas_locations) > 0:
		push_warning("Overwriting target_atlas_alocations to match.")
	target_atlas_locations = []
	for li in l:
		target_atlas_locations.append(li)
	
	
func print_patterns():
	print(patterns)

func set_animation_finished():
	_is_animating = false
	for anim in animation_objects:
		anim.queue_free()
	for parti in particle_objects:
		parti.queue_free()
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
	
	for p in patterns[0]:
		matching_locations.append(Vector2i(-1, -1))
	var cols_to_check = range(col_min, col_max)
	for row in row_to_check:
		for col in cols_to_check:
			for j in len(patterns):
				has_match = true
				for i in len(patterns[j]):
					var p = patterns[j][i]
					var atlas_to_match = self.target_atlas_locations[i]

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

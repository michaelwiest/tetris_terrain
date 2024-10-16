extends Node2D
class_name Recipe

@export var patterns: Array
@export var target_atlas_locations: Array
@export var tilemap: TileMap
var animation = preload("res://scenes/green_animation.tscn")
var _is_animating: bool = false
var animation_objects: Array = []
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
	animation_objects = []

func is_animating():
	return _is_animating

func animate(locs):
	clear_sound.play()
	for i in range(len(locs)):
		var loc = locs[i]
		var anim = animation.instantiate()
		animation_objects.append(anim)
		add_child(anim)
		anim.position = loc
		anim.play()
		if i == 0:
			_is_animating = true
			anim.animation_finished.connect(set_animation_finished)
	


func find_patterns_in_tilemap(tilemap: TileMap, board_layer: int, row_offset: int, col_offset: int):
	var has_match
	var matching_locations = []
	var rows = tilemap.get_used_rect().size[1]
	var cols = tilemap.get_used_rect().size[0]
	for p in patterns[0]:
		matching_locations.append(Vector2i(-1, -1))
	for row in rows:
		for col in cols:
			for j in len(patterns):
				has_match = true
				for i in len(patterns[j]):
					var p = patterns[j][i]
					var atlas_to_match = self.target_atlas_locations[i]

					var rc = row + p[1]
					var cc = col + p[0]
					if (rc > rows):
						has_match = false
						continue
					if (cc > cols):
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

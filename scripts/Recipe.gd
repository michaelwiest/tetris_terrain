extends Node2D
class_name Recipe

@export var patterns: Array
@export var target_atlas_locations: Array
@export var tilemap: TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	if len(patterns) != len(target_atlas_locations):
		push_error("Recipe pattern length and target_atlas_location must be the same.")
#	for p in patterns:
#		print(typeof(p))
#	print(patterns)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_patterns(p):
	if len(patterns) > 0:
		push_warning("Overwriting pattern to match.")
	patterns = []
	for pi in p:
		print(typeof(pi))
		patterns.append(pi)

func set_target_atlas_locations(l):
	if len(target_atlas_locations) > 0:
		push_warning("Overwriting target_atlas_locations to match.")
	target_atlas_locations = []
	for li in l:
		target_atlas_locations.append(li)
	
	
func print_patterns():
	print(patterns)

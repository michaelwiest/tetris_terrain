extends Node2D
class_name PieceSpawner

@export var valid_shapes: Array[ShapeAutoload.Shape]
@export var valid_color_indices: Array[int]
#@onready var shapes_full = ShapeAutoload.shapes
var shapes_full: Array = []
@export_range(0, 1) var split_color_chance: float = 0.0

var piece_count: int = 0

var piece_resource = preload("res://scenes/Piece.tscn")
var shapes: Array
# Called when the node enters the scene tree for the first time.
func _ready():
	shapes_full = []
	for vs in valid_shapes:
		shapes_full.append(ShapeAutoload.get_shapes(vs))
	shapes = shapes_full.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_new_game():
	piece_count = 0

func pick_piece(recipes: Array[Recipe], disable_auto_match: bool = true, ) -> Piece:
	var piece_positions
	if not shapes.is_empty():
		shapes.shuffle()
		piece_positions = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		shapes.shuffle()
		piece_positions = shapes.pop_front()

	var atlas_arr = pick_piece_atlas()
	var new_piece = piece_resource.instantiate()

	new_piece.instance(piece_positions, atlas_arr)
	add_child(new_piece)
	if disable_auto_match:
		for r in recipes:
			if r.has_piece(new_piece):
				new_piece.queue_free()
				return pick_piece(recipes, disable_auto_match)
	
	piece_count += 1
	
	return new_piece



func pick_piece_atlas(n_entries: int = 4):
	var chosen_index_0: int = valid_color_indices[randi() % valid_color_indices.size()]
	var choice_0 = Vector2i(chosen_index_0, 0)
	var choice_1 = choice_0
	if randf_range(0, 1.0) < split_color_chance:
		var chosen_index_1: int = valid_color_indices[randi() % valid_color_indices.size()]
		choice_1 = Vector2i(chosen_index_1, 0)
	return [choice_0, choice_0, choice_1, choice_1]

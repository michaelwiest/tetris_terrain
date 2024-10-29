extends Node2D
class_name PieceSpawner

@export var valid_shapes: Array[ShapeAutoload.Shape]
@export var valid_color_indices: Array[int]
var shapes_full: Array = []
@export_range(0, 1) var split_color_chance: float = 0.0

@export_group("Effects")
@export var effect_spawners: Array[EffectSpawner]

@export_group("Upgrades")
@export var upgrade_spawners: Array[UpgradeSpawner]
var active_upgrade_spawners: Array[UpgradeSpawner]
var upgrade_effect_preload = preload("res://scenes/effects/UpgradeEffect.tscn")

# Use this ultimately to manually add effects when specified via an upgrade.
var effects_to_add: Array[Effect] = []

var piece_count: int = 0

var piece_resource = preload("res://scenes/Piece.tscn")
var shapes: Array
# Called when the node enters the scene tree for the first time.
func _ready():
	shapes_full = []
	for vs in valid_shapes:
		shapes_full.append(ShapeAutoload.get_shapes(vs))
	shapes = shapes_full.duplicate()
	
	active_upgrade_spawners = upgrade_spawners


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
	add_effects(new_piece)
	return new_piece

func add_effects(piece: Piece):
	for i in range(len(active_upgrade_spawners)):
		var us: UpgradeSpawner = active_upgrade_spawners[i]
		if randf_range(0, 1) < us.chance:
			var upgrade_node: Upgrade = load(us.upgrade_path).instantiate()
			var upgrade_effect: UpgradeEffect = upgrade_effect_preload.instantiate()
			upgrade_effect.upgrade = upgrade_node
			upgrade_effect.upgrade_added.connect(on_piece_matched)
			upgrade_effect.piece_spawner_upgrade_index = i
			piece.add_effect(upgrade_effect)
	
	for es in effect_spawners:
		if randf_range(0, 1) < es.chance:
			var new_effect: Effect = load(es.effect_path).instantiate()
			piece.add_effect(new_effect)


func pick_piece_atlas(n_entries: int = 4):
	var chosen_index_0: int = valid_color_indices[randi() % valid_color_indices.size()]
	var choice_0 = Vector2i(chosen_index_0, 0)
	var choice_1 = choice_0
	if randf_range(0, 1.0) < split_color_chance:
		var chosen_index_1: int = valid_color_indices[randi() % valid_color_indices.size()]
		choice_1 = Vector2i(chosen_index_1, 0)
	return [choice_0, choice_0, choice_1, choice_1]


func on_piece_matched(index_to_remove: int):
	if index_to_remove < len(active_upgrade_spawners):
		active_upgrade_spawners.remove_at(index_to_remove)
		
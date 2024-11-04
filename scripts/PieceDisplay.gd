extends Control
class_name PieceDisplay

@onready var tilemap: TileMap = $TileMap
@export var offset: Vector2i = Vector2i(1, 1)
@onready var piece: Piece
@export var tilemap_scale: Vector2 = Vector2(1.0, 1.0)
var existing_parent: Node2D 
var effects: Array[Effect]
# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap.scale = tilemap_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_tileset(tile_set: TileSet):
	tilemap.tile_set = tile_set

func clear_piece():
	piece.clear(tilemap, 0, offset)

func draw_piece():
	# Something is messed up in here where the animations are getting drawn below the tilemap.
	# This is because the WHOLE tilemap is also offset by 100.....
	# If i make both of these parent to a main node then this shouldn't be an issue?
	piece.draw(tilemap, 0, offset, 0, effects)
	
func set_piece(new_piece: Piece):
	# Need to do something here around copying the effects, adding them to this scene
	# and then drawing appropriately.
	if piece:
		clear_piece()
		piece.toggle_effect_visibility()
	piece = new_piece
	piece.toggle_effect_visibility()
	cleanup_temp_effects(piece)
	draw_piece()

func cleanup_temp_effects(piece: Piece):
	for e in effects:
		remove_child(e)
		e.queue_free()
		
	effects = []
	for ep in piece.effect_paths:
		var new_effect = load(ep).instantiate()
		add_child(new_effect)
		effects.append(new_effect)
	


#func release_piece():
#		if existing_parent:
#			call_deferred("remove_child", piece)
#			existing_parent.call_deferred("add_child", piece)
#
#func set_piece(new_piece: Piece):
#	release_piece()
#	# Need to do something here around copying the effects, adding them to this scene
#	# and then drawing appropriately.
#	existing_parent = new_piece.get_parent()
#	existing_parent.call_deferred("remove_child", new_piece)
#	call_deferred("add_child", new_piece)
#	if piece:
#		clear_piece()
##	add_child(new_piece)
##	var new_piece2 = new_piece.duplicate_piece()
##	print(new_piece2)
##	piece = new_piece2
#
##	tilemap.add_child(new_piece2)
#	piece = new_piece
#	draw_piece()

extends Control
class_name PieceDisplay

@onready var tilemap: TileMap = $TileMap
@export var offset: Vector2i = Vector2i(1, 1)
@onready var piece: Piece
@export var tilemap_scale: Vector2 = Vector2(1.0, 1.0)
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
	piece.draw(tilemap, 0, offset, 0, Vector2(global_position[0], global_position[1] ) )
	
func set_piece(new_piece: Piece):
	# Need to do something here around copying the effects, adding them to this scene
	# and then drawing appropriately.
#	new_piece.get_parent().call_deferred("remove_child", new_piece)
#	call_deferred("add_child", new_piece)
	if piece:
		clear_piece()
#	add_child(new_piece)
	piece = new_piece
	draw_piece()

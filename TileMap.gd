extends TileMap

#tetrominoes
var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i := [i_0, i_90, i_180, i_270]

var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

var s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

var l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

var j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

var shapes := [i, t, o, z, s, l, j]
var shapes_full := shapes.duplicate()

#grid variables
const COLS : int = 10
const ROWS : int = 20
const GLOBAL_COL_OFFSET = 8

#movement variables
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
const start_pos := Vector2i(5 + GLOBAL_COL_OFFSET, 1)
var cur_pos : Vector2i
var speed : float
const ACCEL : float = 0.12

#game piece variables
var piece_type
var next_piece_type
var rotation_index : int = 0
var active_piece : Array

#game variables
var score : int
const REWARD : int = 100
var game_running : bool

#tilemap variables
var tile_id : int = 0
# The current color / type of the given piece.
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

#layer variables
var board_layer : int = 0
var active_layer : int = 1
var grid = []

@onready var line: Recipe = $Line
@onready var square: Recipe = $Square
@onready var tee: Recipe = $Tee
@onready var move_sound = $SfxrStreamPlayer
var recipes: Array = []
var pattern_to_clear: Array = []
var unmatched_pieces_to_sink: Array = []

# Drop cleared part of piece
# Get multi-colored patternss. Slash general pattern to scene.
# Display available recipes.
# 

enum State {MOVING, CHECKING, ANIMATING, PREP, CLEANUP}

var current_state = State.MOVING

func convert_positions_to_local(positions):
	var to_return = []
	for pos in positions:
		to_return.append(map_to_local(pos))
	return to_return

func get_active_piece_not_in_pattern(matched_pattern: Array) -> Array:
	var to_return = []
	for p in active_piece:
		if cur_pos + p not in matched_pattern:
			to_return.append(cur_pos + p)
	return to_return
		
# Called when the node enters the scene tree for the first time.
func _ready():
	square.set_patterns([o_0])
	line.set_patterns([i_0, i_90])
	tee.set_patterns([t_0, t_90, t_180, t_270])
	tee.set_target_atlas_locations([Vector2i(0, 0), Vector2i(0, 0),Vector2i(0, 0),Vector2i(0, 0),])
	square.set_target_atlas_locations([Vector2i(1, 0), Vector2i(1, 0),Vector2i(1, 0),Vector2i(1, 0),])
	line.set_target_atlas_locations([Vector2i(2, 0), Vector2i(2, 0),Vector2i(2, 0),Vector2i(2, 0),])
	
	
	recipes.append(square)
	recipes.append(line)
	recipes.append(tee)
	new_game()
	$HUD.get_node("StartButton").pressed.connect(new_game)

func new_game():
	score = 0
	speed = 1.0
	game_running = true
	steps = [0, 0, 0] #0:left, 1:right, 2:down
	$HUD.get_node("GameOverLabel").hide()
	#clear everything
	clear_piece()
	clear_board()
	clear_panel()
	piece_type = pick_piece()
	# Hack to simplify
	piece_atlas = pick_piece_atlas()
	
	next_piece_type = pick_piece()
	#next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	next_piece_atlas = pick_piece_atlas()
	create_piece()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		if Input.is_action_pressed("ui_left"):
			steps[0] += 10
		elif Input.is_action_pressed("ui_right"):
			steps[1] += 10
		elif Input.is_action_pressed("ui_down"):
			steps[2] += 10
		elif Input.is_action_just_pressed("ui_up"):
			rotate_piece()
		
		#apply downward movement every frame
		steps[2] += speed
		match current_state:
			State.MOVING:
				for i in range(steps.size()):
					if steps[i] > steps_req:
						move_piece(directions[i])
						steps[i] = 0
			State.ANIMATING:
				var any_animating: bool = false
				for r in recipes:
					any_animating = r.is_animating() or any_animating
				if not any_animating:
					current_state = State.CLEANUP
			State.CHECKING:
				check_board()
			State.CLEANUP:
				cleanup()
			State.PREP:
				prep()
				

func pick_piece():
	var piece
	if not shapes.is_empty():
		shapes.shuffle()
		piece = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		shapes.shuffle()
		piece = shapes.pop_front()
	return piece

func create_piece():
	#reset variables
	steps = [0, 0, 0] #0:left, 1:right, 2:down
	cur_pos = start_pos
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas)
	#show next piece
	draw_piece(next_piece_type[0], Vector2i(15 + GLOBAL_COL_OFFSET, 6), next_piece_atlas)

func clear_piece():
	for i in active_piece:
		erase_cell(active_layer, cur_pos + i)

func draw_piece(piece, pos, atlas):
	for i in range(len(piece)):
		var piece_i = piece[i]
		var atlas_i = Vector2i(2, 0)
		if i % 2 == 0:
			atlas_i = Vector2i(1, 0)
		
		set_cell(active_layer, pos + piece_i, tile_id, atlas)

func rotate_piece():
	if can_rotate():
		clear_piece()
		rotation_index = (rotation_index + 1) % 4
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, cur_pos, piece_atlas)

func pick_piece_atlas():
	return Vector2i(randi_range(0, 2), 0)


func prep():
	piece_type = next_piece_type
	piece_atlas = pick_piece_atlas()
	# Purple is 1
	next_piece_type = pick_piece()
	next_piece_atlas = pick_piece_atlas()
	clear_panel()
	create_piece()
	check_game_over()
	current_state = State.MOVING

func check_board():
	for r in recipes:
		var maybe_matched_recipe = r.find_patterns_in_tilemap(self, board_layer, 0, GLOBAL_COL_OFFSET)
		var has_match = maybe_matched_recipe[0]
		if has_match:
			var matched_pattern = maybe_matched_recipe[1]
			unmatched_pieces_to_sink = get_active_piece_not_in_pattern(matched_pattern)
			r.animate(convert_positions_to_local(matched_pattern))
			pattern_to_clear = matched_pattern
			current_state = State.ANIMATING
			break
		else:
			current_state = State.PREP

func cleanup():
	shift_rows_from_pattern(pattern_to_clear)
	sink_unmatched_pieces(unmatched_pieces_to_sink)
	active_piece = []
	current_state = State.CHECKING
	
	score += REWARD
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
	speed += ACCEL
	

func move_piece(dir):
	if can_move(dir):
		clear_piece()
		cur_pos += dir
		draw_piece(active_piece, cur_pos, piece_atlas)
		if dir == Vector2i.DOWN:
			move_sound.play()
	else:
		if dir == Vector2i.DOWN:
			land_piece()
			current_state = State.CHECKING

func can_move(dir):
	#check if there is space to move
	var cm = true
	for i in active_piece:
		if not is_free(i + cur_pos + dir):
			cm = false
	return cm

func can_rotate():
	var cr = true
	var temp_rotation_index = (rotation_index + 1) % 4
	for i in piece_type[temp_rotation_index]:
		if not is_free(i + cur_pos):
			cr = false
	return cr

func is_free(pos):
	return get_cell_source_id(board_layer, pos) == -1


func land_piece():
	#remove each segment from the active layer and move to board layer
	for i in active_piece:
		erase_cell(active_layer, cur_pos + i)
		set_cell(board_layer, cur_pos + i, tile_id, piece_atlas)

func clear_panel():
	for i in range(14, 19 + GLOBAL_COL_OFFSET):
		for j in range(5, 9 + GLOBAL_COL_OFFSET):
			erase_cell(active_layer, Vector2i(i, j))

func shift_rows_from_pattern(matching_location):
	var atlas
	# For each column identify all the rows to check.
	var rc_map = {}
	for p in matching_location:
		if p[0] not in rc_map:
			rc_map[p[0]] = [p[1]]
		else:
			rc_map[p[0]].append(p[1])
	for col in rc_map:
		var rows = rc_map[col]
		var n_shifts = len(rows)
		shift_column(col, rows.max(), n_shifts)
			
func shift_column(col, row, n_shifts):
	var atlas
	var atlases = []
	for i in range(row, 1 + n_shifts, -1):
		atlas = get_cell_atlas_coords(board_layer, Vector2i(col, i - n_shifts))
		atlases.append(atlas)
	var to_traverse = range(row, 1 + n_shifts, -1)
	for tt in to_traverse:
		var ind = to_traverse.find(tt)
		var i = to_traverse[ind]
		var atlas2 = atlases[ind]
		if atlas2 == Vector2i(-1, -1):
			erase_cell(board_layer, Vector2i(col, i))
		else:
			set_cell(board_layer, Vector2i(col, i), tile_id, atlas2)


func sink_unmatched_pieces(piece: Array):
	for p in piece:
		var col = p[0]
		var row = p[1]
		var latest_row: int = row
		var current_atlas = get_cell_atlas_coords(board_layer, Vector2i(col, row))
		for i in range(row + 1, ROWS + 1, 1):
			var atlas = get_cell_atlas_coords(board_layer, Vector2i(col, i))
			if atlas == Vector2i(-1, -1):
				latest_row = i
		erase_cell(board_layer, Vector2i(col, row))
		set_cell(board_layer, Vector2i(col, latest_row), tile_id, current_atlas)
		
				
	


func shift_rows(row):
	var atlas
	for i in range(row, 1, -1):
		for j in range(COLS):
			atlas = get_cell_atlas_coords(board_layer, Vector2i(j + 1, i - 1))
			if atlas == Vector2i(-1, -1):
				erase_cell(board_layer, Vector2i(j + 1, i))
			else:
				set_cell(board_layer, Vector2i(j + 1, i), tile_id, atlas)

func clear_board():
	for i in range(ROWS):
		for j in range(GLOBAL_COL_OFFSET, COLS + GLOBAL_COL_OFFSET):
			erase_cell(board_layer, Vector2i(j + 1, i + 1))

func check_game_over():
	for i in active_piece:
		if not is_free(i + cur_pos):
			land_piece()
			$HUD.get_node("GameOverLabel").show()
			game_running = false

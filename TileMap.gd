extends TileMap
#grid variables
const COLS : int = 10
const ROWS : int = 20

#movement variables
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
const start_pos := Vector2i(5 , 1)
var cur_pos : Vector2i
@export var initial_speed: float = 0.7
@onready var speed : float = initial_speed
@export var ACCEL : float = 0.09

@export_range(0, 1.0) var effect_chance = 0.4

@onready var recipe_display_container: GridContainer = $HUD/RecipeContainer
@onready var soundtrack = $Soundtrack

#game variables
var score : int
const REWARD : int = 100
var temp_reward: int = REWARD
var game_running : bool

#tilemap variables
var tile_id : int = 0
# The current color / type of the given piece.
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

#layer variables
var board_layer : int = 0
var active_layer : int = 1

var streak_count: int = 0
var previous_streak_count: int = 0
var streak_mult: float = 1.0

@onready var line: Recipe = $Line
@onready var square: Recipe = $Square
@onready var tee: Recipe = $Tee
@onready var active_piece: Piece
@onready var next_piece: Piece
@onready var move_sound = $SfxrStreamPlayer
@onready var piece_spawner = $PieceSpawner
var recipes: Array[Recipe] = []
var pattern_to_clear: Array = []
var unmatched_pieces_to_sink: Array = []
var tail_animation = preload("res://scenes/tail_effect.tscn")
var recipe_display = preload("res://scenes/RecipeDisplay.tscn")
#var effect = preload("res://scenes/effects/ExplosionEffect.tscn")
var effect = preload("res://scenes/effects/ScoreEffect.tscn")

@onready var piece_display = $HUD/Panel/MarginContainer/PieceDisplay

#
 # TODO: 
# - implement recipes like i did for effects.
# - fix effect display and add: shared border anim, icon, and descriptor.
# - store score value on piece spawner

# - move from checking atlas coords to checking the column value like it is set for each recipe.
# Display effects in the preview.

# Bugs:
# - game over checker

enum State {MOVING, CHECKING, ANIMATING, PREP, CLEANUP}

var current_state = State.MOVING

func convert_positions_to_local(positions):
	var to_return = []
	for pos in positions:
		to_return.append(map_to_local(pos))
	return to_return

func get_active_piece_not_in_pattern(matched_pattern: Array) -> Array:
	var to_return = []
	for p in active_piece.active_piece:
		if cur_pos + p not in matched_pattern:
			to_return.append(cur_pos + p)
	return to_return
		
# Called when the node enters the scene tree for the first time.
func _ready():
	piece_display.set_tileset(self.tile_set)
	recipes.append(square)
	recipes.append(line)
	recipes.append(tee)
	for r in recipes:
		r.set_upgrades()
	
	for i in range(len(recipes)):
		var new_container = recipe_display.instantiate()
		new_container.recipe = recipes[i]

		recipe_display_container.add_child(new_container)
		new_container.set_tileset(self.tile_set)
	new_game()
	$HUD.get_node("StartButton").pressed.connect(new_game)

func new_game():
	soundtrack.play()
	score = 0
	speed = initial_speed
	
	game_running = true
	steps = [0, 0, 0] #0:left, 1:right, 2:down
	$HUD.get_node("GameOverLabel").hide()
	$HUD.get_node("ScoreLabel/ScoreValue").text = str(score)
	#clear everything
#	clear_board()
	active_piece = piece_spawner.pick_piece(recipes)
	next_piece = piece_spawner.pick_piece(recipes)
	piece_display.set_piece(next_piece)
	
	create_piece()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if game_running:
		# Super hack to scale the music tempo.
		soundtrack.pitch_scale = 1.0 + ((speed - initial_speed) / initial_speed) * 0.05
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
				

func create_piece():
	#reset variables
	steps = [0, 0, 0] #0:left, 1:right, 2:down
	cur_pos = start_pos
	
	draw_piece(active_piece, cur_pos)
	

func draw_piece(piece: Piece, pos):
	piece.draw(self, active_layer, pos, tile_id)
	
func clear_piece(piece: Piece):
	piece.clear(self, active_layer, cur_pos)
	


func rotate_piece():
	if can_rotate(cur_pos, active_piece):
		clear_piece(active_piece)
		active_piece.rotate_piece()
		draw_piece(active_piece, cur_pos)
	else:
		# Check if we're on the left and right edges in which case we need to 
		# move over inside.
		var temp_right = cur_pos + Vector2i.RIGHT
		var temp_left = cur_pos + Vector2i.LEFT
		if can_rotate(temp_right, active_piece):
			clear_piece(active_piece)
			cur_pos = temp_right
			active_piece.rotate_piece()
			draw_piece(active_piece, cur_pos)
			
		elif can_rotate(temp_left, active_piece):
			clear_piece(active_piece)
			cur_pos = temp_left
			active_piece.rotate_piece()
			draw_piece(active_piece, cur_pos)

func prep():
	temp_reward = REWARD
	
	if (streak_count <= previous_streak_count):
		streak_count = 0
		$HUD.get_node("StreakLabel/StreakValue").text = str(streak_count)
	previous_streak_count = streak_count
	# Nastiness for float <> int stuff.
	if streak_count == 0:
		streak_mult = 1.0
	else:
		streak_mult = 1.0 + (streak_count / 10.0)
	active_piece.queue_free()
	active_piece = next_piece
	
	
	
	next_piece = piece_spawner.pick_piece(recipes)
	
	piece_display.set_piece(next_piece)
	create_piece()
	check_game_over()
	
	current_state = State.MOVING

func check_board():
	for r in recipes:
		var matched_pattern = r.find_patterns_in_tilemap(self, board_layer, ROWS, COLS, active_piece, 0, 0)
		if r.has_match:
			pattern_to_clear = matched_pattern
			r.trigger_upgrades(self)
			active_piece.set_matched_effects(pattern_to_clear)
			active_piece.trigger_effects(self)

			unmatched_pieces_to_sink = get_active_piece_not_in_pattern(matched_pattern)
			r.animate(convert_positions_to_local(pattern_to_clear))
			current_state = State.ANIMATING
			break
		else:
			current_state = State.PREP

func cleanup():
	shift_rows_from_pattern(pattern_to_clear)
	sink_unmatched_pieces(unmatched_pieces_to_sink)
	current_state = State.CHECKING
	score += temp_reward * streak_mult
	temp_reward *= 2
	streak_count += 1
	
	$HUD.get_node("ScoreLabel/ScoreValue").text = str(score)
	$HUD.get_node("StreakLabel/StreakValue").text = str(streak_count)
	speed += ACCEL
	

func move_piece(dir):
	if can_move(active_piece, dir):
		clear_piece(active_piece)
		cur_pos += dir
		draw_piece(active_piece, cur_pos)
		if dir == Vector2i.DOWN:
			pass
#			move_sound.play()
	else:
		if dir == Vector2i.DOWN:
			land_piece()
			current_state = State.CHECKING

func can_move(piece: Piece, dir):
	#check if there is space to move
	var cm = true
	for i in piece.active_piece:
		if not is_free(i + cur_pos + dir):
			cm = false
	return cm

func can_rotate(pos_to_check, current_piece: Piece):
	var cr = true
	for i in current_piece.rotated_positions():
		if not is_free(i + pos_to_check):
			cr = false
	return cr

func is_free(pos):
	return get_cell_source_id(board_layer, pos) == -1


func land_piece():
	#remove each segment from the active layer and move to board layer
	for i in range(len(active_piece.active_piece)):
		var ap = active_piece.active_piece[i]
		var tm = active_piece.tilemap_ids[i]
		erase_cell(active_layer, cur_pos + ap)
		set_cell(board_layer, cur_pos + ap, tile_id, tm)
	active_piece.land(cur_pos)


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
		var found_unmatched_piece_index = unmatched_pieces_to_sink.find(Vector2i(col, i))
		# We need to shift any unmatched pieces that are ABOVE the piece being cleared otherwise
		# their location will get lost.
		if found_unmatched_piece_index != -1:
			unmatched_pieces_to_sink[found_unmatched_piece_index] = Vector2i(col, i + n_shifts)
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

func _sort_by_col(a: Vector2i, b: Vector2i):
	if a[1] > b[1]:
		return true
	return false

func sink_unmatched_pieces(piece: Array):
	# Sort the pieces by their row (second index)
	piece.sort_custom(_sort_by_col)
	for p in piece:
		var col = p[0]
		var row = p[1]
		var latest_row: int = row
		var current_atlas = get_cell_atlas_coords(board_layer, Vector2i(col, row))
		for i in range(row + 1, ROWS + 1, 1):
			var atlas = get_cell_atlas_coords(board_layer, Vector2i(col, i))
			if atlas == Vector2i(-1, -1):
				latest_row = i
			else:
				break
		if latest_row > row:
			erase_cell(board_layer, p)
			set_cell(board_layer, Vector2i(col, latest_row), tile_id, current_atlas)
			var tail_anim  = tail_animation.instantiate()
			tail_anim.scale = Vector2i(1, latest_row - row)
			tail_anim.restart()
			add_child(tail_anim)
			
			tail_anim.position = map_to_local(Vector2i(col, latest_row))
		


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
		for j in range(COLS):
			erase_cell(board_layer, Vector2i(j + 1, i + 1))
			erase_cell(active_layer, Vector2i(j + 1, i + 1))

func check_game_over():
	# Something is broken in here.
	for i in active_piece.active_piece:
		if not is_free(i + cur_pos):
			land_piece()
			$HUD.get_node("GameOverLabel").show()
			game_running = false


func _on_soundtrack_finished():
	if game_running:
		soundtrack.play()

extends TileMap

class_name Level

const COLS : int = 10
const ROWS : int = 20

#movement variables
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
const start_pos := Vector2i(5 , 1)
var cur_pos : Vector2i
@export_group("Game variables")
@export var initial_speed: float = 0.7
@onready var speed : float = initial_speed
@export var ACCEL : float = 0.09
@export var goal_score: int = 5000

@export_group("Metadata and Description")
@export var level_id: int
@export var level_name: String
@export_multiline var description: String


@export_group("Recipe info")
@export var recipes: Array[Recipe]

@onready var recipe_display_container: GridContainer = $HUD/VBoxContainer/RecipeContainer
@onready var soundtrack = $Soundtrack
@onready var hud: LevelHud = $HUD
@onready var pause_menu = $PauseMenu

var save: SaveGame

#game variables
var paused: bool = false
var score : int
const REWARD : int = 100
var temp_reward: int = REWARD

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
var matched_recipe: Recipe

@onready var active_piece: Piece
@onready var next_piece: Piece
@onready var move_sound = $SfxrStreamPlayer
@onready var piece_spawner = $PieceSpawner
@onready var animation_queue = $AnimationQueueHandler

var pattern_to_clear: Array = []
var unmatched_pieces_to_sink: Array = []
var tail_animation = preload("res://scenes/animations/tail_effect.tscn")
var recipe_display = preload("res://scenes/RecipeDisplay.tscn")

@onready var piece_display = $HUD/VBoxContainer/NextPieceContainer/MarginContainer/VBoxContainer/PieceDisplay
@onready var effect_display = $EffectDisplayContainer
@onready var game_over_menu = $GameOverMenu
@onready var intro = $LevelIntro

var level_data: LevelData
var _save: SaveGame
#
# TODO: 
# buggish.
# - Need to add upgrade effects to animation bus. slash do stuff after animation finish.
# to ship:
# - level select.
#     - storing scores and available levels. etc.
# - clean up title screen.
# - slow down upgrade.
# - immune upgrade.
# - Icons and animations/
#    - icons for effects.
#    - upgrade border effect.

# - effects can trigger each other (eg bomb).
# - Held piece enabling effect?

enum State {MOVING, CHECKING, ANIMATING, PREP, CLEANUP, INTRO, GAME_OVER}

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

func _load_data():
	_save.load_all_data()
	if _save._has_level_data(level_id):
		level_data = _save._load_level_data(level_id)
	else:
		level_data = LevelData.new()
		level_data.level_id = level_id
	hud.set_high(level_data.high_score)
func _save_data():
	level_data.completed = score > goal_score
	level_data.high_score = score
	_save.save_level(level_data)

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(level_id != null, "Must Specify level id!")
	_save = SaveGame.new()
	_load_data()
	clear_board()
	
	new_game()

func _remove_recipe_displays():
	for r in recipe_display_container.get_children():
		if r is RecipeDisplay:
			r.queue_free()
	
func set_recipe_displays():
	for i in range(len(recipes)):
		var new_container = recipe_display.instantiate()
		new_container.recipe = recipes[i]
		recipe_display_container.add_child(new_container)
		new_container.set_tileset(self.tile_set)

func new_game():
	intro.start()
	current_state = State.INTRO
	
	if soundtrack.is_playing():
		soundtrack.stop()
	piece_display.set_tileset(self.tile_set)
	hud.set_goal(goal_score)
	paused = false
	get_tree().paused = false
	
	score = 0
	speed = initial_speed
	
	steps = [0, 0, 0] #0:left, 1:right, 2:down
	
	hud.set_score(score)
	
	#clear everything
	clear_board()
	piece_spawner.reset()
	effect_display.reset()
	for r in recipes:
		r.reset()
	active_piece = piece_spawner.pick_piece(recipes)
	effect_display.display(piece_spawner)
	next_piece = piece_spawner.pick_piece(recipes)
	piece_display.set_piece(next_piece)
	_remove_recipe_displays()
	set_recipe_displays()
	
	create_piece()
	if current_state != State.INTRO and not soundtrack.playing:
		soundtrack.play()
		

func pause_game():
	if paused:
		get_tree().paused = false
		pause_menu.toggle_pause()
	else:
		get_tree().paused = true
		pause_menu.toggle_pause()
	paused = !paused

func handle_game_over():
	_save_data()
	paused = true
	get_tree().paused = true
	soundtrack.stop()
	game_over_menu.set_success_state(score >= goal_score)
	game_over_menu.toggle_menu()

func _process(delta):
	if current_state == State.INTRO:
		return
	elif current_state == State.GAME_OVER:
		handle_game_over()
	
	else:
		# Note that this doesn't allow pausing during the intro!
		if Input.is_action_just_pressed("ui_cancel"):
			pause_game()
		
		# Super hack to scale the music tempo.
		soundtrack.pitch_scale = 1.0 + ((speed - initial_speed) / initial_speed) * 0.05
		if Input.is_action_pressed("ui_left"):
			steps[0] += 10
		elif Input.is_action_pressed("ui_right"):
			steps[1] += 10
		elif Input.is_action_pressed("ui_down"):
			steps[2] += 10
		if Input.is_action_just_pressed("ui_up"):
			sink_piece()
		elif Input.is_action_just_pressed("ui_accept"):
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
				if animation_queue.should_animate():
					animation_queue.animate()
				else:
					current_state = State.CLEANUP
			State.CHECKING:
				check_board()
			State.CLEANUP:
				move_pieces_and_score()
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
		hud.set_streak(streak_count)
	previous_streak_count = streak_count
	# Nastiness for float <> int stuff.
	if streak_count == 0:
		streak_mult = 1.0
	else:
		streak_mult = 1.0 + (streak_count / 10.0)
	active_piece.queue_free()
	active_piece = next_piece
	effect_display.display(piece_spawner)
	next_piece = piece_spawner.pick_piece(recipes)
	
	piece_display.set_piece(next_piece)
	create_piece()
	check_game_over()
	if current_state != State.GAME_OVER:
		current_state = State.MOVING

func check_board():
	for r in recipes:
		var matched_pattern = r.find_patterns_in_tilemap(self, board_layer, ROWS, COLS, active_piece, 0, 0)
		if r.has_match:
			matched_recipe = r
			pattern_to_clear = matched_pattern
			active_piece.set_matched_effects(pattern_to_clear)
			active_piece.trigger_effects(self)
			r.trigger_upgrades(self)
			unmatched_pieces_to_sink = get_active_piece_not_in_pattern(matched_pattern)
			r.set_animations(self, convert_positions_to_local(pattern_to_clear))
			
			current_state = State.ANIMATING
			break
		else:
			current_state = State.PREP

func move_pieces_and_score():
	
	shift_rows_from_pattern(pattern_to_clear)
	sink_unmatched_pieces(unmatched_pieces_to_sink)
	current_state = State.CHECKING
	score += temp_reward * streak_mult
	temp_reward *= 2
	streak_count += 1
	
	hud.set_score(score)
	hud.set_streak(streak_count)

	speed += ACCEL
	check_game_over(start_pos)

func sink_piece():
	clear_piece(active_piece)
	while can_move(active_piece, Vector2i.DOWN):
		cur_pos += Vector2i.DOWN
	draw_piece(active_piece, cur_pos)
	# This is all for animation but it's not super visible...
	for p in active_piece.active_piece:
		var tail_anim  = tail_animation.instantiate()
		tail_anim.scale = Vector2i(1, 5)
		tail_anim.restart()
		add_child(tail_anim)
		
		tail_anim.position = map_to_local(Vector2i(p + cur_pos))
		
	land_piece()

func move_piece(dir):
	if can_move(active_piece, dir):
		clear_piece(active_piece)
		cur_pos += dir
		draw_piece(active_piece, cur_pos)
		
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
	pass
	for i in range(ROWS):
		for j in range(COLS):
			erase_cell(board_layer, Vector2i(j + 1, i + 1))
			erase_cell(active_layer, Vector2i(j + 1, i + 1))

func check_game_over(pos: Vector2i = cur_pos):
	for i in active_piece.active_piece:
		if not is_free(i + pos):
			land_piece()
			current_state = State.GAME_OVER


func _on_soundtrack_finished():
	if current_state != State.GAME_OVER:
		soundtrack.play()


func _on_level_intro_finished():
	current_state = State.MOVING
	soundtrack.play()

extends CanvasLayer

var button_index: int = 0
var buttons: Array[Button] = []
@onready var button_box = $Control/MarginContainer/VBoxContainer
@onready var level: Level = $".."
#@onready var level = $Control
var is_paused: bool = true
var selected_button: Button
var can_listen_for_cancel = false

func _ready():
	visible = false
	for maybe_button in button_box.get_children():
		if maybe_button is Button:
			buttons.append(maybe_button)
	selected_button = buttons[0]


func set_paused():
	visible = !visible
	is_paused = !is_paused
	can_listen_for_cancel = false

func _process(delta):
	if is_paused:
		if Input.is_action_just_pressed("ui_down"):
			button_index += 1
		elif Input.is_action_just_pressed("ui_up"):
			button_index -= 1
			if button_index < 0:
				button_index = len(buttons) - 1
		if Input.is_action_just_pressed("ui_accept"):
			selected_button.pressed.emit()
#		elif Input.is_action_just_pressed("ui_cancel") and can_listen_for_cancel:
#			level.pause_game()
		
		button_index = button_index % len(buttons)
		selected_button = buttons[button_index]
		# Why on earth is this not highlighting it properly.
		selected_button.grab_focus()


func _on_resume_pressed():
	level.pause_game()


func _on_new_game_pressed():
	level.new_game()
	level.pause_game()

extends CanvasLayer

var button_index: int = 0
var buttons: Array[Button] = []
@onready var button_box = $Control/MarginContainer/VBoxContainer
@onready var level: Level = $".."
var is_paused: bool = false
var selected_button: Button
var can_listen_for_cancel = false
@onready var timer = $Timer

func _ready():
	visible = false
	for maybe_button in button_box.get_children():
		if maybe_button is Button:
			buttons.append(maybe_button)
	selected_button = buttons[0]


func toggle_pause():
	visible = !visible
	is_paused = !is_paused
	can_listen_for_cancel = false
	timer.start()

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
		elif Input.is_action_just_pressed("ui_cancel") and can_listen_for_cancel:
			_on_resume_pressed()
		
		button_index = button_index % len(buttons)
		selected_button = buttons[button_index]
		selected_button.grab_focus()


func _on_resume_pressed():
	button_index = 0
	level.pause_game()


func _on_new_game_pressed():
	button_index = 0
	level.new_game()
	level.pause_game()


func _on_timer_timeout():
	can_listen_for_cancel = true

extends CanvasLayer
class_name level_intro
@export var countdown_start: int = 5
signal finished
@onready var timer = $Timer
@onready var countdown_label: Label = $Control/MarginContainer/CountDown
@onready var sfx = $SfxrStreamPlayer
var current_countdown: int
var can_listen: bool = false

func _ready():
	visible = false
	current_countdown = countdown_start
	countdown_label.text = str(current_countdown)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if can_listen and Input.is_action_just_pressed("ui_accept"):
		finish()

func start():
	can_listen = true
	current_countdown = countdown_start
	countdown_label.text = str(current_countdown)
	visible = true
	timer.start()
	sfx.play()
	
func finish():
	visible = false
	can_listen = false
	timer.stop()
	finished.emit()


func _on_timer_timeout():
	if current_countdown <= 1:
		finish()
		
	else:
		sfx.play()
		current_countdown -= 1
		countdown_label.text = str(current_countdown)
		

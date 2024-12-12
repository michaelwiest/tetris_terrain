extends Node2D

class_name Upgrade
enum Timing {BEFORE_MATCH, AFTER_MATCH}
@onready var active: bool = true
@export var color: Color = Color(1, 1, 1)
@export var display_name: String
@export_multiline var description: String
@export var is_permanent: bool = false
@export var timing: Timing
@onready var icon = $Icon
@onready var sfx = $SFX

func hide_icon():
	icon.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
#	icon.visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func trigger(tilemap: Level, recipe: Recipe):
	var trigger_callable = Callable(self, "trigger_internal").bind(tilemap, recipe)
	if active:
		# need to have some sort of pre-compute step for animations and sounds.
		# and then add them to the queue and then call the trigger_internal function.
		# eg. set_animations_and_sounds() and then call self.animation below eg.
		tilemap.animation_queue.add_animations_and_sound(
			[] as Array[AnimatedSprite2D],
			[sfx] as Array[AudioStreamPlayer],
			[] as Array[CPUParticles2D],
			[trigger_callable]
			)
	
func trigger_internal(tilemap: Level, recipe: Recipe):
	pass

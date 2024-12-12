extends Node2D

class_name AnimationQueue

# This should receive keep a queue of animations and sounds.
# This should get pushed to by the various effects / upgrades.
# This loops through all animations in order and plays them.
# then at the end it emits a signal to the tilemap and we continue.
var animations: Array = []
var sounds: Array = []
var particles: Array = []
var callables: Array = []
var progress: float = 0.0
var speed_scale: float = 1.0
var is_animating: bool = false
var current_index: int = 0
var ready_for_next_animation = true
var ready_for_next_sound = true
var ready_for_next_particle = true
var temp_animations: Array[AnimatedSprite2D] = []
var temp_sounds: Array[AudioStreamPlayer] = []
var temp_particles: Array[CPUParticles2D] = []
# called after animation is finished
var temp_callables: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_animations_and_sound(
	new_animations: Array[AnimatedSprite2D],
	new_sounds: Array[AudioStreamPlayer],
	new_particles: Array[CPUParticles2D],
	after_animation_callable = [],
):
	animations.append(new_animations)
	sounds.append(new_sounds)
	particles.append(new_particles)
	callables.append(after_animation_callable)
	
func play():
	is_animating = true
	for i in range(len(temp_animations)):
		ready_for_next_animation = false
		temp_animations[i].visible = true
		temp_animations[i].play()
		# Assumes all the animations have the same length in time.
		if i == 0:
			temp_animations[i].animation_finished.connect(finished_animation)
	
	for i in range(len(temp_sounds)):
		ready_for_next_sound = false
		temp_sounds[i].play()
		# Assumes all the sounds have the same length in time.
		if i == 0:
			temp_sounds[i].finished.connect(finished_sound)

	# Seemingly I can't detect when the particles are done?
	for i in range(len(temp_particles)):
		ready_for_next_particle = true # <- hard-coded because can't detect the change.
		temp_particles[i].visible = true
		temp_particles[i].restart()

func animate():
	# Check that we have completed the current animmation step.
	if is_ready():
		if not should_animate():
			return
		else:
			temp_animations = animations.pop_front()
			temp_sounds = sounds.pop_front()
			temp_particles = particles.pop_front()
			temp_callables = callables.pop_front()
			play()
		
func should_animate():
	return len(animations) > 0 or is_animating

func finished_animation():
	for t in temp_animations:
		t.visible = false
	ready_for_next_animation = true
	is_animating = not is_ready()
	if is_ready():
		do_callables_after_finish()

func finished_sound():
	ready_for_next_sound = true
	is_animating = not is_ready()
	if is_ready():
		do_callables_after_finish()

func finished_particle():
	# Unused for now.
	for t in temp_particles:
		t.visible = false
	ready_for_next_particle = true
	is_animating = not is_ready()

func is_ready():
	return ready_for_next_animation and ready_for_next_particle and ready_for_next_sound

# This should probably listen to the animation finished signal.
func do_callables_after_finish():
	for c in temp_callables:
		c.call()
	temp_callables = []

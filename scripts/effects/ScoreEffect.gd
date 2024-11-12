extends Effect

class_name ScoreEffect
@export var score_amount: int = 500
@onready var explosion = $CPUParticles2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func trigger_internal(tilemap: TileMap):
	tilemap.score += score_amount
	explosion.modulate = color
	tilemap.animation_queue.add_animations_and_sound([] as Array[AnimatedSprite2D], [sfx] as Array[AudioStreamPlayer], [explosion] as Array[CPUParticles2D])
	

extends BadEffect

@export var accel_mult: float = 2.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func trigger_internal(tilemap: TileMap):
	tilemap.speed += tilemap.ACCEL * accel_mult
	tilemap.animation_queue.add_animations_and_sound([] as Array[AnimatedSprite2D], [sfx] as Array[AudioStreamPlayer], [] as Array[CPUParticles2D])
	

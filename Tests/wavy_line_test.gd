extends Line2D


func _process(delta: float) -> void:
	if not material: return
	
	var wave_speed := 5.0
	var offset = wave_speed * delta
	# Para evitar que el offset crezca hasta el infinito
	offset = fmod(offset, TAU)
	
	material.set_shader_parameter("carga", 2.0)
	material.set_shader_parameter("offset_animacion", offset)

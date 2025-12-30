extends ColorRect


func _ready() -> void:
	material = material.duplicate()
	
	if get_parent().type >= AlgorithmManager.INDUSTRIAL:
		material.set_shader_parameter("forma_nodo", 0)

func update_shader(val: float, max: float, disp: float) -> void:
	var mat = material as ShaderMaterial
	mat.set_shader_parameter("nivel_actual", val)
	mat.set_shader_parameter("nivel_maximo", max)
	mat.set_shader_parameter("factor_disponibilidad", disp)
	
	if disp * max > val:
		mat.set_shader_parameter("color_lleno", Color.CRIMSON)
	else:
		mat.set_shader_parameter("color_lleno", Color.GREEN)

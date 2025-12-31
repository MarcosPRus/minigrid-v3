extends ColorRect

@onready var parent: GridNode = get_parent()

func _ready() -> void:
	material = material.duplicate()
	
	if parent.is_generator:
		material.set_shader_parameter("node_shape", 1)
		if parent.type == AlgorithmManager.HYDRO:
			material.set_shader_parameter("node_shape", 2)
	elif parent.is_consumer:
		material.set_shader_parameter("node_shape", 0)


func update_shader(val: float, max: float, disp: float) -> void:
	var mat = material as ShaderMaterial
	mat.set_shader_parameter("current_level", val)
	mat.set_shader_parameter("total_segments", max)
	mat.set_shader_parameter("availability_factor", disp)
	
	if parent.is_consumer:
		if disp * max > val:
			mat.set_shader_parameter("color_fill", Color.RED)
		else:
			mat.set_shader_parameter("color_fill", Color.GREEN)
	elif parent.is_generator:
		if disp * max == val:
			mat.set_shader_parameter("color_fill", Color.YELLOW)
		else:
			mat.set_shader_parameter("color_fill", Color.GREEN)

class_name GridLine
extends Line2D

var format_string: String = "%.2f / %.2f"

var id: String
var id_a: int
var id_b: int
var pos_a: Vector2
var pos_b: Vector2
var capacity: int = 10

# Para la animación del shader
var speed_mod: float = 0.25
var current_speed: float = 0.0
var current_flow_offset: float = 0.0

var flow: float

#@onready var flow_label: Label = Label.new()


func _ready() -> void:
	## Initial configuration	
	AlgorithmManager.grid_state_updated.connect(on_grid_state_updated)
	apply_shader_and_theme()
	#add_child(flow_label)

func _process(delta: float) -> void:
	if not material: return
	
	current_flow_offset += current_speed * delta
	current_flow_offset = fmod(current_flow_offset, 1.0)
	material.set_shader_parameter("flow_offset", current_flow_offset)


func update_capacity() -> void:
	## TODO: Implementar outages, reducciones de capacidad, etc
	AlgorithmManager.Solver.set_connection_capacity(id_a, id_b, capacity)

func on_grid_state_updated(solver_state: mod_AStar2D) -> void:
	flow = solver_state.net_flows[id]
	update_shader()


func apply_shader_and_theme() -> void:
	z_index = -1
	width = 5
	
	## FLOWY LINE STYLE
	texture_mode = Line2D.LINE_TEXTURE_TILE
	material = preload("res://Classes Custom/Linea/flowy_line_shader.tres")
	material = material.duplicate()
	material.set_shader_parameter("is_active", false)
	
	#flow_label.add_theme_color_override("font_color", Color.DARK_RED)
	#flow_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	#flow_label.add_theme_constant_override("shadow_outline_size", 2)
	#flow_label.global_position = (pos_a + pos_b)/2
	#flow_label.z_index = 10

func update_shader() -> void:
	if flow == 0.0:
		material.set_shader_parameter("is_active", false)
	else:
		material.set_shader_parameter("is_active", true)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var target_speed: float = flow * speed_mod
	tween.tween_property(self, "current_speed", target_speed, .5)
	tween.parallel().tween_property(material, "shader_parameter/utilization", flow/capacity, 0.5)

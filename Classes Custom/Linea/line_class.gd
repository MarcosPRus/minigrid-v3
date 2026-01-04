class_name GridLine
extends Line2D

var format_string: String = "%.2f / %.2f"

var id: String
var id_a: int
var id_b: int
var pos_a: Vector2
var pos_b: Vector2
var capacity: int = 10
var is_virtual: bool = false

# Para la animación del shader
var aux_flow: float = 0.0
var offset: float = 0.0
const ANIM_SPEED = 2.5

var flow: float

@onready var flow_label: Label = Label.new()


func _ready() -> void:
	## Initial configuration
	# Avoid drawing lines that connect virtual nodes
	if AlgorithmManager.nodes[id_a].type == 0 or AlgorithmManager.nodes[id_b].type == 0:
		is_virtual = true
		return
	
	var a: Vector2i = Vector2i(pos_a/BuildingManager.building_grid_size)
	var b: Vector2i = Vector2i(pos_b/BuildingManager.building_grid_size)
	print("[Line Debug] (A) Closest grid point to ", str(pos_a), " is ", str(a))
	print("[Line Debug] (B) Closest grid point to ", str(pos_b), " is ", str(b))
	var points_aux := BuildingManager.building_grid.get_point_path(a, b)
	print("[Line Debug] Points array: ", str(points_aux))
	for point in points_aux:
		add_point(point)
		
	#add_point(pos_a)
	#add_point(pos_b)
	apply_shader_and_theme()
	#add_child(flow_label)


func apply_shader_and_theme() -> void:
	width = 20.0
	z_index = -1
	
	texture = preload("res://Classes Custom/Linea/wavy_line_gradiend.tres")
	#texture_mode = Line2D.LINE_TEXTURE_TILE
	texture_mode = Line2D.LINE_TEXTURE_STRETCH
	material = preload("res://Classes Custom/Linea/wavy_line_shader.tres")
	material = material.duplicate()
	material.set_shader_parameter("carga", 0.0)
	
	flow_label.add_theme_color_override("font_color", Color.DARK_RED)
	flow_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	flow_label.add_theme_constant_override("shadow_outline_size", 2)
	flow_label.global_position = (pos_a + pos_b)/2
	flow_label.z_index = 10


func _process(delta: float) -> void:
	if not material: return
	
	aux_flow = move_toward(aux_flow, flow, delta * ANIM_SPEED)
	var wave_speed = 2.0 + (aux_flow * 2.0)
	offset += wave_speed * delta
	# Para evitar que el offset crezca hasta el infinito
	offset = fmod(offset, TAU)
	
	material.set_shader_parameter("carga", aux_flow/capacity)
	material.set_shader_parameter("offset_animacion", offset)
	
	#flow_label.text = format_string % [flow, capacity]


func update_capacity() -> void:
	if is_virtual:
		return
	#capacity = randf_range(0.1, 2.0) ## TODO: DELETE THIS SHIT
	AlgorithmManager.Solver.set_connection_capacity(id_a, id_b, capacity)

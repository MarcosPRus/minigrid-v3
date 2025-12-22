class_name GridLine
extends Line2D

var format_string: String = "%.2f / %.2f"

var id: String
var id_a: int
var id_b: int
var pos_a: Vector2
var pos_b: Vector2
var capacity: float = 1.0
var is_virtual: bool = false

var flow: float:
	set(value):
		update_flow(value)

@onready var flow_label: Label = Label.new()


func _ready() -> void:
	## Initial configuration
	# Avoid drawing lines that connect virtual nodes
	if AlgorithmManager.nodes[id_a].type == 0 or AlgorithmManager.nodes[id_b].type == 0:
		is_virtual = true
		return
	
	width = 4.0
	add_point(pos_a)
	add_point(pos_b)
	
	flow_label.add_theme_color_override("font_color", Color.DARK_RED)
	flow_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	flow_label.add_theme_constant_override("shadow_outline_size", 2)
	flow_label.global_position = (pos_a + pos_b)/2
	flow_label.z_index = 10
	
	add_child(flow_label)


func update_params() -> void:
	if is_virtual:
		return
	capacity = randf_range(0.1, 2.0) ## TODO: DELETE THIS SHIT
	AlgorithmManager.Solver.set_connection_capacity(id_a, id_b, capacity)


func update_flow(value: float) -> void:
	flow_label.text = format_string % [value, capacity]
	if value < 0.2 * capacity:
		default_color = Color.GREEN
	elif value < 0.5 * capacity:
		default_color = Color.YELLOW
	elif value < 0.75 * capacity:
		default_color = Color.ORANGE
	else:
		default_color = Color.RED

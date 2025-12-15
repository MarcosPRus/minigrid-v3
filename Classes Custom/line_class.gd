class_name GridLine
extends Line2D


var id: String
var id_a: int
var id_b: int
var pos_a: Vector2
var pos_b: Vector2

var flow: float:
	set(value):
		update_flow(value)

@onready var flow_label: Label = Label.new()


func _ready() -> void:
	## Initial configuration
	# Avoid drawing lines that connect virtual nodes
	if AlgorithmManager.nodes[id_a].type == 0 or AlgorithmManager.nodes[id_b].type == 0:
		return
	
	width = 4.0
	add_point(pos_a)
	add_point(pos_b)
	
	flow_label.add_theme_color_override("font_color", Color.DARK_RED)
	flow_label.global_position = (pos_a + pos_b)/2
	flow_label.z_index = 10
	
	add_child(flow_label)


func update_flow(value: float) -> void:
	flow_label.text = "%.2f" % value
	default_color = Color.GREEN if value == 0 else Color.RED

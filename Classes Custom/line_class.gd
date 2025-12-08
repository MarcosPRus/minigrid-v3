class_name GridLine
extends Line2D


var id: String
var id_a: int
var id_b: int
var pos_a: Vector2
var pos_b: Vector2

var flow: float:
	set(value):
		flow_label.text = str(value)
		default_color = Color.GREEN if value == 0 else Color.RED

@onready var line: Line2D = Line2D.new()
@onready var flow_label: Label = Label.new()


func _ready() -> void:
	## Initial configuration
	if AlgorithmManager.nodes[id_a].type == 0 or AlgorithmManager.nodes[id_b].type == 0:
		return
	line.width = 4.0
	line.add_point(pos_a)
	line.add_point(pos_b)
	
	flow_label.add_theme_color_override("font_color", Color.DARK_RED)
	flow_label.global_position = (pos_a + pos_b)/2
	flow_label.z_index = 10
	
	add_child(flow_label)
	add_child(line)

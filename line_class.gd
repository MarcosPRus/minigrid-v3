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

@onready var line: Line2D = Line2D.new()
@onready var flow_label: Label = Label.new()


func _ready() -> void:
	## Initial configuration
	line.width = 4.0
	line.add_point(pos_a)
	line.add_point(pos_b)
	
	flow_label.add_theme_color_override("font_color", Color.DARK_RED)
	flow_label.global_position = (pos_a + pos_b)/2
	
	add_child(flow_label)
	add_child(line)

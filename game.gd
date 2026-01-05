extends Node2D

#@export var grid_line_color: Color = Color.ALICE_BLUE
#var line_space: int = 64

func _ready() -> void:
	AlgorithmManager.NodesContainer = $NodesContainer
	AlgorithmManager.LinesContainer = $LinesContainer
	

#func _draw():
	#var size = Vector2(1920, 1080)
	#for i in range(1+int(size.x/line_space)):
		#draw_line(Vector2(i * line_space, -100), Vector2(i * line_space, size.y + 100), grid_line_color)
	#for i in range(1+int(size.y/line_space)):
		#draw_line(Vector2(-100, i * line_space), Vector2(size.x + 100, i * line_space), grid_line_color)
#
#func _process(delta):
	#queue_redraw()

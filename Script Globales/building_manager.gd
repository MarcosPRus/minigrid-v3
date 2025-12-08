extends Node2D

enum states {IDLE, NODE_PREVIEW, LINE_PREVIEW}

var UI: Control
var state: int = states.IDLE

var previewing_type: int = 0
var connecting_node: GridNode

var city_names = ["Madrid", "Barcelona", "Sevilla", "Valencia"]


func _process(delta: float) -> void:
	if state == states.NODE_PREVIEW:
		UI.preview_sprite.global_position = get_global_mouse_position()
	elif state == states.LINE_PREVIEW:
		UI.preview_line.points[1] = get_global_mouse_position()


func button_pressed(type: int) -> void:
	previewing_type = type
	node_preview()

func left_click(pos: Vector2) -> void:
	if state == states.NODE_PREVIEW:
		AlgorithmManager.add_node(pos, previewing_type, city_names.pick_random(), 1.0)
	
	
func right_click() -> void:
	idle()

func node_selected(node: GridNode) -> void:
	if state == states.IDLE or state == states.NODE_PREVIEW:
		line_preview(node.global_position)
		connecting_node = node
	elif state == states.LINE_PREVIEW:
		if node != connecting_node:
			AlgorithmManager.connect_nodes(connecting_node.id, node.id, 1.0)
			connecting_node = null
			idle()


func idle() -> void:
	state = states.IDLE
	UI.preview_sprite.hide()
	UI.preview_line.hide()

func node_preview() -> void:
	state = states.NODE_PREVIEW
	
	UI.preview_sprite.show()
	UI.preview_line.hide()

func line_preview(pos: Vector2) -> void:
	state = states.LINE_PREVIEW
	
	UI.preview_sprite.hide()
	UI.preview_line.show()
	UI.preview_line.points[0] = pos

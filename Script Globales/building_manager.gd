extends Node2D

enum states {IDLE, NODE_PREVIEW, LINE_PREVIEW}

## Array de pesos para cada tipo de nodo
#                      VIRT    SOLAR  WIND   HYDRO THERMAL  IND   RES
var weights: Array = [5.000, 1.001, 1.002, 1.005, 1.012, 1.000, 1.000]

var UI: Control
var state: int = states.IDLE

var previewing_type: int = 0
var connecting_node: GridNode
var city_names = ["Madrid", "Barcelona", "Sevilla", "Valencia"]

var building_grid_size: Vector2 = Vector2(64,64)
@onready var building_grid: AStar2D = AStar2D.new()

func _ready() -> void:
	initialize_building_grid()

func _process(delta: float) -> void:
	if state == states.NODE_PREVIEW:
		UI.preview_sprite.global_position = snapped(get_global_mouse_position(), building_grid_size)
	elif state == states.LINE_PREVIEW:
		UI.preview_line.points[1] = get_global_mouse_position()


func initialize_building_grid() -> void:
	var id: int = 1
	for i in range(1+int(1920/building_grid_size.x)):
		for j in range(1+int(1080/building_grid_size.y)):
			var pos := Vector2(i*building_grid_size.x, j*building_grid_size.y)
			building_grid.add_point(id, pos)
			building_grid.connect_points(id, id-1)
			print("[Bulding Manager Debug] Building grid point ", str(id), " created at:   ", str(pos))
			id += 1

func button_pressed(type: int) -> void:
	previewing_type = type
	node_preview()

func left_click(pos: Vector2) -> void:
	if state == states.NODE_PREVIEW:
		var snapped_pos: Vector2 = snapped(pos, building_grid_size)
		AlgorithmManager.add_node(snapped_pos, previewing_type, city_names.pick_random(), weights[previewing_type])

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

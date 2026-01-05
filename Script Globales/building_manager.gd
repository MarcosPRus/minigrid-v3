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

var building_grid_size: Vector2i = Vector2i(96,96)
var building_grid: AStarGrid2D = AStarGrid2D.new()

var lines_grid_size: Vector2i = Vector2i(16,16)
var lines_grid: AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
	initialize_building_grid()
	initialize_lines_grid()

func _process(delta: float) -> void:
	if state == states.NODE_PREVIEW:
		UI.preview_sprite.global_position = snapped(get_global_mouse_position(), Vector2(building_grid_size))
	elif state == states.LINE_PREVIEW:
		UI.preview_line.points[1] = get_global_mouse_position()


func initialize_building_grid() -> void:
	building_grid.region = Rect2i(0, 0, 32, 32)
	building_grid.cell_size = building_grid_size
	building_grid.jumping_enabled = true
	#building_grid.set_default_compute_heuristic
	#building_grid.set_default_estimate_heuristic
	building_grid.update()

func initialize_lines_grid() -> void:
	lines_grid.region = Rect2i(-256, -256, 512, 512)
	lines_grid.cell_size = lines_grid_size
	
	#lines_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	#lines_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	#lines_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	lines_grid.jumping_enabled = true
	lines_grid.update()

func button_pressed(type: int) -> void:
	previewing_type = type
	node_preview()

func left_click(pos: Vector2) -> void:
	var id: int = -1
	var snapped_pos: Vector2i
	if state == states.NODE_PREVIEW:
		snapped_pos = snapped(pos, Vector2(building_grid_size))
		id = AlgorithmManager.add_node(snapped_pos, previewing_type, city_names.pick_random(), weights[previewing_type])
	
	# Si recibimos un -1, es que la posición está ocupada
	if id == -1:
		return
	# Si no, el nodo se ha colocado. Aumentamos el peso de la rejilla de líneas para evitar que
	# se pisen nodos y líneas no conectados
	else:
		for x in range(-2, 3):
			for y in range(-2, 3):
				var cell = Vector2i(snapped_pos/lines_grid_size) + Vector2i(x, y)
				lines_grid.set_point_weight_scale(cell, 1.1)
		idle()

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


# Esta es la función mágica que encuentra el camino y "ocupa" el espacio
func get_line_path(from: Vector2i, to: Vector2i) -> PackedVector2Array:
	# Convertimos posición de mundo a coordenadas de rejilla
	# local_to_map es interno de tilemaps, aquí lo hacemos manual dividiendo
	var start_id = Vector2i(from / lines_grid_size)
	var end_id = Vector2i(to / lines_grid_size)
	
	# Pedimos el camino a la rejilla
	var id_path = lines_grid.get_id_path(start_id, end_id)
	var point_path = lines_grid.get_point_path(start_id, end_id)
	
	# MARCAR OCUPADO:
	# Recorremos el camino encontrado y aumentamos el "coste" de esas celdas.
	# Así, la próxima línea intentará evitar pasar por aquí.
	for cell_id in id_path:
		# No bloqueamos el inicio ni el final para permitir conectar al mismo nodo
		if cell_id == start_id or cell_id == end_id:
			continue
		
		# Aumentamos el peso (coste). 
		# 1.0 es default. Ponemos 5.0 o 10.0 para que sea "caro" pisar el cable.
		# Si no hay otro remedio, lo cruzará (mejor que bloquearlo con solid=true).
		var current_weight = lines_grid.get_point_weight_scale(cell_id)
		lines_grid.set_point_weight_scale(cell_id, current_weight + 0.1)
	
	return point_path

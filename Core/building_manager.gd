class_name BuildingManager
extends Node2D

enum states {IDLE, NODE_PREVIEW, LINE_PREVIEW}

## Array de pesos para cada tipo de nodo
#                      VIRT    SOLAR  WIND   HYDRO THERMAL  IND   RES
var weights: Array = [5.000, 1.001, 1.002, 1.005, 1.012, 1.000, 1.000]


var state: int = states.IDLE
var ui_ref: Control
var algorithm_manager_ref: AlgorithmManager

var previewing_type: int = 0
var connecting_node: GridNode
var city_names = ["Madrid", "Barcelona", "Sevilla", "Valencia"]

static var blg_grid_size: Vector2i = Vector2i(32,32)
var blg_grid: AStarGrid2D = AStarGrid2D.new()


func _ready() -> void:
	Events.node_clicked.connect(on_node_selected)
	initialize_blg_grid()

func _process(delta: float) -> void:
	if state == states.NODE_PREVIEW:
		ui_ref.preview_sprite.global_position = snapped(get_global_mouse_position(), Vector2(blg_grid_size))
	elif state == states.LINE_PREVIEW:
		ui_ref.preview_line.points[1] = get_global_mouse_position()


func initialize_blg_grid() -> void:
	blg_grid.region = Rect2i(-512, -512, 2048, 2048)
	blg_grid.cell_size = blg_grid_size
	#blg_grid.jumping_enabled = true
	#blg_grid.set_default_compute_heuristic
	#blg_grid.set_default_estimate_heuristic
	
	blg_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	blg_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	blg_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	
	blg_grid.update()


func button_pressed(type: int) -> void:
	previewing_type = type
	node_preview()

func left_click(pos: Vector2) -> void:
	var id: int = -1
	var snapped_pos: Vector2i
	if state == states.NODE_PREVIEW:
		snapped_pos = snapped(pos, Vector2(blg_grid_size))
		id = algorithm_manager_ref.add_node(snapped_pos, previewing_type, city_names.pick_random(), weights[previewing_type])
	
	# Si recibimos un -1, es que la posición está ocupada
	if id == -1:
		return
	# Si no, el nodo se ha colocado. Aumentamos el peso de la rejilla de líneas para evitar que
	# se pisen nodos y líneas no conectados
	else:
		var center_cell: Vector2i = Vector2i(snapped_pos/blg_grid_size)
		for x in range(-1, 2):
			for y in range(-1, 2):
				var cell = center_cell + Vector2i(x, y)
				#blg_grid.set_point_solid(cell, true)
				blg_grid.set_point_weight_scale(cell, 10.0)
				
		#blg_grid.set_point_solid(center_cell, false)
		idle()

func right_click() -> void:
	idle()

func on_node_selected(node: GridNode) -> void:
	if state == states.IDLE or state == states.NODE_PREVIEW:
		line_preview(node.global_position)
		connecting_node = node
	elif state == states.LINE_PREVIEW:
		if node != connecting_node:
			algorithm_manager_ref.connect_nodes(connecting_node.id, node.id, 10.0)
			connecting_node = null
			idle()


func idle() -> void:
	state = states.IDLE
	ui_ref.preview_sprite.hide()
	ui_ref.preview_line.hide()

func node_preview() -> void:
	state = states.NODE_PREVIEW
	
	ui_ref.preview_sprite.show()
	ui_ref.preview_line.hide()

func line_preview(pos: Vector2) -> void:
	state = states.LINE_PREVIEW
	
	ui_ref.preview_sprite.hide()
	ui_ref.preview_line.show()
	ui_ref.preview_line.points[0] = pos


# Esta es la función mágica que encuentra el camino y "ocupa" el espacio
func get_line_path(from: Vector2i, to: Vector2i) -> PackedVector2Array:
	# Convertimos posición de mundo a coordenadas de rejilla
	# local_to_map es interno de tilemaps, aquí lo hacemos manual dividiendo
	var start_id = Vector2i(from / blg_grid_size)
	var end_id = Vector2i(to / blg_grid_size)	
	
	# Pedimos el camino a la rejilla
	var id_path = blg_grid.get_id_path(start_id, end_id)
	var point_path = blg_grid.get_point_path(start_id, end_id)
	
	# MARCAR OCUPADO:
	# Recorremos el camino encontrado y bloquemos esas celdas.
	# Así, la próxima línea intentará evitar pasar por aquí.
	for cell_id in id_path:
		# No bloqueamos el inicio ni el final para permitir conectar al mismo nodo
		if cell_id == start_id or cell_id == end_id:
			continue
		
		# Bloquemas la celda
		#blg_grid.set_point_solid(cell_id, true)
		blg_grid.set_point_weight_scale(cell_id, 10.0)
	
	return point_path

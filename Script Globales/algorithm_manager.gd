extends Node2D

signal grid_state_updated(solver_state: mod_AStar2D)

enum {SS, SC}
enum {VIRTUAL, SOLAR, WIND, HYDRO, THERMAL, INDUSTRIAL, RESIDENTIAL}

var NodesContainer: Node2D
var LinesContainer: Node2D
var Solver: mod_AStar2D

var nodes: Dictionary[int, GridNode] = {}
var lines: Dictionary[String, GridLine] = {}

var final_flows: Dictionary = {}


func _ready() -> void:
	Solver = mod_AStar2D.new()
	await get_tree().create_timer(0.5).timeout
	# Añadimos los nodos SS y SC lo primero
	var SS = add_node(Vector2(-10000, -10000), VIRTUAL, "SS", 1.0) # ID 0 por ser el primero
	var SC = add_node(Vector2(-10000, -10000), VIRTUAL, "SC", 1.0) # ID 1 por ser el segundo
	assert(SS == 0 and SC == 1, "SS and SC IDs are incorrect!")


func add_node(pos: Vector2i, type: int, name_:String, weight: float = 1.0) -> int:
	# Comprobamos que no haya nodos o líneas solapadas (solo para nodos y líneas reales)
	if type != VIRTUAL and is_position_occupied(pos):
		print("[AlgorithmManager Debug] Error: Node overlaps with existing node at ", pos)
		return -1 # Retornamos ID inválido
	
	# Creamos el id del nuevo nodo
	var new_node_id: int = -1
	var virt_node_id: int = -1
	# Lo actualizamos según nos diga el Solver
	if type == VIRTUAL: # Si es un virtual
		new_node_id = Solver.add_node(pos, weight)
		save_node(new_node_id, pos, type, name_)
	elif type <= THERMAL: # Si es un generador
		# Añadimos el generador virtual
		virt_node_id = add_node(pos-Vector2i(128, 0), VIRTUAL, name_+"_v", weight)
		# Añadimos el nodo real con peso 1
		new_node_id = Solver.add_node(pos, 1.0)
		save_node(new_node_id, pos, type, name_)
		# En el siguiente frame, conectamos el SS con el nodo virtual, y el virtual con el real.
		connect_nodes(SS, virt_node_id, 1.0) # Cap generación 1 por defecto
		connect_nodes(new_node_id, virt_node_id, INF)
	elif type >= INDUSTRIAL: # Si es un consumidor
		# Añadimos el nodo real
		new_node_id = Solver.add_node(pos, 1.0)
		# Lo conectamos al SC
		save_node(new_node_id, pos, type, name_)
		connect_nodes(SC, new_node_id, 1.0) # Demanda 1 por defecto (Demanda)
	
	update_grid()
	return new_node_id


func save_node(new_node_id: int, pos: Vector2, type: int, name_:String) -> void:
	# Creamos la instancia del nodo, y la añadimos al diccionario de nodos
	var new_node: GridNode = GridNode.add_node_scene(new_node_id, pos, type, name_)
	NodesContainer.add_child(new_node)
	nodes[new_node_id] = new_node
	print("[AlgorithmManager Debug] New node (", str(new_node_id), ") saved!: ", str(new_node), "  at ", str(pos))


func connect_nodes(id_a: int, id_b: int, capacity: float) -> String:
	# Checkeamos que los nodos no están conectados
	if Solver.are_points_connected(id_a, id_b):
		return "Nodes already connected"
	# Obtenemos el id de la linea, añadiendola al Solver
	var new_line_id = Solver.add_line(id_a, id_b, capacity)
	# Creamos la instancia de la línea, y la añadimos al diccionario de líneas
	# 2. Lógica Visual (Routing)
	if nodes[id_a].type == VIRTUAL or nodes[id_b].type == VIRTUAL:
		return "virtual"
	else:
		var new_line: GridLine = GridLine.new()
		
		var start_pos = nodes[id_a].global_position
		var end_pos = nodes[id_b].global_position
		# Obtenemos el camino visual esquivando obstáculos
		var visual_path = BuildingManager.get_line_path(start_pos, end_pos)
		new_line.points = visual_path # Asignamos los puntos a la Line2D
		
		new_line.id = new_line_id
		new_line.id_a = id_a
		new_line.pos_a = nodes[id_a].global_position
		new_line.id_b = id_b
		new_line.pos_b = nodes[id_b].global_position
		LinesContainer.add_child(new_line)
		
		lines[new_line_id] = new_line
		print("[AlgorithmManager Debug] New line (", new_line_id, ") created!: ", str(new_line))
		
	update_grid()
	return new_line_id


func update_generator_capacity(node_id: int, new_cap: int, new_cost: float) -> void:
	# Un generador modifica su capacidad máxima de generación
	# modificando la capacidad de la línea que conecta el SS con el generador virtual
	Solver.set_connection_capacity(SS, node_id-1, new_cap)
	# Y también su coste (Peso del nodo virtual)
	Solver.set_point_weight_scale(node_id - 1, new_cost) # El nodo generador virtual siempre tiene el id del generador -1


func update_consumer_capacity(node_id: int, new_demand: int) -> void:
	# Un consumidor modifica su demanda modificando la capacidad
	# de la línea que conecta el SC con el consumidor
	Solver.set_connection_capacity(SC, node_id, new_demand)


func update_grid() -> void:
	for l in lines.values():
		l.update_capacity()
	
	# TODO: Cambiar esto a ejecución por grupos, primero los consumidores,
	# luego los generadores inflexibles, luego los generadores flexibles,
	# y por último el almacenamiento.
	for n in nodes.values():
		n.update_capacity()
	
	final_flows = Solver.solve()
	
	#update_flows(Solver.final_flows)
	grid_state_updated.emit(Solver)


#func update_flows(final_flows: Dictionary) -> void:	
	#print("Final flows: ")
	#for l in lines.values():
		#l.flow = final_flows[l.id]
		#print(l.id, ": ", final_flows[l.id])
	#
	#for n in nodes.values():
		#if n.is_generator:
			#var gen: float = final_flows[str(SS)+"-"+str(n.id-1)]
			#var cap: float = Solver.Caps[str(SS)+"-"+str(n.id-1)]
			#n.update_gen_gui(gen, cap)
		#elif n.is_consumer:
			#var dem_sat: float = final_flows[str(SC)+"-"+str(n.id)]
			#var dem_tot: float = Solver.Caps[str(SC)+"-"+str(n.id)]
			#n.update_cons_gui(dem_sat, dem_tot)


func is_position_occupied(target_pos: Vector2i, node_radius: float = 48.0, line_radius: int = 2) -> bool:
	## Comprobación de nodos
	# Ignoramos nodos virtuales y SS y SC porque están en -10000, -10000
	for node in nodes.values():
		if !node.is_virtual:
			if node.global_position.distance_to(target_pos) < node_radius:
				return true
	
	## Comprobación de líneas
	# Convertimos la posición de mundo a la celda central de la rejilla visual
	var center_id = Vector2i(target_pos / BuildingManager.blg_grid_size)
	# Escaneamos el área que ocupará el nodo
	for x in range(-line_radius, line_radius+1):
		for y in range(-line_radius, line_radius+1):
			var cell = center_id + Vector2i(x, y)
			# CHECK CLAVE:
			# Si es sólido, hay un edificio.
			if BuildingManager.blg_grid.is_point_solid(cell):
				return true
	return false

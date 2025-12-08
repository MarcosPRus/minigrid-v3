extends Node2D

enum {SS, SC}
enum {VIRTUAL, SOLAR, WIND, HYDRO, NUCLEAR, GAS, COAL, INDUSTRIAL, COMMERCIAL, RESIDENTIAL}

var NodesContainer: Node2D
var LinesContainer: Node2D
var Solver: mod_AStar2D

var nodes: Dictionary = {}
var lines: Dictionary = {}


func _ready() -> void:
	Solver = mod_AStar2D.new()
	await get_tree().create_timer(0.5).timeout
	# Añadimos los nodos SS y SC lo primero
	var SS = add_node(Vector2(-1000, -1000), VIRTUAL, "SS", 1.0) # ID 0 por ser el primero
	var SC = add_node(Vector2(-1000, -1000), VIRTUAL, "SC", 1.0) # ID 1 por ser el segundo
	assert(SS == 0 and SC == 1, "SS and SC IDs are incorrect!")
	
	
	#var n1: int = add_node(Vector2(500, 300), SOLAR, "Solar", 1.0)
	#var n2: int = add_node(Vector2(700, 500), RESIDENTIAL, "City", 1.0)
	#var n3: int = add_node(Vector2(500, 700), COAL, "Coal", 1.0)
	#var l1: String = connect_nodes(n1, n2, 1.0)
	#var l2: String = connect_nodes(n2, n3, 1.0)
	#Solver.solve()


func add_node(pos: Vector2, type: int, name_:String, weight: float = 1.0) -> int:
	# Creamos el id del nuevo nodo
	var new_node_id: int = -1
	var virt_node_id: int = 0
	# Lo actualizamos según nos diga el Solver
	if type == VIRTUAL: # Si es un virtual
		new_node_id = Solver.add_node(pos, weight)
		save_node(new_node_id, pos, type, name_)
	elif type <= COAL: # Si es un generador
		# Añadimos el generador virtual
		virt_node_id = add_node(pos-Vector2(128, 0), VIRTUAL, name_+"_v", weight)
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
	var new_node: GridNode = GridNode.new()
	new_node.id = new_node_id
	new_node.name = name_
	new_node.pos = pos
	new_node.type = type
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
	var new_line: GridLine = GridLine.new()
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


func update_grid() -> void:
	Solver.solve()


func new_grid_state(final_flows: Dictionary) -> void:
	print("Final flows: ")
	for line_id in lines.keys():
		lines[line_id].flow = final_flows[line_id]
		print(line_id, ": ", final_flows[line_id])

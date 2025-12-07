extends Node2D

enum {SOLAR, WIND, HYDRO, NUCLEAR, GAS, COAL, INDUSTRIAL, COMMERCIAL, RESIDENTIAL}

var NodesContainer: Node2D # TODO: El contenedor de nodos tiene que asignarse a sí mismo a esta variable
var LinesContainer: Node2D # TODO: El contenedor de líneas tiene que asignarse a sí mismo a esta variable
var Solver: mod_AStar2D

var nodes: Dictionary = {}
var lines: Dictionary = {}


func _ready() -> void:
	Solver = mod_AStar2D.new()
	
	await get_tree().create_timer(0.5).timeout
	
	var n1: int = add_node(Vector2.ZERO, SOLAR, 1.0)
	var n2: int = add_node(Vector2.ZERO, RESIDENTIAL, 1.0)
	var l1: String = connect_nodes(n1, n2, 0.5)
	Solver.solve()

func add_node(pos: Vector2, type: int, weight: float = 1.0) -> int:
	# Creamos el id del nuevo nodo
	var new_node_id: int = -1
	# Lo actualizamos según nos diga el Solver
	if type <= COAL:
		new_node_id = Solver.add_generator(pos, weight)
	elif type >= INDUSTRIAL:
		new_node_id = Solver.add_consumer(pos)
	# Creamos la instancia del nodo, y la añadimos al diccionario de nodos
	var new_node: GridNode = GridNode.new()
	new_node.id = new_node_id
	new_node.pos = pos
	new_node.type = type
	NodesContainer.add_child(new_node)
	
	nodes[new_node_id] = new_node
	
	print("[AlgorithmManager Debug] New node (", str(new_node_id), ") created!: ", str(new_node), "  at ", str(pos))
	return new_node_id


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
	new_line.id_b = id_b
	LinesContainer.add_child(new_line)
	
	lines[new_line_id] = new_line
	
	print("[AlgorithmManager Debug] New line (", new_line_id, ") created!: ", str(new_line))
	return new_line_id

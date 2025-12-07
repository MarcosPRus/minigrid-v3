class_name mod_AStar2D
extends AStar2D

const SS: int = 0
const SC: int = 1

var G: AStar2D
var G_copy: AStar2D

var Caps: Dictionary = {}
var Caps_copy: Dictionary = {}

var min_cap
var next_id: int = 2

func _init() -> void:
	# Create the default A* instances
	G = AStar2D.new()
	G_copy = AStar2D.new()
	# Add the SS and SC nodes
	G.add_point(SS, Vector2(-1000, -1000), 1.0) # Super Source
	G.add_point(SC, Vector2(-1000, -1000), 1.0) # Super Consumer
	
	print("[Mod A* Debug] G created: \t", G)
	#print("[Mod A* Debug] G has ", G.get_point_count(), " nodes")
	copy_G_into_G_copy()
	print("[Mod A* Debug] G_copy created: \t", G_copy)
	#print("[Mod A* Debug] G_copy has ", G_copy.get_point_count(), " nodes")
	
	#print("Adding a point to G_copy ONLY")
	#G_copy.add_point(5, Vector2(0,0))
	#print("[Mod A* Debug] G has ", G.get_point_count(), " nodes")
	#print("[Mod A* Debug] G_copy has ", G_copy.get_point_count(), " nodes")


func copy_G_into_G_copy() -> void:
	var ids_nodos = G.get_point_ids()
	# Copiamos los nodos
	for id in ids_nodos:
		var pos = G.get_point_position(id)
		var weight = G.get_point_weight_scale(id)
		G_copy.add_point(id, pos, weight)
	
	# Copiamos las líneas
	for id in ids_nodos:
		var connections = G.get_point_connections(id)
		for target_id in connections:
			# Verificamos que no estén ya conectados
			if not G_copy.are_points_connected(id, target_id):
				G_copy.connect_points(id, target_id, true)


## Function used by the Algorithm Manager to add consumers to the graph
# pos = Vector de posición 2D
# max_cap = Capacidad máxima de generación o consumo del nodo (el tamaño o "nivel" del nodo)
func add_consumer(pos: Vector2i) -> int:
	# Al añadir nodos, los tenemos que añadir solamente a G
	# Una vez añadido el nodo, tenemos que recalcular la red, por lo que reseteamos G_copy
	# Añadimos el nodo real
	G.add_point(next_id, pos, 1.0)
	# Lo conectamos al nodo SC
	add_line(next_id, SC, 1.0) # Capacidad inicial nula
	
	next_id += 1
	return next_id-1


## Function used by the Algorithm Manager to add generators to the graph
# pos = Vector de posición 2D
# weight = Peso del nodo (sólo aplica para los nodos generadores virtuales)
# max_cap = Capacidad máxima de generación o consumo del nodo (el tamaño o "nivel" del nodo)
func add_generator(pos: Vector2i, weight: float) -> int:
	# Al añadir nodos, los tenemos que añadir solamente a G
	# Una vez añadido el nodo, tenemos que recalcular la red, por lo que reseteamos G_copy
	# Añadimos el nodo real
	G.add_point(next_id, pos, 1.0)
	# Añadimos el nodo virtual
	G.add_point(next_id+1, pos, 1.0)
	# Los conectamos entre ellos y al nodo SS
	add_line(next_id, next_id+1, INF) # Nodo real - Nodo virtual (Capacidad infinita)
	add_line(next_id+1, SS, 1.0) # Nodo virtual - SS (Capacidad inicial nula)
	
	next_id += 2
	return next_id-2


## Function used by the Algorithm Manager to add lines to the graph
## Also used internally to connect to Virtual Nodes
# id_a = Id of the first node
# id_b = Id of the second node (the order doesn't matter)
# cap = capacity of the connection
func add_line(id_a: int, id_b: int, cap: float) -> String:
	# Asumimos que la conexión no existe, la lógica de detección de líneas duplicadas
	# la implementa el AlgorithmManager a más alto nivel
	G.connect_points(id_a, id_b, true)
	# Y añadimos esta línea al diccionario de capacidades
	var connection_id: String = str(id_a) + "-" + str(id_b)
	Caps[connection_id] = cap
	
	return connection_id


func solve() -> void:
	copy_G_into_G_copy()
	Caps_copy = Caps.duplicate()
	
	var next_path = G_copy.get_id_path(SS, SC)
	
	#while next_path:
	print("[Mod A* Debug] Shortest path found: ", next_path)
	# Llamamos a la función que busqua en un "path", la capacidad mínima o cuello de botella
	var bottleneck_cap = get_bottleneck_capacity(next_path)
	print("[Mod A* Debug] Bottleneck line capacity is: ", bottleneck_cap)
	# Llamamos a la función que reduce las capacidades de las líneas en la copia del 


func get_bottleneck_capacity(path: PackedInt64Array) -> float:
	var min_cap := INF
	var curr_cap := 0.0
	
	for i in range(path.size() - 1):
		var line_id_1 = str(path[i]) + "-" + str(path[i+1])
		var line_id_2 = str(path[i+1]) + "-" + str(path[i])
		# Con get(), intentamos conseguir la capacidad de a-b. Si esa key no existe, intentamos 
		# obtener la capacidad de b-a. Si tampoco existe, recibimos "null"
		curr_cap = Caps_copy.get(line_id_1, Caps_copy.get(line_id_2, null))
		if curr_cap < min_cap:
			min_cap = curr_cap
	
	return min_cap
		

class_name mod_AStar2D
extends AStar2D

enum {SS, SC}

var G: AStar2D
var G_copy: AStar2D

var Caps: Dictionary = {}
var Caps_copy: Dictionary = {}
var final_flows: Dictionary = {}
var net_flows: Dictionary = {}

var min_cap
var next_id: int = 0

func _init() -> void:
	# Create the default A* instances
	G = AStar2D.new()
	G_copy = AStar2D.new()
	
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

#region Old functions
func add_virtual(pos: Vector2i, weight: float) -> int:
	G.add_point(next_id, pos, weight)
	next_id += 1
	return next_id-1
	

## Function used by the Algorithm Manager to add consumers to the graph
# pos = Vector de posición 2D
# max_cap = Capacidad máxima de generación o consumo del nodo (el tamaño o "nivel" del nodo)
func add_consumer(pos: Vector2i) -> int:
	# Al añadir nodos, los tenemos que añadir solamente a G
	# Una vez añadido el nodo, tenemos que recalcular la red, por lo que reseteamos G_copy
	# Añadimos el nodo real
	G.add_point(next_id, pos, 1.0)
	# Lo conectamos al nodo SC. Siempre el nodo SS o SC primero, para tener ids de líneas consistentes
	add_line(SC, next_id, 1.0) # Capacidad inicial
	
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
	add_line(SS, next_id+1, 1.0) # SS - Nodo virtual (Capacidad inicial)
	
	next_id += 2
	return next_id-2
#endregion

## Function used by the Algorithm Manager to add nodes to the graph
func add_node(pos: Vector2, weight: float) -> int:
	G.add_point(next_id, pos, weight)
	
	next_id += 1
	return next_id-1

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


func reset_flows():
	net_flows.clear()
	for key in Caps.keys():
		net_flows[key] = 0.0


func solve() -> Dictionary:
	copy_G_into_G_copy()
	reset_flows()
	Caps_copy = Caps.duplicate()
	
	var next_path = G_copy.get_id_path(SS, SC, false)
	
	while next_path:
		print("[Mod A* Debug] Shortest path found: ", next_path)
		# Llamamos a la función que busqua en un "path", la capacidad mínima o cuello de botella
		var bottleneck_cap = get_bottleneck_capacity(next_path)
		print("[Mod A* Debug] Bottleneck line capacity is: ", bottleneck_cap)
		# Llamamos a la función que reduce las capacidades de las líneas en la copia del
		reduce_capacity_along_path(next_path, bottleneck_cap)
		# Volvemos a buscar el camino más corto en G_copy
		next_path = G_copy.get_id_path(SS, SC)
	
	print("[Mod A* Debug] No path found!")
	
	# Notificamos al Algorithm Manager para que éste notifique a los nodos y líneas individuales que hay 
	# un nuevo estado de la red
	for line in Caps.keys():
		final_flows[line] = Caps[line] - Caps_copy[line]
	
	return final_flows


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


func reduce_capacity_along_path(path: PackedInt64Array, cap: float) -> void:
	for i in range(path.size() - 1):
		var line_id_1 = str(path[i]) + "-" + str(path[i+1])
		var line_id_2 = str(path[i+1]) + "-" + str(path[i])
		# TODO: Tiene que haber una mejor forma de hacer esto
		# TODO: La hay, cambiar por ids numéricos (ej: id_a * 1000 + id_b)
		if Caps_copy.has(line_id_1):
			# Reducimos la capacidad
			Caps_copy[line_id_1] -= cap
			# Y registramos la dirección
			net_flows[line_id_1] += cap
			
			print("[Mod A* Debug] Capacity along ", str(path[i]), "-", str(path[i+1]), " reduced by ", str(cap))
			if Caps_copy[line_id_1] <= 0:
				G_copy.disconnect_points(path[i], path[i+1])
				print("[Mod A* Debug] Segment ", str(path[i]), "-", str(path[i+1]), " removed ")
		
		elif Caps_copy.has(line_id_2):
			# Reducimos la capacidad
			Caps_copy[line_id_2] -= cap
			# Y registramos la dirección
			net_flows[line_id_2] -= cap
			
			print("[Mod A* Debug] Capacity along ", str(path[i]), "-", str(path[i+1]), " reduced by ", str(cap))
			if Caps_copy[line_id_2] <= 0:
				G_copy.disconnect_points(path[i], path[i+1])
				print("[Mod A* Debug] Segment ", str(path[i]), "-", str(path[i+1]), " removed ")


func set_connection_capacity(id_a: int, id_b: int, new_cap: int) -> void:
	var line_id_1 = str(id_a) + "-" + str(id_b)
	var line_id_2 = str(id_b) + "-" + str(id_a)
	# TODO: Tiene que haber una mejor forma de hacer esto
	if Caps.has(line_id_1):
		Caps[line_id_1] = new_cap
	elif Caps_copy.has(line_id_2):
		Caps[line_id_2] = new_cap

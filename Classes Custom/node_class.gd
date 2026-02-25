class_name GridNode
extends Node2D


static var total_consumption: float
static var total_generation: float

var id: int
@export var type: int

@export var is_virtual: bool = false
@export var is_generator: bool = false
@export var is_consumer: bool = false

@export var hourly_profile: Curve

@export var node_state: NodeState

@onready var click_area: Area2D = $ClickArea
@onready var node_gui: Control = $NodeGUI
@onready var node_gui_v2: ColorRect = $NodeGUIv2
@onready var node_gui_v3: NodeGUIv3 = $NodeGUIv3


# Helper function to easily add node scenes to the tree (constructor?
static func add_node_scene(new_node_id: int, pos: Vector2, type: int, name_: String) -> GridNode:
	var node_scenes := [load("res://Nodos/0_Virtual/virtual_node.tscn"), \
						load("res://Nodos/1_Solar/solar_node.tscn"), \
						load("res://Nodos/2_Wind/wind_node.tscn"), \
						load("res://Nodos/3_Hydro/hydro_node.tscn"), \
						load("res://Nodos/4_Thermal/thermal_node.tscn"), \
						load("res://Nodos/5_Industrial/industrial_node.tscn"), \
						load("res://Nodos/6_Residential/residential_node.tscn")]
						
	var new_node: GridNode = node_scenes[type].instantiate()
	new_node.id = new_node_id
	new_node.name = name_
	new_node.global_position = pos
	return new_node


func _ready() -> void:	
	if type == AlgorithmManager.VIRTUAL:
		return
	
	click_area.input_event.connect(_on_click_area_input_event)
	node_gui_v3.setup(node_state.base_cap)


func update_capacity(weather_state: WeatherState) -> int:
	if is_virtual:
		return -1
	
	# TODO: Implementar calculo de nuevos parámetros según hora y parámetros ambientales
	var new_cap: int = ceil(node_state.base_cap * hourly_profile.sample(weather_state.hour))
	node_state.disp = new_cap / node_state.base_cap
	
	return new_cap


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_released("left_click"):
		Events.node_clicked.emit(self)
		#BuildingManager.node_selected(self)


func on_grid_state_updated(solver_state: mod_AStar2D) -> void:
	if is_generator:
		node_state.generation = solver_state.final_flows[str(0)+"-"+str(id-1)]
		update_gen_gui()
	elif is_consumer:
		node_state.consumption = solver_state.final_flows[str(1)+"-"+str(id)]
		update_cons_gui()
	
	node_gui_v3.update(node_state)


func update_gen_gui() -> void:	
	node_gui.update_progress_bar(node_state)
	node_gui_v2.update_shader(node_state)
	node_gui_v3.update_generation(node_state)


func update_cons_gui() -> void:
	node_gui.update_progress_bar(node_state)
	node_gui_v2.update_shader(node_state)
	node_gui_v3.update_consumption(node_state)

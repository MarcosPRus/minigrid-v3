class_name GridNode
extends Node2D

static var total_consumption: float
static var total_generation: float

var total_energy_gen: float = 0.0
var total_energy_con: float = 0.0

var id: int
@export var type: int
var pos: Vector2
@export var base_cap: int = 5

@export var is_virtual: bool = false
@export var is_generator: bool = false
@export var is_consumer: bool = false
@export var hourly_profile: Curve

@onready var click_area: Area2D = $ClickArea
@onready var node_gui: Control = $NodeGUI
@onready var node_gui_v2: ColorRect = $NodeGUIv2
@onready var node_gui_v3: NodeGUIv3 = $NodeGUIv3


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
	node_gui_v3.setup(base_cap)

func update_params() -> void:
	if is_virtual:
		return
	
	# TODO: Implementar calculo de nuevos parámetros según hora y parámetros ambientales
	var aux_value: int = ceil(base_cap * hourly_profile.sample(GameCoordinator.hour))
	
	if is_generator: # Generator
		AlgorithmManager.update_generator_state(id, aux_value, BuildingManager.weights[type])
	else:
		AlgorithmManager.update_consumer_state(id, aux_value)


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_released("left_click"):
		BuildingManager.node_selected(self)


func update_gen_gui(gen: float, cap: float) -> void:	
	node_gui.update_progress_bar(gen, cap)
	node_gui_v2.update_shader(gen, base_cap, cap/base_cap)
	node_gui_v3.update_generation(gen, base_cap, cap/base_cap)


func update_cons_gui(dem_sat: float, dem_tot: float) -> void:
	node_gui.update_progress_bar(dem_sat, dem_tot)
	node_gui_v2.update_shader(dem_sat, base_cap, dem_tot/base_cap)
	node_gui_v3.update_consumption(dem_sat, base_cap, dem_tot/base_cap)

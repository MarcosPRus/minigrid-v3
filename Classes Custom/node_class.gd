class_name GridNode
extends Node2D

static var total_consumption: float
static var total_generation: float

var total_energy_gen: float = 0.0
var total_energy_con: float = 0.0

var id: int
var type: int
var pos: Vector2
var base_cap: int = 2
var variance: float = 0.05

var is_virtual: bool = false
var is_generator: bool = false
var is_consumer: bool = false
var hourly_profile: Curve

@onready var sprite: Sprite2D = Sprite2D.new()
@onready var click_area: Area2D = load("res://Node Components/click_area.tscn").instantiate()
@onready var node_gui: Control = load("res://Node Components/node_gui.tscn").instantiate()


func _ready() -> void:
	match type:
		AlgorithmManager.VIRTUAL:
			is_virtual = true
			return
		AlgorithmManager.SOLAR:
			is_generator = true
			hourly_profile = load("res://Hourly Profiles/solar_profile.tres")
		AlgorithmManager.WIND:
			is_generator = true
			hourly_profile = load("res://Hourly Profiles/constant_profile.tres")
		AlgorithmManager.HYDRO:
			is_generator = true
			hourly_profile = load("res://Hourly Profiles/constant_profile.tres")
		AlgorithmManager.NUCLEAR:
			is_generator = true
			hourly_profile = load("res://Hourly Profiles/constant_profile.tres")
		AlgorithmManager.COAL:
			is_generator = true
			hourly_profile = load("res://Hourly Profiles/constant_profile.tres")
		AlgorithmManager.RESIDENTIAL:
			is_consumer = true
			hourly_profile = load("res://Hourly Profiles/residential_profile.tres")
	
	## Initial configuration
	self.global_position = pos
	
	sprite.texture = load("res://Assets/spritesheet.png")
	sprite.hframes = 10
	sprite.frame = type
	
	click_area.input_event.connect(_on_click_area_input_event)
	
	add_child(sprite)
	add_child(click_area)
	add_child(node_gui)


func update_params() -> void:
	if is_virtual:
		return
	
	# TODO: Implementar calculo de nuevos parámetros según hora y parámetros ambientales
	var aux_value = base_cap * \
					hourly_profile.sample(GameCoordinator.hour) * \
					randf_range(1-variance, 1+variance)
	
	if is_generator: # Generator
		AlgorithmManager.update_generator_state(id, aux_value, BuildingManager.weights[type])
	else:
		AlgorithmManager.update_consumer_state(id, aux_value)


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_released("left_click"):
		BuildingManager.node_selected(self)


func update_gen_gui(gen: float, cap: float) -> void:	
	node_gui.update_progress_bar(gen, cap)
	

func update_cons_gui(dem_sat: float, dem_tot: float) -> void:
	node_gui.update_progress_bar(dem_sat, dem_tot)

class_name GridNode
extends Node2D

var id: int
var type: int
var pos: Vector2

var is_virtual: bool = false
var is_generator: bool = false
var is_consumer: bool = false

@onready var sprite: Sprite2D = Sprite2D.new()
@onready var click_area: Area2D = load("res://click_area.tscn").instantiate()
@onready var node_gui: Control = load("res://node_gui.tscn").instantiate()


func _ready() -> void:
	if type == AlgorithmManager.VIRTUAL:
		is_virtual = true
		return
	elif type > AlgorithmManager.VIRTUAL and type < AlgorithmManager.INDUSTRIAL: # Generator
		is_generator = true
	elif type >= AlgorithmManager.INDUSTRIAL and type <= AlgorithmManager.RESIDENTIAL:
		is_consumer = true
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
	
	var aux_value = randf_range(0.0, 2.0) ## TODO: DELETE THIS SHIT
	if is_generator: # Generator
		AlgorithmManager.update_generator_state(id, aux_value, randf_range(0.0, 1.025))
	else:
		AlgorithmManager.update_consumer_state(id, aux_value)


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_released("left_click"):
		BuildingManager.node_selected(self)


func update_gen_gui(gen: float, cap: float) -> void:
	node_gui.update_progress_bar(gen, cap)
	

func update_cons_gui(dem_sat: float, dem_tot: float) -> void:
	node_gui.update_progress_bar(dem_sat, dem_tot)

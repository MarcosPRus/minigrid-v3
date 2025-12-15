class_name GridNode
extends Node2D

var id: int
var type: int
var pos: Vector2

var is_virtual: bool = false
var is_generator: bool = false
var is_consumer: bool = false

@onready var name_label: Label = Label.new()
@onready var state_label: Label = Label.new()
@onready var sprite: Sprite2D = Sprite2D.new()
@onready var click_area: Area2D = load("res://click_area.tscn").instantiate()


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
	
	name_label.z_index = 10
	name_label.text = name
	name_label.position.y = -64
	
	state_label.z_index = 10
	state_label.text = "?"
	state_label.position.y = -64
	
	click_area.input_event.connect(_on_click_area_input_event)
	
	add_child(sprite)
	#add_child(name_label)
	add_child(state_label)
	add_child(click_area)


func update_params() -> void:
	if is_virtual:
		return
	if is_generator: # Generator
		AlgorithmManager.update_generator_state(id, randf_range(0.0, 2.0), randf_range(0.0, 1.025))
	else:
		AlgorithmManager.update_consumer_state(id, randf_range(0.1, 2.0))


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_released("left_click"):
		BuildingManager.node_selected(self)

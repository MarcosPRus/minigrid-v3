class_name GridNode
extends Node2D

enum {VIRTUAL, SOLAR, WIND, HYDRO, NUCLEAR, GAS, COAL, INDUSTRIAL, COMMERCIAL, RESIDENTIAL}

var id: int
var type: int
var pos: Vector2

@onready var name_label: Label = Label.new()
@onready var sprite: Sprite2D = Sprite2D.new()
@onready var click_area: Area2D = load("res://click_area.tscn").instantiate()


func _ready() -> void:
	if type == VIRTUAL:
		return
	## Initial configuration
	self.global_position = pos
	
	sprite.texture = load("res://Assets/spritesheet.png")
	sprite.hframes = 10
	sprite.frame = type
	
	name_label.z_index = 10
	name_label.text = name
	
	click_area.input_event.connect(_on_click_area_input_event)
	
	add_child(sprite)
	add_child(name_label)
	add_child(click_area)


func update_params() -> void:
	pass

func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_released("left_click"):
		BuildingManager.node_selected(self)

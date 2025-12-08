class_name GridNode
extends Node2D

enum node_types {SOLAR, WIND, HYDRO, NUCLEAR, GAS, COAL, INDUSTRIAL, COMMERCIAL, RESIDENTIAL}

var id: int
var type: int
var pos: Vector2

@onready var name_label: Label = Label.new()
@onready var sprite: Sprite2D = Sprite2D.new()


func _ready() -> void:
	## Initial configuration
	self.global_position = pos
	sprite.texture = load("res://icon.svg")
	
	name_label.text = name
	
	add_child(sprite)
	add_child(name_label)


func update_params() -> void:
	pass

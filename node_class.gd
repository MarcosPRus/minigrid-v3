class_name GridNode
extends Node2D

enum node_types {SOLAR, WIND, HYDRO, NUCLEAR, GAS, COAL, INDUSTRIAL, COMMERCIAL, RESIDENTIAL}

var id: int
var type: int
var pos: Vector2


func _ready() -> void:
	self.global_position = pos

extends Node2D

@export var grid_line_color: Color = Color(0.2, 0.2, 0.2, 0.25)
var line_space: int = 32

@onready var algorithm_manager: AlgorithmManager = $AlgorithmManager
@onready var building_manager: BuildingManager = $BuildingManager
@onready var game_coordinator: GameCoordinator = $GameCoordinator
@onready var ui: UI = $CanvasLayer/UI

func _ready() -> void:
	algorithm_manager.building_manager_ref = building_manager
	algorithm_manager.game_coordinator_ref = game_coordinator
	
	building_manager.algorithm_manager_ref = algorithm_manager
	building_manager.ui_ref = ui
	
	game_coordinator.algorithm_manager_ref = algorithm_manager
	game_coordinator.ui_ref = ui
	
	ui.algorithm_manager_ref = algorithm_manager
	ui.building_manager_ref = building_manager


func _draw():
	var size = Vector2(1920, 1080)
	for i in range(1+int(size.x/line_space)):
		draw_line(Vector2(i * line_space, -100), Vector2(i * line_space, size.y + 100), grid_line_color)
	for i in range(1+int(size.y/line_space)):
		draw_line(Vector2(-100, i * line_space), Vector2(size.x + 100, i * line_space), grid_line_color)


func _process(delta):
	queue_redraw()

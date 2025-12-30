extends Control

@onready var preview_sprite: Sprite2D = $PreviewSprite
@onready var preview_line: Line2D = $PreviewLine


func _ready() -> void:
	BuildingManager.UI = self
	preview_sprite.hide()
	preview_line.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		BuildingManager.left_click(get_global_mouse_position())
	elif event.is_action_pressed("right_click"):
		BuildingManager.right_click()
		


#region Button pressed signals
func _on_button_simulate_pressed() -> void:
	AlgorithmManager.update_grid()

func _on_button_solar_pressed() -> void:
	var type: int = AlgorithmManager.SOLAR
	BuildingManager.button_pressed(type)
	preview_sprite.frame = type

func _on_button_wind_pressed() -> void:
	var type: int = AlgorithmManager.WIND
	BuildingManager.button_pressed(type)
	preview_sprite.frame = type

func _on_button_hydro_pressed() -> void:
	var type: int = AlgorithmManager.HYDRO
	BuildingManager.button_pressed(type)
	preview_sprite.frame = type

func _on_button_thermal_pressed() -> void:
	var type: int = AlgorithmManager.THERMAL
	BuildingManager.button_pressed(type)
	preview_sprite.frame = type

func _on_button_industrial_pressed() -> void:
	var type: int = AlgorithmManager.INDUSTRIAL
	BuildingManager.button_pressed(type)
	preview_sprite.frame = type

func _on_button_residential_pressed() -> void:
	var type: int = AlgorithmManager.RESIDENTIAL
	BuildingManager.button_pressed(type)
	preview_sprite.frame = type
#endregion

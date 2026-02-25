class_name UI
extends Control

var months: Array[String] = ["January", "February", "March",
							"April", "May", "June", "Jule",
							"August", "September", "October",
							"November", "December"]

var building_manager_ref: BuildingManager
var algorithm_manager_ref: AlgorithmManager

@onready var preview_sprite: Sprite2D = $PreviewSprite
@onready var preview_line: Line2D = $PreviewLine
@onready var calendar: Label = $HBoxContainer2/HBoxContainer/Calendar
@onready var clock: Label = $HBoxContainer2/Clock

func _ready() -> void:
	preview_sprite.hide()
	preview_line.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		building_manager_ref.left_click(get_global_mouse_position())
	elif event.is_action_pressed("right_click"):
		building_manager_ref.right_click()


func update_time_weather(weather_state: WeatherState) -> void:
	calendar.text = str(weather_state.day) + " " + months[weather_state.month-1] + str(weather_state.year)
	clock.text = str(weather_state.hour) + ":00"


#region Button pressed signals
func _on_button_simulate_pressed() -> void:
	algorithm_manager_ref.update_grid()

func _on_button_solar_pressed() -> void:
	var type: int = AlgorithmManager.SOLAR
	building_manager_ref.button_pressed(type)
	preview_sprite.frame = type

func _on_button_wind_pressed() -> void:
	var type: int = AlgorithmManager.WIND
	building_manager_ref.button_pressed(type)
	preview_sprite.frame = type

func _on_button_hydro_pressed() -> void:
	var type: int = AlgorithmManager.HYDRO
	building_manager_ref.button_pressed(type)
	preview_sprite.frame = type

func _on_button_thermal_pressed() -> void:
	var type: int = AlgorithmManager.THERMAL
	building_manager_ref.button_pressed(type)
	preview_sprite.frame = type

func _on_button_industrial_pressed() -> void:
	var type: int = AlgorithmManager.INDUSTRIAL
	building_manager_ref.button_pressed(type)
	preview_sprite.frame = type

func _on_button_residential_pressed() -> void:
	var type: int = AlgorithmManager.RESIDENTIAL
	building_manager_ref.button_pressed(type)
	preview_sprite.frame = type
#endregion

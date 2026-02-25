class_name GameCoordinator
extends Node2D

const appearance_chance: float = 0.15

var weather_state: WeatherState = WeatherState.new()

var ui_ref: Control
var algorithm_manager_ref: AlgorithmManager

var trys_count: int = 0
var trys_max: int = 15

@onready var hour_timer: Timer = Timer.new()


func _ready() -> void:
	hour_timer.autostart = true
	hour_timer.wait_time = 1.0
	hour_timer.one_shot = false
	hour_timer.connect("timeout", _on_timer_timeout)
	add_child(hour_timer)


func _on_timer_timeout() -> void:
	weather_state.hour += 1
	if weather_state.hour > 23:
		weather_state.hour = 0
		weather_state.day += 1
		if weather_state.day > 30:
			weather_state.day = 1
			weather_state.month += 1
			if weather_state.month > 12:
				weather_state.month = 0
				weather_state.year += 1
	
	print("New hour started: ", weather_state.hour)
	algorithm_manager_ref.update_grid()
	ui_ref.update_time_weather(weather_state)
	
	if randf() <= appearance_chance:
		spawn_consumer()


func spawn_consumer() -> void:
	if trys_count >= trys_max:
		return
	
	var pos: Vector2i = snapped(Vector2i(randi_range(100,1820), randi_range(100,980)), BuildingManager.blg_grid_size)
	var type = [AlgorithmManager.RESIDENTIAL, AlgorithmManager.INDUSTRIAL].pick_random()
	var id: int = algorithm_manager_ref.add_node(pos, type, "name", 1.0)
	
	# Si recibimos un -1, es que la posición está ocupada, volvemos a intentarlo
	# Limitamos el número de intentos para evitar crashear si no quedan huecos libres.
	if id == -1:
		spawn_consumer()
		trys_count += 1
	else:
		trys_count = 0

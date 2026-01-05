extends Node2D

const appearance_chance: float = 0.15

var hour: int = 0
var day: int = 1
var month: int = 1
var year: int = 2000

var UI: UI

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
	hour += 1
	if hour > 23:
		hour = 0
		day += 1
		if day > 30:
			day = 1
			month += 1
			if month > 12:
				month = 0
				year += 1
	
	print("New hour started: ", hour)
	AlgorithmManager.update_grid()
	UI.update_time_weather(hour, day, month, year, 1000, 15.6)
	
	if randf() <= appearance_chance:
		spawn_consumer()


func spawn_consumer() -> void:
	if trys_count >= trys_max:
		return
	
	var pos: Vector2i = snapped(Vector2i(randi_range(200,1720), randi_range(200,880)), BuildingManager.building_grid_size)
	var type = [AlgorithmManager.RESIDENTIAL, AlgorithmManager.INDUSTRIAL].pick_random()
	var id: int = AlgorithmManager.add_node(pos, type, "name", 1.0)
	
	# Si recibimos un -1, es que la posición está ocupada, volvemos a intentarlo
	# Limitamos el número de intentos para evitar crashear si no quedan huecos libres.
	if id == -1:
		spawn_consumer()
		trys_count += 1
	else:
		trys_count = 0

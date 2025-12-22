extends Node2D

enum phases {MORNING, MIDDAY, AFTERNOON, NIGHT}

var current_phase: int = 0

@onready var phase_timer: Timer = $PhaseTimer


func _on_phase_timer_timeout() -> void:
	if current_phase == phases.NIGHT:
		current_phase = 0
	else:
		current_phase += 1
	print("New phase started: ", phases.find_key(current_phase))
	#AlgorithmManager.update_grid()

class_name NodeGUIv3
extends GridContainer

const COLOR_ACTIVE = Color.GREEN
const COLOR_INACTIVE = Color.POWDER_BLUE
const COLOR_DISABLED = Color.DARK_GRAY
const COLOR_INSATISFIED_INACTIVE = Color.PALE_VIOLET_RED
const COLOR_INSATISFIED = Color.RED

var node_width: int = 128
var color_rect: ColorRect
var rect_min_size: Vector2 = Vector2(16, 16) # Tamaño fijo de cada celda
var rects: Array[ColorRect] = []

func _ready() -> void:
	color_rect = ColorRect.new()
	#color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#color_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	color_rect.custom_minimum_size = rect_min_size

func setup(base_cap: int) -> void:
	# Limpiar hijos previos si reutilizas el nodo
	for child in get_children():
		child.queue_free()
	rects.clear()
	columns = min(base_cap, columns)
	add_rects(base_cap)

func add_rects(num: int) -> void:
	for r in range(num):
		var new_rect: ColorRect = color_rect.duplicate()
		add_child(new_rect)
		rects.append(new_rect)

func update_generation(val: int, max: int, disp: float) -> void:
	for i in range(rects.size()):
		if i < val:
			rects[i].color = COLOR_ACTIVE
		elif i >= disp * max:
			rects[i].color = COLOR_DISABLED
		else:
			rects[i].color = COLOR_INACTIVE

func update_consumption(val: int, max: int, disp: float) -> void:
	var demand_insatisfied: bool = val < max * disp
	for i in range(rects.size()):
		if i < val:
			if demand_insatisfied:
				rects[i].color = COLOR_INSATISFIED
			else:
				rects[i].color = COLOR_ACTIVE
		elif i >= disp * max:
			rects[i].color = COLOR_DISABLED
		else:
			if demand_insatisfied:
				rects[i].color = COLOR_INSATISFIED_INACTIVE
			else:
				rects[i].color = COLOR_INACTIVE

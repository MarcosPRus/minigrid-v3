extends Control

var format_string: String = "%.2f / %.2f"

var tween_val: Tween
var tween_max: Tween


func _ready() -> void:
	var parent = get_parent()
	
	$Sprite2D.frame = parent.type
	
	if parent.is_generator:
		modulate = Color.DARK_TURQUOISE
		#var style_box := StyleBoxFlat.new()
		#style_box.bg_color = Color.TEAL
		#$ProgressBar.add_theme_stylebox_override("fill", style_box)
	if parent.is_consumer:
		modulate = Color.HOT_PINK
		#var style_box := StyleBoxFlat.new()
		#style_box.bg_color = Color.WEB_MAROON
		#$ProgressBar.add_theme_stylebox_override("fill", style_box)


func update_progress_bar(node_state: NodeState) -> void:
	var val = node_state.generation + node_state.consumption
	var max = node_state.base_cap
	$Label.text = format_string % [val, max]

	if tween_val:
		tween_val.kill()
	if tween_max:
		tween_max.kill()
	
	tween_val = create_tween()
	tween_max = create_tween()
	tween_val.tween_property($ProgressBar, "value", val, 1.0).set_trans(Tween.TRANS_LINEAR)
	tween_max.tween_property($ProgressBar, "max_value", max, 1.0).set_trans(Tween.TRANS_LINEAR)

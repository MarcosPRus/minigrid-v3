extends Control

var format_string: String = "%.2f / %.2f"

var tween_val: Tween
var tween_max: Tween


func _ready() -> void:
	var parent = get_parent()
	if parent.is_generator:
		var style_box := StyleBoxFlat.new()
		style_box.bg_color = Color.TEAL
		$ProgressBar.add_theme_stylebox_override("fill", style_box)
	if parent.is_consumer:
		var style_box := StyleBoxFlat.new()
		style_box.bg_color = Color.WEB_MAROON
		$ProgressBar.add_theme_stylebox_override("fill", style_box)


func update_progress_bar(val: float, max: float) -> void:
	$Label.text = format_string % [val, max]

	if tween_val:
		tween_val.kill()
	if tween_max:
		tween_max.kill()
	
	tween_val = create_tween()
	tween_max = create_tween()
	tween_val.tween_property($ProgressBar, "value", val, 1.0).set_trans(Tween.TRANS_LINEAR)
	tween_max.tween_property($ProgressBar, "max_value", max, 1.0).set_trans(Tween.TRANS_LINEAR)

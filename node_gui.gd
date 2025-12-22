extends Control

var format_string: String = "%.2f / %.2f"


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
	$ProgressBar.max_value = max
	$ProgressBar.value = val

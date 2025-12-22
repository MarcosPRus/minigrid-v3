extends Control

## REFERENCIA:
# var format_string: String = "%.2f / %.2f"
# state_label.text = format_string % [gen, cap]

func _ready() -> void:
	var parent = get_parent()
	if parent.is_generator:
		var style_box := StyleBoxFlat.new()
		style_box.bg_color = Color.GREEN_YELLOW
		$ProgressBar.add_theme_stylebox_override("fill", style_box)
	if parent.is_consumer:
		var style_box := StyleBoxFlat.new()
		style_box.bg_color = Color.HOT_PINK
		$ProgressBar.add_theme_stylebox_override("fill", style_box)

func update_progress_bar(val: float, max: float) -> void:
	$ProgressBar.value = val
	$ProgressBar.max_value = max

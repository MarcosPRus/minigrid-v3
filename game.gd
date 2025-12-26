extends Node2D


func _ready() -> void:
	AlgorithmManager.NodesContainer = $NodesContainer
	AlgorithmManager.LinesContainer = $LinesContainer

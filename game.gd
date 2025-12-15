extends Node2D


func _ready() -> void:
	AlgorithmManager.NodesContainer = $GameCoordinator/NodesContainer
	AlgorithmManager.LinesContainer = $GameCoordinator/LinesContainer

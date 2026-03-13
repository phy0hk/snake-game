extends Node2D

signal up
signal down
signal left
signal right

func _on_up_pressed() -> void:
	up.emit()

func _on_down_pressed() -> void:
	down.emit()


func _on_left_pressed() -> void:
	left.emit()


func _on_right_pressed() -> void:
	right.emit()

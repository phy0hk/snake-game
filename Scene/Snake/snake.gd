extends Line2D

signal eat_apple
signal body_hit
signal hit_boundary

func _on_snake_head_area_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if(area.name=="Apple"):
		eat_apple.emit()
	elif(area.name=="Wall"):
		hit_boundary.emit()


func _on_body_area_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if(area.name=="SnakeHeadArea"):
		hit_boundary.emit()
	else:
		body_hit.emit()

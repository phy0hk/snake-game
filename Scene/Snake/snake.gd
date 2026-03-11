extends Area2D

var direction = "RIGHT"
var headPos
var tailPos

func _ready() -> void:
	update_snake_shape()

func update_snake_shape():
	headPos = $WholeBody.get_point_position(len($WholeBody.points)-1)
	$WholeBody/Head.position = headPos
	tailPos = $WholeBody.get_point_position(0)
	$WholeBody/Tail.position = tailPos

func _process(delta: float) -> void:
	update_snake_shape()
	move_head()

func move_head():
	var currentHeadPos = headPos
	var newPos:Vector2 = currentHeadPos
	if direction == "RIGHT":
		newPos.x += 1
	$WholeBody.set_point_position(len($WholeBody.points)-1,newPos)
	

extends Node

@export var direction = "RIGHT"
@export var speed = 100
@export var gap_distance: int = 13
@export var is_game_over = false
@export var game_started = true
var velocity = Vector2.ZERO
var position_history: Array = []
var headPos: Vector2
var body_collisions: Array = []
var points_value = 0

func _ready() -> void:
	# Initialize headPos so it doesn't start at (0,0)
	headPos = $"Snake".get_point_position(0)
	$Dialog.hide()
	# Fill history initially so the tail doesn't jump to (0,0) on start
	for i in range($"Snake".points.size() * gap_distance):
		position_history.push_back(headPos)

func _process(delta: float) -> void:
	if !is_game_over && game_started:
		get_input()
		move_head(delta)
		update_body_positions()
		update_sprites() 

func get_input():
	if Input.is_action_pressed("UP") && direction != "DOWN": direction="UP"
	elif Input.is_action_pressed("DOWN") && direction != "UP": direction="DOWN"
	elif Input.is_action_pressed("LEFT")  && direction != "RIGHT": direction="LEFT"
	elif Input.is_action_pressed("RIGHT") && direction != "LEFT": direction="RIGHT"

func move_head(delta: float):
	velocity = Vector2.ZERO
	if direction == "RIGHT" : velocity.x = 1
	elif direction == "LEFT": velocity.x = -1
	elif direction == "UP" : velocity.y = -1
	elif direction == "DOWN": velocity.y = 1
	
	# Update the actual coordinate
	headPos += velocity * speed * delta
	$"Snake".set_point_position(0, headPos)
	
	# Record history
	position_history.push_front(headPos)
	if position_history.size() > $"Snake".points.size() * gap_distance:
		position_history.pop_back()

func update_body_positions():
	for i in range(1, $"Snake".points.size()):
		var history_index = i * gap_distance
		if history_index < position_history.size():
			$"Snake".set_point_position(i, position_history[history_index])
			if body_collisions.size() >= i:
				body_collisions[i-1].position = position_history[history_index]
			if i - 1 < body_collisions.size():
				var body_node = body_collisions[i-1]
				if is_instance_valid(body_node) and body_node.is_inside_tree():
					body_node.position = position_history[history_index]

func update_sprites():
	$Snake/SnakeHeadArea.position = $"Snake".get_point_position(0)
	if direction == "RIGHT": 
		$Snake/SnakeHeadArea.rotation = deg_to_rad(0)
	elif direction == "LEFT": 
		$Snake/SnakeHeadArea.rotation = deg_to_rad(180)
	elif direction == "UP": 
		$Snake/SnakeHeadArea.rotation = deg_to_rad(-90)
	elif direction == "DOWN": 
		$Snake/SnakeHeadArea.rotation = deg_to_rad(90)

func restart():
	$Dialog.hide()
	is_game_over = false
	game_started = true
	direction = "RIGHT"
	$Snake.points = PackedVector2Array([Vector2(24, 0), Vector2(-60, 0)])
	headPos = $Snake.get_point_position(0) 
	position_history.clear()
	for i in range($Snake.points.size() * gap_distance):
		position_history.push_back(headPos)
	for child in $Snake/BodyArea.get_children():
		child.queue_free()
	body_collisions.clear()
	$Snake/SnakeHeadArea.position = headPos

func game_over():
	$Dialog.show()
	velocity = Vector2.ZERO
	is_game_over = true
	game_started = false

func point_up():
	var new_body_position = $"Snake".get_point_position($"Snake".points.size()-1)
	$"Snake".add_point(new_body_position)
	var newCollisionShape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 5
	newCollisionShape.shape = shape
	newCollisionShape.position = new_body_position
	$Snake/BodyArea.add_child(newCollisionShape)
	body_collisions.append(newCollisionShape)


func _on_wall_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.name == "SnakeHeadArea":
		game_over()


func _on_apple_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.name == "SnakeHeadArea":
		call_deferred("point_up")


func _on_snake_hit_boundary() -> void:
	game_over()


func _on_restart_pressed() -> void:
	restart()


func _on_exit_pressed() -> void:
	get_tree().quit(0)


func _on_dpad_down() -> void:
	if direction != "UP":
		direction = "DOWN"


func _on_dpad_left() -> void:
	if direction != "RIGHT":
		direction = "LEFT"


func _on_dpad_right() -> void:
	if direction != "LEFT":
		direction = "RIGHT"

func _on_dpad_up() -> void:
	if direction != "DOWN":
		direction = "UP"

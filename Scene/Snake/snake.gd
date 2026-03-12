extends Line2D

@export var direction = "RIGHT"
@export var speed = 100
@export var gap_distance: int = 13
var velocity = Vector2.ZERO
var wall_hit = false
var position_history: Array = []
var headPos: Vector2
var body_collisions: Array = []
signal eat_apple
signal body_hit

func _ready() -> void:
	# Initialize headPos so it doesn't start at (0,0)
	headPos = get_point_position(0)
	# Fill history initially so the tail doesn't jump to (0,0) on start
	for i in range(points.size() * gap_distance):
		position_history.push_back(headPos)

func _process(delta: float) -> void:
	if !wall_hit:
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
	set_point_position(0, headPos)
	
	# Record history
	position_history.push_front(headPos)
	if position_history.size() > points.size() * gap_distance:
		position_history.pop_back()

func update_body_positions():
	for i in range(1, points.size()):
		var history_index = i * gap_distance
		if history_index < position_history.size():
			set_point_position(i, position_history[history_index])
			if body_collisions.size() >= i:
				body_collisions[i-1].position = position_history[history_index]

func update_sprites():
	$SnakeHeadArea.position = get_point_position(0)
	if direction == "RIGHT": 
		$SnakeHeadArea.rotation = deg_to_rad(0)
	elif direction == "LEFT": 
		$SnakeHeadArea.rotation = deg_to_rad(180)
	elif direction == "UP": 
		$SnakeHeadArea.rotation = deg_to_rad(-90)
	elif direction == "DOWN": 
		$SnakeHeadArea.rotation = deg_to_rad(90)

func game_over():
	wall_hit = true
	velocity = Vector2.ZERO

func point_up():
	var new_body_position = get_point_position(points.size()-1)
	add_point(new_body_position)
	var newCollisionShape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 5
	newCollisionShape.shape = shape
	newCollisionShape.position = new_body_position
	$BodyArea.add_child(newCollisionShape)
	body_collisions.append(newCollisionShape)


func _on_wall_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "SnakeHeadArea":
		game_over()


func _on_apple_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	point_up()

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "Apple":
		eat_apple.emit()


func _on_body_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if(area.name=="SnakeHeadArea"):
		game_over()
	else:
		body_hit.emit()

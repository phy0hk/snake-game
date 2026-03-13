extends Area2D

@export var rows = 13
@export var cols = 21
var sprite:Sprite2D
var apple:CollisionShape2D

func _ready():
	sprite = $AppleSprite
	apple = $CollisionShape2D
	generate_apple()

func generate_apple():
	var x = randi_range(0,cols)
	var y = randi_range(0,rows)
	apple.position = Vector2(144+(32*x),144+(32*y))
	sprite.position = apple.position
	print(apple.position)
	print(x,"And",y)


func _on_snake_eat_apple() -> void:
	generate_apple()


func _on_snake_body_hit() -> void:
	generate_apple()

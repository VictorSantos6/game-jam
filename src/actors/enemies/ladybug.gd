extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

const SPEED = 60

var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_right.is_colliding() or ray_cast_left.is_colliding():
		direction = -direction
		sprite.flip_h = direction == -1
	
	position.x += direction * SPEED * delta

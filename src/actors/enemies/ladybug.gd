extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var killzone: Area2D = $AnimatedSprite2D/Killzone

const SPEED := 60.0
const GRAVITY := 900.0
const FLOOR_CHECK_AHEAD := 9.0
const FLOOR_CHECK_DEPTH := 14.0

var direction := 1

func _ready() -> void:
	# Ignore hurtbox so floor checks only hit world geometry.
	ray_cast_right.add_exception(killzone)
	ray_cast_left.add_exception(killzone)

	ray_cast_right.collide_with_areas = false
	ray_cast_left.collide_with_areas = false
	ray_cast_right.collide_with_bodies = true
	ray_cast_left.collide_with_bodies = true
	ray_cast_right.enabled = true
	ray_cast_left.enabled = true

	# Probe floor in front of the enemy to turn at platform edges.
	ray_cast_right.target_position = Vector2(FLOOR_CHECK_AHEAD, FLOOR_CHECK_DEPTH)
	ray_cast_left.target_position = Vector2(-FLOOR_CHECK_AHEAD, FLOOR_CHECK_DEPTH)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	if is_on_floor():
		var front_ray := ray_cast_right if direction > 0 else ray_cast_left
		if not front_ray.is_colliding():
			direction = -direction

	velocity.x = direction * SPEED
	move_and_slide()
	sprite.flip_h = direction < 0

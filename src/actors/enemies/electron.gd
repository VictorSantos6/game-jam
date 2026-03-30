extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var killzone: Area2D = $AnimatedSprite2D/Killzone

const SPEED := 45.0
const PROBE_DISTANCE := 4.0
const TURN_COOLDOWN := 0.08

var direction := 1
var turn_cooldown_timer := 0.0

func _ready() -> void:
	# Ignore this enemy's own hurtbox so rays only detect world obstacles.
	ray_cast_right.add_exception(killzone)
	ray_cast_left.add_exception(killzone)

	# Align probe origin with the visible enemy so turn timing matches contact.
	ray_cast_right.position = sprite.position
	ray_cast_left.position = sprite.position

	# Probe only a very short distance ahead and ignore Area2D triggers.
	ray_cast_right.target_position = Vector2(PROBE_DISTANCE, 0.0)
	ray_cast_left.target_position = Vector2(-PROBE_DISTANCE, 0.0)
	ray_cast_right.collide_with_areas = false
	ray_cast_left.collide_with_areas = false
	ray_cast_right.collide_with_bodies = true
	ray_cast_left.collide_with_bodies = true

func _physics_process(delta: float) -> void:
	# Electron never falls
	velocity.y = 0.0
	velocity.x = 0.0
	move_and_slide()
